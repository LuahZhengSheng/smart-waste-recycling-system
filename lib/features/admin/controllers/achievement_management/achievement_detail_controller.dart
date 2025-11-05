import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../authentication/models/user_model.dart';
import '../../../leaderboard_achievement/models/achievement_level_model.dart';
import '../../../leaderboard_achievement/models/achievement_model.dart';
import '../../../leaderboard_achievement/models/user_achievement_model.dart';
import '../../../../utils/helpers/helper_functions.dart';

class AchievementDetailsController extends GetxController {
  // Observables
  final RxBool isLoading = false.obs;
  final Rx<Achievement?> achievement = Rx<Achievement?>(null);
  final RxList<UserAchievement> userAchievements = <UserAchievement>[].obs;
  final RxMap<int, List<UserModel>> levelUsers = <int, List<UserModel>>{}.obs;
  final RxMap<int, int> levelUserCounts = <int, int>{}.obs;
  final RxInt totalUsersWithAchievement = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Achievement) {
      loadAchievementDetails(args);
    }
  }

  void loadAchievementDetails(Achievement achievementModel) async {
    try {
      isLoading.value = true;
      achievement.value = achievementModel;

      // Load user achievement data
      await loadUserAchievementData();

      // Calculate level statistics
      calculateLevelStatistics();

    } catch (e) {
      FHelperFunctions.showAlert('Error', 'Failed to load achievement details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserAchievementData() async {
    // Mock API call - replace with actual API
    await Future.delayed(const Duration(milliseconds: 800));

    userAchievements.value = _generateMockUserAchievements();
  }

  List<UserAchievement> _generateMockUserAchievements() {
    final now = DateTime.now();
    final achievementModel = achievement.value!;

    // Generate mock users with different achievement levels
    List<UserAchievement> mockData = [];

    // Simulate different completion rates for each level
    for (int level = 1; level <= achievementModel.maxLevel; level++) {
      int userCountForLevel = _calculateUserCountForLevel(level, achievementModel.maxLevel);

      for (int i = 0; i < userCountForLevel; i++) {
        final user = _generateMockUser(i, level);
        mockData.add(UserAchievement(
          userAchievementId: 'ua_${achievementModel.achievementId}_${level}_$i',
          progress: _calculateProgressForLevel(level, achievementModel),
          updatedAt: now.subtract(Duration(days: i + (level * 5))),
          achievement: achievementModel, userId: '',
          currentLevel: 1,
        ));
      }
    }

    return mockData;
  }

  UserModel _generateMockUser(int index, int level) {
    final names = [
      'Alice Johnson', 'Bob Smith', 'Charlie Brown', 'Diana Prince',
      'Ethan Hunt', 'Fiona Green', 'George Wilson', 'Hannah Lee',
      'Ivan Petrov', 'Julia Roberts', 'Kevin Hart', 'Luna Park',
      'Michael Chen', 'Nancy Drew', 'Oliver Stone', 'Penny Lane',
      'Quinn Taylor', 'Rachel Green', 'Sam Wilson', 'Tina Turner'
    ];

    final avatars = [
      'https://randomuser.me/api/portraits/women/1.jpg',
      'https://randomuser.me/api/portraits/men/1.jpg',
      'https://randomuser.me/api/portraits/women/2.jpg',
      'https://randomuser.me/api/portraits/men/2.jpg',
      'https://randomuser.me/api/portraits/women/3.jpg',
      'https://randomuser.me/api/portraits/men/3.jpg',
    ];

    final nameIndex = (index + level) % names.length;
    final avatarIndex = (index + level) % avatars.length;

    return UserModel(
      userId: 'user_${index}_${level}',
      username: names[nameIndex],
      email: '${names[nameIndex].toLowerCase().replaceAll(' ', '.')}@example.com',
      profileImg: avatars[avatarIndex],
      loginAttemptCount: 0,
      role: 'user',
      isVerified: true,
      isActive: true,
      joinDate: DateTime.now().subtract(Duration(days: 30 + index)),
      rewardPoint: 100 + (level * 50) + (index * 10),
    );
  }

  int _calculateUserCountForLevel(int level, int maxLevel) {
    // Simulate decreasing number of users as levels increase
    final baseCount = 100;
    final dropoffRate = 0.6;
    return (baseCount * (dropoffRate * (maxLevel - level + 1))).round();
  }

  int _calculateProgressForLevel(int level, Achievement achievement) {
    final levelData = achievement.achievementLevels
        .firstWhereOrNull((l) => l.level == level);
    return levelData?.unlockCriteria ?? 0;
  }

  void calculateLevelStatistics() {
    levelUsers.clear();
    levelUserCounts.clear();

    // Group users by achievement level
    for (var userAchievement in userAchievements) {
      final level = userAchievement.currentLevel;

      if (!levelUsers.containsKey(level)) {
        levelUsers[level] = [];
      }

      // Create a mock user for this achievement
      final user = _generateMockUser(levelUsers[level]!.length, level);
      levelUsers[level]!.add(user);
    }

    // Calculate counts for each level
    for (var level in levelUsers.keys) {
      levelUserCounts[level] = levelUsers[level]!.length;
    }

    totalUsersWithAchievement.value = userAchievements.length;
  }

  double getLevelCompletionPercentage(int level) {
    if (totalUsersWithAchievement.value == 0) return 0.0;

    final levelCount = levelUserCounts[level] ?? 0;
    return levelCount / totalUsersWithAchievement.value;
  }

  List<UserModel> getUsersForLevel(int level) {
    return levelUsers[level] ?? [];
  }

  int getUserCountForLevel(int level) {
    return levelUserCounts[level] ?? 0;
  }

  String getAchievementStatus() {
    final achievementModel = achievement.value;
    if (achievementModel == null) return 'unknown';

    // Check if achievement is active (doesn't contain "Inactive" in title)
    if (achievementModel.title.toLowerCase().contains('inactive')) {
      return 'inactive';
    }
    return 'active';
  }

  Color getStatusColor(bool dark) {
    final status = getAchievementStatus();
    switch (status) {
      case 'active':
        return dark ? const Color(0xFF4FD69C) : const Color(0xFF2DCE89);
      case 'inactive':
        return dark ? const Color(0xFF64748B) : const Color(0xFF8898AA);
      default:
        return dark ? const Color(0xFF94A3B8) : const Color(0xFFADB5BD);
    }
  }

  void refreshData() {
    if (achievement.value != null) {
      loadAchievementDetails(achievement.value!);
    }
  }

  void editAchievement() {
    // Navigate to edit screen
    FHelperFunctions.showSnackBar('Navigate to edit achievement: ${achievement.value?.title}');
    // TODO: Implement navigation to edit screen
  }

  void toggleAchievementStatus() {
    final achievementModel = achievement.value;
    if (achievementModel == null) return;

    final currentStatus = getAchievementStatus();
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: Text('${newStatus == 'active' ? 'Activate' : 'Deactivate'} Achievement'),
        content: Text(
          newStatus == 'active'
              ? 'Are you sure you want to activate "${achievementModel.title}"?'
              : 'Are you sure you want to deactivate "${achievementModel.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update achievement status
              _updateAchievementStatus(newStatus);
              Get.back();
            },
            child: Text(newStatus == 'active' ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }

  void _updateAchievementStatus(String newStatus) {
    // In a real app, this would make an API call
    final achievementModel = achievement.value!;
    String newTitle = achievementModel.title;

    if (newStatus == 'active') {
      newTitle = newTitle.replaceAll(' (Inactive)', '');
    } else {
      newTitle = '$newTitle (Inactive)';
    }

    achievement.value = achievementModel.copyWith(title: newTitle);

    FHelperFunctions.showSnackBar(
      'Achievement ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully',
    );
  }
}