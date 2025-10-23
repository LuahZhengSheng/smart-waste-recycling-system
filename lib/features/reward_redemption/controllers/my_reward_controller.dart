import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../data/repositories/reward_redemption/redemption_repository.dart';
import '../../../data/repositories/reward_redemption/reward_repository.dart';

class MyRewardsController extends GetxController with GetSingleTickerProviderStateMixin {
  static MyRewardsController get instance => Get.find();

  final rewardRepo = Get.put(RewardRepository());
  final redemptionRepo = Get.put(RedemptionRepository());

  // Tab Controller
  late TabController tabController;

  // Observable variables
  final RxList<RedemptionModel> userRedemptions = <RedemptionModel>[].obs;
  final RxMap<String, RewardModel> rewardsMap = <String, RewardModel>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _initializeUser();
    fetchUserRedemptions();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Initialize user data
  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
    }
  }

  /// Fetch user's redemptions from Firebase
  Future<void> fetchUserRedemptions() async {
    try {
      isLoading.value = true;

      // Fetch redemptions
      final redemptions = await redemptionRepo.getUserRedemptions(currentUserId.value);
      userRedemptions.assignAll(redemptions);

      // Fetch reward details for each redemption
      final rewardIds = redemptions.map((r) => r.rewardId).toSet();
      for (var rewardId in rewardIds) {
        try {
          final reward = await rewardRepo.getRewardById(rewardId);
          if (reward.rewardImage.isNotEmpty) {
            reward.rewardImage = await rewardRepo.getRewardImageUrl(reward.rewardImage);
          }
          rewardsMap[rewardId] = reward;
        } catch (e) {
          // If reward not found, continue with other rewards
          continue;
        }
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load redemptions: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get reward details by ID
  RewardModel? getRewardById(String rewardId) {
    return rewardsMap[rewardId];
  }

  /// Get active redemptions (not expired, within 30 days)
  List<RedemptionModel> get activeRedemptions {
    final now = DateTime.now();
    return userRedemptions.where((redemption) {
      final daysSinceRedemption = now.difference(redemption.createdAt).inDays;
      return daysSinceRedemption < 30;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get expired redemptions (30 days or older)
  List<RedemptionModel> get expiredRedemptions {
    final now = DateTime.now();
    return userRedemptions.where((redemption) {
      final daysSinceRedemption = now.difference(redemption.createdAt).inDays;
      return daysSinceRedemption >= 30;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchUserRedemptions();
  }

  /// Check if redemption is near expiry (within 7 days of 30-day validity)
  bool isRedemptionNearExpiry(RedemptionModel redemption) {
    final now = DateTime.now();
    final daysSinceRedemption = now.difference(redemption.createdAt).inDays;
    final daysUntilExpiry = 30 - daysSinceRedemption;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  /// Get days until redemption expires
  int getDaysUntilExpiry(RedemptionModel redemption) {
    final now = DateTime.now();
    final daysSinceRedemption = now.difference(redemption.createdAt).inDays;
    return 30 - daysSinceRedemption;
  }

  /// Get redemption summary
  Map<String, int> get redemptionSummary {
    return {
      'active': activeRedemptions.length,
      'expired': expiredRedemptions.length,
      'total': userRedemptions.length,
    };
  }
}