import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission_profile/emission_profile.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/emission_profile_controller.dart';

class StuffInputScreen extends StatelessWidget {
  const StuffInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StuffController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Stuff',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: const Icon(
                      Iconsax.box,
                      color: Color(0xFFF44336),
                      size: FSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stuff Emissions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Calculate emissions from purchases',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Shopping Frequency
            Text(
              'Shopping Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Obx(() => Wrap(
              spacing: FSizes.sm,
              children: controller.shoppingFrequencies.map((frequency) {
                final isSelected = controller.selectedShoppingFrequency.value == frequency;
                return ChoiceChip(
                  label: Text(frequency),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedShoppingFrequency.value = frequency;
                      controller.calculateEmissions();
                    }
                  },
                  selectedColor: const Color(0xFFF44336).withOpacity(0.2),
                  backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Monthly Spending Categories
            Text(
              'Monthly Spending (RM)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),

            Obx(() => Column(
              children: controller.spendingCategories.entries.map((entry) {
                final categoryData = entry.value as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: FSizes.md),
                  child: TextFormField(
                    controller: controller.spendingControllers[entry.key],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      hintText: 'Enter monthly spending',
                      prefixIcon: Icon(categoryData['icon'] as IconData?),
                      suffixText: 'RM',
                    ),
                    onChanged: (value) => controller.calculateEmissions(),
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Buying Habits
            Text(
              'Buying Habits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),

            Obx(() => Column(
              children: [
                CheckboxListTile(
                  title: const Text('I buy second-hand when possible'),
                  value: controller.buySecondHand.value,
                  activeColor: const Color(0xFFF44336),
                  onChanged: (value) {
                    controller.buySecondHand.value = value ?? false;
                    controller.calculateEmissions();
                  },
                ),
                CheckboxListTile(
                  title: const Text('I repair items instead of replacing'),
                  value: controller.repairItems.value,
                  activeColor: const Color(0xFFF44336),
                  onChanged: (value) {
                    controller.repairItems.value = value ?? false;
                    controller.calculateEmissions();
                  },
                ),
                CheckboxListTile(
                  title: const Text('I buy eco-friendly products'),
                  value: controller.buyEcoFriendly.value,
                  activeColor: const Color(0xFFF44336),
                  onChanged: (value) {
                    controller.buyEcoFriendly.value = value ?? false;
                    controller.calculateEmissions();
                  },
                ),
                CheckboxListTile(
                  title: const Text('I avoid fast fashion'),
                  value: controller.avoidFastFashion.value,
                  activeColor: const Color(0xFFF44336),
                  onChanged: (value) {
                    controller.avoidFastFashion.value = value ?? false;
                    controller.calculateEmissions();
                  },
                ),
              ],
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Results Card
            Obx(() => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark ? FColors.darkContainer : FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: dark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Annual Emissions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.calculatedEmissions.value.toStringAsFixed(2)} kg CO2e',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFFF44336),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Iconsax.box,
                        color: Color(0xFFF44336),
                        size: FSizes.iconLg,
                      ),
                    ],
                  ),
                  if (controller.calculatedEmissions.value > 0) ...[
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Shopping: ${controller.selectedShoppingFrequency.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                    ),
                    if (controller.getTotalReduction() > 0)
                      Text(
                        '${controller.getTotalReduction().toStringAsFixed(0)}% reduction from eco-habits',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FColors.success,
                        ),
                      ),
                  ],
                ],
              ),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.calculatedEmissions.value > 0
                    ? () => controller.saveEmissions()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Text(
                  'Save Stuff Emissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StuffController extends GetxController {
  final shoppingFrequencies = ['Rarely', 'Monthly', 'Weekly', 'Daily'].obs;
  final selectedShoppingFrequency = 'Monthly'.obs;
  final calculatedEmissions = 0.0.obs;

  // Spending categories with emission factors (kg CO2e per RM)
  final spendingCategories = {
    'Clothing': {'factor': 0.025, 'icon': Iconsax.shopping_bag},
    'Electronics': {'factor': 0.035, 'icon': Iconsax.mobile},
    'Home Items': {'factor': 0.020, 'icon': Iconsax.home},
    'Books/Media': {'factor': 0.015, 'icon': Iconsax.book},
    'Sports/Hobby': {'factor': 0.030, 'icon': Iconsax.activity},
  };

  final spendingControllers = <String, TextEditingController>{}.obs;

  // Eco-friendly habits
  final buySecondHand = false.obs;
  final repairItems = false.obs;
  final buyEcoFriendly = false.obs;
  final avoidFastFashion = false.obs;

  // Shopping frequency multipliers
  final Map<String, double> frequencyMultipliers = {
    'Rarely': 0.5,
    'Monthly': 1.0,
    'Weekly': 2.0,
    'Daily': 4.0,
  };

  @override
  void onInit() {
    super.onInit();
    initializeControllers();
  }

  void initializeControllers() {
    for (String category in spendingCategories.keys) {
      spendingControllers[category] = TextEditingController();
    }
  }

  void calculateEmissions() {
    double totalEmissions = 0.0;

    // Calculate emissions from spending
    spendingControllers.forEach((category, controller) {
      final spending = double.tryParse(controller.text) ?? 0.0;
      final categoryData = spendingCategories[category] as Map<String, dynamic>;
      final emissionFactor = categoryData['factor'] as double;
      totalEmissions += spending * emissionFactor * 12; // Monthly to annual
    });

    // Apply shopping frequency multiplier
    final frequencyMultiplier = frequencyMultipliers[selectedShoppingFrequency.value] ?? 1.0;
    totalEmissions *= frequencyMultiplier;

    // Apply eco-friendly habit reductions
    double reductionFactor = 1.0;

    if (buySecondHand.value) reductionFactor -= 0.15; // 15% reduction
    if (repairItems.value) reductionFactor -= 0.10; // 10% reduction
    if (buyEcoFriendly.value) reductionFactor -= 0.12; // 12% reduction
    if (avoidFastFashion.value) reductionFactor -= 0.08; // 8% reduction

    totalEmissions *= reductionFactor.clamp(0.0, 1.0);

    calculatedEmissions.value = totalEmissions;
  }

  double getTotalReduction() {
    double reduction = 0.0;
    if (buySecondHand.value) reduction += 15;
    if (repairItems.value) reduction += 10;
    if (buyEcoFriendly.value) reduction += 12;
    if (avoidFastFashion.value) reduction += 8;
    return reduction;
  }

  void saveEmissions() {
    final emissionData = {
      'shoppingFrequency': selectedShoppingFrequency.value,
      'monthlySpending': Map.fromEntries(spendingControllers.entries.map((e) =>
          MapEntry(e.key, double.tryParse(e.value.text) ?? 0.0))),
      'ecoHabits': {
        'buySecondHand': buySecondHand.value,
        'repairItems': repairItems.value,
        'buyEcoFriendly': buyEcoFriendly.value,
        'avoidFastFashion': avoidFastFashion.value,
      },
      'annualEmissions': calculatedEmissions.value,
    };

    // Update emissions profile
    final profileController = Get.find<EmissionsProfileController>();
    profileController.updateCategoryEmission('stuff', calculatedEmissions.value);

    FHelperFunctions.showSnackBar('Stuff emissions saved successfully!');
    Get.back();
  }

  @override
  void onClose() {
    spendingControllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }
}