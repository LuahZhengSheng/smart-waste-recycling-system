import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementLevelModel {
  final String achievementLevelId;
  final int level;
  final int unlockCriteria;
  final String description;
  final String badgeImage;

  AchievementLevelModel({
    required this.achievementLevelId,
    required this.level,
    required this.unlockCriteria,
    required this.description,
    required this.badgeImage,
  });

  /// Empty AchievementLevel
  static AchievementLevelModel empty() {
    return AchievementLevelModel(
      achievementLevelId: '',
      level: 0,
      unlockCriteria: 0,
      description: '',
      badgeImage: '',
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'achievementLevelId': achievementLevelId,
      'level': level,
      'unlockCriteria': unlockCriteria,
      'description': description,
      'badgeImage': badgeImage,
    };
  }

  /// From Snapshot
  factory AchievementLevelModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return AchievementLevelModel.empty();

    return AchievementLevelModel(
      achievementLevelId: document.id, // 从文档ID获取
      level: data['level'] ?? 0,
      unlockCriteria: data['unlockCriteria'] ?? 0,
      description: data['description'] ?? '',
      badgeImage: data['badgeImage'] ?? '',
    );
  }

  /// From Map (保持原有功能)
  factory AchievementLevelModel.fromMap(Map<String, dynamic> map) {
    return AchievementLevelModel(
      achievementLevelId: map['achievementLevelId'] ?? '',
      level: map['level'] ?? 0,
      unlockCriteria: map['unlockCriteria'] ?? 0,
      description: map['description'] ?? '',
      badgeImage: map['badgeImage'] ?? '',
    );
  }

  /// CopyWith method for easy updates
  AchievementLevelModel copyWith({
    String? achievementLevelId,
    int? level,
    int? unlockCriteria,
    String? description,
    String? badgeImage,
  }) {
    return AchievementLevelModel(
      achievementLevelId: achievementLevelId ?? this.achievementLevelId,
      level: level ?? this.level,
      unlockCriteria: unlockCriteria ?? this.unlockCriteria,
      description: description ?? this.description,
      badgeImage: badgeImage ?? this.badgeImage,
    );
  }

  @override
  String toString() {
    return 'AchievementLevelModel(id: $achievementLevelId, level: $level, unlockCriteria: $unlockCriteria, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AchievementLevelModel &&
            other.achievementLevelId == achievementLevelId);
  }

  @override
  int get hashCode => achievementLevelId.hashCode;
}