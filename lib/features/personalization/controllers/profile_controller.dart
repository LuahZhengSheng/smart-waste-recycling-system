import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/constants/image_strings.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../authentication/models/user_model.dart';
import '../../authentication/screens/login/login.dart';
import '../screens/profile/edit_profile/edit_profile.dart';
import '../screens/profile/widgets/re_authenticate_user_login_form.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final imageUploading = false.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  final dateOfBirth = TextEditingController();
  final gender = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  // User data observable
  final Rx<UserModel> user = UserModel.empty().obs;

  final authRepository = Get.put(AuthenticationRepository());

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  /// Fetch user record
  Future<void> fetchUserRecord() async {
    try {
      // TODO: Implement actual user fetching from your data source
      // For now, using mock data
      user(UserModel(
        userId: '123',
        username: 'john_doe',
        email: 'john@example.com',
        phoneNo: '+1234567890',
        profileImage: 'https://via.placeholder.com/150',
        loginAttemptCount: 0,
        role: 'user',
        isVerified: true,
        isActive: true,
        joinDate: DateTime.now().subtract(const Duration(days: 365)),
        rewardPoint: 1250,
        gender: 'Male',
        dob: DateTime(1990, 5, 15),
      ));

      // Populate text controllers
      firstName.text = user.value.username.split(' ').first;
      lastName.text = user.value.username.split(' ').length > 1
          ? user.value.username.split(' ').last : '';
      username.text = user.value.username;
      email.text = user.value.email;
      phoneNumber.text = user.value.phoneNo ?? '';
      gender.text = user.value.gender ?? '';
      if (user.value.dob != null) {
        dateOfBirth.text = '${user.value.dob!.day}/${user.value.dob!.month}/${user.value.dob!.year}';
      }
    } catch (e) {
      user(UserModel.empty());
      FLoaders.warningSnackBar(title: 'Data not found', message: e.toString());
    }
  }

  /// Save user record from any registration provider
  Future<void> saveUserRecord(UserCredential? userCredential) async {
    try {
      // Refresh User Record
      await fetchUserRecord();

      // If no record already stored
      if (user.value.userId.isEmpty) {
        if (userCredential != null) {
          // Map Data
          final user = UserModel(
            userId: userCredential.user!.uid,
            username: userCredential.user!.displayName ?? '',
            email: userCredential.user!.email ?? '',
            phoneNo: userCredential.user!.phoneNumber ?? '',
            profileImage: userCredential.user!.photoURL ?? '',
            loginAttemptCount: 0,
            role: 'user',
            isVerified: userCredential.user!.emailVerified,
            isActive: true,
            joinDate: DateTime.now(),
          );

          // Save user data
          // TODO: Implement actual saving to your data source
          await saveUserData(user);
        }
      }
    } catch (e) {
      FLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  /// Save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      // TODO: Implement actual saving to your data source
      // For now, just update the local observable
      this.user(user);
      FLoaders.successSnackBar(title: 'Success', message: 'Your data has been saved successfully.');
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Data not saved', message: 'Something went wrong while saving your information.');
    }
  }

  /// Delete account warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
        child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Delete')),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ),
    );
  }

  /// Delete User Account
  void deleteUserAccount() async {
    try {
      FFullScreenLoader.openLoadingDialog('Processing', FImages.docerAnimation);

      /// First re-authenticate user
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;
      if (provider.isNotEmpty) {
        // Re Verify Auth Email
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          FFullScreenLoader.stopLoading();
          Get.offAll(() => const LoginScreen());
        } else if (provider == 'password') {
          FFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthLoginForm());
        }
      }
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// -- RE-AUTHENTICATE before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      FFullScreenLoader.openLoadingDialog('Processing', FImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        FFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());
      await AuthenticationRepository.instance.deleteAccount();
      FFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Upload Profile Image
  Future<void> uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image != null) {
        // Check file size (5MB = 5 * 1024 * 1024 bytes)
        final file = File(image.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          FLoaders.errorSnackBar(
            title: 'Image too large',
            message: 'Please select an image smaller than 5MB.',
          );
          return;
        }

        imageUploading.value = true;

        // TODO: Upload image to your storage service and get URL
        final imageUrl = await uploadImage('Users/Images/Profile/', image);

        // Update user's profile picture
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await updateSingleField(json);

        user.value.profileImage = imageUrl;
        user.refresh();

        FLoaders.successSnackBar(title: 'Congratulations', message: 'Your profile image has been updated!');
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Oh Snap!', message: 'Something went wrong: $e');
    } finally {
      imageUploading.value = false;
    }
  }

  /// Upload Profile Image from Camera
  Future<void> uploadUserProfilePictureFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image != null) {
        // Check file size (5MB = 5 * 1024 * 1024 bytes)
        final file = File(image.path);
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          FLoaders.errorSnackBar(
            title: 'Image too large',
            message: 'Please select an image smaller than 5MB.',
          );
          return;
        }

        imageUploading.value = true;

        // TODO: Upload image to your storage service and get URL
        final imageUrl = await uploadImage('Users/Images/Profile/', image);

        // Update user's profile picture
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await updateSingleField(json);

        user.value.profileImage = imageUrl;
        user.refresh();

        FLoaders.successSnackBar(title: 'Congratulations', message: 'Your profile image has been updated!');
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Oh Snap!', message: 'Something went wrong: $e');
    } finally {
      imageUploading.value = false;
    }
  }

  /// Show Image Source Selection
  void showImageSourceSelection() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    uploadUserProfilePictureFromCamera();
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.blue, size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    uploadUserProfilePicture();
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_library, color: Colors.green, size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Placeholder methods - implement according to your needs
  Future<String> uploadImage(String path, XFile image) async {
    // TODO: Implement actual image upload
    return 'https://via.placeholder.com/150';
  }

  Future<void> updateSingleField(Map<String, dynamic> json) async {
    // TODO: Implement actual field update
  }

  void navigateToEditProfile() {
    Get.to(() => const EditProfileScreen());
  }

  void logout() {
    authRepository.logout();
  }
}