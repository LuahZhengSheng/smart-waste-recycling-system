import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/screens/admin/login/login.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/features/authentication/screens/onboarding/onboarding.dart';
import 'package:fyp/features/authentication/screens/signup/verify_email.dart';
import 'package:fyp/navigation_menu.dart';
import 'package:fyp/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/admin/screens/admin_layout.dart';
import '../../../features/recycling_center/screens/home/home.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;

  final String _usersCollection = "users";

  /// Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  /// Called from main.dart on app launch
  @override
  void onReady() {
    // Remove the native splash screen
    FlutterNativeSplash.remove();
    // Redirect to the appropriate screen
    screenRedirect();
  }

  /// Function to Show Relevant Screen
  Future<void> screenRedirect() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      // ✅ 已登录
      if (user.emailVerified) {
        // 获取用户角色（假设角色信息存储在Firestore中）
        // final userDoc = await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(user.uid)
        //     .get();

        // final String role = userDoc.data()?['role'] ?? 'user'; // 默认角色为 'user'
        final String role = "admin"; // 默认角色为 'user'

        print(role);

        if (kIsWeb) {
          // 👉 Web 用 Sidebar（可根据角色调整）
          Get.offAll(() => UserManagementPage());
        } else {
          // 👉 App 用 Navigation Menu，根据角色重定向到不同页面
          switch (role) {
            case 'user':
              Get.offAll(() => const NavigationMenu());
              break;
            case 'center_staff':
              Get.offAll(() => const StaffHomeScreen());
              break;
            default: // 普通用户
              Get.offAll(() => const NavigationMenu());
          }
        }
      } else {
        // 账号存在但还没验证邮箱
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
    } else {
      // ✅ 未登录
      if (kIsWeb) {
        // 👉 Web 直接去 AdminLogin
        Get.offAll(() => const AdminLoginScreen());
      } else {
        // 👉 App
        deviceStorage.writeIfNull('IsFirstTime', true);
        final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;

        if (isFirstTime) {
          // 第一次使用 → OnBoarding
          Get.offAll(() => const OnBoardingScreen());
        } else {
          // 非第一次 → Login
          Get.offAll(() => const LoginScreen());
        }
      }
    }
  }

  // /// Function to Show Relevant Screen
  // Future<void> screenRedirect() async {
  //   final User? user = _auth.currentUser;
  //   if (user != null) {
  //     if (user.emailVerified) {
  //       Get.offAll(() => const NavigationMenu());
  //     } else {
  //       Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
  //     }
  //   } else {
  //     // Local Storage
  //     deviceStorage.writeIfNull('IsFirstTime', true);
  //     // Check if it's the first time launching the app
  //     deviceStorage.read('IsFirstTime') != true
  //         ? Get.offAll(() => const LoginScreen()) // Redirect to Login Screen if not the first time
  //         : Get.offAll(const OnBoardingScreen()); // Redirect to OnBoarding Screen if It's the first time
  //   }
  // }

  /// 更新用户 FCM Token
  Future<void> _updateUserFCMToken(String userId) async {
    try {
      // 获取当前设备的 FCM token
      String? fcmToken = await _firebaseMessaging.getToken();

      print('fcmToken: $fcmToken');
      print('userID#: $userId');

      if (fcmToken != null && userId.isNotEmpty) {
        // 更新用户文档中的 FCM token
        await _firestore.collection(_usersCollection).doc(userId).update({
          'fcmToken': fcmToken,
        });

        if (kDebugMode) {
          print('FCM Token updated for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token: $e');
      }
      // 不抛出异常，因为 FCM token 更新失败不应该影响登录流程
    }
  }

/* --------------------------- Email & Password sign-in --------------------------- */

  /// [EmailAuthentication] - Login
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print('Test##');

      // 登录成功后更新 FCM token
      if (userCredential.user != null) {
        print('Test##2');
        await _updateUserFCMToken(userCredential.user!.uid);
        print('Test##3');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Register
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Mail Verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [ReAuthenticate] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword(
      String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential =
      EmailAuthProvider.credential(email: email, password: password);

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [EmailAuthentication] - Forget Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

/* --------------------------- Federated identity & social sign-in --------------------------- */

  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await userAccount?.authentication;

      // Create a new credential
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential? userCredential = await _auth.signInWithCredential(credentials);

      // 登录成功后更新 FCM token
      if (userCredential?.user != null) {
        await _updateUserFCMToken(userCredential!.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

  /// [FacebookAuthentication] - FACEBOOK
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(
          '${loginResult.accessToken?.tokenString}');

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      // 登录成功后更新 FCM token
      if (userCredential.user != null) {
        await _updateUserFCMToken(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

  /// [GoogleAuthentication] - Link Google Account to Existing Firebase User
  Future<UserCredential?> linkGoogleAccount() async {
    try {
      // 获取当前用户
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'No user is currently logged in.';
      }

      // 触发 Google 登录流程
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw 'Google sign-in failed';
      }

      // 获取 Google 登录凭证
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 将 Google 登录凭证链接到当前用户
      final UserCredential userCredential =
      await currentUser.linkWithCredential(googleCredential);

      // 链接成功后更新 FCM token
      await _updateUserFCMToken(currentUser.uid);

      // 返回合并后的用户凭证
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

/* --------------------------- Federated identity & social sign-in --------------------------- */

  /// [LogoutUser] - Valid for any authentication
  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        // Disconnect Google Account to ensure user must choose account again
        await googleSignIn.disconnect();
      }

      // Sign out from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// [DeleteUser] - Remove user Auth and Firestore Account
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw FFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}