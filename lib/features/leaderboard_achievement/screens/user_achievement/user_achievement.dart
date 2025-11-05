import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';

import '../../controllers/user_achievement_controller.dart';
import '../leaderboard/leaderboard.dart';
import '../test.dart';
import 'widgets/achievement_card.dart';

class MyAchievementsScreen extends StatelessWidget {
  const MyAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserAchievementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.primaryBackground,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('My Achievements'),
        backArrowColor: dark ? FColors.white : FColors.black,
        titleColor: dark ? FColors.white : FColors.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userAchievements.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: FColors.primary),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: dark ? FColors.grey : FColors.darkGrey,
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  controller.error.value,
                  style: TextStyle(
                    color: dark ? FColors.grey : FColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FSizes.md),
                ElevatedButton(
                  onPressed: () => controller.refreshAchievements(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAchievements(),
          color: FColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(context, dark, controller),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Achievement List by Category
                _buildAchievementsByCategory(context, dark, controller),

                const SizedBox(height: FSizes.spaceBtwSections),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, bool dark, UserAchievementController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.md),
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [
            FColors.primary.withOpacity(0.2),
            FColors.accent.withOpacity(0.1)
          ]
              : [
            FColors.primary.withOpacity(0.1),
            FColors.accent.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                onTap: () => Get.to(() => const LeaderboardScreen()),
                // onTap: () => Get.to(() => const AddAchievementScreen()),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                child: Container(
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: FColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                  child: const Icon(
                    Icons.emoji_events_outlined,
                    size: 32,
                    color: FColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          // Progress Summary
          Obx(() {
            final completed = controller.completedCount;
            final total = controller.totalCount;
            final progress = controller.overallProgress;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.white : FColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$completed/$total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: dark
                        ? FColors.darkGrey.withOpacity(0.3)
                        : FColors.grey.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(FColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementsByCategory(
      BuildContext context, bool dark, UserAchievementController controller) {
    return Obx(() {
      final achievementsByCategory = controller.achievementsByCategory;

      if (achievementsByCategory.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: dark ? FColors.grey : FColors.darkGrey,
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'No achievements yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.grey : FColors.textSecondary,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Start recycling to unlock your first achievement!',
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: achievementsByCategory.entries.map((entry) {
          final category = entry.key;
          final achievements = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: FColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: FColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                      child: Text(
                        '${achievements.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: FColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
                child: Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: dark ? FColors.grey : FColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: FSizes.md),

              // Achievement Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
                child: Column(
                  children: achievements.map((userAchievement) {
                    final achievementId = userAchievement.achievement.achievementId;
                    final hasLevelUp = controller.hasRecentLevelUp(achievementId);

                    return AchievementCard(
                      userAchievement: userAchievement,
                      dark: dark,
                      hasLevelUp: hasLevelUp,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),
            ],
          );
        }).toList(),
      );
    });
  }
}