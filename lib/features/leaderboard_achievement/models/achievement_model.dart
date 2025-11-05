import 'package:cloud_firestore/cloud_firestore.dart';

import 'achievement_level_model.dart';

class Achievement {
  final String achievementId;
  final String title;
  final String category;
  final int maxLevel;
  final DateTime createdAt;
  final List<AchievementLevel> achievementLevels;

  Achievement({
    required this.achievementId,
    required this.title,
    required this.category,
    required this.maxLevel,
    required this.createdAt,
    this.achievementLevels = const [],
  });

  /// Empty Achievement
  static Achievement empty() {
    return Achievement(
      achievementId: '',
      title: '',
      category: '',
      maxLevel: 0,
      createdAt: DateTime(0),
      achievementLevels: [],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'title': title,
      'category': category,
      'maxLevel': maxLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'achievementLevels': achievementLevels.map((level) => level.toJson()).toList(),
    };
  }

  /// From Snapshot
  factory Achievement.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return Achievement.empty();

    // 将 Timestamp 转换为 DateTime
    Timestamp getTimestamp(String fieldName) => data[fieldName] ?? Timestamp.fromDate(DateTime(0));

    // 处理 achievementLevels 数组
    List<dynamic> levelsData = data['achievementLevels'] ?? [];
    List<AchievementLevel> levelsList = levelsData.map((levelMap) => AchievementLevel.fromMap(levelMap)).toList();

    return Achievement(
      achievementId: document.id, // 从文档ID获取
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      maxLevel: data['maxLevel'] ?? 0,
      createdAt: getTimestamp('createdAt').toDate(),
      achievementLevels: levelsList,
    );
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    // 将 Timestamp 转换为 DateTime
    DateTime getDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime(0);
      } else {
        return DateTime(0);
      }
    }

    // 处理 achievementLevels 数组
    List<dynamic> levelsData = map['achievementLevels'] ?? [];
    List<AchievementLevel> levelsList = levelsData.map((levelMap) => AchievementLevel.fromMap(levelMap)).toList();

    return Achievement(
      achievementId: map['achievementId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      maxLevel: map['maxLevel'] ?? 0,
      createdAt: getDateTime(map['createdAt']),
      achievementLevels: levelsList,
    );
  }

  /// CopyWith method for easy updates
  Achievement copyWith({
    String? achievementId,
    String? title,
    String? category,
    int? maxLevel,
    DateTime? createdAt,
    List<AchievementLevel>? achievementLevels,
  }) {
    return Achievement(
      achievementId: achievementId ?? this.achievementId,
      title: title ?? this.title,
      category: category ?? this.category,
      maxLevel: maxLevel ?? this.maxLevel,
      createdAt: createdAt ?? this.createdAt,
      achievementLevels: achievementLevels ?? this.achievementLevels,
    );
  }
}