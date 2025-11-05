import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/leaderboard_achievement/models/achievement_model.dart';
import '../../../features/leaderboard_achievement/models/user_achievement_model.dart';
import 'achievement_repostory.dart';

class UserAchievementRepository extends GetxController {
  static UserAchievementRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userAchievementsCollection = 'userAchievements';

  /// Get all user achievements stream
  Stream<List<UserAchievement>> getUserAchievementsStream(String userId) {
    return _db
        .collection(_userAchievementsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {

      List<UserAchievement> userAchievements = [];

      for (var doc in snapshot.docs) {
        final userAchievement = await _getUserAchievementWithFullData(doc);
        if (userAchievement != UserAchievement.empty()) {
          userAchievements.add(userAchievement);
        } else {
          print('❌ [UserAchievementRepository] 加载成就失败，文档ID: ${doc.id}');
        }
      }

      return userAchievements;
    });
  }

  /// Get user achievement by ID stream
  Stream<UserAchievement> getUserAchievementStream(String userAchievementId) {
    return _db
        .collection(_userAchievementsCollection)
        .doc(userAchievementId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return UserAchievement.empty();
      return await _getUserAchievementWithFullData(doc);
    });
  }

  /// Get user achievements by category stream
  Stream<List<UserAchievement>> getUserAchievementsByCategoryStream(
      String userId, String category) {
    return getUserAchievementsStream(userId).map((userAchievements) {
      return userAchievements
          .where((ua) => ua.achievement.category == category)
          .toList();
    });
  }

  /// Get user achievement with full achievement data
  Future<UserAchievement> _getUserAchievementWithFullData(
      DocumentSnapshot<Map<String, dynamic>> doc) async {

    if (!doc.exists) {
      return UserAchievement.empty();
    }

    final data = doc.data()!;

    // 获取成就ID（直接存储字符串ID而不是DocumentReference）
    final achievementId = data['achievementId'] as String?;

    if (achievementId == null || achievementId.isEmpty) {
      return UserAchievement.empty();
    }

    try {
      final achievement = await AchievementRepository.instance
          .getAchievementById(achievementId);

      if (achievement == Achievement.empty()) {
        return UserAchievement.empty();
      }

      // 构建完整的 UserAchievement 对象
      final userAchievement = UserAchievement(
        userAchievementId: doc.id,
        userId: data['userId'] ?? '',
        progress: data['progress'] ?? 0,
        currentLevel: data['currentLevel'] ?? 0,
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        achievement: achievement,
      );

      return userAchievement;

    } catch (e) {
      print('💥 [UserAchievementRepository] 获取成就数据时发生错误: $e');
      print('📋 [UserAchievementRepository] 错误堆栈: ${e.toString()}');
      return UserAchievement.empty();
    }
  }

  /// Get user achievement by achievement ID
  Future<UserAchievement?> getUserAchievementByAchievementId(
      String userId, String achievementId) async {
    try {
      final snapshot = await _db
          .collection(_userAchievementsCollection)
          .where('userId', isEqualTo: userId)
          .where('achievementId', isEqualTo: achievementId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return await _getUserAchievementWithFullData(snapshot.docs.first);
    } catch (e) {
      throw 'Failed to fetch user achievement: $e';
    }
  }

  /// Update user achievement progress
  Future<void> updateProgress(String userAchievementId, int newProgress) async {
    try {
      await _db
          .collection(_userAchievementsCollection)
          .doc(userAchievementId)
          .update({
        'progress': newProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update progress: $e';
    }
  }

  /// Increment user achievement progress
  Future<void> incrementProgress(String userAchievementId, int increment) async {
    try {
      await _db
          .collection(_userAchievementsCollection)
          .doc(userAchievementId)
          .update({
        'progress': FieldValue.increment(increment),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to increment progress: $e';
    }
  }

  /// Create user achievement
  Future<String> createUserAchievement({
    required String userId,
    required String achievementId,
    int initialProgress = 0,
    int initialLevel = 0,
  }) async {
    try {
      final docRef = await _db.collection(_userAchievementsCollection).add({
        'userId': userId,
        'achievementId': achievementId, // 直接存储成就ID字符串
        'progress': initialProgress,
        'currentLevel': initialLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ [UserAchievementRepository] 创建用户成就成功:');
      print('   - 用户ID: $userId');
      print('   - 成就ID: $achievementId');
      print('   - 初始进度: $initialProgress');
      print('   - 初始等级: $initialLevel');
      print('   - 文档ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      throw 'Failed to create user achievement: $e';
    }
  }

  /// Get or create user achievement
  Future<UserAchievement> getOrCreateUserAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      // Try to get existing
      final existing = await getUserAchievementByAchievementId(userId, achievementId);
      if (existing != null) {
        print('✅ [UserAchievementRepository] 找到现有用户成就');
        return existing;
      }

      print('🆕 [UserAchievementRepository] 创建新用户成就');
      // Create new
      final newId = await createUserAchievement(
        userId: userId,
        achievementId: achievementId,
      );

      // Get the newly created achievement
      final doc = await _db
          .collection(_userAchievementsCollection)
          .doc(newId)
          .get();

      return await _getUserAchievementWithFullData(doc);
    } catch (e) {
      throw 'Failed to get or create user achievement: $e';
    }
  }

  /// Initialize user achievements for a new user
  Future<void> initializeUserAchievements({
    required String userId,
    required List<String> achievementIds,
  }) async {
    try {
      print('🚀 [UserAchievementRepository] 开始初始化用户成就，用户ID: $userId');
      print('📋 [UserAchievementRepository] 需要初始化的成就数量: ${achievementIds.length}');

      for (final achievementId in achievementIds) {
        try {
          await getOrCreateUserAchievement(
            userId: userId,
            achievementId: achievementId,
          );
          print('✅ [UserAchievementRepository] 初始化成就成功: $achievementId');
        } catch (e) {
          print('❌ [UserAchievementRepository] 初始化成就失败: $achievementId, 错误: $e');
        }
      }

      print('🎉 [UserAchievementRepository] 用户成就初始化完成');
    } catch (e) {
      throw 'Failed to initialize user achievements: $e';
    }
  }
}