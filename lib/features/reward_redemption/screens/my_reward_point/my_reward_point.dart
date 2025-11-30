import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../recycling_center/models/recycle_activity_model.dart';
import '../../controllers/reward_point_controller.dart';
import '../../models/reward_redemption_enums.dart';
import '../transaction_detail/transaction_detail.dart';
import '../../../reward_redemption/models/redemption_model.dart';

class MyRewardPointsScreen extends StatelessWidget {
  const MyRewardPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardPointsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: Text("My Reward Points"),
      ),
      body: Obx(() {
        // Show initial loading when first loading all transactions
        if (controller.isInitialLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: FColors.primary),
                const SizedBox(height: FSizes.md),
                Text(
                  'Loading transactions...',
                  style: TextStyle(
                    color: dark ? FColors.white : FColors.textPrimary,
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
          backgroundColor: dark ? FColors.dark : FColors.light,
          child: Column(
            children: [
              // Compact Points Summary Card
              _buildCompactPointsCard(controller, dark),

              // Modern Tab Bar
              _buildModernTabBar(controller, dark),

              // Date Filter Row
              _buildDateFilterRow(controller, dark, context),

              // Tab Bar View (移除 Stack 和 loading overlay)
              Expanded(
                child: _buildTabBarView(controller, dark),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCompactPointsCard(
      RewardPointsController controller, bool dark) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(FSizes.defaultSpace),
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.xl, vertical: FSizes.lg),
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
              Iconsax.medal,
              color: FColors.white,
              size: 28,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildModernTabBar(RewardPointsController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
        unselectedLabelColor: dark ? FColors.darkGrey : FColors.textSecondary,
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
      bool dark,
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
            constraints: BoxConstraints(
              minHeight: 52,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.md,
            ),
            decoration: BoxDecoration(
              color: dark ? FColors.darkerGrey : FColors.white,
              borderRadius: BorderRadius.circular(12),
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
                    color: dark ? FColors.white : FColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: FSizes.xs),
                Icon(
                  Iconsax.arrow_down_1,
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTabBarView(RewardPointsController controller, bool dark) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        _buildTransactionsList(controller, dark),
        _buildTransactionsList(controller, dark),
        _buildTransactionsList(controller, dark),
      ],
    );
  }

  Widget _buildTransactionsList(
      RewardPointsController controller,
      bool dark,
      ) {
    return Obx(() {
      final items = controller.currentTabItems;

      if (items.isEmpty) {
        return _buildEmptyState(dark);
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
                dark,
                index,
                controller,
              );
            } else {
              return _buildSpendingCard(
                item['data'] as RedemptionModel,
                dark,
                index,
                controller,
              );
            }
          } else if (controller.tabController.index == 1) {
            // Earning tab
            return _buildEarningCard(
              item as RecyclingActivity,
              dark,
              index,
              controller,
            );
          } else {
            // Spending tab
            return _buildSpendingCard(
              item as RedemptionModel,
              dark,
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
      bool dark,
      int index,
      RewardPointsController controller,
      ) {
    // 使用缓存数据，不需要 FutureBuilder
    final center = controller.getCenterByStaffIdCached(activity.centerStaffId);
    final centerName = center?.name ?? 'Recycling Center';

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
              color: dark ? FColors.darkerGrey : FColors.white,
              borderRadius: BorderRadius.circular(12),
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
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            size: 12,
                            color: dark
                                ? FColors.white.withOpacity(0.5)
                                : FColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${FFormatter.formatDate(activity.createdAt)} • ${_formatTime(activity.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: dark
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
                            color: dark
                                ? FColors.white.withOpacity(0.5)
                                : FColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.weight.toStringAsFixed(1)} kg • ${activity.wasteObject}',
                            style: TextStyle(
                              fontSize: 11,
                              color: dark
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
                        color: dark
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
  }

  Widget _buildSpendingCard(
      RedemptionModel redemption,
      bool dark,
      int index,
      RewardPointsController controller,
      ) {
    // 使用缓存数据，不需要 FutureBuilder
    final reward = controller.getRewardByIdCached(redemption.rewardId);
    final rewardTitle = reward?.title ?? 'Reward Redemption';
    final points = reward?.pointsNeeded ?? 0;

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
              color: dark ? FColors.darkerGrey : FColors.white,
              borderRadius: BorderRadius.circular(12),
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
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            size: 12,
                            color: dark
                                ? FColors.white.withOpacity(0.5)
                                : FColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${FFormatter.formatDate(redemption.createdAt)} • ${_formatTime(redemption.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: dark
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
                        color: dark
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
  }

  Widget _buildEmptyState(bool dark) {
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
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 13,
              color: dark
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
