import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/personalization/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/services/qr_code/jwt_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/activity_image.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/waste_category_model.dart';
import '../screens/add_recyling_activity/widgets/submission_success.dart';

class StaffHomeController extends GetxController {
  static StaffHomeController get instance => Get.find();

  // Repositories
  final UserRepository _userRepository = Get.put(UserRepository());
  final RecyclingActivityRepository _activityRepository = Get.put(RecyclingActivityRepository());
  final WasteCategoryRepository _wasteCategoryRepository = Get.put(WasteCategoryRepository());
  final JWTService _jwtService = Get.put(JWTService());

  // Observables
  final RxString userId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isValidUser = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxInt userRewardPoints = 0.obs;
  final RxString userProfileImage = ''.obs;
  final Rx<UserSearchMethod> searchMethod = UserSearchMethod.username.obs;

  // Recycling activities with their images
  final RxList<ActivityWithImage> currentActivitiesWithImages = <ActivityWithImage>[].obs;
  final RxList<WasteCategory> wasteCategories = <WasteCategory>[].obs;

  // Form controllers
  final TextEditingController userIdController = TextEditingController();
  final GlobalKey<FormState> userIdFormKey = GlobalKey<FormState>();

  // Staff info
  final RxString staffId = ''.obs;

  // Computed properties for compatibility
  List<RecyclingActivity> get currentActivities =>
      currentActivitiesWithImages.map((e) => e.activity).toList();

  @override
  void onInit() {
    super.onInit();
    _initializeStaffInfo();
    loadWasteCategories();
  }

  @override
  void onClose() {
    userIdController.dispose();
    super.onClose();
  }

  void _initializeStaffInfo() {
    final authUser = AuthenticationRepository.instance.authUser;
    if (authUser != null) {
      staffId.value = authUser.uid;
    }
  }

  Future<void> loadWasteCategories() async {
    try {
      isLoading.value = true;
      final categories = await _wasteCategoryRepository.getAllWasteCategories();
      wasteCategories.value = categories;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load waste categories: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUser() async {
    if (!userIdFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      searchMethod.value = UserSearchMethod.username;

      final username = userIdController.text.trim();
      final user = await _userRepository.getUserByUsername(username);

      if (user != null && user.userId.isNotEmpty) {
        await _setUserInfo(
          user.userId,
          user.username,
          user.email,
          user.rewardPoint,
          user.profileImg,
        );

        FLoaders.successSnackBar(
          title: 'Success',
          message: 'User found! You can now add recycling activities.',
        );
      } else {
        isValidUser.value = false;
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not found. Please check the username.',
        );
      }
    } catch (e) {
      isValidUser.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to search user: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateAndSetUserFromQR(String scannedResult) async {
    try {
      isLoading.value = true;
      searchMethod.value = UserSearchMethod.qrCode;

      String userId;

      if (scannedResult.length == 28) {
        userId = scannedResult;
      } else {
        final extractedUserId = _jwtService.validateQRToken(scannedResult);
        if (extractedUserId != null) {
          userId = extractedUserId;
        } else {
          throw Exception('Invalid QR code format');
        }
      }

      final user = await _userRepository.fetchOtherUserDetails(userId);

      if (user.userId.isNotEmpty) {
        await _setUserInfo(
          user.userId,
          user.username,
          user.email,
          user.rewardPoint,
          user.profileImg,
        );

        FLoaders.customToast(
          message: 'QR scan successful! User verified.',
        );
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not found in database.',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to process QR code: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _setUserInfo(
      String id,
      String name,
      String email,
      int points,
      String? profileImg,
      ) async {
    userId.value = id;
    userName.value = name;
    userEmail.value = email;
    userRewardPoints.value = points;
    userProfileImage.value = profileImg ?? '';
    isValidUser.value = true;
    currentActivitiesWithImages.clear();
  }

  Future<String?> getUserProfileImageUrl() async {
    if (userProfileImage.value.isEmpty) return null;

    try {
      final cachedUrl = _userRepository.getCachedProfileImageUrl(userProfileImage.value);
      if (cachedUrl != null) {
        return cachedUrl;
      }
      return await _userRepository.getProfileImageUrl(userProfileImage.value);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addRecyclingActivity(RecyclingActivity activity, File? imageFile) async {
    try {
      currentActivitiesWithImages.add(
          ActivityWithImage(activity: activity, imageFile: imageFile)
      );
      return true;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to add activity: $e',
      );
      return false;
    }
  }

  Future<bool> editRecyclingActivity(int index, RecyclingActivity activity, File? imageFile) async {
    try {
      if (index >= 0 && index < currentActivitiesWithImages.length) {
        currentActivitiesWithImages[index] = ActivityWithImage(
          activity: activity,
          imageFile: imageFile,
        );
        return true;
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid activity index',
        );
        return false;
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to edit activity: $e',
      );
      return false;
    }
  }

  Future<bool> deleteRecyclingActivity(int index) async {
    try {
      if (index >= 0 && index < currentActivitiesWithImages.length) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text('Are you sure you want to delete this activity?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          currentActivitiesWithImages.removeAt(index);
          FLoaders.warningSnackBar(
            title: 'Deleted',
            message: 'Recycling activity removed!',
          );
          return true;
        }
        return false;
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Invalid activity index',
        );
        return false;
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: $e',
      );
      return false;
    }
  }

  Future<void> submitAllActivities() async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Submit All Activities'),
        content: Text(
          'Submit ${currentActivitiesWithImages.length} activities?\n\n'
              'Total Weight: ${totalSessionWeight.toStringAsFixed(1)} kg\n'
              'Total Points: $totalSessionPoints points\n\n'
              'Note: This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.staffLightSecondary,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Store values before clearing
      final submittedActivitiesCount = currentActivitiesWithImages.length;
      final submittedWeight = totalSessionWeight;
      final submittedPoints = totalSessionPoints;
      final submittedUserName = userName.value;

      FFullScreenLoader.openLoadingDialog(
        'Submitting activities...',
        'assets/images/animations/loader-animation.json',
      );

      // Submit through repository with images
      await _activityRepository.submitActivitiesWithImages(
        currentActivitiesWithImages.toList(),
        userId.value,
      );

      FFullScreenLoader.stopLoading();

      // Reset form
      resetForm();

      // Navigate to success screen with data
      Get.off(() => SubmissionSuccessScreen(
        activitiesCount: submittedActivitiesCount,
        totalWeight: submittedWeight,
        totalPoints: submittedPoints,
        userName: submittedUserName,
      ));
    } catch (e) {
      FFullScreenLoader.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to submit activities: $e',
      );
    }
  }

  void resetForm() {
    userIdController.clear();
    userId.value = '';
    userName.value = '';
    userEmail.value = '';
    userRewardPoints.value = 0;
    userProfileImage.value = '';
    isValidUser.value = false;
    currentActivitiesWithImages.clear();
    searchMethod.value = UserSearchMethod.username;
  }

  int get totalSessionPoints {
    return currentActivitiesWithImages.fold(
        0,
            (sum, item) => sum + item.activity.pointsEarned
    );
  }

  double get totalSessionWeight {
    return currentActivitiesWithImages.fold(
        0.0,
            (sum, item) => sum + item.activity.weight
    );
  }

  String? validateUserId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter username';
    }
    return null;
  }
}