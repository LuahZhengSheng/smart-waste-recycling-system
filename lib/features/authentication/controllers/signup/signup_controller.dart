import 'package:flutter/cupertino.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/features/authentication/screens/signup/verify_email.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  /// -- SIGNUP
  void signup() async {
    try {
      // Start Loading
      FFullScreenLoader.openLoadingDialog('We are processing your information...', FImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!signupFormKey.currentState!.validate()) {
        FFullScreenLoader.stopLoading();
        return;
      }

      // Password Confirmation
      if (password.text != confirmPassword.text) {
        FLoaders.warningSnackBar(
          title: 'Passwords Do Not Match',
          message: 'Please make sure your passwords match.',
        );
        FFullScreenLoader.stopLoading();
        return;
      }

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        FLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message: 'In order to create account, you must have to read and accept the Privacy Policy & Terms of Use.',
        );
        FFullScreenLoader.stopLoading();
        return;
      }

      // Register user in the Firebase Authentication & Save user data in the Firebase
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(
          email.text.trim(),
          password.text.trim()
      );

      // Save Authenticated user data in the Firebase Firestore
      final newUser = UserModel(
        userId: userCredential.user!.uid,
        username: username.text.trim(),
        email: email.text.trim(),
        loginAttemptCount: 0,
        role: 'user', // Default role for new users
        isVerified: false,
        isActive: true,
        joinDate: DateTime.now(), // This will be updated with server time in Firestore
        rewardPoint: 0,
        monthlyRewardPoint: 0,
        totalRewardPoint: 0,
        notifications: [],
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      // Show Success Message
      FLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your account has been created! Verify email to continue.'
      );

      FFullScreenLoader.stopLoading();

      // Move to Verify Email Screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      FFullScreenLoader.stopLoading();
      // Show some Generic Error to the user
      FLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}