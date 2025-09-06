import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/my_event_controller.dart';

class DateFilterBottomSheet extends StatelessWidget {
  final MyEventsController controller;

  const DateFilterBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(FSizes.cardRadiusLg),
          topRight: Radius.circular(FSizes.cardRadiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.darkGrey : FColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Date',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Date filter options
          Padding(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              children: [
                _buildFilterOption(
                  context,
                  'All Time',
                  'Show all events',
                  Iconsax.calendar,
                      () => _selectFilter(context, 'All Time'),
                ),
                _buildFilterOption(
                  context,
                  'This Week',
                  'Events in current week',
                  Iconsax.calendar_1,
                      () => _selectFilter(context, 'This Week'),
                ),
                _buildFilterOption(
                  context,
                  'This Month',
                  'Events in current month',
                  Iconsax.calendar_2,
                      () => _selectFilter(context, 'This Month'),
                ),
                _buildFilterOption(
                  context,
                  'Custom Range',
                  'Pick your own date range',
                  Iconsax.calendar_edit,
                      () => _selectCustomRange(context),
                ),
              ],
            ),
          ),

          // Show custom date range if selected
          Obx(() => controller.dateFilterType.value == 'Custom'
              ? _buildCustomDateRange(context, dark)
              : const SizedBox()),

          const SizedBox(height: FSizes.defaultSpace),
        ],
      ),
    );
  }

  /// Build filter option
  Widget _buildFilterOption(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      ) {
    final dark = FHelperFunctions.isDarkMode(context);
    final isSelected = controller.dateFilterType.value == title;

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? FColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              border: Border.all(
                color: isSelected
                    ? FColors.primary
                    : (dark ? FColors.darkGrey : FColors.borderPrimary),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FColors.primary
                        : (dark ? FColors.darkGrey.withOpacity(0.3) : FColors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: FSizes.iconSm,
                    color: isSelected
                        ? FColors.white
                        : (dark ? FColors.darkGrey : FColors.textSecondary),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? FColors.primary
                              : (dark ? FColors.white : FColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Iconsax.tick_circle,
                    color: FColors.primary,
                    size: FSizes.iconSm,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build custom date range section
  Widget _buildCustomDateRange(BuildContext context, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: FColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(color: FColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date Range',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: FColors.primary,
            ),
          ),
          const SizedBox(height: FSizes.sm),

          Row(
            children: [
              // Start date
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.white,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      border: Border.all(
                        color: dark ? FColors.darkGrey : FColors.borderPrimary,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                          controller.startDate.value != null
                              ? FHelperFunctions.getFormattedDate(controller.startDate.value!)
                              : 'Select date',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: controller.startDate.value != null
                                ? (dark ? FColors.white : FColors.textPrimary)
                                : (dark ? FColors.darkGrey : FColors.textSecondary),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: FSizes.sm),

              // End date
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.white,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      border: Border.all(
                        color: dark ? FColors.darkGrey : FColors.borderPrimary,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                          controller.endDate.value != null
                              ? FHelperFunctions.getFormattedDate(controller.endDate.value!)
                              : 'Select date',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: controller.endDate.value != null
                                ? (dark ? FColors.white : FColors.textPrimary)
                                : (dark ? FColors.darkGrey : FColors.textSecondary),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: FSizes.sm),

          // Apply custom filter button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (controller.startDate.value != null && controller.endDate.value != null)
                  ? () => _applyCustomFilter(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
                foregroundColor: FColors.white,
                disabledBackgroundColor: (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.3),
              ),
              child: const Text('Apply Custom Filter'),
            ),
          )),
        ],
      ),
    );
  }

  /// Select filter option
  void _selectFilter(BuildContext context, String filterType) {
    controller.updateDateFilter(filterType);
    if (filterType != 'Custom') {
      Navigator.pop(context);
    }
  }

  /// Select custom date range
  void _selectCustomRange(BuildContext context) {
    controller.updateDateFilter('Custom');
  }

  /// Select start date
  void _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.startDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: controller.endDate.value ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final dark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: dark ? FColors.darkContainer : FColors.white,
              onSurface: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.startDate.value = selectedDate;
    }
  }

  /// Select end date
  void _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.endDate.value ??
          (controller.startDate.value?.add(const Duration(days: 1)) ?? DateTime.now()),
      firstDate: controller.startDate.value ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final dark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: dark ? FColors.darkContainer : FColors.white,
              onSurface: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.endDate.value = selectedDate;
    }
  }

  /// Apply custom filter
  void _applyCustomFilter(BuildContext context) {
    controller.updateDateFilter(
      'Custom',
      start: controller.startDate.value,
      end: controller.endDate.value,
    );
    Navigator.pop(context);
  }
}