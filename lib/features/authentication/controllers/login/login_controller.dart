import 'package:flutter/cupertino.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/personalization/controllers/user_controller.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs; // Observable for hiding/showing password
  final localStorage = GetStorage();
  final email = TextEditingController(); // Controller for email input
  final password = TextEditingController(); // Controller for password input
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();  // Form key for form validation
  final userController = Get.put(UserController());

  @override
  void onInit() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? ''; // 默认空字符串
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? ''; // 默认空字符串
    super.onInit();
  }

  /// -- Email and Password SignIn
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      MyFullScreenLoader.openLoadingDialog('Logging you in...', MyImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Save data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      // Login user using Email & Password Authentication
      final userCredentials = await AuthenticationRepository.instance.loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Remove Loader
      MyFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      // Show some Generic Error to the user
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// -- Google SignIn Authentication
  Future<void> googleSignIn() async {
    try {
      // Start Loading
      MyFullScreenLoader.openLoadingDialog('Logging you in...', MyImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Google Authentication
      final userCredentials = await AuthenticationRepository.instance.signInWithGoogle();

      final user = userCredentials!.user!;
      final providerData = user.providerData;

      // 检查用户的登录方式
      bool hasEmailProvider = providerData.any((element) => element.providerId == 'password');

      // 如果是通过 email/password 注册的用户，不更新其用户数据
      if (!hasEmailProvider) {
        // 只有完全新的用户才保存 Google 信息
        await userController.saveUserRecord(userCredentials);
      }

      // Redirect
      AuthenticationRepository.instance.screenRedirect();

    } catch (e) {
      // Remove Loader
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// -- Facebook SignIn Authentication
  Future<void> facebookSignIn() async {
    try {
      // Start Loading
      MyFullScreenLoader.openLoadingDialog('Logging you in...', MyImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Facebook Authentication
      final userCredentials = await AuthenticationRepository.instance.signInWithFacebook();

      final user = userCredentials!.user!;
      final providerData = user.providerData;

      // Check if user has already signed up with email/password
      bool hasEmailProvider = providerData.any((element) => element.providerId == 'password');

      // If the user registered with email/password, do not update their data
      if (!hasEmailProvider) {
        // Only save Facebook login data for completely new users
        await userController.saveUserRecord(userCredentials);
      }

      // Redirect after login
      AuthenticationRepository.instance.screenRedirect();

    } catch (e) {
      // Stop Loading & Show Error
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

}