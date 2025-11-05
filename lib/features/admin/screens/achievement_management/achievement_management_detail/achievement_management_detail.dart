import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../../leaderboard_achievement/models/achievement_level_model.dart';
import '../../../controllers/achievement_management/achievement_detail_controller.dart';

class AchievementDetailsScreen extends StatelessWidget {
  const AchievementDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AchievementDetailsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: _buildAppBar(controller, dark),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
          );
        }

        if (controller.achievement.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.document_text,
                  size: 64,
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'Achievement not found',
                  style: TextStyle(
                    fontSize: 18,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshData(),
          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAchievementHeader(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildStatsOverview(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildLevelProgressSection(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),
                _buildTopPerformersSection(controller, dark),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(AchievementDetailsController controller, bool dark) {
    return AppBar(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Iconsax.arrow_left_2,
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
        ),
      ),
      title: Text(
        'Achievement Details',
        style: TextStyle(
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.refreshData,
          icon: Icon(
            Iconsax.refresh,
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                controller.editAchievement();
                break;
              case 'toggle_status':
                controller.toggleAchievementStatus();
                break;
            }
          },
          icon: Icon(
            Iconsax.more,
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
          color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Iconsax.edit,
                    size: 18,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    'Edit Achievement',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    controller.getAchievementStatus() == 'active'
                        ? Iconsax.pause_circle
                        : Iconsax.play_circle,
                    size: 18,
                    color: controller.getAchievementStatus() == 'active'
                        ? (dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                        : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    controller.getAchievementStatus() == 'active'
                        ? 'Deactivate'
                        : 'Activate',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: FSizes.sm),
      ],
    );
  }

  Widget _buildAchievementHeader(AchievementDetailsController controller, bool dark) {
    final achievement = controller.achievement.value!;

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Achievement Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCategoryColor(achievement.category, dark),
                      _getCategoryColor(achievement.category, dark).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: _getCategoryColor(achievement.category, dark).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(achievement.category),
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: FSizes.lg),

              // Achievement Info
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: dark ? FColors.adminDarkText : FColors.adminLightText,
                            ),
                          ),
                        ),
                        _buildStatusBadge(controller, dark),
                      ],
                    ),
                    const SizedBox(height: FSizes.sm),

                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(achievement.category, dark).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        border: Border.all(
                          color: _getCategoryColor(achievement.category, dark).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        achievement.category,
                        style: TextStyle(
                          color: _getCategoryColor(achievement.category, dark),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: FSizes.md),

                    // Achievement Metadata
                    Wrap(
                      spacing: FSizes.lg,
                      runSpacing: FSizes.sm,
                      children: [
                        _buildMetadataItem(
                          icon: Iconsax.layer,
                          label: 'Max Level',
                          value: achievement.maxLevel.toString(),
                          dark: dark,
                        ),
                        _buildMetadataItem(
                          icon: Iconsax.medal_star,
                          label: 'Total Levels',
                          value: achievement.achievementLevels.length.toString(),
                          dark: dark,
                        ),
                        _buildMetadataItem(
                          icon: Iconsax.calendar,
                          label: 'Created',
                          value: _formatDate(achievement.createdAt),
                          dark: dark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AchievementDetailsController controller, bool dark) {
    final status = controller.getAchievementStatus();
    final color = controller.getStatusColor(dark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'active' ? Iconsax.tick_circle : Iconsax.pause_circle,
            color: color,
            size: 14,
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            status.capitalize!,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required String value,
    required bool dark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
        ),
        const SizedBox(width: FSizes.xs),
        Text(
          '$label: ',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(AchievementDetailsController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievement Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.lg),

          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.people,
                  title: 'Total Users',
                  value: controller.totalUsersWithAchievement.value.toString(),
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  dark: dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.crown,
                  title: 'Max Level Users',
                  value: controller.getUserCountForLevel(controller.achievement.value!.maxLevel).toString(),
                  color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                  dark: dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildStatCard(
                  icon: Iconsax.percentage_circle,
                  title: 'Completion Rate',
                  value: '${(controller.getLevelCompletionPercentage(controller.achievement.value!.maxLevel) * 100).toStringAsFixed(1)}%',
                  color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                  dark: dark,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressSection(AchievementDetailsController controller, bool dark) {
    final achievement = controller.achievement.value!;

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'User completion rates for each achievement level',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.lg),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievement.achievementLevels.length,
            separatorBuilder: (context, index) => const SizedBox(height: FSizes.md),
            itemBuilder: (context, index) {
              final level = achievement.achievementLevels[index];
              return _buildLevelProgressCard(controller, level, dark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard(
      AchievementDetailsController controller,
      AchievementLevel level,
      bool dark,
      ) {
    final userCount = controller.getUserCountForLevel(level.level);
    final percentage = controller.getLevelCompletionPercentage(level.level);

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(level.level, dark),
                      _getLevelColor(level.level, dark).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    level.level.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: FSizes.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${level.level}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$userCount users',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unlock Criteria: ${level.unlockCriteria}',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getLevelColor(level.level, dark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.xs),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: dark
                      ? FColors.adminDarkBorder.withOpacity(0.3)
                      : FColors.adminLightBorder.withOpacity(0.3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          _getLevelColor(level.level, dark),
                          _getLevelColor(level.level, dark).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersSection(AchievementDetailsController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Performers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.adminDarkPrimary.withOpacity(0.1)
                      : FColors.adminLightPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.crown,
                      size: 14,
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      'Max Level',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Users who have reached the highest level of this achievement',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.lg),

          Obx(() {
            final maxLevel = controller.achievement.value!.maxLevel;
            final topUsers = controller.getUsersForLevel(maxLevel);

            if (topUsers.isEmpty) {
              return _buildEmptyState(dark);
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topUsers.take(10).length, // Show top 10 users
              separatorBuilder: (context, index) => const SizedBox(height: FSizes.md),
              itemBuilder: (context, index) {
                final user = topUsers[index];
                return _buildUserCard(user, index + 1, maxLevel, dark);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      child: Column(
        children: [
          Icon(
            Iconsax.medal,
            size: 48,
            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'No users have reached max level yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
          ),
          Text(
            'Keep promoting this achievement to encourage participation',
            style: TextStyle(
              fontSize: 14,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, int rank, int level, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRankGradient(rank, dark),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),

          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getLevelColor(level, dark).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: user.profileImg != null && user.profileImg!.isNotEmpty
                  ? Image.network(
                user.profileImg!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(user, dark),
              )
                  : _buildDefaultAvatar(user, dark),
            ),
          ),
          const SizedBox(width: FSizes.md),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Level Badge & Reward Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(level, dark),
                      _getLevelColor(level, dark).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                ),
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: FSizes.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.coin,
                    size: 14,
                    color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    '${user.rewardPoint} pts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(UserModel user, bool dark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category, bool dark) {
    switch (category.toLowerCase()) {
      case 'recycling':
        return dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
      case 'scanning':
        return dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
      case 'community':
        return dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary;
      case 'streak':
        return dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
      case 'environmental':
        return dark ? const Color(0xFF10B981) : const Color(0xFF059669);
      default:
        return dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'recycling':
        return Iconsax.triangle;
      case 'scanning':
        return Iconsax.scan_barcode;
      case 'community':
        return Iconsax.people;
      case 'streak':
        return Iconsax.flash;
      case 'environmental':
        return Iconsax.tree;
      default:
        return Iconsax.medal_star;
    }
  }

  Color _getLevelColor(int level, bool dark) {
    final colors = [
      dark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), // Level 1 - Gray
      dark ? const Color(0xFF10B981) : const Color(0xFF059669), // Level 2 - Green
      dark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB), // Level 3 - Blue
      dark ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED), // Level 4 - Purple
      dark ? const Color(0xFFF59E0B) : const Color(0xFFD97706), // Level 5 - Orange
      dark ? const Color(0xFFEF4444) : const Color(0xFFDC2626), // Level 6+ - Red
    ];

    if (level <= 0) return colors[0];
    if (level >= colors.length) return colors.last;
    return colors[level - 1];
  }

  List<Color> _getRankGradient(int rank, bool dark) {
    switch (rank) {
      case 1: // Gold
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
        ];
      case 2: // Silver
        return [
          const Color(0xFFC0C0C0),
          const Color(0xFF808080),
        ];
      case 3: // Bronze
        return [
          const Color(0xFFCD7F32),
          const Color(0xFF8B4513),
        ];
      default: // Regular
        return [
          dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.7),
        ];
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}