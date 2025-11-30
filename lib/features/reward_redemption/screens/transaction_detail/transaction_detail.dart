import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatter.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/transaction_detail_controller.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String transactionId;
  final String transactionType; // 'earning' or 'spending'

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionDetailsController());
    final dark = FHelperFunctions.isDarkMode(context);

    // Load transaction details
    controller.loadTransactionDetails(
      transactionId: transactionId,
      type: transactionType,
    );

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: Text("Transaction Details"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: FColors.primary),
                const SizedBox(height: FSizes.md),
                Text(
                  'Loading transaction details...',
                  style: TextStyle(
                    color: dark ? FColors.white : FColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: transactionType == 'earning'
              ? _buildEarningTransactionDetails(controller, dark)
              : _buildSpendingTransactionDetails(controller, dark),
        );
      }),
    );
  }

  /// Build earning transaction details
  Widget _buildEarningTransactionDetails(
      TransactionDetailsController controller,
      bool dark,
      ) {
    return Obx(() {
      final activity = controller.activity.value;
      final center = controller.recyclingCenter.value;
      final staff = controller.staff.value;
      final category = controller.wasteCategory.value;

      if (activity == null) {
        return Center(
          child: Text(
            'Transaction not found',
            style: TextStyle(
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Header Card
          _buildTransactionHeaderCard(
            dark: dark,
            icon: Iconsax.arrow_up_3,
            iconColor: FColors.transactionEarning,
            iconBgColor: FColors.transactionEarning.withOpacity(0.1),
            title: 'Recycling Reward',
            points: '+${activity.pointsEarned}',
            isEarning: true,
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Transaction Details Section
          _buildSectionHeader('Transaction Details', dark),
          const SizedBox(height: FSizes.md),
          _buildInfoCard(
            dark: dark,
            children: [
              _buildInfoRow(
                'Transaction ID',
                activity.activityId.substring(0, 8).toUpperCase(),
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Date & Time',
                DateFormat('MMMM d, yyyy \'at\' h:mm:ss a').format(activity.createdAt),
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Transaction Type',
                'Recycling Reward',
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Points Earned',
                '+${activity.pointsEarned} points',
                dark,
                valueColor: FColors.transactionEarning,
                isBold: true,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Status',
                'Completed',
                dark,
                trailing: _buildStatusBadge('Completed', dark),
              ),
            ],
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Recycling Details Section
          _buildSectionHeader('Recycling Details', dark),
          const SizedBox(height: FSizes.md),
          _buildInfoCard(
            dark: dark,
            children: [
              _buildInfoRow(
                'Waste Type',
                activity.wasteObject,
                dark,
                isBold: true,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Waste Category',
                category?.name ?? 'Loading...',
                dark,
                trailing: category != null
                    ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 16,
                        color: category.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
                    : null,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Weight',
                '${activity.weight.toStringAsFixed(2)} kg',
                dark,
                isBold: true,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Recycling Center',
                center?.name ?? 'Loading...',
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Processed By',
                staff?.username ?? 'Loading...',
                dark,
              ),
            ],
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Support Image Section
          if (activity.supportImage.isNotEmpty) ...[
            _buildSectionHeader('Support Image', dark),
            const SizedBox(height: FSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              child: FutureBuilder<String>(
                future: activity.getSupportImageUrl(activity.userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Image.network(
                      snapshot.data!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  }
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: dark ? FColors.darkContainer : FColors.lightContainer,
                    child: Center(
                      child: Icon(
                        Iconsax.gallery,
                        size: 48,
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Build spending transaction details
  Widget _buildSpendingTransactionDetails(
      TransactionDetailsController controller,
      bool dark,
      ) {
    return Obx(() {
      final redemption = controller.redemption.value;
      final reward = controller.reward.value;

      if (redemption == null) {
        return Center(
          child: Text(
            'Transaction not found',
            style: TextStyle(
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Header Card
          _buildTransactionHeaderCard(
            dark: dark,
            icon: Iconsax.arrow_down_1,
            iconColor: FColors.transactionSpending,
            iconBgColor: FColors.transactionSpending.withOpacity(0.1),
            title: 'Reward Redemption',
            points: '-${redemption.points}',
            isEarning: false,
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Transaction Details Section
          _buildSectionHeader('Transaction Details', dark),
          const SizedBox(height: FSizes.md),
          _buildInfoCard(
            dark: dark,
            children: [
              _buildInfoRow(
                'Transaction ID',
                redemption.redemptionId.substring(0, 8).toUpperCase(),
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Date & Time',
                DateFormat('MMMM d, yyyy \'at\' h:mm:ss a').format(redemption.createdAt),
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Transaction Type',
                'Reward Redemption',
                dark,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Points Spent',
                '-${redemption.points} points',
                dark,
                valueColor: FColors.transactionSpending,
                isBold: true,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Status',
                redemption.status == 'active' ? 'Completed' : 'Expired',
                dark,
                trailing: _buildStatusBadge(
                  redemption.status == 'active' ? 'Completed' : 'Expired',
                  dark,
                ),
              ),
            ],
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Reward Details Section
          _buildSectionHeader('Reward Details', dark),
          const SizedBox(height: FSizes.md),
          _buildInfoCard(
            dark: dark,
            children: [
              _buildInfoRow(
                'Reward ID',
                redemption.rewardId.substring(0, 8).toUpperCase(),
                dark,
              ),
              _buildDivider(dark),
              // Reward Image
              if (reward != null && reward.rewardImage.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    child: Image.network(
                      reward.rewardImage,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 150,
                          color: dark ? FColors.darkContainer : FColors.lightContainer,
                          child: Icon(
                            Iconsax.gift,
                            size: 48,
                            color: dark ? FColors.darkGrey : FColors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildDivider(dark),
              ],
              _buildInfoRow(
                'Reward',
                reward?.title ?? 'Loading...',
                dark,
                isBold: true,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'Expiry Date',
                FFormatter.formatDate(redemption.validUntil),
                dark,
                valueColor: redemption.isExpired ? FColors.error : null,
              ),
              _buildDivider(dark),
              _buildInfoRow(
                'PIN Code',
                redemption.formattedPinCode,
                dark,
                isBold: true,
                trailing: IconButton(
                  icon: Icon(
                    Iconsax.copy,
                    size: 20,
                    color: FColors.primary,
                  ),
                  onPressed: () {
                    // Copy PIN to clipboard
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Build transaction header card with icon and points
  Widget _buildTransactionHeaderCard({
    required bool dark,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String points,
    required bool isEarning,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEarning
              ? [
            FColors.transactionEarning,
            FColors.transactionEarning.withOpacity(0.8),
          ]
              : [
            FColors.transactionSpending,
            FColors.transactionSpending.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (isEarning ? FColors.transactionEarning : FColors.transactionSpending)
                .withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Icon(
              icon,
              color: FColors.white,
              size: 32,
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
                    color: FColors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      points,
                      style: const TextStyle(
                        color: FColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: FSizes.xs),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Pts',
                        style: TextStyle(
                          color: FColors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title, bool dark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: dark ? FColors.white : FColors.textPrimary,
      ),
    );
  }

  /// Build info card container
  Widget _buildInfoCard({
    required bool dark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.transactionCardDark : FColors.transactionCardLight,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.transactionBorderDark : FColors.transactionBorderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(
      String label,
      String value,
      bool dark, {
        Color? valueColor,
        bool isBold = false,
        Widget? trailing,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: dark ? FColors.transactionLabelDark : FColors.transactionLabelLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing ??
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ??
                        (dark ? FColors.transactionValueDark : FColors.transactionValueLight),
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
        ],
      ),
    );
  }

  /// Build divider
  Widget _buildDivider(bool dark) {
    return Divider(
      color: dark ? FColors.transactionBorderDark : FColors.transactionBorderLight,
      height: 1,
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(String status, bool dark) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'completed':
        badgeColor = FColors.badgeCompleted;
        break;
      case 'pending':
        badgeColor = FColors.badgePending;
        break;
      case 'expired':
        badgeColor = FColors.badgeExpired;
        break;
      default:
        badgeColor = FColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}