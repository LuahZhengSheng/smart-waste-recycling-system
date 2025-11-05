import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/helper_functions.dart';
import '../../../leaderboard_achievement/models/achievement_level_model.dart';
import '../../../leaderboard_achievement/models/achievement_model.dart';
import '../../screens/achievement_management/achievement_management_screen.dart';

class AchievementManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<Achievement> allAchievements = <Achievement>[].obs;
  final RxList<Achievement> filteredAchievements = <Achievement>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'category': null,
    'status': null,
    'maxLevelRange': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(), time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
  }

  void loadAchievements() {
    // Mock data - replace with actual API call
    allAchievements.value = _generateMockAchievements();
    filteredAchievements.value = List.from(allAchievements);
  }

  List<Achievement> _generateMockAchievements() {
    final now = DateTime.now();
    return [
      Achievement(
        achievementId: '1',
        title: 'Recycling Master',
        category: 'Recycling',
        maxLevel: 5,
        createdAt: now.subtract(const Duration(days: 60)),
        achievementLevels: [
          AchievementLevel(
            achievementLevelId: '1-1',
            level: 1,
            unlockCriteria: 10,
            description: 'Recycle 10 items',
            badgeImage: 'https://example.com/badge1.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '1-2',
            level: 2,
            unlockCriteria: 50,
            description: 'Recycle 50 items',
            badgeImage: 'https://example.com/badge2.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '1-3',
            level: 3,
            unlockCriteria: 100,
            description: 'Recycle 100 items',
            badgeImage: 'https://example.com/badge3.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '1-4',
            level: 4,
            unlockCriteria: 250,
            description: 'Recycle 250 items',
            badgeImage: 'https://example.com/badge4.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '1-5',
            level: 5,
            unlockCriteria: 500,
            description: 'Recycle 500 items',
            badgeImage: 'https://example.com/badge5.png',
            title: '',
          ),
        ],
      ),
      Achievement(
        achievementId: '2',
        title: 'Scanner Expert',
        category: 'Scanning',
        maxLevel: 3,
        createdAt: now.subtract(const Duration(days: 45)),
        achievementLevels: [
          AchievementLevel(
            achievementLevelId: '2-1',
            level: 1,
            unlockCriteria: 25,
            description: 'Scan 25 items successfully',
            badgeImage: 'https://example.com/scan-badge1.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '2-2',
            level: 2,
            unlockCriteria: 100,
            description: 'Scan 100 items successfully',
            badgeImage: 'https://example.com/scan-badge2.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '2-3',
            level: 3,
            unlockCriteria: 300,
            description: 'Scan 300 items successfully',
            badgeImage: 'https://example.com/scan-badge3.png',
            title: '',
          ),
        ],
      ),
      Achievement(
        achievementId: '3',
        title: 'Community Leader',
        category: 'Community',
        maxLevel: 4,
        createdAt: now.subtract(const Duration(days: 30)),
        achievementLevels: [
          AchievementLevel(
            achievementLevelId: '3-1',
            level: 1,
            unlockCriteria: 5,
            description: 'Create 5 community posts',
            badgeImage: 'https://example.com/community-badge1.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '3-2',
            level: 2,
            unlockCriteria: 15,
            description: 'Create 15 community posts',
            badgeImage: 'https://example.com/community-badge2.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '3-3',
            level: 3,
            unlockCriteria: 50,
            description: 'Create 50 community posts',
            badgeImage: 'https://example.com/community-badge3.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '3-4',
            level: 4,
            unlockCriteria: 100,
            description: 'Create 100 community posts',
            badgeImage: 'https://example.com/community-badge4.png',
            title: '',
          ),
        ],
      ),
      Achievement(
        achievementId: '4',
        title: 'Daily Streak Champion',
        category: 'Streak',
        maxLevel: 6,
        createdAt: now.subtract(const Duration(days: 75)),
        achievementLevels: [
          AchievementLevel(
            achievementLevelId: '4-1',
            level: 1,
            unlockCriteria: 7,
            description: 'Login for 7 consecutive days',
            badgeImage: 'https://example.com/streak-badge1.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '4-2',
            level: 2,
            unlockCriteria: 14,
            description: 'Login for 14 consecutive days',
            badgeImage: 'https://example.com/streak-badge2.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '4-3',
            level: 3,
            unlockCriteria: 30,
            description: 'Login for 30 consecutive days',
            badgeImage: 'https://example.com/streak-badge3.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '4-4',
            level: 4,
            unlockCriteria: 60,
            description: 'Login for 60 consecutive days',
            badgeImage: 'https://example.com/streak-badge4.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '4-5',
            level: 5,
            unlockCriteria: 90,
            description: 'Login for 90 consecutive days',
            badgeImage: 'https://example.com/streak-badge5.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '4-6',
            level: 6,
            unlockCriteria: 180,
            description: 'Login for 180 consecutive days',
            badgeImage: 'https://example.com/streak-badge6.png',
            title: '',
          ),
        ],
      ),
      Achievement(
        achievementId: '5',
        title: 'Environmental Hero',
        category: 'Environmental',
        maxLevel: 3,
        createdAt: now.subtract(const Duration(days: 90)),
        achievementLevels: [
          AchievementLevel(
            achievementLevelId: '5-1',
            level: 1,
            unlockCriteria: 1000,
            description: 'Save 1kg of CO2 through recycling',
            badgeImage: 'https://example.com/env-badge1.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '5-2',
            level: 2,
            unlockCriteria: 5000,
            description: 'Save 5kg of CO2 through recycling',
            badgeImage: 'https://example.com/env-badge2.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '5-3',
            level: 3,
            unlockCriteria: 10000,
            description: 'Save 10kg of CO2 through recycling',
            badgeImage: 'https://example.com/env-badge3.png',
            title: '',
          ),
        ],
      ),
      Achievement(
        achievementId: '6',
        title: 'Waste Sorting Pro (Inactive)',
        category: 'Scanning',
        maxLevel: 4,
        createdAt: now.subtract(const Duration(days: 120)),
        achievementLevels: [
          AchievementLevel(
            achievementLevelId: '6-1',
            level: 1,
            unlockCriteria: 20,
            description: 'Correctly sort 20 waste items',
            badgeImage: 'https://example.com/sort-badge1.png',
            title: '',
          ),
          AchievementLevel(
            achievementLevelId: '6-2',
            level: 2,
            unlockCriteria: 75,
            description: 'Correctly sort 75 waste items',
            badgeImage: 'https://example.com/sort-badge2.png',
            title: '',
          ),
        ],
      ),
    ];
  }

  // Get achievement status - by default achievements are active unless specified otherwise
  String getAchievementStatus(Achievement achievement) {
    // For demo purposes, achievements with "(Inactive)" in title are considered inactive
    if (achievement.title.toLowerCase().contains('inactive')) {
      return 'inactive';
    }
    return 'active';
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<Achievement> result = List.from(allAchievements);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((achievement) {
        return achievement.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            achievement.category.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            achievement.maxLevel.toString().contains(searchQuery.value);
      }).toList();
    }

    // Apply filters
    if (activeFilters['category'] != null) {
      result = result.where((achievement) =>
      achievement.category == activeFilters['category']).toList();
    }

    if (activeFilters['status'] != null) {
      result = result.where((achievement) =>
      getAchievementStatus(achievement) == activeFilters['status']).toList();
    }

    if (activeFilters['maxLevelRange'] != null) {
      result = result.where((achievement) {
        switch (activeFilters['maxLevelRange']) {
          case 'low':
            return achievement.maxLevel >= 1 && achievement.maxLevel <= 3;
          case 'medium':
            return achievement.maxLevel >= 4 && achievement.maxLevel <= 6;
          case 'high':
            return achievement.maxLevel >= 7;
          default:
            return true;
        }
      }).toList();
    }

    filteredAchievements.value = result;
    currentPage.value = 1; // Reset to first page after filtering
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['category'] != null ||
        activeFilters['status'] != null ||
        activeFilters['maxLevelRange'] != null;
  }

  // Sorting functionality
  void sortAchievements(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredAchievements.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Title
          aValue = a.title;
          bValue = b.title;
          break;
        case 1: // Category
          aValue = a.category;
          bValue = b.category;
          break;
        case 2: // Max Level
          aValue = a.maxLevel;
          bValue = b.maxLevel;
          break;
        case 3: // Total Levels
          aValue = a.achievementLevels.length;
          bValue = b.achievementLevels.length;
          break;
        case 4: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 5: // Status
          aValue = getAchievementStatus(a);
          bValue = getAchievementStatus(b);
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  // Achievement actions
  void toggleAchievementStatus(Achievement achievement) {
    final currentStatus = getAchievementStatus(achievement);

    if (currentStatus == 'active') {
      _deactivateAchievement(achievement);
    } else {
      _activateAchievement(achievement);
    }
  }

  void _activateAchievement(Achievement achievement) {
    // In a real app, you would update the achievement status in the database
    // For demo purposes, we'll modify the title to remove "(Inactive)"
    final achievementIndex = allAchievements.indexWhere((a) => a.achievementId == achievement.achievementId);
    if (achievementIndex != -1) {
      final updatedTitle = achievement.title.replaceAll(' (Inactive)', '');
      allAchievements[achievementIndex] = achievement.copyWith(title: updatedTitle);
      applyFiltersAndSearch();
      FHelperFunctions.showSnackBar('Achievement activated successfully');
    }
  }

  void _deactivateAchievement(Achievement achievement) {
    // In a real app, you would update the achievement status in the database
    // For demo purposes, we'll modify the title to add "(Inactive)"
    final achievementIndex = allAchievements.indexWhere((a) => a.achievementId == achievement.achievementId);
    if (achievementIndex != -1) {
      final updatedTitle = '${achievement.title} (Inactive)';
      allAchievements[achievementIndex] = achievement.copyWith(title: updatedTitle);
      applyFiltersAndSearch();
      FHelperFunctions.showSnackBar('Achievement deactivated successfully');
    }
  }

  void viewAchievement(Achievement achievement) {
    // Navigate to view achievement detail screen
    // This would show the achievement levels and other details
    FHelperFunctions.showSnackBar('View Achievement: ${achievement.title}');
    // TODO: Implement navigation to achievement detail screen
    print('View achievement: ${achievement.title}');
  }

  void editAchievement(Achievement achievement) {
    // Navigate to edit achievement screen
    FHelperFunctions.showSnackBar('Edit Achievement: ${achievement.title}');
    // TODO: Implement navigation to edit achievement screen
    print('Edit achievement: ${achievement.title}');
  }

  // Pagination functionality
  List<Achievement> get paginatedAchievements {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredAchievements.length);

    if (startIndex >= filteredAchievements.length) {
      return [];
    }

    return filteredAchievements.sublist(startIndex, endIndex);
  }

  int get totalAchievements => filteredAchievements.length;
  int get totalPages => (totalAchievements / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalAchievements);

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
      currentPage.value = 1; // Reset to first page
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      AchievementFilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}