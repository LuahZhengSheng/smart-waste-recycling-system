import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/user_achievement_controller.dart';
import '../../models/achievement_level_model.dart';
import '../../models/achievement_model.dart';
import '../../models/user_achievement_model.dart';
import '../leaderboard/leaderboard.dart';

class MyAchievementsScreen extends StatelessWidget {
  const MyAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyAchievementsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: dark ? FColors.white : FColors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Achievements',
          style: TextStyle(
            color: dark ? FColors.white : FColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(context, dark),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Achievement List
            _buildAchievementsList(context, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.md),
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [FColors.primary.withOpacity(0.2), FColors.accent.withOpacity(0.1)]
              : [FColors.primary.withOpacity(0.1), FColors.accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock My Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Complete challenges and earn rewards while making the planet greener.',
                  style: TextStyle(
                    fontSize: 13,
                    color: dark ? FColors.grey : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FSizes.md),
          InkWell(
            onTap: () {
              Get.to(() => LeaderboardScreen());
            },
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            child: Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 32,
                color: FColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context, bool dark) {
    // Mock data - replace with controller.userAchievements
    final achievements = _getMockAchievements();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final userAchievement = achievements[index];
        final isCompleted = userAchievement.isCompleted();

        return _buildAchievementCard(
            context,
            userAchievement,
            isCompleted,
            dark
        );
      },
    );
  }

  Widget _buildAchievementCard(
      BuildContext context,
      UserAchievementModel userAchievement,
      bool isCompleted,
      bool dark,
      ) {
    final achievement = userAchievement.achievement;
    final progress = userAchievement.progress;
    final maxProgress = achievement.achievementLevels.isNotEmpty
        ? achievement.achievementLevels.first.unlockCriteria
        : 100;
    final progressPercentage = progress / maxProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: isCompleted
            ? (dark ? FColors.primary.withOpacity(0.15) : FColors.primary.withOpacity(0.08))
            : (dark ? FColors.darkContainer : FColors.white),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Icon
          _buildBadgeIcon(userAchievement, isCompleted, dark),

          const SizedBox(width: FSizes.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      _buildCompletedBadge(dark),
                  ],
                ),

                const SizedBox(height: FSizes.xs),

                Text(
                  achievement.achievementLevels.isNotEmpty
                      ? achievement.achievementLevels.first.description
                      : 'Complete this achievement to earn rewards.',
                  style: TextStyle(
                    fontSize: 12,
                    color: dark ? FColors.grey : FColors.textSecondary,
                  ),
                ),

                if (!isCompleted) ...[
                  const SizedBox(height: FSizes.md),

                  // Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: dark
                              ? FColors.darkGrey.withOpacity(0.3)
                              : FColors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressPercentage.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [FColors.primary, FColors.lightGreen],
                            ),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: FSizes.xs),

                  Text(
                    '$progress/$maxProgress',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: dark ? FColors.grey : FColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(UserAchievementModel userAchievement, bool isCompleted, bool dark) {
    final badge = userAchievement.achievement.achievementLevels.isNotEmpty
        ? userAchievement.achievement.achievementLevels.first.badgeImage
        : '🏆';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
          colors: [FColors.primary, FColors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: dark
              ? [FColors.darkGrey.withOpacity(0.5), FColors.darkGrey.withOpacity(0.3)]
              : [FColors.grey.withOpacity(0.3), FColors.grey.withOpacity(0.1)],
        ),
        shape: BoxShape.circle,
        boxShadow: isCompleted
            ? [
          BoxShadow(
            color: FColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Center(
        child: Text(
          badge,
          style: TextStyle(
            fontSize: isCompleted ? 32 : 28,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedBadge(bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs - 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [FColors.primary, FColors.success],
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: FColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Text(
            'Completed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Mock data helper
  List<UserAchievementModel> _getMockAchievements() {
    return [
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
  }
}