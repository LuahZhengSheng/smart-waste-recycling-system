import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/reward_redemption/reward_repository.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/admin_loaders.dart';
import '../../../reward_redemption/models/reward_model.dart';
import '../../screens/reward_management/edit_reward/edit_reward.dart';
import '../../screens/reward_management/reward_detail/reward_detail.dart';
import '../../screens/reward_management/reward_management/reward_management.dart';

class RewardManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Repository
  final _rewardRepo = Get.put(RewardRepository());

  // Stream subscription
  StreamSubscription<List<RewardModel>>? _rewardsSubscription;

  // Observables
  final RxList<RewardModel> allRewards = <RewardModel>[].obs;
  final RxList<RewardModel> filteredRewards = <RewardModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'active'.obs; // active or inactive
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'availabilityStatus': null,
    'pointsRange': null,
    'quantityRange': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToRewards();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(selectedStatusFilter, (_) => applyFiltersAndSearch());
  }

  @override
  void onClose() {
    _rewardsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  /// Listen to rewards stream
  void _listenToRewards() {
    _rewardsSubscription =
        _rewardRepo.getAllRewardsStream().listen((rewards) {
          allRewards.assignAll(rewards);
          applyFiltersAndSearch();
        }, onError: (error) {
          FAdminLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to load rewards: ${error.toString()}',
          );
        });
  }

  /// Change status filter
  void changeStatusFilter(String status) {
    selectedStatusFilter.value = status;
  }

  /// Get computed reward status
  String getRewardComputedStatus(RewardModel reward) {
    if (reward.status == 'inactive') {
      return 'inactive';
    }

    if (reward.isExpired) {
      return 'expired';
    }

    if (reward.remainingQuantity <= 0) {
      return 'out_of_stock';
    }

    return 'active';
  }

  /// Get availability status for filtering
  String getAvailabilityStatus(RewardModel reward) {
    if (!reward.isAvailable) {
      if (reward.isExpired) return 'expired';
      if (reward.remainingQuantity <= 0) return 'out_of_stock';
      if (reward.status == 'inactive') return 'inactive';
    }
    return 'available';
  }

  /// Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<RewardModel> result = List.from(allRewards);

    // Apply status filter
    result = result
        .where((reward) => reward.status == selectedStatusFilter.value)
        .toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((reward) {
        return reward.title
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()) ||
            reward.description
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            reward.pointsNeeded.toString().contains(searchQuery.value);
      }).toList();
    }

    // Apply filters
    if (activeFilters['availabilityStatus'] != null) {
      result = result
          .where((reward) =>
      getAvailabilityStatus(reward) ==
          activeFilters['availabilityStatus'])
          .toList();
    }

    if (activeFilters['pointsRange'] != null) {
      result = result.where((reward) {
        switch (activeFilters['pointsRange']) {
          case 'low':
            return reward.pointsNeeded <= 500;
          case 'medium':
            return reward.pointsNeeded > 500 && reward.pointsNeeded <= 1000;
          case 'high':
            return reward.pointsNeeded > 1000;
          default:
            return true;
        }
      }).toList();
    }

    if (activeFilters['quantityRange'] != null) {
      result = result.where((reward) {
        switch (activeFilters['quantityRange']) {
          case 'low':
            return reward.remainingQuantity <= 10 &&
                reward.remainingQuantity > 0;
          case 'medium':
            return reward.remainingQuantity > 10 &&
                reward.remainingQuantity <= 50;
          case 'high':
            return reward.remainingQuantity > 50;
          case 'out_of_stock':
            return reward.remainingQuantity == 0;
          default:
            return true;
        }
      }).toList();
    }

    filteredRewards.value = result;
    currentPage.value = 1;
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['availabilityStatus'] != null ||
        activeFilters['pointsRange'] != null ||
        activeFilters['quantityRange'] != null;
  }

  /// Sorting functionality
  void sortRewards(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    // 使用 List.from 创建新列表以避免直接修改原列表
    final sortedRewards = List<RewardModel>.from(filteredRewards);

    sortedRewards.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Reward ID
          aValue = a.rewardId.toLowerCase();
          bValue = b.rewardId.toLowerCase();
          break;
        case 2: // Title
          aValue = a.title.toLowerCase();
          bValue = b.title.toLowerCase();
          break;
        case 3: // Points Needed
          aValue = a.pointsNeeded;
          bValue = b.pointsNeeded;
          break;
        case 4: // Total Quantity
          aValue = a.quantity;
          bValue = b.quantity;
          break;
        case 5: // Remaining Quantity
          aValue = a.remainingQuantity;
          bValue = b.remainingQuantity;
          break;
        case 6: // Redemption Count
          aValue = a.redemptionCount;
          bValue = b.redemptionCount;
          break;
        case 7: // Valid Until
          aValue = a.validUntil;
          bValue = b.validUntil;
          break;
        case 8: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 9: // Status
          aValue = getRewardComputedStatus(a);
          bValue = getRewardComputedStatus(b);
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });

    // 更新 filteredRewards
    filteredRewards.value = sortedRewards;
  }

  /// Toggle reward status
  Future<void> toggleRewardStatus(RewardModel reward) async {
    final isActivating = reward.status != 'active';

    if (isActivating) {
      // Check if reward can be activated
      final canActivate = await _canActivateReward(reward);
      if (!canActivate) {
        return;
      }
    }

    try {
      final newStatus = isActivating ? 'active' : 'inactive';
      await _rewardRepo.updateRewardStatus(reward.rewardId, newStatus);

      // 关闭可能存在的 snackbar，确保成功消息能显示
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: isActivating
            ? 'Reward activated successfully'
            : 'Reward deactivated successfully',
      );
    } catch (e) {
      // 关闭可能存在的 snackbar，确保错误消息能显示
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update reward status: ${e.toString()}',
      );
    }
  }

  /// Check if reward can be activated - 改为异步
  Future<bool> _canActivateReward(RewardModel reward) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (reward.remainingQuantity <= 0) {
      // 先关掉可能存在的 snackbar，避免被覆盖
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      FAdminLoaders.warningSnackBar(
        title: 'Cannot Activate Reward',
        message:
        'Reward cannot be activated because remaining quantity is 0. Please update the quantity first.',
      );

      print('❌ Activation failed: remaining quantity is 0');
      return false;
    }

    if (reward.validUntil.isBefore(tomorrow)) {
      print('❌ Activation failed: valid until date is too soon');

      // 关闭可能存在的 snackbar
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      FAdminLoaders.warningSnackBar(
        title: 'Cannot Activate Reward',
        message: 'Reward cannot be activated because the valid until date must be at least 1 day from now. Please update the expiry date first.',
      );
      return false;
    }

    print('✅ Activation constraints passed');
    return true;
  }

  /// View reward details
  void viewReward(RewardModel reward) {
    Get.to(() => AdminRewardDetailScreen(reward: reward));
  }

  /// Edit reward
  void editReward(RewardModel reward) {
    Get.to(() => EditRewardScreen(rewardId: reward.rewardId));
  }

  /// Pagination functionality
  List<RewardModel> get paginatedRewards {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex =
    (startIndex + itemsPerPage.value).clamp(0, filteredRewards.length);

    if (startIndex >= filteredRewards.length) {
      return [];
    }

    return filteredRewards.sublist(startIndex, endIndex);
  }

  int get totalRewards => filteredRewards.length;
  int get totalPages => (totalRewards / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex =>
      (startIndex + itemsPerPage.value).clamp(0, totalRewards);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1;
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      RewardFilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }
}