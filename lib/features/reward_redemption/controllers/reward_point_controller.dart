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
import '../../recycling_center/models/recycle_activity_model.dart';
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
  final isInitialLoading = true.obs;
  final selectedFilterType = DateFilterType.last30Days.obs;
  final selectedDateRange = Rx<DateTimeRange?>(null);

  // Transaction lists
  final allEarningActivities = <RecyclingActivity>[].obs;
  final allSpendingRedemptions = <RedemptionModel>[].obs;

  // Filtered lists
  final filteredEarningActivities = <RecyclingActivity>[].obs;
  final filteredSpendingRedemptions = <RedemptionModel>[].obs;

  // Cache for rewards and centers to prevent rebuilds
  final rewardCache = <String, RewardModel>{}.obs;
  final centerCache = <String, PartnerRecyclingCenter?>{}.obs;

  // Streams subscriptions
  StreamSubscription? _pointsSubscription;
  StreamSubscription? _activitiesSubscription;
  StreamSubscription? _redemptionsSubscription;

  // Loading completion flags
  final _activitiesLoaded = false.obs;
  final _redemptionsLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);

    // Initialize with default date range
    selectedDateRange.value = selectedFilterType.value.getDateRange();

    // Listen to tab changes
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _onTabChanged();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Load data after widget is fully initialized
    loadRewardPointsData();
  }

  @override
  void onClose() {
    tabController.dispose();
    _pointsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    _redemptionsSubscription?.cancel();
    super.onClose();
  }

  /// Handle tab change - show loading when switching tabs
  void _onTabChanged() async {
    FLoaders.showLoading('Switching tab...');

    // Wait a moment for UI to update
    await Future.delayed(const Duration(milliseconds: 100));

    // Preload cache for the new tab
    await _preloadCacheForCurrentTab();

    FLoaders.stopLoading();
  }

  /// Check if all data is loaded
  void _checkIfAllDataLoaded() async {
    if (_activitiesLoaded.value && _redemptionsLoaded.value) {
      // Preload cache before hiding loading
      await _preloadCacheForCurrentTab();
      isInitialLoading(false);
      isLoading(false);
    }
  }

  /// Load all reward points data with real-time updates
  Future<void> loadRewardPointsData() async {
    try {
      isLoading(true);
      isInitialLoading(true);
      _activitiesLoaded(false);
      _redemptionsLoaded(false);

      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      // Load current points stream
      _subscribeToPoints(userId);

      // Load transactions streams
      await _subscribeToTransactions(userId);
    } catch (e) {
      isInitialLoading(false);
      isLoading(false);
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load reward points data: $e',
      );
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
              (activities) async {
            allEarningActivities.assignAll(activities);
            _activitiesLoaded(true);
            await _updateFilteredLists();
            _checkIfAllDataLoaded();
          },
          onError: (error) {
            _activitiesLoaded(true);
            _checkIfAllDataLoaded();
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
              (redemptions) async {
            allSpendingRedemptions.assignAll(redemptions);
            _redemptionsLoaded(true);
            await _updateFilteredLists();
            _checkIfAllDataLoaded();
          },
          onError: (error) {
            _redemptionsLoaded(true);
            _checkIfAllDataLoaded();
            FLoaders.errorSnackBar(
              title: 'Error',
              message: 'Failed to load redemptions: $error',
            );
          },
        );
  }

  /// Update filtered lists based on date range
  Future<void> _updateFilteredLists() async {
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

  /// Preload cache data for current tab to prevent FutureBuilder rebuilds
  Future<void> _preloadCacheForCurrentTab() async {
    try {
      if (tabController.index == 0 || tabController.index == 1) {
        // All or Earning tab - preload centers
        await _preloadCenters();
      }

      if (tabController.index == 0 || tabController.index == 2) {
        // All or Spending tab - preload rewards
        await _preloadRewards();
      }
    } catch (e) {
      print('Error preloading cache: $e');
    }
  }

  /// Preload centers for earning activities
  Future<void> _preloadCenters() async {
    final staffIds = filteredEarningActivities
        .map((activity) => activity.centerStaffId)
        .toSet();

    final futures = <Future>[];
    for (var staffId in staffIds) {
      if (!centerCache.containsKey(staffId)) {
        futures.add(
          centerRepository.getCenterByStaffId(staffId).then((center) {
            centerCache[staffId] = center;
          }).catchError((e) {
            print('Error loading center for staff $staffId: $e');
            centerCache[staffId] = null;
          }),
        );
      }
    }

    // Wait for all centers to load
    await Future.wait(futures);
  }

  /// Preload rewards for spending redemptions
  Future<void> _preloadRewards() async {
    final rewardIds = filteredSpendingRedemptions
        .map((redemption) => redemption.rewardId)
        .toSet();

    final futures = <Future>[];
    for (var rewardId in rewardIds) {
      if (!rewardCache.containsKey(rewardId)) {
        futures.add(
          rewardRepository.getRewardById(rewardId).then((reward) {
            rewardCache[rewardId] = reward;
          }).catchError((e) {
            print('Error loading reward $rewardId: $e');
          }),
        );
      }
    }

    // Wait for all rewards to load
    await Future.wait(futures);
  }

  /// Apply date filter
  Future<void> applyDateFilter(DateFilterType filterType,
      {DateTimeRange? customRange}) async {
    FLoaders.showLoading('Applying filter...');

    selectedFilterType.value = filterType;

    if (filterType == DateFilterType.custom && customRange != null) {
      selectedDateRange.value = customRange;
    } else {
      selectedDateRange.value = filterType.getDateRange();
    }

    await _updateFilteredLists();
    await _preloadCacheForCurrentTab();

    FLoaders.stopLoading();
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
    return filteredSpendingRedemptions.fold(
        0, (sum, redemption) {
      final reward = rewardCache[redemption.rewardId];
      return sum + (reward?.pointsNeeded ?? 0);
    });
  }

  /// Get center by staff ID with cache
  PartnerRecyclingCenter? getCenterByStaffIdCached(String staffId) {
    return centerCache[staffId];
  }

  /// Get reward by ID with cache
  RewardModel? getRewardByIdCached(String rewardId) {
    return rewardCache[rewardId];
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
    FLoaders.showLoading('Refreshing...');

    // Clear cache on refresh
    rewardCache.clear();
    centerCache.clear();

    await loadRewardPointsData();

    FLoaders.stopLoading();
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
                    await controller.applyDateFilter(filterType,
                        customRange: picked);
                  }
                } else {
                  Get.back();
                  await controller.applyDateFilter(filterType);
                }
              },
            ));
          }),
        ],
      ),
    );
  }
}
