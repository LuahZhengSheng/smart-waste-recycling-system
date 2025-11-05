import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/leaderboard_achievement/models/achievement_level_model.dart';
import '../../../features/leaderboard_achievement/models/achievement_model.dart';


class AchievementRepository extends GetxController {
  static AchievementRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _achievementsCollection = 'achievements';

  /// Get all achievements stream
  Stream<List<Achievement>> getAllAchievementsStream() {
    return _db
        .collection(_achievementsCollection)
        .orderBy('category')
        .orderBy('createdAt')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    });
  }

  /// Get achievement by ID stream
  Stream<Achievement> getAchievementStream(String achievementId) {
    return _db
        .collection(_achievementsCollection)
        .doc(achievementId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return Achievement.empty();
      return await getAchievementWithLevels(doc);
    });
  }

  /// Get achievements by category stream
  Stream<List<Achievement>> getAchievementsByCategoryStream(String category) {
    return _db
        .collection(_achievementsCollection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    });
  }

  /// Get achievement with its levels from subcollection
  Future<Achievement> getAchievementWithLevels(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (!doc.exists) return Achievement.empty();

    final data = doc.data()!;

    // Get levels from subcollection
    final levelsSnapshot = await _db
        .collection(_achievementsCollection)
        .doc(doc.id)
        .collection('achievementLevels')
        .orderBy('level')
        .get();

    final levels = levelsSnapshot.docs
        .map((levelDoc) => AchievementLevel.fromSnapshot(levelDoc))
        .toList();

    return Achievement(
      achievementId: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      maxLevel: data['maxLevel'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      achievementLevels: levels,
    );
  }

  /// Get achievement by ID
  Future<Achievement> getAchievementById(String achievementId) async {
    try {
      final doc = await _db
          .collection(_achievementsCollection)
          .doc(achievementId)
          .get();

      if (!doc.exists) {
        throw 'Achievement not found';
      }

      return await getAchievementWithLevels(doc);
    } catch (e) {
      throw 'Failed to fetch achievement: $e';
    }
  }

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final snapshot = await _db
          .collection(_achievementsCollection)
          .orderBy('category')
          .orderBy('createdAt')
          .get();

      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    } catch (e) {
      throw 'Failed to fetch achievements: $e';
    }
  }

  /// Get achievements by category
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection(_achievementsCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt')
          .get();

      List<Achievement> achievements = [];

      for (var doc in snapshot.docs) {
        final achievement = await getAchievementWithLevels(doc);
        achievements.add(achievement);
      }

      return achievements;
    } catch (e) {
      throw 'Failed to fetch achievements by category: $e';
    }
  }
}