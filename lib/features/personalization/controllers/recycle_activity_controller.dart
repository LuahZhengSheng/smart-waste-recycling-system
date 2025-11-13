import 'package:get/get.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/recycling_center/models/waste_category_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';

import '../../../data/repositories/personalization/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';

class RecycleActivityController extends GetxController {
  static RecycleActivityController get instance => Get.find();

  // Repositories
  final _activityRepo = Get.put(RecyclingActivityRepository());
  final _categoryRepo = Get.put(WasteCategoryRepository());
  final _authRepo = Get.put(AuthenticationRepository());

  // Observable variables
  final RxList<RecyclingActivity> activities = <RecyclingActivity>[].obs;
  final RxList<RecyclingActivity> filteredActivities = <RecyclingActivity>[].obs;
  final RxList<WasteCategory> wasteCategories = <WasteCategory>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<TimeFilter> selectedTimeFilter = TimeFilter.allTime.obs;
  final RxBool isRefreshing = false.obs;

  // Chart category selection
  final Rx<WasteCategory?> selectedCategoryForChart = Rx<WasteCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadWasteCategories();
    _loadActivities();
  }

  /// Load waste categories from repository
  void _loadWasteCategories() {
    _categoryRepo.getWasteCategoriesStream().listen((categories) {
      wasteCategories.assignAll(categories);
    });
  }

  /// Load activities from repository using stream
  void _loadActivities() {
    try {
      isLoading.value = true;
      final userId = _authRepo.authUser?.uid;
      if (userId == null) {
        FLoaders.errorSnackBar(title: 'Error', message: 'User not authenticated');
        return;
      }

      _activityRepo.getUserApprovedActivitiesStream(userId).listen((activityList) {
        activities.assignAll(activityList);
        applyFilters();
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load activities: ${e.toString()}',
      );
    }
  }

  /// Refresh activities
  Future<void> refreshActivities() async {
    isRefreshing.value = true;
    // Stream will automatically update
    await Future.delayed(const Duration(milliseconds: 500));
    isRefreshing.value = false;
    FLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Activities list has been updated',
    );
  }

  /// Apply filters
  void applyFilters() {
    List<RecyclingActivity> filtered = List.from(activities);

    // Apply category filter from chart selection
    if (selectedCategoryForChart.value != null) {
      filtered = filtered
          .where((activity) =>
      activity.wasteCategoryId == selectedCategoryForChart.value!.categoryId)
          .toList();
    }

    // Apply time filter
    if (selectedTimeFilter.value != TimeFilter.allTime) {
      final now = DateTime.now();
      DateTime? filterStartDate;
      DateTime? filterEndDate;

      switch (selectedTimeFilter.value) {
        case TimeFilter.today:
          filterStartDate = DateTime(now.year, now.month, now.day);
          filterEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case TimeFilter.thisWeek:
          final weekday = now.weekday;
          filterStartDate = DateTime(now.year, now.month, now.day - weekday + 1);
          filterEndDate = DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
          break;
        case TimeFilter.thisMonth:
          filterStartDate = DateTime(now.year, now.month, 1);
          filterEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case TimeFilter.thisYear:
          filterStartDate = DateTime(now.year, 1, 1);
          filterEndDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        default:
          break;
      }

      if (filterStartDate != null && filterEndDate != null) {
        filtered = filtered.where((activity) {
          return activity.createdAt.isAfter(filterStartDate!) &&
              activity.createdAt.isBefore(filterEndDate!);
        }).toList();
      }
    }

    filteredActivities.assignAll(filtered);
  }

  /// Set time filter
  void setTimeFilter(TimeFilter filter) {
    selectedTimeFilter.value = filter;
    applyFilters();
  }

  /// Clear all filters
  void clearAllFilters() {
    selectedTimeFilter.value = TimeFilter.allTime;
    selectedCategoryForChart.value = null;
    applyFilters();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    selectedCategoryForChart.value = null;
    applyFilters();
  }

  /// Check if there are any active filters
  bool get hasActiveFilters {
    return selectedTimeFilter.value != TimeFilter.allTime ||
        selectedCategoryForChart.value != null;
  }

  /// Get total points earned
  int get totalPointsEarned {
    return filteredActivities.fold(0, (sum, activity) => sum + activity.pointsEarned);
  }

  /// Get total weight recycled
  double get totalWeightRecycled {
    return filteredActivities.fold(0.0, (sum, activity) => sum + activity.weight);
  }

  /// Get total CO2 reduced
  double get totalCO2Reduced {
    return totalWeightRecycled * 0.5;
  }

  /// Get waste category distribution for chart
  List<WasteCategory> getCategoryDistribution() {
    final categoryWeights = <String, double>{};

    for (final activity in activities) {
      categoryWeights[activity.wasteCategoryId] =
          (categoryWeights[activity.wasteCategoryId] ?? 0) + activity.weight;
    }

    return wasteCategories
        .where((category) => categoryWeights.containsKey(category.categoryId))
        .toList();
  }

  /// Get percentage for a specific category
  double getCategoryPercentage(WasteCategory category) {
    final totalWeight = activities.fold<double>(0, (sum, activity) => sum + activity.weight);
    final categoryWeight = activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold<double>(0, (sum, activity) => sum + activity.weight);

    return totalWeight > 0 ? (categoryWeight / totalWeight) * 100 : 0.0;
  }

  /// Select category for chart
  void selectCategoryForChart(WasteCategory category) {
    if (selectedCategoryForChart.value == category) {
      selectedCategoryForChart.value = null;
    } else {
      selectedCategoryForChart.value = category;
    }
    applyFilters();
  }

  /// Get category-specific points
  int getCategoryPoints(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0, (sum, activity) => sum + activity.pointsEarned);
  }

  /// Get category-specific weight
  double getCategoryWeight(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0.0, (sum, activity) => sum + activity.weight);
  }

  /// Get category-specific activity count
  int getCategoryActivityCount(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .length;
  }

  /// Get category-specific CO2 reduced
  double getCategoryCO2Reduced(WasteCategory category) {
    return getCategoryWeight(category) * 0.5;
  }

  /// Get waste category by ID
  WasteCategory getWasteCategoryById(String categoryId) {
    try {
      return wasteCategories.firstWhere(
            (category) => category.categoryId == categoryId,
      );
    } catch (e) {
      return WasteCategory.empty();
    }
  }

  /// Delete activity
  Future<void> deleteActivity(RecyclingActivity activity) async {
    try {
      if (!activity.canDelete) {
        FLoaders.warningSnackBar(
          title: 'Cannot Delete',
          message: 'Only pending or rejected activities can be deleted',
        );
        return;
      }

      isLoading.value = true;
      await _activityRepo.deleteActivity(activity.activityId);

      FLoaders.successSnackBar(
        title: 'Deleted',
        message: 'Activity has been deleted successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}