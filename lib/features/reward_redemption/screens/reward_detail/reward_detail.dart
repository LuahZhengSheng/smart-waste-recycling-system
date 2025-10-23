import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/reward_redemption/controllers/reward_controller.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';

class RewardDetailScreen extends StatelessWidget {
  final RewardModel reward;
  final RedemptionModel? redemption;
  final bool isFromMyRewards;

  const RewardDetailScreen({
    super.key,
    required this.reward,
    this.redemption,
    this.isFromMyRewards = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardController>();
    final dark = FHelperFunctions.isDarkMode(context);
    final daysUntilExpiry = reward.validUntil.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      body: Column(
        children: [
          /// Custom App Bar with Image
          _buildHeader(dark),

          /// Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title Section
                  Container(
                    color: dark ? FColors.dark : FColors.white,
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.title,
                          style: TextStyle(
                            color: dark ? FColors.white : FColors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: FSizes.md),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.md,
                                vertical: FSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FColors.primary,
                                    FColors.accent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
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
                                    Iconsax.star1,
                                    color: FColors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${reward.pointsNeeded} Points',
                                    style: const TextStyle(
                                      color: FColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.sm,
                                vertical: FSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(reward, redemption)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getStatusColor(reward, redemption),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _getStatusText(reward, redemption),
                                style: TextStyle(
                                  color: _getStatusColor(reward, redemption),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// Divider
                  Container(
                    height: 8,
                    color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
                  ),

                  /// Info Cards
                  Container(
                    color: dark ? FColors.dark : FColors.white,
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          icon: Iconsax.calendar,
                          title: 'Valid Until',
                          value: reward.formattedValidUntil,
                          subtitle: daysUntilExpiry > 0
                              ? '$daysUntilExpiry days left'
                              : 'Expires soon',
                          dark: dark,
                        ),
                        const SizedBox(height: FSizes.sm),
                        _buildInfoCard(
                          icon: Iconsax.box,
                          title: 'Available Quantity',
                          value: '${reward.remainingQuantity} left',
                          subtitle: '${reward.quantity} total',
                          dark: dark,
                        ),
                        if (!isFromMyRewards) ...[
                          const SizedBox(height: FSizes.sm),
                          Obx(() {
                            final userPoints = controller.userPoints.value;
                            final canAfford = userPoints >= reward.pointsNeeded;
                            return _buildInfoCard(
                              icon: Iconsax.wallet_3,
                              title: 'Your Points',
                              value: '$userPoints',
                              subtitle: canAfford
                                  ? 'Sufficient points'
                                  : 'Need ${reward.pointsNeeded - userPoints} more',
                              valueColor: canAfford ? FColors.success : null,
                              dark: dark,
                            );
                          }),
                        ],
                      ],
                    ),
                  ),

                  /// Divider
                  Container(
                    height: 8,
                    color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
                  ),

                  /// Description
                  Container(
                    color: dark ? FColors.dark : FColors.white,
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            color: dark ? FColors.white : FColors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: FSizes.sm),
                        Text(
                          reward.description,
                          style: TextStyle(
                            color: dark
                                ? FColors.darkGrey
                                : FColors.textSecondary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Divider
                  Container(
                    height: 8,
                    color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
                  ),

                  /// Terms & Conditions
                  Container(
                    color: dark ? FColors.dark : FColors.white,
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: dark ? FColors.white : FColors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: FSizes.sm),
                        Container(
                          padding: const EdgeInsets.all(FSizes.md),
                          decoration: BoxDecoration(
                            color: dark
                                ? FColors.darkerGrey
                                : FColors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reward.termsConditions,
                            style: TextStyle(
                              color: dark
                                  ? FColors.darkGrey
                                  : FColors.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Redemption Info (if from My Rewards)
                  if (redemption != null) ...[
                    Container(
                      height: 8,
                      color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
                    ),
                    _buildRedemptionInfo(redemption!, dark),
                  ],

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isFromMyRewards
          ? _buildBottomButton(controller, dark)
          : null,
    );
  }

  /// Build Header with Image
  Widget _buildHeader(bool dark) {
    return Stack(
      children: [
        /// Image
        Container(
          height: 280,
          width: double.infinity,
          color: FColors.primary.withOpacity(0.1),
          child: reward.rewardImage.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: reward.rewardImage,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: FColors.primary,
                strokeWidth: 3,
              ),
            ),
            errorWidget: (context, url, error) => Center(
              child: Icon(
                Iconsax.gift,
                size: 64,
                color: FColors.primary.withOpacity(0.5),
              ),
            ),
          )
              : Center(
            child: Icon(
              Iconsax.gift,
              size: 64,
              color: FColors.primary.withOpacity(0.5),
            ),
          ),
        ),

        /// Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        /// Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FSizes.sm),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: dark
                            ? FColors.darkerGrey.withOpacity(0.8)
                            : FColors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.arrow_left,
                        color: dark ? FColors.white : FColors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build Info Card
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    Color? valueColor,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: FColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? (dark ? FColors.white : FColors.black),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                      fontSize: 11,
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

  /// Build Redemption Info Section
  Widget _buildRedemptionInfo(RedemptionModel redemption, bool dark) {
    final daysRemaining = 30 - DateTime.now().difference(redemption.createdAt).inDays;
    final isExpired = daysRemaining <= 0;

    return Container(
      color: dark ? FColors.dark : FColors.white,
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      child: Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isExpired
                ? [
              FColors.error.withOpacity(0.1),
              FColors.error.withOpacity(0.05),
            ]
                : [
              FColors.success.withOpacity(0.1),
              FColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpired
                ? FColors.error.withOpacity(0.3)
                : FColors.success.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? FColors.error.withOpacity(0.1)
                        : FColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isExpired ? Iconsax.close_circle : Iconsax.tick_circle,
                    color: isExpired ? FColors.error : FColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Text(
                    isExpired ? 'Reward Expired' : 'Redeemed Successfully',
                    style: TextStyle(
                      color: isExpired ? FColors.error : FColors.success,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),

            /// PIN Code Section
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark ? FColors.darkerGrey : FColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PIN Code',
                        style: TextStyle(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: redemption.pinCode),
                            );
                            FLoaders.customToast(message: 'PIN code copied!');
                          },
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
                                  Iconsax.copy,
                                  size: 14,
                                  color: FColors.primary,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Copy',
                                  style: TextStyle(
                                    color: FColors.primary,
                                    fontSize: 12,
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
                  const SizedBox(height: FSizes.sm),
                  Text(
                    redemption.formattedPinCode,
                    style: const TextStyle(
                      color: FColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FSizes.md),

            /// Info Rows
            _buildInfoRow(
              'Redeemed Date',
              redemption.formattedCreatedAt,
              dark,
            ),
            const SizedBox(height: FSizes.sm),
            _buildInfoRow(
              'Status',
              isExpired ? 'Expired' : '$daysRemaining days left',
              dark,
              valueColor: isExpired ? FColors.error : FColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: dark ? FColors.darkGrey : FColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (dark ? FColors.white : FColors.black),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build Bottom Redeem Button
  Widget _buildBottomButton(RewardController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.dark : FColors.white,
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final canRedeem = controller.canRedeemReward(reward);
          final isLoading = controller.isLoading.value;
          final userPoints = controller.userPoints.value;

          return SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: canRedeem && !isLoading
                  ? () => _handleRedeem(controller)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRedeem
                    ? FColors.primary
                    : FColors.buttonDisabled,
                foregroundColor: FColors.white,
                disabledBackgroundColor: FColors.buttonDisabled,
                disabledForegroundColor: FColors.white.withOpacity(0.7),
                elevation: canRedeem ? 4 : 0,
                shadowColor: FColors.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(FColors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canRedeem ? Iconsax.gift : Iconsax.lock_1,
                    size: 20,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    canRedeem
                        ? 'Redeem Now'
                        : userPoints < reward.pointsNeeded
                        ? 'Insufficient Points'
                        : 'Unavailable',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Handle Redeem Action
  void _handleRedeem(RewardController controller) {
    FLoaders.showRewardRedemptionDialog(
      rewardTitle: reward.title,
      pointsRequired: reward.pointsNeeded,
      currentPoints: controller.userPoints.value,
      onConfirm: () async {
        await controller.redeemReward(reward);
      },
    );
  }

  /// Get status color
  Color _getStatusColor(RewardModel reward, RedemptionModel? redemption) {
    if (redemption != null) {
      final daysRemaining = 30 - DateTime.now().difference(redemption.createdAt).inDays;
      return daysRemaining <= 0 ? FColors.error : FColors.success;
    }
    return reward.isAvailable ? FColors.success : FColors.error;
  }

  /// Get status text
  String _getStatusText(RewardModel reward, RedemptionModel? redemption) {
    if (redemption != null) {
      final daysRemaining = 30 - DateTime.now().difference(redemption.createdAt).inDays;
      return daysRemaining <= 0 ? 'EXPIRED' : 'ACTIVE';
    }
    return reward.statusDisplayText.toUpperCase();
  }
}