import 'package:get/get.dart';

import '../models/achievement_level_model.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';

class MyAchievementsController extends GetxController {
  static MyAchievementsController get instance => Get.find();

  // Observable list of user achievements
  var userAchievements = <UserAchievementModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserAchievements();
  }

  /// Fetch user achievements (mock data for now)
  Future<void> fetchUserAchievements() async {
    try {
      isLoading.value = true;

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      userAchievements.value = [
        UserAchievementModel(
          userAchievementId: '1',
          userId: 'user123',
          currentLevel: 1,
          progress: 17,
          updatedAt: DateTime.now(),
          achievement: AchievementModel(
            achievementId: 'ach1',
            title: 'Sort & Scan Waste 50 Times',
            category: 'Scanning',
            maxLevel: 3,
            createdAt: DateTime.now(),
            achievementLevels: [
              AchievementLevelModel(
                achievementLevelId: 'level1',
                level: 1,
                unlockCriteria: 50,
                description: 'Scan and sort waste 50 times to unlock this achievement.',
                badgeImage: '🔒',
              ),
            ],
          ),
        ),
        UserAchievementModel(
          userAchievementId: '2',
          userId: 'user123',
          currentLevel: 1,
          progress: 8,
          updatedAt: DateTime.now(),
          achievement: AchievementModel(
            achievementId: 'ach2',
            title: 'Recycle 20 Times',
            category: 'Recycling',
            maxLevel: 3,
            createdAt: DateTime.now(),
            achievementLevels: [
              AchievementLevelModel(
                achievementLevelId: 'level2',
                level: 1,
                unlockCriteria: 20,
                description: 'Recycle items 20 times to help save the environment.',
                badgeImage: '🏅',
              ),
            ],
          ),
        ),
        UserAchievementModel(
          userAchievementId: '3',
          userId: 'user123',
          currentLevel: 3,
          progress: 100,
          updatedAt: DateTime.now(),
          achievement: AchievementModel(
            achievementId: 'ach3',
            title: 'Eco Warrior',
            category: 'Special',
            maxLevel: 3,
            createdAt: DateTime.now(),
            achievementLevels: [
              AchievementLevelModel(
                achievementLevelId: 'level3',
                level: 3,
                unlockCriteria: 100,
                description: 'Complete all environmental challenges to become an Eco Warrior.',
                badgeImage: '🏆',
              ),
            ],
          ),
        ),
        UserAchievementModel(
          userAchievementId: '4',
          userId: 'user123',
          currentLevel: 0,
          progress: 5,
          updatedAt: DateTime.now(),
          achievement: AchievementModel(
            achievementId: 'ach4',
            title: 'Green Champion',
            category: 'Community',
            maxLevel: 3,
            createdAt: DateTime.now(),
            achievementLevels: [
              AchievementLevelModel(
                achievementLevelId: 'level4',
                level: 1,
                unlockCriteria: 20,
                description: 'Participate in 20 community green events.',
                badgeImage: '🌟',
              ),
            ],
          ),
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }

  /// Get total completed achievements
  int get completedCount => userAchievements
      .where((achievement) => achievement.isCompleted())
      .length;

  /// Get total achievements
  int get totalCount => userAchievements.length;

  /// Get progress percentage for overall achievements
  double get overallProgress {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }
}