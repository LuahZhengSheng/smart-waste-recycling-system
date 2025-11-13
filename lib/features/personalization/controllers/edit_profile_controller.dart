import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/constants/image_strings.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../authentication/models/user_model.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  static EditProfileController get instance => Get.find();

  final username = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final dateOfBirth = TextEditingController();

  // 使用 Rx<String?> 来管理下拉菜单的值
  final selectedGender = Rx<String?>(null);

  // 下拉菜单选项
  final List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  final profileController = ProfileController.instance;
  final userRepository = UserRepository.instance;
  final updateUserFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isEditing = false.obs;

  DateTime? selectedDate;

  @override
  void onInit() {
    super.onInit();
    // 监听用户数据变化，实时更新表单
    ever(profileController.user, (UserModel user) {
      if (!isEditing.value) {
        initializeFields();
      }
    });
    initializeFields();
  }

  /// Initialize text fields with current user data
  void initializeFields() {
    final user = profileController.user.value;

    username.text = user.username;
    email.text = user.email;
    phoneNumber.text = user.phoneNo ?? '';

    // 修复：直接设置 selectedGender 的值
    selectedGender.value = user.gender;

    // 修复日期字段
    if (user.dob != null) {
      selectedDate = user.dob;
      dateOfBirth.text = _formatDate(user.dob!);
    } else {
      selectedDate = null;
      dateOfBirth.text = '';
    }

    if (kDebugMode) {
      print('=== EditProfileController Fields Initialized ===');
      print('Username: ${user.username}');
      print('Gender value: "${selectedGender.value}"');
      print('Gender from user model: "${user.gender}"');
      print('Gender options: $genderOptions');
      print('Gender value in options: ${genderOptions.contains(selectedGender.value)}');
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Toggle edit mode
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset fields when canceling edit
      initializeFields();
    }
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
              primary: const Color(0xFF4BAF6F),
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

  /// Validate Malaysian phone number
  String? validateMalaysianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Remove all non-digit characters
    final phoneNumber = value.replaceAll(RegExp(r'\D'), '');

    // Malaysian mobile numbers start with specific prefixes
    final validPrefixes = [
      '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', // Mobile prefixes
    ];

    // Check if it starts with +60 or 60
    if (phoneNumber.startsWith('60')) {
      final withoutCountryCode = phoneNumber.substring(2);

      // Check if it's 9 or 10 digits after country code
      if (withoutCountryCode.length < 9 || withoutCountryCode.length > 10) {
        return 'Invalid Malaysian phone number';
      }

      // Check if it starts with valid prefix
      final prefix = withoutCountryCode.substring(0, 2);
      if (!validPrefixes.contains(prefix)) {
        return 'Invalid Malaysian mobile number';
      }

      return null;
    }

    // Without country code, should be 10-11 digits
    if (phoneNumber.length < 10 || phoneNumber.length > 11) {
      return 'Phone number should be 10-11 digits';
    }

    // Check if it starts with 0
    if (!phoneNumber.startsWith('0')) {
      return 'Phone number should start with 0';
    }

    // Check if it starts with valid prefix (after 0)
    final prefix = phoneNumber.substring(1, 3);
    if (!validPrefixes.contains(prefix)) {
      return 'Invalid Malaysian mobile number';
    }

    return null;
  }

  /// Format Malaysian phone number
  String formatMalaysianPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If it starts with country code
    if (digits.startsWith('60')) {
      final withoutCountryCode = digits.substring(2);
      // Format as: 012-345 6789
      if (withoutCountryCode.length >= 9) {
        return '${withoutCountryCode.substring(0, 3)}-${withoutCountryCode.substring(3, 6)} ${withoutCountryCode.substring(6)}';
      }
    }

    // Format as: 012-345 6789
    if (digits.length >= 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    return phoneNumber;
  }

  /// Validate and update user profile
  Future<void> updateUserProfile() async {
    try {
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

      final currentUser = profileController.user.value;
      final newUsername = username.text.trim();
      final newPhoneNumber = phoneNumber.text.trim();
      final newGender = selectedGender.value;

      // Check if username has changed and is unique
      if (newUsername != currentUser.username) {
        final isUnique = await userRepository.isUsernameUnique(
          newUsername,
          currentUser.userId,
        );

        if (!isUnique) {
          isLoading.value = false;
          FLoaders.errorSnackBar(
            title: 'Username Taken',
            message: 'This username is already in use. Please choose another.',
          );
          return;
        }
      }

      // Check if phone number has changed and is unique
      if (newPhoneNumber.isNotEmpty && newPhoneNumber != currentUser.phoneNo) {
        final isUnique = await userRepository.isPhoneNumberUnique(
          newPhoneNumber,
          currentUser.userId,
        );

        if (!isUnique) {
          isLoading.value = false;
          FLoaders.errorSnackBar(
            title: 'Phone Number Taken',
            message: 'This phone number is already in use.',
          );
          return;
        }
      }

      // 修复：确保 profileImg 只存储文件名，而不是完整 URL
      String? profileImgFileName;
      if (currentUser.profileImg != null && currentUser.profileImg!.isNotEmpty) {
        // 如果已经是文件名（不包含 http），直接使用
        if (!currentUser.profileImg!.startsWith('http')) {
          profileImgFileName = currentUser.profileImg;
        } else {
          // 如果是完整 URL，提取文件名
          profileImgFileName = _extractFileNameFromUrl(currentUser.profileImg!);
          if (kDebugMode) {
            print('Extracted filename from URL: $profileImgFileName');
          }
        }
      }

      // Update user data - 确保只存储文件名
      final updatedUser = currentUser.copyWith(
        username: newUsername,
        phoneNo: newPhoneNumber.isEmpty ? null : newPhoneNumber,
        gender: newGender,
        dob: selectedDate,
        profileImg: profileImgFileName, // 只存储文件名
      );

      if (kDebugMode) {
        print('=== Profile Update Debug ===');
        print('Original profileImg: ${currentUser.profileImg}');
        print('Extracted filename: $profileImgFileName');
        print('Updated user profileImg: ${updatedUser.profileImg}');
      }

      // Save to Firestore
      await userRepository.updateUserDetails(updatedUser);

      // 更新本地用户数据 - 但要确保本地数据也只存储文件名
      profileController.user.value = updatedUser;

      isLoading.value = false;

      // Disable edit mode - 但不返回，保持在当前页面
      isEditing.value = false;

      // Show Success Message
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Your profile has been updated successfully',
      );
    } catch (e) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Update Failed',
        message: e.toString(),
      );
    }
  }

  /// 从 URL 中提取文件名 - 优化版本
  String? _extractFileNameFromUrl(String url) {
    try {
      if (kDebugMode) {
        print('=== _extractFileNameFromUrl Debug Start ===');
        print('Input URL: $url');
      }

      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (kDebugMode) {
        print('URI pathSegments: $pathSegments');
        print('Path segments count: ${pathSegments.length}');
      }

      if (pathSegments.isNotEmpty) {
        // Firebase Storage URL 固定格式: /v0/b/bucket/o/profile_images/filename?alt=media
        // pathSegments: ['v0', 'b', 'bucket', 'o', 'profile_images', 'filename']

        // 方法1：直接根据固定位置获取（更高效）
        if (pathSegments.length >= 6) {
          final result = pathSegments[5];
          if (kDebugMode) {
            print('✅ Method 1 (Fixed Position) - Result: $result');
          }
          return result;
        }

        // 方法2：查找包含 profile_images 的路径段
        for (int i = 0; i < pathSegments.length; i++) {
          final segment = pathSegments[i];
          if (segment.contains('profile_images/')) {
            if (kDebugMode) {
              print('🔍 Method 2 - Found segment with profile_images/: $segment (index: $i)');
            }
            // 分割路径段获取文件名
            final segments = segment.split('profile_images/');
            if (kDebugMode) {
              print('   Split segments: $segments');
            }
            if (segments.length >= 2) {
              final result = segments[1];
              if (kDebugMode) {
                print('✅ Method 2 (Split profile_images/) - Result: $result');
              }
              return result;
            }
          }
        }

        // 方法3：查找 profile_images 的位置
        final profileImagesIndex = pathSegments.indexOf('profile_images');
        if (kDebugMode) {
          print('🔍 Method 3 - profile_images index: $profileImagesIndex');
        }
        if (profileImagesIndex != -1 && profileImagesIndex + 1 < pathSegments.length) {
          final result = pathSegments[profileImagesIndex + 1];
          if (kDebugMode) {
            print('✅ Method 3 (profile_images index) - Result: $result');
          }
          return result;
        }

        // 备用方案：获取最后一个路径段
        final result = pathSegments.last;
        if (kDebugMode) {
          print('✅ Method 4 (Last segment) - Result: $result');
        }
        return result;
      }

      if (kDebugMode) {
        print('❌ No path segments found');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error extracting filename from URL: $e');
      }
      return null;
    } finally {
      if (kDebugMode) {
        print('=== _extractFileNameFromUrl Debug End ===');
      }
    }
  }

  /// Reset form to initial values
  void resetForm() {
    initializeFields();
    isEditing.value = false;
  }

  /// 手动返回方法（如果需要）
  void goBack() {
    if (isEditing.value) {
      // 如果在编辑模式，先重置表单再返回
      resetForm();
    }
    Get.back();
  }

  @override
  void onClose() {
    username.dispose();
    email.dispose();
    phoneNumber.dispose();
    dateOfBirth.dispose();
    super.onClose();
  }
}