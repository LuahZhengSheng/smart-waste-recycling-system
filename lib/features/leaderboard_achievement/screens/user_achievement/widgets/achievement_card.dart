import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/enums.dart';

import '../../../models/achievement_enums.dart';
import '../../../models/user_achievement_model.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.userAchievement,
    required this.dark,
    this.hasLevelUp = false,
  });

  final UserAchievement userAchievement;
  final bool dark;
  final bool hasLevelUp;

  @override
  Widget build(BuildContext context) {
    final achievement = userAchievement.achievement;
    final displayLevelInfo = userAchievement.displayLevelInfo; // 使用 displayLevelInfo
    final isCompleted = userAchievement.isCompleted();
    final isLocked = userAchievement.status == AchievementStatus.locked;
    final progress = userAchievement.progress;
    final targetCriteria = userAchievement.targetCriteria;
    final progressPercentage = userAchievement.progressPercentage();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: FSizes.md),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: isCompleted
            ? (dark ? FColors.primary.withOpacity(0.15) : FColors.primary.withOpacity(0.08))
            : (dark ? FColors.darkContainer : FColors.white),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: hasLevelUp
            ? Border.all(
          color: FColors.primary,
          width: 2,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: hasLevelUp
                ? FColors.primary.withOpacity(0.3)
                : (dark ? Colors.black26 : Colors.black.withOpacity(0.05)),
            blurRadius: hasLevelUp ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Icon
          _buildBadgeIcon(displayLevelInfo?.badgeImage, isCompleted, isLocked),

          const SizedBox(width: FSizes.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: dark ? FColors.white : FColors.textPrimary,
                            ),
                          ),
                          if (displayLevelInfo != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              displayLevelInfo.title, // 使用 displayLevelInfo 的 title
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: FColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCompleted) _buildCompletedBadge(),
                    if (hasLevelUp) _buildLevelUpBadge(),
                  ],
                ),

                const SizedBox(height: FSizes.xs),

                // Description
                Text(
                  displayLevelInfo?.description ?? // 使用 displayLevelInfo 的 description
                      'Complete this achievement to earn rewards.',
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
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
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

                  // Progress Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$progress/$targetCriteria',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: dark ? FColors.grey : FColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Level ${userAchievement.currentLevel}/${achievement.maxLevel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: FColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(String? badge, bool isCompleted, bool isLocked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
          colors: [FColors.primary, FColors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : isLocked
            ? LinearGradient(
          colors: [
            FColors.darkGrey.withOpacity(0.5),
            FColors.darkGrey.withOpacity(0.3)
          ],
        )
            : LinearGradient(
          colors: [
            FColors.primary.withOpacity(0.3),
            FColors.lightGreen.withOpacity(0.2)
          ],
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
          badge ?? (isLocked ? '🔒' : '🏆'),
          style: TextStyle(
            fontSize: isCompleted ? 32 : 28,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
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

  Widget _buildLevelUpBadge() {
    return Container(
      margin: const EdgeInsets.only(left: FSizes.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs - 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [FColors.warning, FColors.secondary],
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: FColors.warning.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Text(
            'Level Up!',
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
}