import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp/features/reward_redemption/controllers/my_reward_controller.dart';
import 'package:fyp/features/reward_redemption/screens/reward_detail/reward_detail.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../../common/widgets/appbar/appbar.dart';

class MyRewardsScreen extends StatelessWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyRewardsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: dark ? FColors.dark : FColors.light,
        appBar: FAppBar(
          showBackArrow: true,
          title: const Text('My Rewards'),
        ),
        body: Column(
          children: [
            /// Tab Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.defaultSpace,
                vertical: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.darkerGrey
                      : FColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: controller.tabController,
                  labelColor: FColors.white,
                  unselectedLabelColor: dark
                      ? FColors.darkGrey
                      : FColors.textSecondary,
                  indicator: BoxDecoration(
                    color: FColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: FColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Expired'),
                  ],
                ),
              ),
            ),

            /// Tab Bar View
            Expanded(
              child: RefreshIndicator(
                color: FColors.primary,
                onRefresh: controller.refreshData,
                child: TabBarView(
                  controller: controller.tabController,
                  children: [
                    _buildActiveTab(controller, dark),
                    _buildExpiredTab(controller, dark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Active Rewards Tab
  Widget _buildActiveTab(MyRewardsController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: FColors.primary),
        );
      }

      final activeRedemptions = controller.activeRedemptions;

      if (activeRedemptions.isEmpty) {
        return _buildEmptyState(
          icon: Iconsax.ticket,
          title: 'No Active Rewards',
          message: 'You don\'t have any active rewards.\nRedeem some rewards to see them here!',
          dark: dark,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        itemCount: activeRedemptions.length,
        itemBuilder: (context, index) {
          final redemption = activeRedemptions[index];
          final reward = controller.getRewardById(redemption.rewardId);
          return _buildActiveRedemptionCard(
            redemption,
            reward,
            controller,
            dark,
          );
        },
      );
    });
  }

  /// Build Expired Rewards Tab
  Widget _buildExpiredTab(MyRewardsController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: FColors.primary),
        );
      }

      final expiredRedemptions = controller.expiredRedemptions;

      if (expiredRedemptions.isEmpty) {
        return _buildEmptyState(
          icon: Iconsax.clock,
          title: 'No Expired Rewards',
          message: 'Your expired rewards will appear here.',
          dark: dark,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        itemCount: expiredRedemptions.length,
        itemBuilder: (context, index) {
          final redemption = expiredRedemptions[index];
          final reward = controller.getRewardById(redemption.rewardId);
          return _buildExpiredRedemptionCard(
            redemption,
            reward,
            dark,
          );
        },
      );
    });
  }

  /// Build Active Redemption Card
  Widget _buildActiveRedemptionCard(
      RedemptionModel redemption,
      RewardModel? reward,
      MyRewardsController controller,
      bool dark,
      ) {
    final isNearExpiry = controller.isRedemptionNearExpiry(redemption);
    final daysUntilExpiry = controller.getDaysUntilExpiry(redemption);

    return GestureDetector(
      onTap: () {
        if (reward != null) {
          Get.to(() => RewardDetailScreen(
            reward: reward,
            redemption: redemption,
            isFromMyRewards: true,
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        decoration: BoxDecoration(
          color: dark ? FColors.darkerGrey : FColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isNearExpiry
              ? Border.all(color: FColors.warning, width: 2)
              : Border.all(
            color: dark
                ? FColors.darkGrey.withOpacity(0.3)
                : FColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            /// Header with Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: FColors.primary.withOpacity(0.1),
                    child: reward?.rewardImage.isNotEmpty == true
                        ? CachedNetworkImage(
                      imageUrl: reward!.rewardImage,
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
                          size: 48,
                          color: FColors.primary.withOpacity(0.5),
                        ),
                      ),
                    )
                        : Center(
                      child: Icon(
                        Iconsax.gift,
                        size: 48,
                        color: FColors.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.sm,
                      vertical: FSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: FColors.success,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: FColors.success.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: FColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.all(FSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    reward?.title ?? 'Unknown Reward',
                    style: TextStyle(
                      color: dark ? FColors.white : FColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: FSizes.sm),

                  /// PIN Section
                  Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark
                          ? FColors.dark
                          : FColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PIN Code',
                              style: TextStyle(
                                color: dark
                                    ? FColors.darkGrey
                                    : FColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '● ● ● ● ● ●',
                              style: TextStyle(
                                color: dark ? FColors.white : FColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showPinCodeDialog(
                              redemption,
                              reward,
                              dark,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.sm,
                                vertical: FSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: FColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.eye,
                                    size: 16,
                                    color: FColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'View',
                                    style: TextStyle(
                                      color: FColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: FSizes.sm),

                  /// Info Row
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 14,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Redeemed ${redemption.formattedCreatedAt}',
                        style: TextStyle(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  /// Expiry Warning
                  if (isNearExpiry) ...[
                    const SizedBox(height: FSizes.sm),
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: FColors.warning,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.warning_2,
                            color: FColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              daysUntilExpiry > 0
                                  ? 'Expires in $daysUntilExpiry day${daysUntilExpiry > 1 ? 's' : ''}'
                                  : 'Expires today',
                              style: const TextStyle(
                                color: FColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Expired Redemption Card
  Widget _buildExpiredRedemptionCard(
      RedemptionModel redemption,
      RewardModel? reward,
      bool dark,
      ) {
    return GestureDetector(
      onTap: () {
        if (reward != null) {
          Get.to(() => RewardDetailScreen(
            reward: reward,
            redemption: redemption,
            isFromMyRewards: true,
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        padding: const EdgeInsets.all(FSizes.md),
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
        child: Row(
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: FColors.primary.withOpacity(0.1),
                child: reward?.rewardImage.isNotEmpty == true
                    ? CachedNetworkImage(
                  imageUrl: reward!.rewardImage,
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
                      size: 28,
                      color: FColors.primary.withOpacity(0.5),
                    ),
                  ),
                )
                    : Center(
                  child: Icon(
                    Iconsax.gift,
                    size: 28,
                    color: FColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: FSizes.md),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward?.title ?? 'Unknown Reward',
                    style: TextStyle(
                      color: dark ? FColors.white : FColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'PIN: ${redemption.formattedPinCode}',
                    style: TextStyle(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Redeemed ${redemption.formattedCreatedAt}',
                    style: TextStyle(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            /// Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.sm,
                vertical: FSizes.xs,
              ),
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FColors.error,
                  width: 1,
                ),
              ),
              child: const Text(
                'EXPIRED',
                style: TextStyle(
                  color: FColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required bool dark,
  }) {
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
                icon,
                size: 64,
                color: FColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.darkGrey : FColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show PIN Code Dialog
  void _showPinCodeDialog(
      RedemptionModel redemption,
      RewardModel? reward,
      bool dark,
      ) {
    Get.dialog(
      Dialog(
        backgroundColor: dark ? FColors.darkerGrey : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.code,
                  color: FColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'PIN Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                reward?.title ?? 'Reward',
                style: TextStyle(
                  fontSize: 14,
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(FSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.primary.withOpacity(0.1),
                      FColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          redemption.formattedPinCode,
                          style: const TextStyle(
                            color: FColors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(width: FSizes.md),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: redemption.pinCode),
                              );
                              FLoaders.customToast(
                                message: 'PIN code copied!',
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: FColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.copy,
                                color: FColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FSizes.md),
              Text(
                'Show this PIN to the merchant',
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.white,
                    padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}