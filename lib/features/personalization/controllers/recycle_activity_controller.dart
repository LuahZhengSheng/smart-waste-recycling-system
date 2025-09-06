import 'package:fyp/features/personalization/controllers/activity_detail_controller.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/personalization/screens/recycle_activity/activity_detail.dart';
import 'package:fyp/features/recycling_center/models/waste_category.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RecycleActivityController extends GetxController {
  static RecycleActivityController get instance => Get.find();

  // Observable variables
  final RxList<RecyclingActivity> activities = <RecyclingActivity>[].obs;
  final RxList<RecyclingActivity> filteredActivities = <RecyclingActivity>[].obs;
  final RxList<WasteCategory> wasteCategories = <WasteCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedDateFilter = 'All Time'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString selectedStatusFilter = 'All'.obs;
  final RxBool isRefreshing = false.obs;

  // New observable for chart category selection
  final Rx<WasteCategory?> selectedCategoryForChart = Rx<WasteCategory?>(null);

  // Firebase instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String currentUserId = 'current_user_id'; // Replace with actual user ID from auth

  // Date filter options
  final List<String> dateFilterOptions = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'Custom Range'
  ];

  // Status filter options
  final List<String> statusFilterOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Completed'
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeMockData();
  }

  /// Initialize mock data for testing
  void _initializeMockData() {
    // Mock waste categories
    wasteCategories.assignAll([
      WasteCategory(
        categoryId: '1',
        name: 'Plastic',
        description: 'Plastic bottles, containers, and packaging materials',
        disposalMethod: 'Clean and sort by type for recycling',
        icon: Iconsax.box,
        color: Colors.blue,
        basePoints: 10.0,
        examples: ['Plastic bottles', 'Food containers', 'Shopping bags'],
        isRecyclable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      WasteCategory(
        categoryId: '2',
        name: 'Paper',
        description: 'Newspapers, cardboard, office paper',
        disposalMethod: 'Remove staples and sort by type',
        icon: Iconsax.document,
        color: Colors.brown,
        basePoints: 8.0,
        examples: ['Newspapers', 'Cardboard', 'Office paper'],
        isRecyclable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      WasteCategory(
        categoryId: '3',
        name: 'Glass',
        description: 'Glass bottles and jars',
        disposalMethod: 'Clean and sort by color',
        icon: Iconsax.glass,
        color: Colors.green,
        basePoints: 12.0,
        examples: ['Glass bottles', 'Jars', 'Windows'],
        isRecyclable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      WasteCategory(
        categoryId: '4',
        name: 'Metal',
        description: 'Aluminum cans and metal containers',
        disposalMethod: 'Clean and crush if possible',
        icon: Iconsax.setting_2,
        color: Colors.grey,
        basePoints: 15.0,
        examples: ['Aluminum cans', 'Steel cans', 'Metal containers'],
        isRecyclable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      WasteCategory(
        categoryId: '5',
        name: 'Electronics',
        description: 'Electronic devices and components',
        disposalMethod: 'Take to specialized e-waste facility',
        icon: Iconsax.mobile,
        color: Colors.purple,
        basePoints: 25.0,
        examples: ['Mobile phones', 'Computers', 'Batteries'],
        isRecyclable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ]);

    // Mock recycling activities
    activities.assignAll([
      RecyclingActivity(
        activityId: '1',
        userId: currentUserId,
        centerId: 'center1',
        wasteObject: 'Plastic bottles',
        wasteCategoryId: '1',
        weight: 2.5,
        supportImage: 'image1.jpg',
        pointsEarned: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'approved',
      ),
      RecyclingActivity(
        activityId: '2',
        userId: currentUserId,
        centerId: 'center1',
        wasteObject: 'Cardboard boxes',
        wasteCategoryId: '2',
        weight: 5.0,
        supportImage: 'image2.jpg',
        pointsEarned: 40,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: 'completed',
      ),
      RecyclingActivity(
        activityId: '3',
        userId: currentUserId,
        centerId: 'center2',
        wasteObject: 'Glass bottles',
        wasteCategoryId: '3',
        weight: 1.8,
        supportImage: 'image3.jpg',
        pointsEarned: 22,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'approved',
      ),
      RecyclingActivity(
        activityId: '4',
        userId: currentUserId,
        centerId: 'center1',
        wasteObject: 'Aluminum cans',
        wasteCategoryId: '4',
        weight: 0.8,
        supportImage: 'image4.jpg',
        pointsEarned: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: 'completed',
      ),
      RecyclingActivity(
        activityId: '5',
        userId: currentUserId,
        centerId: 'center3',
        wasteObject: 'Old smartphone',
        wasteCategoryId: '5',
        weight: 0.2,
        supportImage: 'image5.jpg',
        pointsEarned: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        status: 'pending',
      ),
      RecyclingActivity(
        activityId: '6',
        userId: currentUserId,
        centerId: 'center1',
        wasteObject: 'Food containers',
        wasteCategoryId: '1',
        weight: 3.2,
        supportImage: 'image6.jpg',
        pointsEarned: 32,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        status: 'approved',
      ),
      RecyclingActivity(
        activityId: '7',
        userId: currentUserId,
        centerId: 'center2',
        wasteObject: 'Newspapers',
        wasteCategoryId: '2',
        weight: 4.5,
        supportImage: 'image7.jpg',
        pointsEarned: 36,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        status: 'completed',
      ),
      RecyclingActivity(
        activityId: '8',
        userId: currentUserId,
        centerId: 'center1',
        wasteObject: 'Wine bottles',
        wasteCategoryId: '3',
        weight: 2.1,
        supportImage: 'image8.jpg',
        pointsEarned: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        status: 'approved',
      ),
    ]);

    applyFilters();
  }

  /// Fetch recycling activities from Firebase (replaced with mock data)
  Future<void> fetchRecyclingActivities() async {
    try {
      isLoading.value = true;

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data is already initialized in onInit()
      applyFilters();
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load recycling activities: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh the activities list
  Future<void> refreshActivities() async {
    isRefreshing.value = true;
    await fetchRecyclingActivities();
    isRefreshing.value = false;
    FLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Activities list has been updated',
    );
  }

  /// Apply date and status filters
  void applyFilters() {
    List<RecyclingActivity> filtered = List.from(activities);

    // Apply category filter from chart selection
    if (selectedCategoryForChart.value != null) {
      filtered = filtered.where((activity) =>
      activity.wasteCategoryId == selectedCategoryForChart.value!.categoryId).toList();
    }

    // Apply date filter
    if (selectedDateFilter.value != 'All Time') {
      final now = DateTime.now();
      DateTime? filterStartDate;
      DateTime? filterEndDate;

      switch (selectedDateFilter.value) {
        case 'Today':
          filterStartDate = DateTime(now.year, now.month, now.day);
          filterEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'This Week':
          final weekday = now.weekday;
          filterStartDate = DateTime(now.year, now.month, now.day - weekday + 1);
          filterEndDate = DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
          break;
        case 'This Month':
          filterStartDate = DateTime(now.year, now.month, 1);
          filterEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'Custom Range':
          filterStartDate = startDate.value;
          filterEndDate = endDate.value;
          break;
      }

      if (filterStartDate != null && filterEndDate != null) {
        filtered = filtered.where((activity) {
          return activity.createdAt.isAfter(filterStartDate!) &&
              activity.createdAt.isBefore(filterEndDate!);
        }).toList();
      }
    }

    // Apply status filter
    if (selectedStatusFilter.value != 'All') {
      final statusToFilter = selectedStatusFilter.value.toLowerCase();
      filtered = filtered.where((activity) {
        return activity.status.toLowerCase() == statusToFilter;
      }).toList();
    }

    filteredActivities.assignAll(filtered);
  }

  /// Set date filter
  void setDateFilter(String filter) {
    selectedDateFilter.value = filter;
    applyFilters();
  }

  /// Set status filter
  void setStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
    applyFilters();
  }

  /// Set custom date range
  void setCustomDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    if (start != null && end != null) {
      selectedDateFilter.value = 'Custom Range';
      applyFilters();
    }
  }

  /// Clear all filters
  void clearFilters() {
    selectedDateFilter.value = 'All Time';
    selectedStatusFilter.value = 'All';
    startDate.value = null;
    endDate.value = null;
    applyFilters();
  }

  /// Clear all filters including category filter
  void clearAllFilters() {
    clearFilters();
    selectedCategoryForChart.value = null;
    applyFilters();
  }

  /// Clear only category filter
  void clearCategoryFilter() {
    selectedCategoryForChart.value = null;
    applyFilters();
  }

  /// Check if there are any active filters
  bool get hasActiveFilters {
    return selectedDateFilter.value != 'All Time' ||
        selectedStatusFilter.value != 'All' ||
        selectedCategoryForChart.value != null;
  }

  /// Navigate to activity detail
  // void navigateToActivityDetail(RecyclingActivity activity) {
  //   Get.toNamed('/recycle-activity-detail', arguments: activity);
  // }

  // void navigateToActivityDetail(RecyclingActivity activity) {
  //   Get.to(() {
  //     // 创建controller并传入activity
  //     final controller = Get.put(ActivityDetailController(activity));
  //     return ActivityDetailScreen(controller: controller);
  //   },);
  // }

  /// Get total points earned
  int get totalPointsEarned {
    return filteredActivities.fold(0, (sum, activity) => sum + activity.pointsEarned);
  }

  /// Get total weight recycled
  double get totalWeightRecycled {
    return filteredActivities.fold(0.0, (sum, activity) => sum + activity.weight);
  }

  /// Get total CO2 reduced (mock calculation: 0.5 kg CO2 per kg waste)
  double get totalCO2Reduced {
    return totalWeightRecycled * 0.5;
  }

  /// Get activities count by status
  Map<String, int> get activitiesCountByStatus {
    final counts = <String, int>{};
    for (final activity in filteredActivities) {
      counts[activity.status] = (counts[activity.status] ?? 0) + 1;
    }
    return counts;
  }

  /// Get most recycled waste type
  String get mostRecycledWasteType {
    if (filteredActivities.isEmpty) return 'None';

    final wasteObjectCounts = <String, int>{};
    for (final activity in filteredActivities) {
      wasteObjectCounts[activity.wasteObject] =
          (wasteObjectCounts[activity.wasteObject] ?? 0) + 1;
    }

    return wasteObjectCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get waste category distribution for chart
  List<WasteCategory> getCategoryDistribution() {
    final categoryWeights = <String, double>{};

    for (final activity in activities) {
      categoryWeights[activity.wasteCategoryId] =
          (categoryWeights[activity.wasteCategoryId] ?? 0) + activity.weight;
    }

    return wasteCategories.where((category) =>
        categoryWeights.containsKey(category.categoryId)).toList();
  }

  /// Get percentage for a specific category
  double getCategoryPercentage(WasteCategory category) {
    final totalWeight = activities.fold<double>(0, (sum, activity) => sum + activity.weight);
    final categoryWeight = activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold<double>(0, (sum, activity) => sum + activity.weight);

    return totalWeight > 0 ? (categoryWeight / totalWeight) * 100 : 0.0;
  }

  /// Select category for chart (and apply filter)
  void selectCategoryForChart(WasteCategory category) {
    if (selectedCategoryForChart.value == category) {
      selectedCategoryForChart.value = null;
    } else {
      selectedCategoryForChart.value = category;
    }
    applyFilters();
  }

  /// Get category-specific statistics
  int getCategoryPoints(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0, (sum, activity) => sum + activity.pointsEarned);
  }

  double getCategoryWeight(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .fold(0.0, (sum, activity) => sum + activity.weight);
  }

  int getCategoryActivityCount(WasteCategory category) {
    return activities
        .where((activity) => activity.wasteCategoryId == category.categoryId)
        .length;
  }

  double getCategoryCO2Reduced(WasteCategory category) {
    return getCategoryWeight(category) * 0.5; // Mock calculation
  }

  /// Get waste category by ID
  WasteCategory getWasteCategoryById(String categoryId) {
    return wasteCategories.firstWhere(
          (category) => category.categoryId == categoryId,
      orElse: () => WasteCategory.empty(),
    );
  }

  /// Delete activity (only if pending or rejected)
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

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from local list (in real implementation, would delete from Firebase)
      activities.removeWhere((item) => item.activityId == activity.activityId);
      applyFilters();

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

  /// Get waste type from activity (for backward compatibility)
  String get wasteType {
    return selectedCategoryForChart.value?.name ?? 'All Types';
  }
}