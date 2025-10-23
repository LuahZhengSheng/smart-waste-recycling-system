import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievement_model.dart';

class UserAchievementModel {
  final String userAchievementId;
  final String userId;
  final int currentLevel;
  final int progress;
  final DateTime updatedAt;
  final AchievementModel achievement;

  UserAchievementModel({
    required this.userAchievementId,
    required this.userId,
    required this.currentLevel,
    required this.progress,
    required this.updatedAt,
    required this.achievement,
  });

  /// Empty UserAchievement
  static UserAchievementModel empty() {
    return UserAchievementModel(
      userAchievementId: '',
      userId: '',
      currentLevel: 0,
      progress: 0,
      updatedAt: DateTime(0),
      achievement: AchievementModel.empty(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'userAchievementId': userAchievementId,
      'userId': userId,
      'currentLevel': currentLevel,
      'progress': progress,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'achievement': achievement.toJson(),
    };
  }

  /// From Snapshot
  factory UserAchievementModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return UserAchievementModel.empty();

    // 将 Timestamp 转换为 DateTime
    Timestamp getTimestamp(String fieldName) => data[fieldName] ?? Timestamp.fromDate(DateTime(0));

    // 处理 achievement 对象
    Map<String, dynamic> achievementData = data['achievement'] ?? {};
    AchievementModel achievementModel = AchievementModel.fromMap(achievementData);

    return UserAchievementModel(
      userAchievementId: document.id, // 从文档ID获取
      userId: data['userId'] ?? '',
      currentLevel: data['currentLevel'] ?? 0,
      progress: data['progress'] ?? 0,
      updatedAt: getTimestamp('updatedAt').toDate(),
      achievement: achievementModel,
    );
  }

  /// CopyWith method for easy updates
  UserAchievementModel copyWith({
    String? userAchievementId,
    String? userId,
    int? currentLevel,
    int? progress,
    DateTime? updatedAt,
    AchievementModel? achievement,
  }) {
    return UserAchievementModel(
      userAchievementId: userAchievementId ?? this.userAchievementId,
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      progress: progress ?? this.progress,
      updatedAt: updatedAt ?? this.updatedAt,
      achievement: achievement ?? this.achievement,
    );
  }

  /// Check if the user has completed this achievement
  bool isCompleted() => currentLevel >= achievement.maxLevel;

  /// Calculate current progress percentage
  double progressPercentage() {
    if (achievement.maxLevel == 0) return 0;
    return (progress / achievement.maxLevel).clamp(0, 1).toDouble();
  }
}