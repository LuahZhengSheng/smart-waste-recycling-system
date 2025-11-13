import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

import '../../../data/repositories/personalization/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/recycling_center_repository.dart';
import '../../../data/repositories/reward_redemption/redemption_repository.dart';
import '../../../data/repositories/reward_redemption/reward_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../personalization/models/recycle_activity_model.dart';
import '../../recycling_center/models/partner_recycling_center_model.dart';
import '../models/reward_redemption_enums.dart';
import '../../reward_redemption/models/redemption_model.dart';
import '../../reward_redemption/models/reward_model.dart';

class RewardPointsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static RewardPointsController get instance => Get.find();

  // Repositories
  final userRepository = Get.put(UserRepository());
  final activityRepository = Get.put(RecyclingActivityRepository());
  final centerRepository = Get.put(RecyclingCenterRepository());
  final redemptionRepository = Get.put(RedemptionRepository());
  final rewardRepository = Get.put(RewardRepository());

  // Tab Controller
  late TabController tabController;

  // Observable variables
  final currentPoints = 0.obs;
  final isLoading = false.obs;
  final selectedFilterType = DateFilterType.last30Days.obs;
  final selectedDateRange = Rx<DateTimeRange?>(null);

  // Transaction lists - using actual models
  final allEarningActivities = <RecyclingActivity>[].obs;
  final allSpendingRedemptions = <RedemptionModel>[].obs;

  // Filtered lists
  final filteredEarningActivities = <RecyclingActivity>[].obs;
  final filteredSpendingRedemptions = <RedemptionModel>[].obs;

  // Streams subscriptions
  StreamSubscription? _pointsSubscription;
  StreamSubscription? _activitiesSubscription;
  StreamSubscription? _redemptionsSubscription;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    // Initialize with default date range
    selectedDateRange.value = selectedFilterType.value.getDateRange();

    loadRewardPointsData();

    // Listen to tab changes to update filtered lists
    tabController.addListener(() {
      _updateFilteredLists();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    _pointsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    _redemptionsSubscription?.cancel();
    super.onClose();
  }

  /// Load all reward points data with real-time updates
  Future<void> loadRewardPointsData() async {
    try {
      isLoading(true);

      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      // Load current points stream
      _subscribeToPoints(userId);

      // Load transactions streams
      await _subscribeToTransactions(userId);
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load reward points data: $e',
      );
    } finally {
      isLoading(false);
    }
  }

  /// Subscribe to user points stream
  void _subscribeToPoints(String userId) {
    _pointsSubscription?.cancel();
    _pointsSubscription = userRepository.getUserPointsStream(userId).listen(
      (points) => currentPoints.value = points,
      onError: (error) {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load points: $error',
        );
      },
    );
  }

  /// Subscribe to transactions streams
  Future<void> _subscribeToTransactions(String userId) async {
    // Get earning transactions from approved recycling activities
    _activitiesSubscription?.cancel();
    _activitiesSubscription =
        activityRepository.getUserApprovedActivitiesStream(userId).listen(
      (activities) {
        allEarningActivities.assignAll(activities);
        _updateFilteredLists();
      },
      onError: (error) {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load activities: $error',
        );
      },
    );

    // Get spending transactions from redemptions
    _redemptionsSubscription?.cancel();
    _redemptionsSubscription =
        redemptionRepository.getUserRedemptionsStream(userId).listen(
      (redemptions) {
        allSpendingRedemptions.assignAll(redemptions);
        _updateFilteredLists();
      },
      onError: (error) {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load redemptions: $error',
        );
      },
    );
  }

  /// Update filtered lists based on date range
  void _updateFilteredLists() {
    if (selectedDateRange.value == null) return;

    final startDate = selectedDateRange.value!.start;
    final endDate = selectedDateRange.value!.end.add(const Duration(days: 1));

    // Filter earning activities
    filteredEarningActivities.assignAll(
      allEarningActivities
          .where((activity) =>
              activity.createdAt.isAfter(startDate) &&
              activity.createdAt.isBefore(endDate))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );

    // Filter spending redemptions
    filteredSpendingRedemptions.assignAll(
      allSpendingRedemptions
          .where((redemption) =>
              redemption.createdAt.isAfter(startDate) &&
              redemption.createdAt.isBefore(endDate))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  /// Apply date filter
  void applyDateFilter(DateFilterType filterType,
      {DateTimeRange? customRange}) {
    selectedFilterType.value = filterType;

    if (filterType == DateFilterType.custom && customRange != null) {
      selectedDateRange.value = customRange;
    } else {
      selectedDateRange.value = filterType.getDateRange();
    }

    _updateFilteredLists();
  }

  /// Get current tab items
  List<dynamic> get currentTabItems {
    switch (tabController.index) {
      case 0: // All
        final combined = <Map<String, dynamic>>[];

        for (var activity in filteredEarningActivities) {
          combined.add({
            'type': 'earning',
            'data': activity,
            'date': activity.createdAt,
          });
        }

        for (var redemption in filteredSpendingRedemptions) {
          combined.add({
            'type': 'spending',
            'data': redemption,
            'date': redemption.createdAt,
          });
        }

        combined.sort(
            (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        return combined;

      case 1: // Earning
        return filteredEarningActivities;

      case 2: // Spending
        return filteredSpendingRedemptions;

      default:
        return [];
    }
  }

  /// Get total earning points in selected date range
  int get totalEarningPoints {
    return filteredEarningActivities.fold(
        0, (sum, activity) => sum + activity.pointsEarned);
  }

  /// Get total spending points in selected date range
  int get totalSpendingPoints {
    // Need to fetch reward points for each redemption
    // This is calculated dynamically when needed
    return 0; // Will be calculated in UI or separate method
  }

  /// Get activity details by ID
  Stream<RecyclingActivity> getActivityStream(String activityId) {
    return activityRepository.getActivityStream(activityId);
  }

  /// Get redemption details by ID
  Stream<RedemptionModel> getRedemptionStream(String redemptionId) {
    return redemptionRepository.getRedemptionStream(redemptionId);
  }

  /// Get reward details by ID
  Stream<RewardModel> getRewardStream(String rewardId) {
    return rewardRepository.getRewardStream(rewardId);
  }

  /// Get center by staff ID
  Future<PartnerRecyclingCenter?> getCenterByStaffId(String staffId) {
    return centerRepository.getCenterByStaffId(staffId);
  }

  /// Get center stream
  Stream<PartnerRecyclingCenter?> getCenterByStaffIdStream(String staffId) {
    return centerRepository.getCenterByStaffIdStream(staffId);
  }

  /// Get reward by ID
  Future<RewardModel> getRewardById(String rewardId) {
    return rewardRepository.getRewardById(rewardId);
  }

  /// Show date filter bottom sheet
  void showDateFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      _DateFilterBottomSheet(controller: this),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadRewardPointsData();
  }
}

/// Date Filter Bottom Sheet Widget
class _DateFilterBottomSheet extends StatelessWidget {
  final RewardPointsController controller;

  const _DateFilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.darkerGrey : FColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter options
          ...DateFilterType.values.map((filterType) {
            return Obx(() => ListTile(
                  leading: Icon(
                    filterType == controller.selectedFilterType.value
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: filterType == controller.selectedFilterType.value
                        ? FColors.primary
                        : Colors.grey,
                  ),
                  title: Text(filterType.displayName),
                  onTap: () async {
                    if (filterType == DateFilterType.custom) {
                      Get.back();
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                        initialDateRange: controller.selectedDateRange.value,
                      );
                      if (picked != null) {
                        controller.applyDateFilter(filterType,
                            customRange: picked);
                      }
                    } else {
                      controller.applyDateFilter(filterType);
                      Get.back();
                    }
                  },
                ));
          }),
        ],
      ),
    );
  }
}
