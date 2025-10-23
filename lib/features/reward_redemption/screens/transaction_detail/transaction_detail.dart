import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../personalization/models/recycle_activity_model.dart';
import '../../controllers/reward_point_controller.dart';

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
    final isDark = FHelperFunctions.isDarkMode(context);
    final controller = RewardPointsController.instance;
    final isEarning = transactionType == 'earning';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8FAFC),
      appBar: FAppBar(
        showBackArrow: true,
        title: Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: isEarning
            ? _buildEarningTransaction(controller, isDark, context)
            : _buildSpendingTransaction(controller, isDark, context),
      ),
    );
  }

  Widget _buildEarningTransaction(
      RewardPointsController controller,
      bool isDark,
      BuildContext context,
      ) {
    return StreamBuilder<RecyclingActivity>(
      stream: controller.getActivityStream(transactionId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: FColors.primary));
        }

        final activity = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Summary Card
            _buildPointsSummaryCard(
              isDark: isDark,
              isEarning: true,
              points: activity.pointsEarned,
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Transaction Details Card
            _buildTransactionDetailsCard(
              isDark: isDark,
              isEarning: true,
              context: context,
              id: activity.activityId,
              description: 'Recycling Activity',
              date: activity.createdAt,
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Recycling Activity Details
            _buildEarningDetailsCard(isDark, context, activity, controller),

            const SizedBox(height: FSizes.spaceBtwSections),
          ],
        );
      },
    );
  }

  Widget _buildSpendingTransaction(
      RewardPointsController controller,
      bool isDark,
      BuildContext context,
      ) {
    return StreamBuilder<RedemptionModel>(
      stream: controller.getRedemptionStream(transactionId),
      builder: (context, redemptionSnapshot) {
        if (!redemptionSnapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: FColors.primary));
        }

        final redemption = redemptionSnapshot.data!;

        return StreamBuilder<RewardModel>(
          stream: controller.getRewardStream(redemption.rewardId),
          builder: (context, rewardSnapshot) {
            final points = rewardSnapshot.hasData ? rewardSnapshot.data!.pointsNeeded : 0;
            final description = rewardSnapshot.hasData ? rewardSnapshot.data!.title : 'Reward Redemption';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points Summary Card
                _buildPointsSummaryCard(
                  isDark: isDark,
                  isEarning: false,
                  points: points,
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Transaction Details Card
                _buildTransactionDetailsCard(
                  isDark: isDark,
                  isEarning: false,
                  context: context,
                  id: redemption.redemptionId,
                  description: description,
                  date: redemption.createdAt,
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Redemption Details
                _buildSpendingDetailsCard(isDark, context, redemption, rewardSnapshot.data),

                const SizedBox(height: FSizes.spaceBtwSections),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPointsSummaryCard({
    required bool isDark,
    required bool isEarning,
    required int points,
  }) {
    final pointsColor = isEarning ? FColors.success : FColors.error;
    final pointsPrefix = isEarning ? '+' : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEarning
              ? [FColors.success, FColors.success.withOpacity(0.8)]
              : [FColors.error, FColors.error.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pointsColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEarning ? Iconsax.arrow_up_3 : Iconsax.arrow_down_1,
              color: FColors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pointsPrefix ${points.abs()}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: FColors.white,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: FSizes.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Points',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: FColors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsCard({
    required bool isDark,
    required bool isEarning,
    required BuildContext context,
    required String id,
    required String description,
    required DateTime date,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F36).withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? FColors.darkGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? FColors.white : FColors.textPrimary,
            ),
          ),
          const SizedBox(height: FSizes.lg),
          _buildDetailRow(
            context: context,
            icon: Iconsax.hashtag,
            label: 'Transaction ID',
            value: id,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildDetailRow(
            context: context,
            icon: Iconsax.note_text,
            label: 'Description',
            value: description,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildDetailRow(
            context: context,
            icon: Iconsax.calendar,
            label: 'Date & Time',
            value: '${FFormatter.formatDate(date)} • ${_formatTime(date)}',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildDetailRow(
            context: context,
            icon: isEarning ? Iconsax.arrow_up_3 : Iconsax.arrow_down_1,
            label: 'Type',
            value: isEarning ? 'Earning' : 'Spending',
            isDark: isDark,
            valueColor: isEarning ? FColors.success : FColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningDetailsCard(
      bool isDark,
      BuildContext context,
      RecyclingActivity activity,
      RewardPointsController controller,
      ) {
    return StreamBuilder(
      stream: controller.getCenterByStaffIdStream(activity.centerStaffId),
      builder: (context, centerSnapshot) {
        return Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F36).withOpacity(0.8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? FColors.darkGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recycling Activity Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? FColors.white : FColors.textPrimary,
                ),
              ),
              const SizedBox(height: FSizes.lg),
              _buildDetailRow(
                context: context,
                icon: Iconsax.activity,
                label: 'Activity ID',
                value: activity.activityId,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              if (centerSnapshot.hasData && centerSnapshot.data != null) ...[
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.building,
                  label: 'Recycling Center',
                  value: centerSnapshot.data!.name,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
              ],
              _buildDetailRow(
                context: context,
                icon: Iconsax.trash,
                label: 'Waste Type',
                value: activity.wasteObject,
                isDark: isDark,
              ),
              _buildDivider(isDark),
              _buildDetailRow(
                context: context,
                icon: Iconsax.weight,
                label: 'Weight',
                value: '${activity.weight.toStringAsFixed(2)} kg',
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingDetailsCard(
      bool isDark,
      BuildContext context,
      RedemptionModel redemption,
      RewardModel? reward,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F36).withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? FColors.darkGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redemption Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? FColors.white : FColors.textPrimary,
            ),
          ),
          const SizedBox(height: FSizes.lg),
          _buildDetailRow(
            context: context,
            icon: Iconsax.ticket,
            label: 'Redemption ID',
            value: redemption.redemptionId,
            isDark: isDark,
          ),
          _buildDivider(isDark),
          if (reward != null) ...[
            _buildDetailRow(
              context: context,
              icon: Iconsax.gift,
              label: 'Reward',
              value: reward.title,
              isDark: isDark,
            ),
            _buildDivider(isDark),
          ],
          _buildDetailRow(
            context: context,
            icon: Iconsax.security_safe,
            label: 'PIN Code',
            value: _formatPinCode(redemption.pinCode),
            isDark: isDark,
            isMonospace: true,
          ),
          _buildDivider(isDark),
          _buildDetailRow(
            context: context,
            icon: Iconsax.verify,
            label: 'Status',
            value: redemption.statusDisplayText,
            isDark: isDark,
            valueColor: redemption.isPending
                ? FColors.warning
                : (redemption.isUsed ? FColors.success : FColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: FColors.primary, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? FColors.white.withOpacity(0.6)
                        : FColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ??
                        (isDark ? FColors.white : FColors.textPrimary),
                    fontFamily: isMonospace ? 'Courier' : null,
                    letterSpacing: isMonospace ? 1.5 : 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FSizes.xs),
      child: Divider(
        color: isDark
            ? FColors.darkGrey.withOpacity(0.3)
            : FColors.grey.withOpacity(0.2),
        height: 1,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatPinCode(String pinCode) {
    if (pinCode.length == 6) {
      return '${pinCode.substring(0, 3)} ${pinCode.substring(3)}';
    }
    return pinCode;
  }
}