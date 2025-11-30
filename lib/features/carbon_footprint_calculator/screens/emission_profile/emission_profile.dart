import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/emission_profile_controller.dart';

class EmissionsProfileScreen extends StatelessWidget {
  const EmissionsProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmissionsProfileController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Emissions Profile'),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Total
            _buildHeader(context, controller, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Progress Indicator
            _buildProgressCard(context, controller, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Categories Title
            Text(
              'Emission Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Tap a category to add or update your data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            const SizedBox(height: FSizes.md),

            // Categories List
            Obx(() => Column(
              children: controller.categories.map((category) {
                return _buildCategoryCard(context, controller, category, dark);
              }).toList(),
            )),
          ],
        ),
      )),
    );
  }

  Widget _buildHeader(
      BuildContext context, EmissionsProfileController controller, bool dark) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FColors.primary,
            FColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: FColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.chart,
            color: FColors.white,
            size: 48,
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Total Annual Emissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            controller.totalEmissionTonsLabel,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: FColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'CO₂e',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildProgressCard(
      BuildContext context, EmissionsProfileController controller, bool dark) {
    return Obx(() {
      final progress = controller.completedCategoriesCount / 5;
      return Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: dark ? FColors.borderDark : FColors.borderPrimary,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Completion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${controller.completedCategoriesCount}/5',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                dark ? FColors.darkGrey.withOpacity(0.3) : FColors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? FColors.success : FColors.primary,
                ),
              ),
            ),
            if (progress < 1.0) ...[
              const SizedBox(height: FSizes.sm),
              Text(
                'Complete ${5 - controller.completedCategoriesCount} more ${(5 - controller.completedCategoriesCount) == 1 ? "category" : "categories"} for full profile',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCategoryCard(BuildContext context,
      EmissionsProfileController controller, EmissionCategory category, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: category.emission > 0
              ? category.getColor(darkMode: dark).withOpacity(0.3)
              : (dark ? FColors.borderDark : FColors.borderPrimary),
          width: category.emission > 0 ? 2 : 1,
        ),
        boxShadow: [
          if (category.emission > 0)
            BoxShadow(
              color: category.getColor(darkMode: dark).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToCategory(category),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: category.getBackgroundColor(darkMode: dark),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.getColor(darkMode: dark),
                    size: FSizes.iconLg,
                  ),
                ),
                const SizedBox(width: FSizes.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        category.emission > 0
                            ? '${(category.emission / 1000).toStringAsFixed(2)} t CO₂e'
                            : 'Not calculated yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: category.emission > 0
                              ? category.getColor(darkMode: dark)
                              : (dark ? FColors.darkGrey : FColors.textSecondary),
                          fontWeight: category.emission > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Icon
                Icon(
                  category.emission > 0
                      ? Iconsax.tick_circle5
                      : Iconsax.arrow_right_3,
                  color: category.emission > 0
                      ? FColors.success
                      : (dark ? FColors.darkGrey : FColors.textSecondary),
                  size: FSizes.iconMd,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}