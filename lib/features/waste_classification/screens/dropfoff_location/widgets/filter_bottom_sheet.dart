import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/dropoff_location_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DropoffLocationsController.instance;
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.dark : FColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(FSizes.cardRadiusLg + 8),
          topRight: Radius.circular(FSizes.cardRadiusLg + 8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: FSizes.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: dark ? FColors.darkGrey : FColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: FSizes.md),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      child: Icon(
                        Iconsax.setting_4,
                        color: FColors.primary,
                        size: FSizes.iconMd,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    controller.clearFilters();
                  },
                  icon: const Icon(Iconsax.refresh, size: FSizes.iconSm),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: FColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FSizes.md),

          // Filter Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Radius
                  _buildSectionHeader(
                    context,
                    icon: Iconsax.radar,
                    title: 'Search Radius',
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Obx(() => Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Distance',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: dark ? FColors.white : FColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.sm,
                                vertical: FSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: FColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                              ),
                              child: Text(
                                '${(controller.currentRadius.value / 1000).toStringAsFixed(1)} km',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: FColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: FColors.primary,
                            inactiveTrackColor: FColors.primary.withOpacity(0.2),
                            thumbColor: FColors.primary,
                            overlayColor: FColors.primary.withOpacity(0.2),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: controller.currentRadius.value / 1000,
                            min: 1.0,
                            max: 50.0,
                            divisions: 49,
                            label: '${(controller.currentRadius.value / 1000).toStringAsFixed(1)} km',
                            onChanged: (value) => controller.updateRadius(value),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1 km',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: dark ? FColors.darkGrey : FColors.textSecondary,
                              ),
                            ),
                            Text(
                              '50 km',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: dark ? FColors.darkGrey : FColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Center Type
                  _buildSectionHeader(
                    context,
                    icon: Iconsax.medal_star,
                    title: 'Center Type',
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.togglePartnerFilter,
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                        child: Padding(
                          padding: const EdgeInsets.all(FSizes.md),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(FSizes.xs),
                                decoration: BoxDecoration(
                                  color: controller.showPartnerOnly.value
                                      ? FColors.primary
                                      : (dark ? FColors.dark : FColors.white),
                                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                                  border: Border.all(
                                    color: controller.showPartnerOnly.value
                                        ? FColors.primary
                                        : (dark ? FColors.darkGrey : FColors.borderPrimary),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  controller.showPartnerOnly.value
                                      ? Iconsax.tick_circle5
                                      : Iconsax.tick_circle,
                                  size: 20,
                                  color: controller.showPartnerOnly.value
                                      ? FColors.white
                                      : (dark ? FColors.darkGrey : FColors.grey),
                                ),
                              ),
                              const SizedBox(width: FSizes.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Partner Centers Only',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: dark ? FColors.white : FColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: FSizes.xs),
                                    Text(
                                      'Show only centers where you can earn reward points',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Opening Hours Filter
                  _buildSectionHeader(
                    context,
                    icon: Iconsax.clock,
                    title: 'Opening Hours',
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Obx(() => Column(
                    children: [
                      _buildOpeningHoursOption(
                        context,
                        title: 'Any Time',
                        subtitle: 'Show all centers regardless of opening hours',
                        filter: OpeningHoursFilter.anyTime,
                        controller: controller,
                        dark: dark,
                      ),
                      const SizedBox(height: FSizes.sm),
                      _buildOpeningHoursOption(
                        context,
                        title: 'Open Now',
                        subtitle: 'Only show centers currently open',
                        filter: OpeningHoursFilter.openNow,
                        controller: controller,
                        dark: dark,
                      ),
                      const SizedBox(height: FSizes.sm),
                      _buildOpeningHoursOption(
                        context,
                        title: 'Open 24 Hours',
                        subtitle: 'Only show centers open 24/7',
                        filter: OpeningHoursFilter.open24Hours,
                        controller: controller,
                        dark: dark,
                      ),
                    ],
                  )),

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Rating Filter
                  _buildSectionHeader(
                    context,
                    icon: Iconsax.star1,
                    title: 'Minimum Rating',
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Obx(() => Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rating',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: dark ? FColors.white : FColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.star1,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: FSizes.xs),
                                Text(
                                  controller.minRating.value > 0
                                      ? '${controller.minRating.value.toStringAsFixed(1)}+'
                                      : 'Any',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: FColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.amber,
                            inactiveTrackColor: Colors.amber.withOpacity(0.2),
                            thumbColor: Colors.amber,
                            overlayColor: Colors.amber.withOpacity(0.2),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: controller.minRating.value,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            label: controller.minRating.value > 0
                                ? controller.minRating.value.toStringAsFixed(1)
                                : 'Any',
                            onChanged: (value) => controller.updateMinRating(value),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Accepted Materials Filter
                  _buildSectionHeader(
                    context,
                    icon: Iconsax.box,
                    title: 'Accepted Materials',
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Obx(() => Wrap(
                    spacing: FSizes.sm,
                    runSpacing: FSizes.sm,
                    children: controller.availableMaterials.map((material) {
                      final isSelected = controller.selectedMaterials.contains(material);
                      return FilterChip(
                        label: Text(material),
                        selected: isSelected,
                        onSelected: (_) => controller.toggleMaterialFilter(material),
                        backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                        selectedColor: FColors.primary.withOpacity(0.2),
                        checkmarkColor: FColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? FColors.primary
                              : (dark ? FColors.white : FColors.textPrimary),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? FColors.primary
                              : (dark ? FColors.darkGrey : FColors.borderPrimary),
                        ),
                      );
                    }).toList(),
                  )),

                  const SizedBox(height: FSizes.lg),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.only(
              left: FSizes.lg,
              right: FSizes.lg,
              top: FSizes.md,
              bottom: MediaQuery.of(context).padding.bottom + FSizes.md,
            ),
            decoration: BoxDecoration(
              color: dark ? FColors.dark : FColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FColors.primary,
                  foregroundColor: FColors.white,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: FSizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool dark,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          color: FColors.primary,
          size: FSizes.iconMd,
        ),
        const SizedBox(width: FSizes.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHoursOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required OpeningHoursFilter filter,
        required DropoffLocationsController controller,
        required bool dark,
      }) {
    final isSelected = controller.openingHoursFilter.value == filter;

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        border: Border.all(
          color: isSelected ? FColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.updateOpeningHoursFilter(filter),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          child: Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.xs),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FColors.primary
                        : (dark ? FColors.dark : FColors.white),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    border: Border.all(
                      color: isSelected
                          ? FColors.primary
                          : (dark ? FColors.darkGrey : FColors.borderPrimary),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
                    size: 20,
                    color: isSelected
                        ? FColors.white
                        : (dark ? FColors.darkGrey : FColors.grey),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? FColors.white : FColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}