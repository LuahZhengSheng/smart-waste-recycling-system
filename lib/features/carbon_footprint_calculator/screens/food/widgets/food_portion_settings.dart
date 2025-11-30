import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/food_controller.dart';

class FoodPortionSettingsScreen extends StatelessWidget {
  const FoodPortionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FoodController.instance;
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Portion Size Settings'),
        showBackArrow: true,
        actionButtonText: 'Reset All',
        onActionButtonPressed: () => _showResetDialog(context, controller),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.food.withOpacity(0.1)
                    : FColors.food.withOpacity(0.05),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: FColors.food.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.xs),
                    decoration: BoxDecoration(
                      color: FColors.food.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    ),
                    child: Icon(
                      Iconsax.info_circle,
                      color: FColors.food,
                      size: FSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Portion Sizes',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: FColors.food,
                          ),
                        ),
                        const SizedBox(height: FSizes.xs),
                        Text(
                          'Adjust the default weight for each food type to match your typical serving size. All calculations will update automatically.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Portion sliders
            _buildPortionSlider(
              context: context,
              title: 'Red Meat',
              subtitle: 'Beef, lamb, mutton - per serving',
              icon: Iconsax.danger,
              color: FColors.error,
              key: 'beef',
              controller: controller,
              dark: dark,
            ),
            const SizedBox(height: FSizes.md),

            _buildPortionSlider(
              context: context,
              title: 'Poultry',
              subtitle: 'Chicken - per serving',
              icon: Iconsax.box,
              color: FColors.warning,
              key: 'poultry',
              controller: controller,
              dark: dark,
            ),
            const SizedBox(height: FSizes.md),

            _buildPortionSlider(
              context: context,
              title: 'Fish & Seafood',
              subtitle: 'Fish, prawns - per serving',
              icon: Iconsax.box_time,
              color: FColors.info,
              key: 'seafood',
              controller: controller,
              dark: dark,
            ),
            const SizedBox(height: FSizes.md),

            _buildPortionSlider(
              context: context,
              title: 'Dairy & Eggs',
              subtitle: 'Milk, cheese, eggs - per serving',
              icon: Iconsax.milk,
              color: FColors.secondary,
              key: 'dairy',
              controller: controller,
              dark: dark,
            ),
            const SizedBox(height: FSizes.md),

            _buildPortionSlider(
              context: context,
              title: 'Rice & Grains',
              subtitle: 'Rice, noodles, bread - per serving',
              icon: Iconsax.cup,
              color: FColors.primary,
              key: 'grains',
              controller: controller,
              dark: dark,
            ),
            const SizedBox(height: FSizes.md),

            _buildPortionSlider(
              context: context,
              title: 'Plant-Based Foods',
              subtitle: 'Vegetables, fruits - per serving',
              icon: Iconsax.tree,
              color: FColors.success,
              key: 'plants',
              controller: controller,
              dark: dark,
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Tip card
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.success.withOpacity(0.1)
                    : FColors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: FColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.lamp_on,
                    color: FColors.success,
                    size: FSizes.iconSm,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tip: Standard Serving Sizes',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: FColors.success,
                          ),
                        ),
                        const SizedBox(height: FSizes.xs),
                        Text(
                          '• Meat/Fish: 150g (palm-sized)\n• Rice/Grains: 150g (1 cup cooked)\n• Dairy: 100g (small bowl)\n• Vegetables: 100g (1 cup)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortionSlider({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String key,
    required FoodController controller,
    required bool dark,
  }) {
    return Obx(() {
      final currentWeight = controller.portionWeights[key]!.value;
      final gramValue = (currentWeight * 1000).toInt();

      return Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: FSizes.iconMd,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark
                              ? FColors.darkGrey
                              : FColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Text(
                    '${gramValue}g',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),

            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
                valueIndicatorColor: color,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                valueIndicatorTextStyle: TextStyle(
                  color: dark ? FColors.dark : FColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              child: Slider(
                value: currentWeight,
                min: 0.05,
                max: 0.5,
                divisions: 45,
                label: '${gramValue}g',
                onChanged: (value) {
                  controller.updatePortionWeight(key, value);
                },
              ),
            ),

            // Quick select buttons
            Wrap(
              spacing: FSizes.xs,
              runSpacing: FSizes.xs,
              children: [
                _buildQuickWeightChip(
                  context: context,
                  label: '50g',
                  value: 0.05,
                  currentValue: currentWeight,
                  color: color,
                  dark: dark,
                  onTap: () => controller.updatePortionWeight(key, 0.05),
                ),
                _buildQuickWeightChip(
                  context: context,
                  label: '100g',
                  value: 0.1,
                  currentValue: currentWeight,
                  color: color,
                  dark: dark,
                  onTap: () => controller.updatePortionWeight(key, 0.1),
                ),
                _buildQuickWeightChip(
                  context: context,
                  label: '150g',
                  value: 0.15,
                  currentValue: currentWeight,
                  color: color,
                  dark: dark,
                  onTap: () => controller.updatePortionWeight(key, 0.15),
                ),
                _buildQuickWeightChip(
                  context: context,
                  label: '200g',
                  value: 0.2,
                  currentValue: currentWeight,
                  color: color,
                  dark: dark,
                  onTap: () => controller.updatePortionWeight(key, 0.2),
                ),
                _buildQuickWeightChip(
                  context: context,
                  label: '250g',
                  value: 0.25,
                  currentValue: currentWeight,
                  color: color,
                  dark: dark,
                  onTap: () => controller.updatePortionWeight(key, 0.25),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickWeightChip({
    required BuildContext context,
    required String label,
    required double value,
    required double currentValue,
    required Color color,
    required bool dark,
    required VoidCallback onTap,
  }) {
    // 修复选中判断逻辑 - 使用更严格的比较
    final isSelected = (currentValue - value).abs() < 0.001;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (dark ? FColors.darkContainer : FColors.light),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected
                ? (dark ? FColors.dark : FColors.white)
                : (dark ? FColors.darkGrey : FColors.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, FoodController controller) {
    final dark = FHelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dark ? FColors.darkContainer : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          ),
          title: Row(
            children: [
              Icon(
                Iconsax.warning_2,
                color: FColors.warning,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Reset All Portions?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'This will reset all portion sizes to their default values. This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.resetPortionWeights();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.food,
                foregroundColor: FColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
              ),
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }
}