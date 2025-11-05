import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievement_enums.dart';
import 'achievement_level_model.dart';
import 'achievement_model.dart';

class UserAchievement {
  final String userAchievementId;
  final String userId;
  final int progress;
  final int currentLevel;
  final DateTime updatedAt;
  final Achievement achievement;

  UserAchievement({
    required this.userAchievementId,
    required this.userId,
    required this.progress,
    required this.currentLevel,
    required this.updatedAt,
    required this.achievement,
  });

  /// Empty UserAchievement
  static UserAchievement empty() {
    return UserAchievement(
      userAchievementId: '',
      userId: '',
      progress: 0,
      currentLevel: 0,
      updatedAt: DateTime(0),
      achievement: Achievement.empty(),
    );
  }

  /// Get next level information
  AchievementLevel? get nextLevel {
    if (achievement.achievementLevels.isEmpty) return null;

    // Find the next level (currentLevel + 1)
    return achievement.achievementLevels
        .where((level) => level.level == currentLevel + 1)
        .firstOrNull;
  }

  /// Get current level information (for displaying title and description)
  AchievementLevel? get currentLevelInfo {
    if (currentLevel == 0) {
      // If locked, return level 1 info for display
      return achievement.achievementLevels
          .where((level) => level.level == 1)
          .firstOrNull;
    }

    return achievement.achievementLevels
        .where((level) => level.level == currentLevel)
        .firstOrNull;
  }

  /// Get next level information for display
  AchievementLevel? get nextLevelInfo {
    if (isCompleted()) return null; // 如果已完成，没有下一个等级

    if (currentLevel == 0) {
      // 如果锁定，下一个等级就是等级1
      return achievement.achievementLevels
          .where((level) => level.level == 1)
          .firstOrNull;
    }

    // 返回当前等级的下一个等级
    return nextLevel;
  }

  /// Get display level information (用于显示的等级信息)
  /// 如果 currentLevel < maxLevel，显示下一个等级的信息；如果 currentLevel = maxLevel，显示当前等级的信息
  AchievementLevel? get displayLevelInfo {
    if (currentLevel < achievement.maxLevel) {
      return nextLevelInfo; // 未达到最大等级：显示下一个等级信息
    } else {
      return currentLevelInfo; // 已达到最大等级：显示当前等级信息
    }
  }

  /// Get achievement status
  AchievementStatus get status {
    if (currentLevel == 0) return AchievementStatus.locked;
    if (isCompleted()) return AchievementStatus.completed;
    return AchievementStatus.inProgress;
  }

  /// Get unlock criteria for current target
  int get targetCriteria {
    // If achievement is locked, target is level 1 criteria
    if (currentLevel == 0) {
      final firstLevel = achievement.achievementLevels
          .where((level) => level.level == 1)
          .firstOrNull;
      return firstLevel?.unlockCriteria ?? 0;
    }

    final next = nextLevel;
    if (next != null) return next.unlockCriteria;

    // If at max level, return max level criteria
    if (achievement.achievementLevels.isNotEmpty) {
      final maxLevel = achievement.achievementLevels
          .reduce((a, b) => a.level > b.level ? a : b);
      return maxLevel.unlockCriteria;
    }

    return 0;
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'userAchievementId': userAchievementId,
      'userId': userId,
      'progress': progress,
      'currentLevel': currentLevel,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'achievement': achievement.toJson(),
    };
  }

  /// From Snapshot
  factory UserAchievement.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return UserAchievement.empty();

    Timestamp getTimestamp(String fieldName) =>
        data[fieldName] ?? Timestamp.fromDate(DateTime(0));

    Map<String, dynamic> achievementData = data['achievement'] ?? {};
    Achievement achievementModel = Achievement.fromMap(achievementData);

    return UserAchievement(
      userAchievementId: document.id,
      userId: data['userId'] ?? '',
      progress: data['progress'] ?? 0,
      currentLevel: data['currentLevel'] ?? 0,
      updatedAt: getTimestamp('updatedAt').toDate(),
      achievement: achievementModel,
    );
  }

  /// CopyWith method
  UserAchievement copyWith({
    String? userAchievementId,
    String? userId,
    int? progress,
    int? currentLevel,
    DateTime? updatedAt,
    Achievement? achievement,
  }) {
    return UserAchievement(
      userAchievementId: userAchievementId ?? this.userAchievementId,
      userId: userId ?? this.userId,
      progress: progress ?? this.progress,
      currentLevel: currentLevel ?? this.currentLevel,
      updatedAt: updatedAt ?? this.updatedAt,
      achievement: achievement ?? this.achievement,
    );
  }

  /// Check if the user has completed this achievement
  bool isCompleted() {
    return currentLevel > 0 && currentLevel >= achievement.maxLevel;
  }

  /// Calculate progress percentage for current level
  double progressPercentage() {
    if (targetCriteria == 0) return 0;

    // If achievement is locked, calculate progress towards level 1
    if (currentLevel == 0) {
      final firstLevel = achievement.achievementLevels
          .where((level) => level.level == 1)
          .firstOrNull;
      if (firstLevel == null) return 0;

      final target = firstLevel.unlockCriteria;
      if (target == 0) return 0;

      return (progress / target).clamp(0.0, 1.0);
    }

    // Calculate progress from current level to next level
    final next = nextLevel;
    if (next == null) return 1.0; // Max level reached

    final currentLevelData = achievement.achievementLevels
        .where((level) => level.level == currentLevel)
        .firstOrNull;

    final previousCriteria = currentLevelData?.unlockCriteria ?? 0;
    final range = targetCriteria - previousCriteria;

    if (range == 0) return 1.0;

    final currentProgress = progress - previousCriteria;
    return (currentProgress / range).clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'UserAchievement(id: $userAchievementId, progress: $progress, currentLevel: $currentLevel, status: ${status.displayName})';
  }
}