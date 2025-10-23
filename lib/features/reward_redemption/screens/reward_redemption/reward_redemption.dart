import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp/features/reward_redemption/screens/my_reward/my_reward.dart';
import 'package:fyp/features/reward_redemption/screens/reward_detail/reward_detail.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/reward_redemption/controllers/reward_controller.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';

class RewardRedemptionScreen extends StatelessWidget {
  const RewardRedemptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text('Rewards'),
        centerTitle: false,
        actionButtonText: 'My Rewards',
        actionButtonIcon: Iconsax.ticket,
        onActionButtonPressed: () => Get.to(() => const MyRewardsScreen()),
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        color: FColors.primary,
        onRefresh: controller.refreshRewards,
        child: CustomScrollView(
          slivers: [
            // Points Card
            SliverToBoxAdapter(
              child: Container(
                color: dark ? FColors.dark : FColors.white,
                padding: const EdgeInsets.all(FSizes.defaultSpace),
                child: _buildPointsCard(controller, dark),
              ),
            ),

            // Divider
            SliverToBoxAdapter(
              child: Container(
                height: 8,
                color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
              ),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Container(
                color: dark ? FColors.dark : FColors.white,
                padding: const EdgeInsets.fromLTRB(
                  FSizes.defaultSpace,
                  FSizes.md,
                  FSizes.defaultSpace,
                  FSizes.md,
                ),
                child: Text(
                  'Redeem Your Rewards',
                  style: TextStyle(
                    color: dark ? FColors.white : FColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Rewards Grid
            Obx(() {
              if (controller.isLoading.value && controller.rewards.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: FColors.primary),
                  ),
                );
              }

              if (controller.rewards.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context, dark),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  FSizes.defaultSpace,
                  FSizes.sm,
                  FSizes.defaultSpace,
                  FSizes.defaultSpace,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: FSizes.gridViewSpacing,
                    mainAxisSpacing: FSizes.gridViewSpacing,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final reward = controller.rewards[index];
                      return _buildRewardCard(reward, controller, dark);
                    },
                    childCount: controller.rewards.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Build points card widget
  Widget _buildPointsCard(RewardController controller, bool dark) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FColors.primary,
            FColors.accent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.star1,
                  color: FColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Text(
                'My Reward Points',
                style: TextStyle(
                  color: FColors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            controller.userPoints.value.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
            ),
            style: const TextStyle(
              color: FColors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            'Points Available',
            style: TextStyle(
              color: FColors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ));
  }

  /// Build individual reward card
  Widget _buildRewardCard(RewardModel reward, RewardController controller, bool dark) {
    final canRedeem = controller.canRedeemReward(reward);
    final daysUntilExpiry = reward.validUntil.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () => Get.to(() => RewardDetailScreen(reward: reward)),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkerGrey : FColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark
                ? FColors.darkGrey.withOpacity(0.3)
                : FColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Reward Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: FColors.primary.withOpacity(0.1),
                child: reward.rewardImage.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: reward.rewardImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: FColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Iconsax.gift,
                      size: 40,
                      color: FColors.primary.withOpacity(0.5),
                    ),
                  ),
                )
                    : Center(
                  child: Icon(
                    Iconsax.gift,
                    size: 40,
                    color: FColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            /// Reward Details - Fixed layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(FSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title - Flexible to take available space
                    Expanded(
                      child: Text(
                        reward.title,
                        style: TextStyle(
                          color: dark ? FColors.white : FColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: FSizes.xs),

                    /// Points Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: FSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: canRedeem
                            ? FColors.primary.withOpacity(0.1)
                            : FColors.darkGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.star1,
                            size: 14,
                            color: canRedeem ? FColors.primary : FColors.darkGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.pointsNeeded}',
                            style: TextStyle(
                              color: canRedeem ? FColors.primary : FColors.darkGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: FSizes.xs),

                    /// Expiry Info
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 12,
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            daysUntilExpiry > 0
                                ? '$daysUntilExpiry days left'
                                : 'Expires soon',
                            style: TextStyle(
                              color: dark ? FColors.darkGrey : FColors.textSecondary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.defaultSpace * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.gift,
                size: 64,
                color: FColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              'No rewards available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Check back later for amazing rewards!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}