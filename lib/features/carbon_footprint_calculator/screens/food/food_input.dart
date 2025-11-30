import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/emission_config/food.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/food_controller.dart';
import '../../utils/emission_common_widgets.dart';
import '../../utils/emission_info_dialog.dart';
import 'widgets/food_portion_settings.dart';

class FoodInputScreen extends StatelessWidget {
  const FoodInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FoodController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Food'),
        showBackArrow: true,
        actionButtonText: 'Reset',
        onActionButtonPressed: () => controller.clearInputs(),
      ),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonEmissionWidgets.buildHeaderCard(
                context: context,
                title: 'Annual Food Emissions',
                subtitle: 'Track your dietary carbon footprint',
                icon: Iconsax.shop,
                color: FColors.food,
                dark: dark,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              CommonEmissionWidgets.buildInfoCard(
                context: context,
                dataSource: 'Poore & Nemecek (2018)',
                dataSet: 'Global food emissions via Our World in Data',
                dataYear: 2018,
                dark: dark,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              CommonEmissionWidgets.buildInstructionsCard(
                context: context,
                instructions: const [
                  'Select how often you eat each food type per week',
                  'Use the slider to adjust frequency (0-7+ times/week)',
                  'Foods with higher emissions are marked in red',
                  'Plant-based foods have the lowest carbon impact',
                ],
                dark: dark,
              ),
              const SizedBox(height: FSizes.md),

              _buildPortionSettingsButton(context, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Red Meat
              _buildFoodCategory(
                context: context,
                controller: controller,
                dark: dark,
                title: 'Red Meat',
                subtitle: 'Beef, lamb, mutton',
                icon: Iconsax.danger,
                color: FColors.error,
                frequencyKey: 'beef',
                emissionObs: controller.beefEmissions,
                impactLevel: 'HIGH IMPACT',
                metadataKey: 'beef',
              ),
              const SizedBox(height: FSizes.md),

              // Poultry
              _buildFoodCategory(
                context: context,
                controller: controller,
                dark: dark,
                title: 'Poultry',
                subtitle: 'Chicken (no pork in Malaysia)',
                icon: Iconsax.box,
                color: FColors.warning,
                frequencyKey: 'poultry',
                emissionObs: controller.poultryEmissions,
                impactLevel: 'MEDIUM IMPACT',
                metadataKey: 'chicken',
              ),
              const SizedBox(height: FSizes.md),

              // Fish & Seafood
              _buildFoodCategory(
                context: context,
                controller: controller,
                dark: dark,
                title: 'Fish & Seafood',
                subtitle: 'Fish, prawns, seafood',
                icon: Iconsax.box_time,
                color: FColors.info,
                frequencyKey: 'seafood',
                emissionObs: controller.seafoodEmissions,
                impactLevel: 'MEDIUM IMPACT',
                metadataKey: 'fish_farmed',
              ),
              const SizedBox(height: FSizes.md),

              // Dairy & Eggs
              _buildFoodCategory(
                context: context,
                controller: controller,
                dark: dark,
                title: 'Dairy & Eggs',
                subtitle: 'Milk, cheese, yogurt, eggs',
                icon: Iconsax.milk,
                color: FColors.secondary,
                frequencyKey: 'dairy',
                emissionObs: controller.dairyEmissions,
                isDaily: true,
                metadataKey: 'milk',
              ),
              const SizedBox(height: FSizes.md),

              // Rice & Grains
              _buildFoodCategory(
                context: context,
                controller: controller,
                dark: dark,
                title: 'Rice & Grains',
                subtitle: 'Rice, bread, pasta, noodles',
                icon: Iconsax.cup,
                color: FColors.primary,
                frequencyKey: 'grains',
                emissionObs: controller.grainsEmissions,
                isDaily: true,
                metadataKey: 'rice',
              ),
              const SizedBox(height: FSizes.md),

              // Plant-Based
              _buildFoodCategory(
                context: context,
                controller: controller,
                dark: dark,
                title: 'Plant-Based',
                subtitle: 'Vegetables, fruits, beans, nuts',
                icon: Iconsax.tree,
                color: FColors.success,
                frequencyKey: 'plants',
                emissionObs: controller.plantsEmissions,
                isDaily: true,
                impactLevel: 'LOW IMPACT',
                isLowImpact: true,
                metadataKey: 'vegetable_mix',
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              Obx(
                    () => CommonEmissionWidgets.buildResultsCard(
                  context: context,
                  totalEmissions: controller.totalEmissions.value,
                  color: FColors.food,
                  formatEmission: controller.formatEmissionTons,
                  breakdown: controller.emissionsBreakdown,
                  dark: dark,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              Obx(
                    () => CommonEmissionWidgets.buildSaveButton(
                  context: context,
                  onPressed: () => controller.saveEmissions(),
                  isSaving: controller.isSaving.value,
                  text: 'Save Food Data',
                  color: FColors.food,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortionSettingsButton(BuildContext context, bool dark) {
    return InkWell(
      onTap: () => Get.to(() => const FoodPortionSettingsScreen()),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: FColors.food.withOpacity(0.1),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: FColors.food.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.food.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: Icon(
                Iconsax.setting_2,
                color: FColors.food,
                size: FSizes.iconMd,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adjust Food Portion',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: FColors.food,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Customize serving sizes for accurate calculations',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark
                          ? FColors.darkGrey
                          : FColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: FColors.food,
              size: FSizes.iconSm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCategory({
    required BuildContext context,
    required FoodController controller,
    required bool dark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String frequencyKey,
    required RxDouble emissionObs,
    required String metadataKey, // <-- 新增参数
    bool isDaily = false,
    bool isLowImpact = false,
    String? impactLevel,
  }) {
    return Obx(() {
      final frequency = controller.frequencies[frequencyKey]!.value;
      final maxFrequency = isDaily ? 5.0 : 10.0;

      return Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: isLowImpact
                ? color.withOpacity(0.5)
                : (dark
                ? FColors.borderDark
                : FColors.borderPrimary.withOpacity(0.5)),
            width: isLowImpact ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Info icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius:
                    BorderRadius.circular(FSizes.borderRadiusMd),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (impactLevel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(
                                    FSizes.borderRadiusSm),
                              ),
                              child: Text(
                                impactLevel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark
                              ? FColors.darkGrey
                              : FColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FSizes.xs),
                // Info icon
                EmissionInfoDialog.buildInfoIcon(
                  context: context,
                  metadata: FoodEmissionConfig
                      .foodEmissionFactors[metadataKey]?['metadata']
                  as Map<String, dynamic>,
                  dark: dark,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),

            // Frequency Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDaily ? 'Times per day:' : 'Times per week:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius:
                    BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Text(
                    frequency == 0
                        ? 'Never'
                        : frequency >= maxFrequency
                        ? '${maxFrequency.toInt()}+'
                        : frequency.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.sm),

            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
                valueIndicatorColor: color,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8),
                valueIndicatorTextStyle: TextStyle(
                  color: dark ? FColors.dark : FColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              child: Slider(
                value: frequency,
                min: 0,
                max: maxFrequency,
                divisions: maxFrequency.toInt(),
                label: frequency == 0
                    ? 'Never'
                    : frequency >= maxFrequency
                    ? '${maxFrequency.toInt()}+'
                    : frequency.toStringAsFixed(1),
                onChanged: (value) {
                  controller.updateFrequency(frequencyKey, value);
                },
              ),
            ),

            // Quick select buttons
            Wrap(
              spacing: FSizes.xs,
              runSpacing: FSizes.xs,
              children: [
                _buildQuickSelectChip(
                  context: context,
                  label: 'Never',
                  value: 0,
                  currentValue: frequency,
                  color: color,
                  dark: dark,
                  onTap: () => controller.updateFrequency(frequencyKey, 0),
                ),
                if (!isDaily) ...[
                  _buildQuickSelectChip(
                    context: context,
                    label: '1-2x',
                    value: 1.5,
                    currentValue: frequency,
                    color: color,
                    dark: dark,
                    onTap: () =>
                        controller.updateFrequency(frequencyKey, 1.5),
                  ),
                  _buildQuickSelectChip(
                    context: context,
                    label: '3-4x',
                    value: 3.5,
                    currentValue: frequency,
                    color: color,
                    dark: dark,
                    onTap: () =>
                        controller.updateFrequency(frequencyKey, 3.5),
                  ),
                  _buildQuickSelectChip(
                    context: context,
                    label: 'Daily',
                    value: 7,
                    currentValue: frequency,
                    color: color,
                    dark: dark,
                    onTap: () => controller.updateFrequency(frequencyKey, 7),
                  ),
                ] else ...[
                  _buildQuickSelectChip(
                    context: context,
                    label: '1x',
                    value: 1,
                    currentValue: frequency,
                    color: color,
                    dark: dark,
                    onTap: () => controller.updateFrequency(frequencyKey, 1),
                  ),
                  _buildQuickSelectChip(
                    context: context,
                    label: '2x',
                    value: 2,
                    currentValue: frequency,
                    color: color,
                    dark: dark,
                    onTap: () => controller.updateFrequency(frequencyKey, 2),
                  ),
                  _buildQuickSelectChip(
                    context: context,
                    label: '3x',
                    value: 3,
                    currentValue: frequency,
                    color: color,
                    dark: dark,
                    onTap: () => controller.updateFrequency(frequencyKey, 3),
                  ),
                ],
              ],
            ),

            // Emissions Preview
            Obx(
                  () => CommonEmissionWidgets.buildEmissionPreview(
                context: context,
                emissions: emissionObs.value,
                formatEmission: controller.formatEmissionTons,
                color: color,
                dark: dark,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickSelectChip({
    required BuildContext context,
    required String label,
    required double value,
    required double currentValue,
    required Color color,
    required bool dark,
    required VoidCallback onTap,
  }) {
    final isSelected = (currentValue - value).abs() < 0.1;

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
}
