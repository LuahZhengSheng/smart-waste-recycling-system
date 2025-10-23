import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';

import '../../authentication/models/user_model.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  static EditProfileController get instance => Get.find();

  final username = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final gender = TextEditingController();
  final dateOfBirth = TextEditingController();

  final profileController = ProfileController.instance;
  final updateUserFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  DateTime? selectedDate;

  @override
  void onInit() {
    super.onInit();
    initializeFields();
  }

  /// Initialize text fields with current user data
  void initializeFields() {
    final user = profileController.user.value;

    username.text = user.username;
    email.text = user.email;
    phoneNumber.text = user.phoneNo ?? '';
    gender.text = user.gender ?? '';

    if (user.dob != null) {
      selectedDate = user.dob;
      dateOfBirth.text = _formatDate(user.dob!);
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Show date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF4BAF6F), // FColors.primary
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      dateOfBirth.text = _formatDate(picked);
    }
  }

  /// Validate and update user profile
  Future<void> updateUserProfile() async {
    try {
      // Start Loading
      isLoading.value = true;

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        isLoading.value = false;
        FLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection',
        );
        return;
      }

      // Form Validation
      if (!updateUserFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }

      // Show Loading Dialog
      FFullScreenLoader.openLoadingDialog(
        'Updating your profile...',
        FImages.docerAnimation,
      );

      // Update user data
      final updatedUser = profileController.user.value.copyWith(
        username: username.text.trim(),
        phoneNo: phoneNumber.text.trim().isEmpty ? null : phoneNumber.text.trim(),
        gender: gender.text.trim().isEmpty ? null : gender.text.trim(),
        dob: selectedDate,
      );

      // Save to database/storage
      await updateUserInDatabase(updatedUser);

      // Update local user data
      profileController.user.value = updatedUser;

      // Stop Loading
      FFullScreenLoader.stopLoading();
      isLoading.value = false;

      // Show Success Message
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Your profile has been updated successfully',
      );

      // Navigate back
      Get.back();
    } catch (e) {
      // Stop Loading
      FFullScreenLoader.stopLoading();
      isLoading.value = false;

      // Show Error Message
      FLoaders.errorSnackBar(
        title: 'Update Failed',
        message: e.toString(),
      );
    }
  }

  /// Update user data in database
  Future<void> updateUserInDatabase(UserModel user) async {
    try {
      // TODO: Implement actual database update
      // Example: await UserRepository.instance.updateUser(user);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // For now, just simulate success
      // In production, you would update Firestore/your database here
    } catch (e) {
      throw 'Failed to update user data: $e';
    }
  }

  /// Reset form to initial values
  void resetForm() {
    initializeFields();
  }

  @override
  void onClose() {
    username.dispose();
    email.dispose();
    phoneNumber.dispose();
    gender.dispose();
    dateOfBirth.dispose();
    super.onClose();
  }
}