import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/repositories/reward_redemption/redemption_repository.dart';
import '../../../data/repositories/reward_redemption/reward_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class RewardController extends GetxController {
  static RewardController get instance => Get.find();

  final rewardRepository = Get.put(RewardRepository());
  final redemptionRepository = Get.put(RedemptionRepository());
  final userRepository = Get.put(UserRepository());

  // Observable variables
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt userPoints = 0.obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
    _subscribeToRewardsStream();
  }

  /// Initialize user data
  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
      print('UserID: ${currentUserId.value}');
      _subscribeToUserPoints();
    }
  }

  /// Subscribe to user points stream
  void _subscribeToUserPoints() {
    userRepository.getUserPointsStream(currentUserId.value).listen(
          (points) => userPoints.value = points,
      onError: (error) => FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to sync points: $error',
      ),
    );
  }

  /// Subscribe to rewards stream for real-time updates
  void _subscribeToRewardsStream() {
    isLoading.value = true;
    rewardRepository.getAvailableRewardsStream().listen(
          (fetchedRewards) async {
        try {
          // Fetch image URLs for each reward
          for (var reward in fetchedRewards) {
            if (reward.rewardImage.isNotEmpty) {
              reward.rewardImage = await rewardRepository.getRewardImageUrl(reward.rewardImage);
            }
          }
          rewards.assignAll(fetchedRewards);
        } catch (e) {
          print('❌ Error processing rewards stream: $e');
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to process rewards: $e',
          );
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        print('❌ Error in rewards stream: $error');
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load rewards: $error',
        );
      },
    );
  }

  /// Check if user can redeem a reward
  bool canRedeemReward(RewardModel reward) {
    return userPoints.value >= reward.pointsNeeded &&
        reward.isAvailable;
  }

  /// Redeem a reward
  Future<bool> redeemReward(RewardModel reward) async {
    try {
      // Validation
      if (!canRedeemReward(reward)) {
        if (userPoints.value < reward.pointsNeeded) {
          FLoaders.errorSnackBar(
            title: 'Insufficient Points',
            message: 'You need ${reward.pointsNeeded - userPoints.value} more points',
          );
        } else {
          FLoaders.errorSnackBar(
            title: 'Unavailable',
            message: 'This reward is currently unavailable',
          );
        }
        return false;
      }

      // Check if reward is still available
      final isAvailable = await rewardRepository.isRewardAvailable(reward.rewardId);
      if (!isAvailable) {
        FLoaders.errorSnackBar(
          title: 'Unavailable',
          message: 'This reward is no longer available',
        );
        return false;
      }

      FLoaders.showLoading('Redeeming reward...');

      // Create redemption
      final redemption = RedemptionModel.createNew(
        userId: currentUserId.value,
        rewardId: reward.rewardId,
      );

      // Save redemption to Firebase
      final createdRedemption = await redemptionRepository.createRedemption(redemption);

      // Deduct points from user
      await userRepository.deductPoints(currentUserId.value, reward.pointsNeeded);

      // Update reward quantity
      await rewardRepository.updateRewardQuantity(
        reward.rewardId,
        reward.quantity - 1,
      );

      FLoaders.stopLoading();

      // Show success dialog with PIN
      _showRedemptionSuccessDialog(createdRedemption, reward);

      return true;
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to redeem reward: $e',
      );
      return false;
    }
  }

  /// Show redemption success dialog
  void _showRedemptionSuccessDialog(RedemptionModel redemption, RewardModel reward) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Get.isDarkMode ? FColors.dark : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(FSizes.defaultSpace),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: FColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: FColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Redemption Successful!',
                style: Get.textTheme.titleLarge?.copyWith(
                  color: Get.isDarkMode ? FColors.white : FColors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Your reward has been redeemed successfully',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.isDarkMode ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Container(
                padding: const EdgeInsets.all(FSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.primary.withOpacity(0.1),
                      FColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  border: Border.all(
                    color: FColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your PIN Code',
                      style: Get.textTheme.titleSmall?.copyWith(
                        color: Get.isDarkMode ? FColors.darkGrey : FColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      redemption.formattedPinCode,
                      style: Get.textTheme.headlineMedium?.copyWith(
                        color: FColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FSizes.md),
              Text(
                'Present this PIN to redeem your reward.\nValid for 30 days.',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.isDarkMode ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.white,
                    padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Refresh rewards (now handled automatically by stream)
  Future<void> refreshRewards() async {
    // No need to manually refresh as stream handles real-time updates
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate brief loading
    isLoading.value = false;
  }

  /// Get reward by ID
  RewardModel? getRewardById(String rewardId) {
    try {
      return rewards.firstWhere((reward) => reward.rewardId == rewardId);
    } catch (e) {
      return null;
    }
  }
}