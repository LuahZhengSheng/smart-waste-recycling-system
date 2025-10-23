import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../personalization/models/recycle_activity_model.dart';
import '../../controllers/reward_point_controller.dart';
import '../../models/reward_redemption_enums.dart';
import '../transaction_detail/transaction_detail.dart';
import '../../../../data/repositories/personalization/recycling_activity_repository.dart';
import '../../../reward_redemption/models/redemption_model.dart';

class MyRewardPointsScreen extends StatelessWidget {
  const MyRewardPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardPointsController());
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8FAFC),
      appBar: FAppBar(
        showBackArrow: true,
        title: Text("My Reward Points"),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.allEarningActivities.isEmpty &&
            controller.allSpendingRedemptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: FColors.primary),
                const SizedBox(height: FSizes.md),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: isDark ? FColors.white : FColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: FColors.primary,
          backgroundColor: isDark ? const Color(0xFF1A1F36) : Colors.white,
          child: Column(
            children: [
              // Compact Points Summary Card
              _buildCompactPointsCard(controller, isDark),

              // Modern Tab Bar
              _buildModernTabBar(controller, isDark),

              // Date Filter Row
              _buildDateFilterRow(controller, isDark, context),

              // Tab Bar View
              Expanded(
                child: _buildTabBarView(controller, isDark),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCompactPointsCard(RewardPointsController controller, bool isDark) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(FSizes.defaultSpace),
      padding: const EdgeInsets.symmetric(horizontal: FSizes.xl, vertical: FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FColors.primary,
            FColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: FColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
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
                    '${controller.currentPoints.value}',
                    style: const TextStyle(
                      color: FColors.white,
                      fontSize: 32,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.award5,
              color: FColors.white,
              size: 28,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildModernTabBar(RewardPointsController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F36).withOpacity(0.6)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [FColors.primary, FColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: FColors.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: FColors.white,
        unselectedLabelColor: isDark
            ? FColors.white.withOpacity(0.6)
            : const Color(0xFF718096),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Earning'),
          Tab(text: 'Spending'),
        ],
      ),
    );
  }

  Widget _buildDateFilterRow(
      RewardPointsController controller,
      bool isDark,
      BuildContext context,
      ) {
    return Obx(() {
      final filterType = controller.selectedFilterType.value;
      final dateRange = controller.selectedDateRange.value;

      String displayText = '';
      if (dateRange != null) {
        if (filterType == DateFilterType.today) {
          displayText = DateFormat('dd MMM yyyy').format(dateRange.start);
        } else {
          displayText =
          '${DateFormat('dd MMM yy').format(dateRange.start)} - ${DateFormat('dd MMM yy').format(dateRange.end)}';
        }
      }

      return Container(
        margin: const EdgeInsets.all(FSizes.defaultSpace),
        child: InkWell(
          onTap: () => controller.showDateFilterBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1F36).withOpacity(0.6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? FColors.darkGrey.withOpacity(0.3)
                    : FColors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.calendar,
                  color: FColors.primary,
                  size: 18,
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  displayText,
                  style: TextStyle(
                    color: isDark ? FColors.white : FColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: FSizes.xs),
                Icon(
                  Iconsax.arrow_down_1,
                  color: isDark ? FColors.darkGrey : FColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabBarView(RewardPointsController controller, bool isDark) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        _buildTransactionsList(controller, isDark),
        _buildTransactionsList(controller, isDark),
        _buildTransactionsList(controller, isDark),
      ],
    );
  }

  Widget _buildTransactionsList(
      RewardPointsController controller,
      bool isDark,
      ) {
    return Obx(() {
      final items = controller.currentTabItems;

      if (items.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          // Handle different tab views
          if (controller.tabController.index == 0) {
            // All tab - mixed items
            final type = item['type'] as String;
            if (type == 'earning') {
              return _buildEarningCard(
                item['data'] as RecyclingActivity,
                isDark,
                index,
                controller,
              );
            } else {
              return _buildSpendingCard(
                item['data'] as RedemptionModel,
                isDark,
                index,
                controller,
              );
            }
          } else if (controller.tabController.index == 1) {
            // Earning tab
            return _buildEarningCard(
              item as RecyclingActivity,
              isDark,
              index,
              controller,
            );
          } else {
            // Spending tab
            return _buildSpendingCard(
              item as RedemptionModel,
              isDark,
              index,
              controller,
            );
          }
        },
      );
    });
  }

  Widget _buildEarningCard(
      RecyclingActivity activity,
      bool isDark,
      int index,
      RewardPointsController controller,
      ) {
    return FutureBuilder(
      future: controller.getCenterByStaffId(activity.centerStaffId),
      builder: (context, centerSnapshot) {
        final centerName = centerSnapshot.hasData && centerSnapshot.data != null
            ? centerSnapshot.data!.name
            : 'Recycling Center';

        return Container(
          margin: EdgeInsets.only(
            bottom: FSizes.md,
            top: index == 0 ? FSizes.sm : 0,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.to(() => TransactionDetailsScreen(
                transactionId: activity.activityId,
                transactionType: 'earning',
              )),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1F36).withOpacity(0.8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? FColors.darkGrey.withOpacity(0.3)
                        : FColors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            centerName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? FColors.white : FColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: FSizes.xs),
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 12,
                                color: isDark
                                    ? FColors.white.withOpacity(0.5)
                                    : FColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${FFormatter.formatDate(activity.createdAt)} • ${_formatTime(activity.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? FColors.white.withOpacity(0.6)
                                      : FColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FSizes.xs),
                          Row(
                            children: [
                              Icon(
                                Iconsax.weight,
                                size: 12,
                                color: isDark
                                    ? FColors.white.withOpacity(0.5)
                                    : FColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${activity.weight.toStringAsFixed(1)} kg • ${activity.wasteObject}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? FColors.white.withOpacity(0.6)
                                      : FColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${activity.pointsEarned}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: FColors.success,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Pts',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? FColors.white.withOpacity(0.6)
                                : FColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpendingCard(
      RedemptionModel redemption,
      bool isDark,
      int index,
      RewardPointsController controller,
      ) {
    return FutureBuilder(
      future: controller.getRewardById(redemption.rewardId),
      builder: (context, rewardSnapshot) {
        final rewardTitle = rewardSnapshot.hasData
            ? rewardSnapshot.data!.title
            : 'Reward Redemption';
        final points = rewardSnapshot.hasData
            ? rewardSnapshot.data!.pointsNeeded
            : 0;

        return Container(
          margin: EdgeInsets.only(
            bottom: FSizes.md,
            top: index == 0 ? FSizes.sm : 0,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.to(() => TransactionDetailsScreen(
                transactionId: redemption.redemptionId,
                transactionType: 'spending',
              )),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1F36).withOpacity(0.8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? FColors.darkGrey.withOpacity(0.3)
                        : FColors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rewardTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? FColors.white : FColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: FSizes.xs),
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 12,
                                color: isDark
                                    ? FColors.white.withOpacity(0.5)
                                    : FColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${FFormatter.formatDate(redemption.createdAt)} • ${_formatTime(redemption.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? FColors.white.withOpacity(0.6)
                                      : FColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-$points',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: FColors.error,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Pts',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? FColors.white.withOpacity(0.6)
                                : FColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FColors.primary.withOpacity(0.1),
                  FColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Iconsax.empty_wallet,
              size: 40,
              color: FColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: FSizes.xl),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? FColors.white : FColors.textPrimary,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? FColors.white.withOpacity(0.6)
                  : FColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}