import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementLevel {
  final String achievementLevelId;
  final int level;
  final int unlockCriteria;
  final String title;  // 新增：该等级的称号
  final String description;
  final String badgeImage;

  AchievementLevel({
    required this.achievementLevelId,
    required this.level,
    required this.unlockCriteria,
    required this.title,
    required this.description,
    required this.badgeImage,
  });

  /// Empty AchievementLevel
  static AchievementLevel empty() {
    return AchievementLevel(
      achievementLevelId: '',
      level: 0,
      unlockCriteria: 0,
      title: '',
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
      'title': title,
      'description': description,
      'badgeImage': badgeImage,
    };
  }

  /// From Snapshot
  factory AchievementLevel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return AchievementLevel.empty();

    return AchievementLevel(
      achievementLevelId: document.id,
      level: data['level'] ?? 0,
      unlockCriteria: data['unlockCriteria'] ?? 0,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      badgeImage: data['badgeImage'] ?? '',
    );
  }

  /// From Map
  factory AchievementLevel.fromMap(Map<String, dynamic> map) {
    return AchievementLevel(
      achievementLevelId: map['achievementLevelId'] ?? '',
      level: map['level'] ?? 0,
      unlockCriteria: map['unlockCriteria'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      badgeImage: map['badgeImage'] ?? '',
    );
  }

  /// CopyWith method
  AchievementLevel copyWith({
    String? achievementLevelId,
    int? level,
    int? unlockCriteria,
    String? title,
    String? description,
    String? badgeImage,
  }) {
    return AchievementLevel(
      achievementLevelId: achievementLevelId ?? this.achievementLevelId,
      level: level ?? this.level,
      unlockCriteria: unlockCriteria ?? this.unlockCriteria,
      title: title ?? this.title,
      description: description ?? this.description,
      badgeImage: badgeImage ?? this.badgeImage,
    );
  }

  @override
  String toString() {
    return 'AchievementLevel(id: $achievementLevelId, level: $level, unlockCriteria: $unlockCriteria, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AchievementLevel &&
            other.achievementLevelId == achievementLevelId);
  }

  @override
  int get hashCode => achievementLevelId.hashCode;
}