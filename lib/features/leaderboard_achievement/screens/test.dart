import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/achievement_level_model.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';

class AddAchievementScreen extends StatefulWidget {
  const AddAchievementScreen({super.key});

  @override
  State<AddAchievementScreen> createState() => _AddAchievementScreenState();
}

class _AddAchievementScreenState extends State<AddAchievementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _createdAchievementId; // 存储创建的成就ID
  List<String> _createdLevelIds = []; // 存储创建的等级ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Achievement Data'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add E-Waste Collection Achievement Button
            _buildActionButton(
              'Add E-Waste Collection Achievement',
              Icons.devices,
              Colors.purple,
              _addEWasteCollectionAchievement,
            ),
            const SizedBox(height: 16),

            // Add Achievement Levels Button
            _buildActionButton(
              'Add Achievement Levels',
              Icons.star,
              Colors.orange,
              _addAchievementLevels,
            ),
            const SizedBox(height: 16),

            // Add User Achievement Button
            _buildActionButton(
              'Add User Achievement',
              Icons.person,
              Colors.green,
              _addUserAchievement,
            ),
            const SizedBox(height: 24),

            // Created Achievement ID Display
            if (_createdAchievementId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created Achievement ID:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _createdAchievementId!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Copy this ID for testing user achievements',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Created Level IDs Display
            if (_createdLevelIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Created Level IDs:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ..._createdLevelIds.asMap().entries.map((entry) {
                      final index = entry.key;
                      final levelId = entry.value;
                      return Text(
                        'Level ${index + 1}: $levelId',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 4),
                    const Text(
                      'Levels are stored in achievementLevels subcollection',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Loading Indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // Instructions
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• "Add E-Waste Collection Achievement" - Creates e-waste collection achievement with auto-generated ID'),
                    Text('• "Add Achievement Levels" - Adds 3 levels to the achievement (subcollection with auto-generated IDs)'),
                    Text('• "Add User Achievement" - Assigns achievement progress to user'),
                    SizedBox(height: 16),
                    Text(
                      'Achievement Levels (Based on Item Count):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Level 1: 5 items - E-Waste Beginner'),
                    Text('• Level 2: 15 items - E-Waste Handler'),
                    Text('• Level 3: 30 items - E-Waste Expert'),
                    SizedBox(height: 8),
                    Text(
                      'Note: E-waste is measured by item count due to varying weights',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Data Structure:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text('• achievements/{auto-generated-id} (main document)'),
                    Text('• achievements/{achievementId}/achievementLevels/{auto-generated-id} (subcollection)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _addEWasteCollectionAchievement() async {
    setState(() {
      _isLoading = true;
      _createdLevelIds.clear(); // 清除之前的等级ID
    });

    try {
      // Create E-Waste Collection Achievement with auto-generated ID
      final achievementRef = _firestore.collection('achievements').doc();

      final achievement = Achievement(
        achievementId: achievementRef.id, // 使用 Firestore 自动生成的 ID
        title: 'E-Waste Collector',
        category: 'e_waste_collection',
        maxLevel: 3,
        createdAt: DateTime.now(),
        achievementLevels: [], // Levels will be added to subcollection
      );

      // Save to Firestore - 只保存成就基本信息，不包含等级数组
      await achievementRef.set({
        'achievementId': achievement.achievementId,
        'title': achievement.title,
        'category': achievement.category,
        'maxLevel': achievement.maxLevel,
        'createdAt': Timestamp.fromDate(achievement.createdAt),
        // 注意：不包含 achievementLevels 字段，因为等级在子集合中
      });

      // Store the created achievement ID for later use
      setState(() {
        _createdAchievementId = achievementRef.id;
      });

      _showSuccessSnackBar('E-Waste Collection Achievement added successfully!\nID: ${achievementRef.id}');
    } catch (e) {
      _showErrorSnackBar('Failed to add achievement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addAchievementLevels() async {
    setState(() {
      _isLoading = true;
      _createdLevelIds.clear(); // 清除之前的等级ID
    });

    try {
      if (_createdAchievementId == null) {
        _showErrorSnackBar('Please create the achievement first!');
        return;
      }

      // Create 3 levels for E-Waste Collection achievement (based on item count)
      final levels = [
        AchievementLevel(
          achievementLevelId: '', // 留空，使用自动生成的ID
          level: 1,
          unlockCriteria: 5, // 5 items
          title: 'E-Waste Beginner',
          description: 'Recycle 5 electronic items',
          badgeImage: '📱',
        ),
        AchievementLevel(
          achievementLevelId: '', // 留空，使用自动生成的ID
          level: 2,
          unlockCriteria: 15, // 15 items
          title: 'E-Waste Handler',
          description: 'Recycle 15 electronic items',
          badgeImage: '💻',
        ),
        AchievementLevel(
          achievementLevelId: '', // 留空，使用自动生成的ID
          level: 3,
          unlockCriteria: 30, // 30 items
          title: 'E-Waste Expert',
          description: 'Recycle 30 electronic items',
          badgeImage: '🔧',
        ),
      ];

      // Add levels to the subcollection with auto-generated IDs
      final achievementRef = _firestore.collection('achievements').doc(_createdAchievementId);
      final levelsCollection = achievementRef.collection('achievementLevels');

      // 批量添加所有等级到子集合，使用自动生成的ID
      final batch = _firestore.batch();
      final List<String> levelIds = [];

      for (final level in levels) {
        final levelDoc = levelsCollection.doc(); // 使用自动生成的文档ID
        final levelWithId = level.copyWith(
          achievementLevelId: levelDoc.id, // 设置自动生成的ID
        );
        batch.set(levelDoc, levelWithId.toJson());
        levelIds.add(levelDoc.id);
      }

      await batch.commit();

      // 存储创建的等级ID
      setState(() {
        _createdLevelIds = levelIds;
      });

      print('✅ Added ${levels.length} levels to subcollection: achievements/$_createdAchievementId/achievementLevels');
      print('📋 Level IDs: $_createdLevelIds');

      _showSuccessSnackBar('3 E-Waste Collection levels added to subcollection successfully!\nAll levels use auto-generated IDs');
    } catch (e) {
      _showErrorSnackBar('Failed to add achievement levels: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addUserAchievement() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_createdAchievementId == null) {
        _showErrorSnackBar('Please create the achievement first!');
        return;
      }

      // 使用 AchievementRepository 的方式来获取完整的成就数据（包含子集合的等级）
      final achievement = await _getAchievementWithLevels(_createdAchievementId!);

      if (achievement == Achievement.empty()) {
        _showErrorSnackBar('Achievement not found or has no levels! Please create achievement and levels first.');
        return;
      }

      // Create user achievement with auto-generated ID
      final userAchievementRef = _firestore.collection('userAchievements').doc();

      final userAchievement = UserAchievement(
        userAchievementId: userAchievementRef.id, // 使用自动生成的 ID
        userId: 'sample_user_id', // 替换为实际用户 ID
        progress: 8, // 示例进度 (8 items)
        currentLevel: 1, // 根据进度计算等级
        updatedAt: DateTime.now(),
        achievement: achievement,
      );

      // Save to Firestore
      await userAchievementRef.set({
        'userAchievementId': userAchievement.userAchievementId,
        'userId': userAchievement.userId,
        'achievementId': _createdAchievementId, // 存储成就ID引用
        'progress': userAchievement.progress,
        'currentLevel': userAchievement.currentLevel,
        'updatedAt': Timestamp.fromDate(userAchievement.updatedAt),
      });

      _showSuccessSnackBar('User achievement added successfully!\n'
          'Progress: ${userAchievement.progress} items\n'
          'Current Level: ${userAchievement.currentLevel}\n'
          'Next Level at: ${userAchievement.targetCriteria} items\n'
          'Total Levels: ${userAchievement.achievement.achievementLevels.length}');
    } catch (e) {
      _showErrorSnackBar('Failed to add user achievement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取包含子集合等级的完整成就数据
  Future<Achievement> _getAchievementWithLevels(String achievementId) async {
    try {
      // 获取成就基本信息
      final achievementDoc = await _firestore
          .collection('achievements')
          .doc(achievementId)
          .get();

      if (!achievementDoc.exists) {
        return Achievement.empty();
      }

      final data = achievementDoc.data()!;

      // 获取子集合中的等级数据
      final levelsSnapshot = await _firestore
          .collection('achievements')
          .doc(achievementId)
          .collection('achievementLevels')
          .orderBy('level')
          .get();

      final levels = levelsSnapshot.docs
          .map((levelDoc) => AchievementLevel.fromSnapshot(levelDoc))
          .toList();

      if (levels.isEmpty) {
        print('⚠️ No levels found in subcollection for achievement: $achievementId');
        return Achievement.empty();
      }

      print('✅ Found ${levels.length} levels in subcollection');
      print('📋 Level details:');
      for (final level in levels) {
        print('   - Level ${level.level}: ${level.title} (${level.unlockCriteria} items) (ID: ${level.achievementLevelId})');
      }

      return Achievement(
        achievementId: achievementDoc.id,
        title: data['title'] ?? '',
        category: data['category'] ?? '',
        maxLevel: data['maxLevel'] ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        achievementLevels: levels,
      );
    } catch (e) {
      print('💥 Error getting achievement with levels: $e');
      return Achievement.empty();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}