import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../authentication/models/user_model.dart';
import '../../authentication/screens/login/login.dart';
import '../screens/profile/edit_profile/edit_profile.dart';
import '../screens/profile/edit_profile/image_cropper.dart';
import '../screens/profile/profile_camera.dart';
import '../screens/profile/widgets/media_lightbox.dart';
import '../screens/profile/widgets/re_authenticate_user_login_form.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final imageUploading = false.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  // User data observable with stream
  final Rx<UserModel> user = UserModel.empty().obs;
  StreamSubscription<UserModel>? _userStreamSubscription;

  final authRepository = Get.put(AuthenticationRepository());
  final userRepository = Get.put(UserRepository());
  final uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    _initializeUserStream();
  }

  /// Initialize user stream for real-time updates
  void _initializeUserStream() {
    final currentUserId = AuthenticationRepository.instance.authUser?.uid;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      _userStreamSubscription = userRepository
          .getUserDetailsStream(currentUserId)
          .listen((userData) async {
        // 如果用户有头像文件名，获取完整的下载URL
        if (userData.profileImg != null && userData.profileImg!.isNotEmpty) {
          try {
            final imageUrl = await userRepository.getProfileImageUrl(
                userData.profileImg!
            );
            // 创建带有完整URL的新用户对象
            final userWithImageUrl = userData.copyWith(profileImg: imageUrl);
            user(userWithImageUrl);
          } catch (e) {
            // 如果获取URL失败，使用原始数据
            user(userData);
            if (kDebugMode) {
              print('Failed to get profile image URL: $e');
            }
          }
        } else {
          user(userData);
        }

        if (kDebugMode) {
          print('=== User Stream Update ===');
          print('Username: ${userData.username}');
          print('Gender: ${userData.gender}');
          print('Phone: ${userData.phoneNo}');
          print('Profile Image File Name: ${userData.profileImg}');
        }
      }, onError: (error) {
        if (kDebugMode) {
          print('Error in user stream: $error');
        }
        FLoaders.warningSnackBar(
          title: 'Data Error',
          message: 'Failed to load user data',
        );
      });
    } else {
      user(UserModel.empty());
    }
  }

  /// Manually refresh user data
  Future<void> refreshUserData() async {
    try {
      final currentUserId = AuthenticationRepository.instance.authUser?.uid;
      if (currentUserId != null) {
        final fetchedUser = await userRepository.fetchUserDetails();

        // 如果用户有头像文件名，获取完整的下载URL
        if (fetchedUser.profileImg != null && fetchedUser.profileImg!.isNotEmpty) {
          try {
            final imageUrl = await userRepository.getProfileImageUrl(
                fetchedUser.profileImg!
            );
            final userWithImageUrl = fetchedUser.copyWith(profileImg: imageUrl);
            user(userWithImageUrl);
          } catch (e) {
            user(fetchedUser);
            if (kDebugMode) {
              print('Failed to get profile image URL: $e');
            }
          }
        } else {
          user(fetchedUser);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user data: $e');
      }
    }
  }

  /// Show profile image in lightbox
  void viewProfileImage() {
    if (user.value.profileImg != null && user.value.profileImg!.isNotEmpty) {
      showMediaLightbox([user.value.profileImg!]);
    }
  }

  /// Show Image Source Selection (Camera or Gallery)
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Image Source',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    uploadProfileImageFromCustomCamera();
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
                    uploadProfileImageFromGallery();
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
                GestureDetector(
                  onTap: () {
                    Get.back();
                    viewProfileImage();
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove_red_eye, color: Colors.purple, size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text('View'),
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

  /// Upload Profile Image from Custom Camera
  Future<void> uploadProfileImageFromCustomCamera() async {
    try {
      // Use custom camera controller
      final result = await Get.to(() => ProfileCameraScreen());

      if (result != null && result is File) {
        await _processAndUploadImage(result);
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to capture image: $e');
    }
  }

  /// Upload Profile Image from Gallery
  Future<void> uploadProfileImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        await _processAndUploadImage(File(image.path));
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick image: $e');
    }
  }

  /// Process and upload image
  Future<void> _processAndUploadImage(File imageFile) async {
    try {
      // Check file size (10MB = 10 * 1024 * 1024 bytes)
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 10) {
        FLoaders.errorSnackBar(
          title: 'Image too large',
          message: 'Please select an image smaller than 10MB.',
        );
        return;
      }

      // Show crop screen
      final croppedFile = await Get.to<File?>(() => ImageCropperScreen(imageFile: imageFile));

      if (croppedFile == null) return;

      imageUploading.value = true;

      // Compress and convert to WebP
      final compressedFile = await _compressAndConvertToWebP(croppedFile);

      // 获取当前用户的旧头像文件名
      final oldFileName = user.value.profileImg;
      String? oldImageFileName;
      if (oldFileName != null && oldFileName.isNotEmpty) {
        try {
          final uri = Uri.parse(oldFileName);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            // 获取最后一个路径段（可能是编码的）
            final lastSegment = pathSegments.last;
            // 解码 URL 编码
            final decodedSegment = Uri.decodeComponent(lastSegment);
            // 按斜杠分割并取最后一部分
            final parts = decodedSegment.split('/');
            oldImageFileName = parts.last;
            print('oldFilename: $oldImageFileName');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error extracting old image file name: $e');
          }
        }
      }

      // Upload to Firebase Storage and get download URL (同时删除旧头像)
      final imageUrl = await userRepository.uploadProfileImage(compressedFile, user.value.userId, oldImageFileName);

      // 更新本地用户数据，使用新的图片URL
      user.value = user.value.copyWith(profileImg: imageUrl);
      user.refresh();

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Profile image updated successfully!',
      );
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to upload image: $e');
    } finally {
      imageUploading.value = false;
    }
  }

  /// Compress image and convert to WebP format
  Future<File> _compressAndConvertToWebP(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${uuid.v4()}.webp';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        quality: 85,
        minWidth: 500,
        minHeight: 500,
        autoCorrectionAngle: true,
      );

      if (result == null) {
        throw 'Failed to compress image';
      }

      return File(result.path);
    } catch (e) {
      print('Image compression failed: $e, using original file');
      return imageFile;
    }
  }

  /// Delete account warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          deleteUserAccount();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Get.back(),
      ),
    );
  }

  /// Delete User Account
  void deleteUserAccount() async {
    try {
      FFullScreenLoader.openLoadingDialog('Processing', FImages.docerAnimation);

      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
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
      FLoaders.warningSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Re-authenticate before deleting
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      FFullScreenLoader.openLoadingDialog('Processing', FImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        FFullScreenLoader.stopLoading();
        return;
      }

      await authRepository.reAuthenticateWithEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );

      await authRepository.deleteAccount();
      FFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.warningSnackBar(title: 'Error', message: e.toString());
    }
  }

  void navigateToEditProfile({bool isStaffProfile = false}) {
    Get.to(() => EditProfileScreen(isStaffProfile: isStaffProfile));
    // Get.to(() => AddWasteCategoryScreen());
  }

  void logout() {
    authRepository.logout();
  }

  @override
  void onClose() {
    _userStreamSubscription?.cancel();
    verifyEmail.dispose();
    verifyPassword.dispose();
    super.onClose();
  }
}