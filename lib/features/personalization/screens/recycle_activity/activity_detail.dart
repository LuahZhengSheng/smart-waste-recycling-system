import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/activity_detail_controller.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/recycling_center/models/waste_category.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/loaders/circular_loader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityDetailController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Obx(() {
        if (controller.activity.value == null) {
          return const Center(child: FCircularLoader());
        }

        final activity = controller.activity.value!;
        final category = controller.getWasteCategory();

        if (category == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.warning_2, size: 64, color: FColors.warning),
                const SizedBox(height: FSizes.md),
                Text(
                  'Category not found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  'The waste category for this activity could not be loaded.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FSizes.lg),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Custom App Bar with Hero Image
            _buildHeroAppBar(activity, category, dark, controller),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Status and Basic Info Card
                  _buildStatusCard(activity, category, dark, controller),
                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Tab Navigation
                  _buildTabNavigation(controller, dark),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Tab Content
                  Obx(() => _buildTabContent(controller, activity, category, dark)),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeroAppBar(RecyclingActivity activity, WasteCategory category, bool dark, ActivityDetailController controller) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: dark ? FColors.dark : FColors.white,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: FColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      actions: [
        if (activity.canDelete)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: FColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(() => controller.isDeleting.value
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              onPressed: () => _showDeleteConfirmation(activity, controller),
              icon: const Icon(Iconsax.trash, color: FColors.error),
            )),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                category.color.withOpacity(0.1),
                category.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundPatternPainter(
                    color: category.color.withOpacity(0.05),
                  ),
                ),
              ),
              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // AppBar height offset
                    // Category Icon with Glow Effect
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            category.color.withOpacity(0.3),
                            category.color.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 0.7, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          category.icon,
                          color: FColors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: FSizes.md),
                    // Activity Title
                    Text(
                      activity.wasteObject,
                      style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      category.name,
                      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(RecyclingActivity activity, WasteCategory category, bool dark, ActivityDetailController controller) {
    Color statusColor = _getStatusColorFromActivity(activity);

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
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
          // Status Badge and Age
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status',
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.2),
                          statusColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activity.statusDisplayText.toUpperCase(),
                          style: Theme.of(Get.context!).textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.activityAgeText,
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.textSecondary : FColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Weight',
                  activity.formattedWeight,
                  Iconsax.weight,
                  FColors.info,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildMetricCard(
                  'Points',
                  '${activity.pointsEarned} pts',
                  Iconsax.star,
                  FColors.warning,
                  dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'CO₂ Saved',
                  '${controller.carbonFootprintReduced.toStringAsFixed(1)} kg',
                  Iconsax.tree,
                  FColors.success,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildMetricCard(
                  'Submitted',
                  activity.formattedCreatedAt.split(' ')[0],
                  Iconsax.calendar,
                  FColors.primary,
                  dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool dark) {
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
          Icon(icon, color: color, size: FSizes.iconLg),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.textSecondary : FColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(ActivityDetailController controller, bool dark) {
    final tabs = [
      {'id': 'details', 'label': 'Details', 'icon': Iconsax.info_circle},
      {'id': 'timeline', 'label': 'Timeline', 'icon': Iconsax.clock},
      {'id': 'impact', 'label': 'Impact', 'icon': Iconsax.tree},
      {'id': 'center', 'label': 'Center', 'icon': Iconsax.location},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Row(
        children: tabs.map((tab) {
          return Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => controller.selectTab(tab['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: controller.selectedTab.value == tab['id']
                      ? (dark ? FColors.white : FColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  boxShadow: controller.selectedTab.value == tab['id']
                      ? [
                    BoxShadow(
                      color: (dark ? FColors.white : FColors.primary).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 20,
                      color: controller.selectedTab.value == tab['id']
                          ? (dark ? FColors.black : FColors.white)
                          : (dark ? FColors.textSecondary : FColors.darkGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] as String,
                      style: Theme.of(Get.context!).textTheme.labelSmall?.copyWith(
                        color: controller.selectedTab.value == tab['id']
                            ? (dark ? FColors.black : FColors.white)
                            : (dark ? FColors.textSecondary : FColors.darkGrey),
                        fontWeight: controller.selectedTab.value == tab['id']
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(ActivityDetailController controller, RecyclingActivity activity, WasteCategory category, bool dark) {
    switch (controller.selectedTab.value) {
      case 'details':
        return _buildDetailsTab(activity, category, dark);
      case 'timeline':
        return _buildTimelineTab(controller, dark);
      case 'impact':
        return _buildImpactTab(controller, activity, dark);
      case 'center':
        return _buildCenterTab(controller, dark);
      default:
        return _buildDetailsTab(activity, category, dark);
    }
  }

  Widget _buildDetailsTab(RecyclingActivity activity, WasteCategory category, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Details',
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          _buildDetailRow('Category', category.name, category.icon, category.color),
          _buildDetailRow('Item Type', activity.wasteObject, Iconsax.box, FColors.info),
          _buildDetailRow('Weight', activity.formattedWeight, Iconsax.weight, FColors.success),
          _buildDetailRow('Points Earned', '${activity.pointsEarned} points', Iconsax.star, FColors.warning),
          _buildDetailRow('Submitted', activity.formattedCreatedAt, Iconsax.calendar, FColors.primary),
          _buildDetailRow('Activity ID', activity.activityId.isNotEmpty ? activity.activityId : 'Generated automatically', Iconsax.code_circle, FColors.darkGrey),

          const SizedBox(height: FSizes.spaceBtwItems),

          // Category Description
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color.withOpacity(0.1),
                  category.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(color: category.color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.info_circle, color: category.color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Category Information',
                      style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  category.description,
                  style: Theme.of(Get.context!).textTheme.bodyMedium,
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  'Base points: ${category.formattedPoints}',
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Examples: ${category.formattedExamples}',
                  style: Theme.of(Get.context!).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: FColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(ActivityDetailController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Timeline',
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          Obx(() => Column(
            children: controller.timeline.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == controller.timeline.length - 1;

              return _buildTimelineItem(item, isLast, dark);
            }).toList(),
          )),

          // Action buttons for rejected status
          if (controller.activity.value?.isRejected == true) ...[
            const SizedBox(height: FSizes.spaceBtwItems),
            Obx(() => Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.resubmitActivity(),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)
                    )
                        : const Icon(Iconsax.refresh_2),
                    label: Text(controller.isLoading.value ? 'Resubmitting...' : 'Resubmit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FColors.primary,
                      side: const BorderSide(color: FColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ActivityTimelineItem item, bool isLast, bool dark) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case TimelineStatus.completed:
        statusColor = FColors.success;
        statusIcon = Iconsax.tick_circle;
        break;
      case TimelineStatus.pending:
        statusColor = FColors.warning;
        statusIcon = Iconsax.clock;
        break;
      case TimelineStatus.rejected:
        statusColor = FColors.error;
        statusIcon = Iconsax.close_circle;
        break;
      case TimelineStatus.inProgress:
        statusColor = FColors.info;
        statusIcon = Iconsax.timer_1;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    statusColor.withOpacity(0.3),
                    statusColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: FColors.white,
                  size: 16,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: statusColor.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
          ],
        ),
        const SizedBox(width: FSizes.md),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : FSizes.spaceBtwItems),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(Get.context!).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  FHelperFunctions.getFormattedDate(item.timestamp, format: 'MMM dd, yyyy • HH:mm'),
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.textSecondary : FColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactTab(ActivityDetailController controller, RecyclingActivity activity, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Environmental Impact',
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Impact Metrics
          _buildImpactCard(
            'Carbon Footprint Reduced',
            '${controller.carbonFootprintReduced.toStringAsFixed(2)} kg CO₂',
            'By recycling this waste, you prevented ${controller.carbonFootprintReduced.toStringAsFixed(2)} kg of CO₂ from entering the atmosphere.',
            Iconsax.tree,
            FColors.success,
            dark,
          ),
          const SizedBox(height: FSizes.md),

          _buildImpactCard(
            'Energy Saved',
            '${controller.energySaved.toStringAsFixed(1)} kWh',
            'This recycling activity saved enough energy to power an LED bulb for ${(controller.energySaved * 100).toStringAsFixed(0)} hours.',
            Iconsax.flash,
            FColors.warning,
            dark,
          ),
          const SizedBox(height: FSizes.md),

          _buildImpactCard(
            'Water Conserved',
            '${controller.waterSaved.toStringAsFixed(1)} L',
            'Your recycling efforts helped conserve ${controller.waterSaved.toStringAsFixed(1)} liters of fresh water.',
            Iconsax.drop,
            FColors.info,
            dark,
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Achievement Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FColors.primary.withOpacity(0.1),
                  FColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(color: FColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        FColors.primary.withOpacity(0.3),
                        FColors.primary.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.award,
                    color: FColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  'Eco Warrior',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    color: FColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Thank you for making a positive impact on our planet!',
                  style: Theme.of(Get.context!).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(String title, String value, String description, IconData icon, Color color, bool dark) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: FSizes.iconLg),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.textSecondary : FColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterTab(ActivityDetailController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recycling Center',
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Center Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.primary.withOpacity(0.2),
                      FColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.building,
                  color: FColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.recyclingCenterName.value,
                      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    const SizedBox(height: 4),
                    Obx(() => Row(
                      children: [
                        const Icon(Iconsax.star1, color: FColors.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          controller.recyclingCenterRating.value.toString(),
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: FColors.warning,
                          ),
                        ),
                        Text(
                          ' • Verified Center',
                          style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                            color: FColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Center Details
          _buildCenterDetail(
            'Address',
            controller.recyclingCenterAddress.value,
            Iconsax.location,
            FColors.primary,
          ),
          _buildCenterDetail(
            'Phone',
            controller.recyclingCenterPhone.value,
            Iconsax.call,
            FColors.info,
          ),
          _buildCenterDetail(
            'Operating Hours',
            'Mon - Sat: 8:00 AM - 6:00 PM\nSun: 9:00 AM - 4:00 PM',
            Iconsax.clock,
            FColors.success,
          ),

          const SizedBox(height: FSizes.spaceBtwItems),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Open map or navigation
                    FDeviceUtils.launchUrl('https://maps.google.com/?q=${Uri.encodeComponent(controller.recyclingCenterAddress.value)}');
                  },
                  icon: const Icon(Iconsax.location),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FColors.primary,
                    side: const BorderSide(color: FColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    FDeviceUtils.launchUrl('tel:${controller.recyclingCenterPhone.value}');
                  },
                  icon: const Icon(Iconsax.call),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Additional Info
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer.withOpacity(0.5) : FColors.lightContainer,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.info_circle, color: FColors.info, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Center Information',
                      style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: FColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  'This is a certified recycling center that follows all environmental guidelines and regulations. They accept various types of waste materials and ensure proper recycling processes.',
                  style: Theme.of(Get.context!).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterDetail(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: FColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColorFromActivity(RecyclingActivity activity) {
    if (activity.isPending) return FColors.warning;
    if (activity.isApproved) return FColors.success;
    if (activity.isRejected) return FColors.error;
    if (activity.isCompleted) return FColors.info;
    return FColors.darkGrey;
  }

  void _showDeleteConfirmation(RecyclingActivity activity, ActivityDetailController controller) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this activity?',
              style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Activity: ${activity.wasteObject}',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            Text(
              'Points: ${activity.pointsEarned} pts',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            const SizedBox(height: FSizes.sm),
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: FColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: FColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: FColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: FHelperFunctions.isDarkMode(Get.context!) ? FColors.white : FColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteActivity();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw scattered circles
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 20 + 5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}