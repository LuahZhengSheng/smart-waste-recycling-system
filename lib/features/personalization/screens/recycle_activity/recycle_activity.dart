import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/recycle_activity_controller.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/personalization/screens/recycle_activity/activity_detail.dart';
import 'package:fyp/features/recycling_center/models/waste_category.dart';
import 'package:fyp/utils/loaders/circular_loader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'dart:math' as math;

class RecycleHistoryScreen extends StatelessWidget {
  const RecycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecycleActivityController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle History'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? FColors.dark : FColors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showFilterModal(context, controller),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.filter, size: 20),
            ),
            tooltip: 'Filter',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: controller.refreshActivities,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.refresh, size: 20),
            ),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activities.isEmpty) {
          return const Center(child: FCircularLoader());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshActivities,
          child: CustomScrollView(
            slivers: [
              // Interactive Donut Chart Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  child: _buildInteractiveChart(controller, dark),
                ),
              ),

              // Statistics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                  child: _buildStatisticsSection(controller, dark),
                ),
              ),

              // Filter Chips with Clear Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  child: _buildFilterChipsWithClear(controller, dark),
                ),
              ),

              // Activities List
              controller.filteredActivities.isEmpty
                  ? SliverFillRemaining(
                child: _buildEmptyState(dark),
              )
                  : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final activity = controller.filteredActivities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
                        child: _buildEnhancedActivityCard(activity, dark, controller),
                      );
                    },
                    childCount: controller.filteredActivities.length,
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: FSizes.defaultSpace),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInteractiveChart(RecycleActivityController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dark ? FColors.darkContainer : FColors.white,
            dark ? FColors.darkContainer.withOpacity(0.8) : FColors.lightContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (dark ? FColors.black : FColors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Waste Category Distribution',
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.black,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          SizedBox(
            height: 220,
            child: GestureDetector(
              onTapDown: (details) {
                _handleChartTap(details, controller);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Donut Chart
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: DonutChartPainter(
                      categories: controller.getCategoryDistribution(),
                      selectedCategory: controller.selectedCategoryForChart.value,
                    ),
                  ),
                  // Center Text
                  Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.selectedCategoryForChart.value != null
                            ? '${controller.getCategoryPercentage(controller.selectedCategoryForChart.value!).toStringAsFixed(1)}%'
                            : 'Tap\nCategory',
                        style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedCategoryForChart.value?.color ?? FColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.selectedCategoryForChart.value != null)
                        Text(
                          controller.selectedCategoryForChart.value!.name,
                          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.textSecondary : FColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: controller.getCategoryDistribution().map((category) {
              return GestureDetector(
                onTap: () => controller.selectCategoryForChart(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.selectedCategoryForChart.value == category
                        ? category.color.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.selectedCategoryForChart.value == category
                          ? category.color
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                          fontWeight: controller.selectedCategoryForChart.value == category
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _handleChartTap(TapDownDetails details, RecycleActivityController controller) {
    final center = const Offset(100, 100); // Center of the 200x200 chart
    final tapPosition = details.localPosition - const Offset(10, 30); // Adjust for padding
    final distance = (tapPosition - center).distance;

    // Check if tap is within the donut ring (between inner and outer radius)
    if (distance >= 60 && distance <= 100) {
      final angle = math.atan2(tapPosition.dy - center.dy, tapPosition.dx - center.dx);
      final normalizedAngle = (angle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);

      final categories = controller.getCategoryDistribution();
      final totalWeight = categories.fold<double>(0, (sum, category) => sum + controller.getCategoryWeight(category));

      double currentAngle = 0;
      for (final category in categories) {
        final categoryWeight = controller.getCategoryWeight(category);
        final sweepAngle = (categoryWeight / totalWeight) * 2 * math.pi;

        if (normalizedAngle >= currentAngle && normalizedAngle <= currentAngle + sweepAngle) {
          controller.selectCategoryForChart(category);
          break;
        }
        currentAngle += sweepAngle;
      }
    }
  }

  Widget _buildStatisticsSection(RecycleActivityController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (dark ? FColors.black : FColors.grey).withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final isFiltered = controller.selectedCategoryForChart.value != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFiltered
                      ? '${controller.selectedCategoryForChart.value!.name} Impact'
                      : 'Your Total Impact',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isFiltered)
                  IconButton(
                    onPressed: () => controller.clearCategoryFilter(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: FColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Iconsax.close_circle, size: 16, color: FColors.error),
                    ),
                    tooltip: 'Clear Filter',
                  ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Total Points',
                    isFiltered
                        ? controller.getCategoryPoints(controller.selectedCategoryForChart.value!).toString()
                        : controller.totalPointsEarned.toString(),
                    Iconsax.star,
                    FColors.warning,
                    dark,
                  ),
                ),
                const SizedBox(width: FSizes.spaceBtwItems),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Weight Recycled',
                    isFiltered
                        ? '${controller.getCategoryWeight(controller.selectedCategoryForChart.value!).toStringAsFixed(1)} kg'
                        : '${controller.totalWeightRecycled.toStringAsFixed(1)} kg',
                    Iconsax.weight,
                    FColors.success,
                    dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Activities',
                    isFiltered
                        ? controller.getCategoryActivityCount(controller.selectedCategoryForChart.value!).toString()
                        : controller.filteredActivities.length.toString(),
                    Iconsax.activity,
                    FColors.info,
                    dark,
                  ),
                ),
                const SizedBox(width: FSizes.spaceBtwItems),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'CO₂ Reduced',
                    isFiltered
                        ? '${controller.getCategoryCO2Reduced(controller.selectedCategoryForChart.value!).toStringAsFixed(1)} kg'
                        : '${controller.totalCO2Reduced.toStringAsFixed(1)} kg',
                    Iconsax.tree,
                    FColors.primary,
                    dark,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: FSizes.iconLg),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.textSecondary : FColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsWithClear(RecycleActivityController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Obx(() => controller.hasActiveFilters
                ? Container(
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: FColors.error.withOpacity(0.3)),
              ),
              child: TextButton.icon(
                onPressed: controller.clearAllFilters,
                icon: const Icon(Iconsax.refresh_2, size: 16, color: FColors.error),
                label: const Text('Clear All', style: TextStyle(color: FColors.error)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            )
                : const SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: FSizes.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Category Filter Chip (shows when category is selected from chart)
              Obx(() => controller.selectedCategoryForChart.value != null
                  ? Padding(
                padding: const EdgeInsets.only(right: FSizes.sm),
                child: _buildEnhancedFilterChip(
                  label: controller.selectedCategoryForChart.value!.name,
                  selected: true,
                  onTap: () => controller.clearCategoryFilter(),
                  color: controller.selectedCategoryForChart.value!.color,
                  dark: dark,
                  isCategory: true,
                ),
              )
                  : const SizedBox.shrink()),

              // Date Filter Chip
              Obx(() => _buildEnhancedFilterChip(
                label: controller.selectedDateFilter.value,
                selected: controller.selectedDateFilter.value != 'All Time',
                onTap: () => _showDateFilterOptions(controller),
                color: FColors.primary,
                dark: dark,
              )),
              const SizedBox(width: FSizes.sm),
              // Status Filter Chip
              Obx(() => _buildEnhancedFilterChip(
                label: 'Status: ${controller.selectedStatusFilter.value}',
                selected: controller.selectedStatusFilter.value != 'All',
                onTap: () => _showStatusFilterOptions(controller),
                color: FColors.secondary,
                dark: dark,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
    required bool dark,
    bool isCategory = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          )
              : null,
          color: !selected
              ? (dark ? FColors.darkContainer : FColors.lightContainer)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color
                : (dark ? FColors.borderPrimary.withOpacity(0.2) : FColors.borderPrimary),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
            Text(
              label,
              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : null,
              ),
            ),
            if (isCategory && selected) ...[
              const SizedBox(width: 4),
              Icon(
                Iconsax.close_circle,
                size: 16,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedActivityCard(RecyclingActivity activity, bool dark, RecycleActivityController controller) {
    final category = controller.getWasteCategoryById(activity.wasteCategoryId);

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
        boxShadow: [
          BoxShadow(
            color: (dark ? FColors.black : FColors.grey).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          onTap: () async {
            final result = await Get.to(
                  () => const ActivityDetailScreen(),
              arguments: activity, // Pass the activity data
            );

            // If activity was deleted, refresh the list
            if (result == true) {
              controller.refreshActivities();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            category.color.withOpacity(0.2),
                            category.color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: FSizes.iconLg,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.wasteObject,
                            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                              color: dark ? FColors.textSecondary : FColors.darkGrey,
                            ),
                          ),
                          Text(
                            activity.formattedCreatedAt,
                            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                              color: dark ? FColors.textSecondary : FColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEnhancedStatusChip(activity.status, activity.statusColor, dark),
                  ],
                ),
                const SizedBox(height: FSizes.md),
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.darkContainer.withOpacity(0.5)
                        : FColors.lightContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        icon: Iconsax.weight,
                        value: activity.formattedWeight,
                        color: FColors.info,
                      ),
                      _buildMetricItem(
                        icon: Iconsax.star,
                        value: '${activity.pointsEarned} pts',
                        color: FColors.warning,
                      ),
                      _buildMetricItem(
                        icon: Iconsax.tree,
                        value: '${(activity.weight * 0.5).toStringAsFixed(1)} kg CO₂',
                        color: FColors.success,
                      ),
                    ],
                  ),
                ),
                if (activity.canDelete) ...[
                  const SizedBox(height: FSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: FColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _showDeleteConfirmation(activity, controller),
                          icon: const Icon(Iconsax.trash, size: 16, color: FColors.error),
                          label: const Text('Delete', style: TextStyle(color: FColors.error)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatusChip(String status, String colorName, bool dark) {
    Color chipColor;
    switch (colorName.toLowerCase()) {
      case 'green':
        chipColor = FColors.success;
        break;
      case 'orange':
        chipColor = FColors.warning;
        break;
      case 'red':
        chipColor = FColors.error;
        break;
      case 'blue':
        chipColor = FColors.info;
        break;
      default:
        chipColor = FColors.darkGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chipColor.withOpacity(0.2),
            chipColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.box_remove,
              size: 80,
              color: dark ? FColors.darkGrey : FColors.grey,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            'No Activities Found',
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Try adjusting your filters or start recycling\nto see your activities here.',
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.textSecondary : FColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Modal and Dialog methods with enhanced styling
  void _showFilterModal(BuildContext context, RecycleActivityController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FHelperFunctions.isDarkMode(context) ? FColors.dark : FColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.cardRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Filter Activities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text('Date Range:', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: FSizes.sm),
            Wrap(
              spacing: FSizes.sm,
              runSpacing: FSizes.sm,
              children: controller.dateFilterOptions.map((option) {
                return Obx(() => FilterChip(
                  label: Text(option),
                  selected: controller.selectedDateFilter.value == option,
                  onSelected: (_) {
                    controller.setDateFilter(option);
                    if (option != 'Custom Range') {
                      Get.back();
                    }
                  },
                  selectedColor: FColors.primary.withOpacity(0.2),
                  checkmarkColor: FColors.primary,
                  backgroundColor: FHelperFunctions.isDarkMode(context)
                      ? FColors.darkContainer
                      : FColors.lightContainer,
                  side: BorderSide(
                    color: controller.selectedDateFilter.value == option
                        ? FColors.primary
                        : (FHelperFunctions.isDarkMode(context)
                        ? FColors.borderPrimary.withOpacity(0.2)
                        : FColors.borderPrimary),
                  ),
                ));
              }).toList(),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text('Status:', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: FSizes.sm),
            Wrap(
              spacing: FSizes.sm,
              runSpacing: FSizes.sm,
              children: controller.statusFilterOptions.map((option) {
                return Obx(() => FilterChip(
                  label: Text(option),
                  selected: controller.selectedStatusFilter.value == option,
                  onSelected: (_) {
                    controller.setStatusFilter(option);
                    Get.back();
                  },
                  selectedColor: FColors.secondary.withOpacity(0.2),
                  checkmarkColor: FColors.secondary,
                  backgroundColor: FHelperFunctions.isDarkMode(context)
                      ? FColors.darkContainer
                      : FColors.lightContainer,
                  side: BorderSide(
                    color: controller.selectedStatusFilter.value == option
                        ? FColors.secondary
                        : (FHelperFunctions.isDarkMode(context)
                        ? FColors.borderPrimary.withOpacity(0.2)
                        : FColors.borderPrimary),
                  ),
                ));
              }).toList(),
            ),
            const SizedBox(height: FSizes.md),
          ],
        ),
      ),
    );
  }

  void _showDateFilterOptions(RecycleActivityController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        decoration: BoxDecoration(
          color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.dark : FColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(FSizes.cardRadiusLg)),
          boxShadow: [
            BoxShadow(
              color: FColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Select Date Range',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FSizes.md),
            ...controller.dateFilterOptions.map((option) {
              return Obx(() => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: controller.selectedDateFilter.value == option
                      ? FColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontWeight: controller.selectedDateFilter.value == option
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: controller.selectedDateFilter.value == option
                          ? FColors.primary
                          : null,
                    ),
                  ),
                  leading: Radio<String>(
                    value: option,
                    groupValue: controller.selectedDateFilter.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDateFilter(value);
                        Get.back();
                      }
                    },
                    activeColor: FColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    controller.setDateFilter(option);
                    Get.back();
                  },
                ),
              ));
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterOptions(RecycleActivityController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        decoration: BoxDecoration(
          color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.dark : FColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(FSizes.cardRadiusLg)),
          boxShadow: [
            BoxShadow(
              color: FColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Filter by Status',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FSizes.md),
            ...controller.statusFilterOptions.map((option) {
              Color statusColor;
              switch (option.toLowerCase()) {
                case 'pending':
                  statusColor = FColors.warning;
                  break;
                case 'approved':
                  statusColor = FColors.success;
                  break;
                case 'rejected':
                  statusColor = FColors.error;
                  break;
                case 'completed':
                  statusColor = FColors.info;
                  break;
                default:
                  statusColor = FColors.darkGrey;
              }

              return Obx(() => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: controller.selectedStatusFilter.value == option
                      ? statusColor.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          fontWeight: controller.selectedStatusFilter.value == option
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: controller.selectedStatusFilter.value == option
                              ? statusColor
                              : null,
                        ),
                      ),
                      if (option != 'All') ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  leading: Radio<String>(
                    value: option,
                    groupValue: controller.selectedStatusFilter.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setStatusFilter(value);
                        Get.back();
                      }
                    },
                    activeColor: statusColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    controller.setStatusFilter(option);
                    Get.back();
                  },
                ),
              ));
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(RecyclingActivity activity, RecycleActivityController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        backgroundColor: FHelperFunctions.isDarkMode(Get.context!) ? FColors.dark : FColors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.trash, color: FColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Activity'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this ${activity.wasteObject} recycling activity? This action cannot be undone.',
          style: Theme.of(Get.context!).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: FHelperFunctions.isDarkMode(Get.context!) ? FColors.white : FColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteActivity(activity);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  final List<WasteCategory> categories;
  final WasteCategory? selectedCategory;

  DonutChartPainter({
    required this.categories,
    required this.selectedCategory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final innerRadius = radius * 0.7; // Thinner ring
    final strokeWidth = 25.0; // Fixed stroke width for thinner appearance

    double startAngle = -math.pi / 2;
    final totalWeight = categories.fold<double>(
        0, (sum, category) => sum + _getCategoryWeight(category)
    );

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = FColors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final backgroundRect = Rect.fromCircle(
        center: center,
        radius: radius - strokeWidth / 2
    );
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Draw category segments
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final weight = _getCategoryWeight(category);
      final sweepAngle = (weight / totalWeight) * 2 * math.pi;

      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Highlight selected category with slightly thicker stroke and shadow
      if (selectedCategory == category) {
        // Draw shadow first
        final shadowPaint = Paint()
          ..color = category.color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        final shadowRect = Rect.fromCircle(
            center: center,
            radius: radius - strokeWidth / 2
        );
        canvas.drawArc(shadowRect, startAngle, sweepAngle, false, shadowPaint);

        // Thicker main stroke
        paint.strokeWidth = strokeWidth + 2;
      }

      final rect = Rect.fromCircle(
          center: center,
          radius: radius - strokeWidth / 2
      );
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;

  double _getCategoryWeight(WasteCategory category) {
    // Mock calculation based on category ID - in real implementation, this would calculate from activities
    switch (category.categoryId) {
      case '1': // Plastic
        return 45.0;
      case '2': // Paper
        return 30.0;
      case '3': // Glass
        return 15.0;
      case '4': // Metal
        return 8.0;
      case '5': // Electronics
        return 2.0;
      default:
        return 5.0;
    }
  }
}