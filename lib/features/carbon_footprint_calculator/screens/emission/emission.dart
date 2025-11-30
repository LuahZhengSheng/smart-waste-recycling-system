import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/emission_controller.dart';
import '../../utils/emission_utils.dart';

class EmissionsScreen extends StatelessWidget {
  const EmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmissionsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('My Emissions'),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Annual Carbon Footprint',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: FSizes.xs),
                  Text(
                    'Compare your emissions with others',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Chart Section
                  _buildChartSection(context, controller, dark),

                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Legend
                  _buildLegend(context, controller, dark),

                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Comparison Card
                  _buildComparisonCard(context, controller, dark),

                  const SizedBox(height: FSizes.md),

                  // Action Card
                  _buildActionCard(context, controller, dark),
                ],
              ),
            )),
    );
  }

  Widget _buildChartSection(
      BuildContext context, EmissionsController controller, bool dark) {
    return Obx(() => Container(
          height: 350,
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Chart content
              Padding(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Column(
                  children: [
                    // Chart title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Emissions Comparison',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (controller.canShowChart)
                          Text(
                            't CO₂e',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: dark
                                          ? FColors.darkGrey
                                          : FColors.textSecondary,
                                    ),
                          ),
                      ],
                    ),
                    const SizedBox(height: FSizes.lg),

                    // Bars
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildEmissionBar(
                            context,
                            controller,
                            'You',
                            controller.userEmissions,
                            true,
                            dark,
                          ),
                          _buildEmissionBar(
                            context,
                            controller,
                            'Average',
                            controller.avgEmissions,
                            false,
                            dark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Locked overlay
// Locked overlay
              if (!controller.canShowChart)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.lock,
                            size: 48,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(height: FSizes.md),
                          Text(
                            !controller.hasCalculatedEmissions.value
                                ? 'Calculate Your Emissions'
                                : 'Not enough data yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: FSizes.xs),
                          Text(
                            !controller.hasCalculatedEmissions.value
                                ? 'Start by entering your emission data'
                                : 'We need more users to calculate the average',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildEmissionBar(
    BuildContext context,
    EmissionsController controller,
    String label,
    Map<String, double> data,
    bool isUser,
    bool dark,
  ) {
    final total = controller.getTotalEmissions(data);
    final totalTons = total / 1000.0;
    final categories = ['Land Travel', 'Air Travel', 'Energy', 'Food', 'Stuff'];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 给柱子一个最大高度，比父高度略小，避免 top/bottom padding 后溢出
                  final maxBarHeight = constraints.maxHeight - 16; // 预留一点空间

                  return GestureDetector(
                    onTap: isUser && controller.hasCalculatedEmissions.value
                        ? () => _showDetailedBreakdown(context, data, dark)
                        : null,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 100),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      child: total > 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: _buildStackedBarsWithMaxHeight(
                                categories,
                                data,
                                total,
                                dark,
                                maxBarHeight,
                              ),
                            )
                          : Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: dark
                                    ? FColors.darkGrey.withOpacity(0.3)
                                    : FColors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(
                                    FSizes.borderRadiusMd),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: FSizes.sm),
            // Label
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            // Total

            Text(
              total > 0 ? totalTons.toStringAsFixed(2) : '0.00',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStackedBarsWithMaxHeight(
    List<String> categories,
    Map<String, double> data,
    double total,
    bool dark,
    double maxHeight,
  ) {
    return categories.map((category) {
      final value = data[category] ?? 0.0;
      if (value == 0) return const SizedBox.shrink();

      final height = (value / total) * maxHeight;
      final color = EmissionUtils.getCategoryColor(category, darkMode: dark);

      return Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: total == value
              ? BorderRadius.circular(FSizes.borderRadiusMd)
              : null,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
      BuildContext context, EmissionsController controller, bool dark) {
    final categories = [
      ('Land Travel', 'land_travel'),
      ('Air Travel', 'air_travel'),
      ('Energy', 'energy'),
      ('Food', 'food'),
      ('Stuff', 'stuff'),
    ];

    return Wrap(
      spacing: FSizes.md,
      runSpacing: FSizes.sm,
      children: categories.map((item) {
        final color = EmissionUtils.getCategoryColor(item.$2, darkMode: dark);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              item.$1,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildComparisonCard(
      BuildContext context, EmissionsController controller, bool dark) {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: dark
                  ? [
                      FColors.darkContainer,
                      FColors.darkContainer.withOpacity(0.7)
                    ]
                  : [FColors.primary.withOpacity(0.1), FColors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            border: Border.all(
              color:
                  dark ? FColors.borderDark : FColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                controller.comparisonPercentage.value > 0
                    ? Iconsax.arrow_up_1
                    : controller.comparisonPercentage.value < 0
                        ? Iconsax.arrow_down
                        : Iconsax.minus,
                color: controller.getComparisonColor(dark),
                size: 32,
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                controller.comparisonText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: controller.getComparisonColor(dark),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.xs),
              Text(
                controller.canShowChart
                    ? 'Compared to all users'
                    : 'Comparison will appear once enough data is available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }

  Widget _buildActionCard(
      BuildContext context, EmissionsController controller, bool dark) {
    return Obx(() {
      final completedCount = controller.getCompletedCategoriesCount();
      final allCompleted = controller.allCategoriesCompleted;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: FColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allCompleted ? Iconsax.tick_circle : Iconsax.edit,
                  color: FColors.primary,
                  size: 32,
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allCompleted
                            ? 'Profile Complete!'
                            : 'Complete Your Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: FColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        allCompleted
                            ? 'All categories completed'
                            : '$completedCount/5 categories completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark
                                  ? FColors.darkGrey
                                  : FColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.navigateToEmissionsProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Text(
                  allCompleted ? 'Update Emissions' : 'Calculate Emissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: FColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showDetailedBreakdown(
      BuildContext context, Map<String, double> data, bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? FColors.darkContainer : FColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Emissions Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: FSizes.md),
            ...data.entries.map((entry) {
              final color =
                  EmissionUtils.getCategoryColor(entry.key, darkMode: dark);
              final tons = entry.value / 1000.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: FSizes.xs),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${tons.toStringAsFixed(2)} t',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
