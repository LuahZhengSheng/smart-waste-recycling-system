import 'dart:async';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/utils/constants/enums.dart';

import '../../../data/repositories/achievement/achievement_repostory.dart';
import '../../../data/repositories/achievement/user_achievement_repository.dart';
import '../models/achievement_enums.dart';
import '../models/user_achievement_model.dart';

class UserAchievementController extends GetxController {
  static UserAchievementController get instance => Get.find();

  final UserAchievementRepository _userAchievementRepo =
      Get.put(UserAchievementRepository());
  final AchievementRepository _achievementRepo =
      Get.put(AchievementRepository());
  final _authRepo = AuthenticationRepository.instance;

  // Observable data
  final RxList<UserAchievement> userAchievements = <UserAchievement>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Track level changes for animations
  final RxMap<String, int> previousLevels = <String, int>{}.obs;
  final RxMap<String, bool> levelUpAnimations = <String, bool>{}.obs;

  StreamSubscription? _achievementsSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchUserAchievements();
  }

  @override
  void onClose() {
    _achievementsSubscription?.cancel();
    super.onClose();
  }

  /// Fetch user achievements with real-time updates
  void fetchUserAchievements() {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authRepo.authUser?.uid;
      if (userId == null) {
        error.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      _achievementsSubscription?.cancel();
      _achievementsSubscription =
          _userAchievementRepo.getUserAchievementsStream(userId).listen(
        (achievements) {
          _handleAchievementsUpdate(achievements);
          isLoading.value = false;
        },
        onError: (e) {
          error.value = 'Failed to fetch achievements: $e';
          isLoading.value = false;
        },
      );
    } catch (e) {
      error.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  /// Handle achievements update and check for level changes
  void _handleAchievementsUpdate(List<UserAchievement> newAchievements) {
    for (final newAchievement in newAchievements) {
      final achievementId = newAchievement.achievement.achievementId;
      final newLevel = newAchievement.currentLevel;

      // Check if this is an existing achievement with a level change
      final oldAchievement = userAchievements.firstWhereOrNull(
        (a) => a.achievement.achievementId == achievementId,
      );

      if (oldAchievement != null) {
        final oldLevel = oldAchievement.currentLevel;

        // Level up detected
        if (newLevel > oldLevel) {
          previousLevels[achievementId] = oldLevel;
          levelUpAnimations[achievementId] = true;

          // Reset animation flag after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            levelUpAnimations[achievementId] = false;
          });
        }
      } else {
        // New achievement, store initial level
        previousLevels[achievementId] = newLevel;
      }
    }

    userAchievements.value = newAchievements;
  }

  /// Get achievements grouped by category
  Map<AchievementCategory, List<UserAchievement>> get achievementsByCategory {
    final Map<AchievementCategory, List<UserAchievement>> grouped = {};

    for (final userAchievement in userAchievements) {
      final category = AchievementCategory.fromString(
        userAchievement.achievement.category,
      );

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }

      grouped[category]!.add(userAchievement);
    }

    return grouped;
  }

  /// Get total completed achievements count
  int get completedCount =>
      userAchievements.where((achievement) => achievement.isCompleted()).length;

  /// Get total achievements count
  int get totalCount => userAchievements.length;

  /// Get overall completion percentage
  double get overallProgress {
    if (totalCount == 0) return 0;
    return completedCount / totalCount;
  }

  /// Get achievements by status
  List<UserAchievement> getAchievementsByStatus(AchievementStatus status) {
    return userAchievements
        .where((achievement) => achievement.status == status)
        .toList();
  }

  /// Check if achievement recently leveled up
  bool hasRecentLevelUp(String achievementId) {
    return levelUpAnimations[achievementId] ?? false;
  }

  /// Get previous level for achievement
  int? getPreviousLevel(String achievementId) {
    return previousLevels[achievementId];
  }

  /// Refresh achievements
  Future<void> refreshAchievements() async {
    fetchUserAchievements();
  }
}
