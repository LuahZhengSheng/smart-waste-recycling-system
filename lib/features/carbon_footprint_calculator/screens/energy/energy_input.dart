import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission_profile/emission_profile.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/emission_profile_controller.dart';

class EnergyInputScreen extends StatelessWidget {
  const EnergyInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnergyController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Energy',
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
                color: const Color(0xFFFFEB3B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEB3B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: const Icon(
                      Iconsax.flash_1,
                      color: Color(0xFFFFEB3B),
                      size: FSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Energy Emissions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Calculate home energy usage emissions',
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

            // Housing Type
            Text(
              'Housing Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Obx(() => Wrap(
              spacing: FSizes.sm,
              children: controller.housingTypes.map((type) {
                final isSelected = controller.selectedHousingType.value == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.selectedHousingType.value = type;
                  },
                  selectedColor: const Color(0xFFFFEB3B).withOpacity(0.2),
                  backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Electricity Usage
            Text(
              'Monthly Electricity Bill (RM)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            TextFormField(
              controller: controller.electricityBillController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter monthly electricity bill',
                prefixIcon: Icon(Iconsax.flash_1),
                suffixText: 'RM',
              ),
              onChanged: (value) => controller.calculateEmissions(),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Gas Usage
            Text(
              'Monthly Gas Bill (RM)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            TextFormField(
              controller: controller.gasBillController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter monthly gas bill (optional)',
                prefixIcon: Icon(Iconsax.gas_station),
                suffixText: 'RM',
              ),
              onChanged: (value) => controller.calculateEmissions(),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Household Size
            Text(
              'Household Size',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Obx(() => Row(
              children: [
                Expanded(
                  child: Slider(
                    value: controller.householdSize.value.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    activeColor: const Color(0xFFFFEB3B),
                    label: '${controller.householdSize.value} people',
                    onChanged: (value) {
                      controller.householdSize.value = value.toInt();
                      controller.calculateEmissions();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEB3B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Text(
                    '${controller.householdSize.value}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFFFEB3B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                          color: const Color(0xFFFFEB3B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Iconsax.flash_1,
                        color: Color(0xFFFFEB3B),
                        size: FSizes.iconLg,
                      ),
                    ],
                  ),
                  if (controller.calculatedEmissions.value > 0) ...[
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Per person: ${(controller.calculatedEmissions.value / controller.householdSize.value).toStringAsFixed(2)} kg CO2e',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
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
                  backgroundColor: const Color(0xFFFFEB3B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Text(
                  'Save Energy Emissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
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

class EnergyController extends GetxController {
  final electricityBillController = TextEditingController();
  final gasBillController = TextEditingController();

  final housingTypes = ['Apartment', 'Terrace House', 'Semi-D', 'Bungalow', 'Condo'].obs;
  final selectedHousingType = 'Apartment'.obs;
  final householdSize = 2.obs;
  final calculatedEmissions = 0.0.obs;

  // Emission factors for Malaysia
  final double electricityEmissionFactor = 0.554; // kg CO2e per kWh (Malaysia grid)
  final double gasEmissionFactor = 1.96; // kg CO2e per m³ of natural gas
  final double electricityRate = 0.435; // RM per kWh (average Malaysia rate)
  final double gasRate = 1.35; // RM per m³ (average rate)

  // Housing type multipliers (based on typical size and usage)
  final Map<String, double> housingMultipliers = {
    'Apartment': 0.8,
    'Terrace House': 1.0,
    'Semi-D': 1.3,
    'Bungalow': 1.6,
    'Condo': 0.9,
  };

  void calculateEmissions() {
    final electricityBill = double.tryParse(electricityBillController.text) ?? 0.0;
    final gasBill = double.tryParse(gasBillController.text) ?? 0.0;

    if (electricityBill > 0 || gasBill > 0) {
      // Calculate electricity usage from bill
      final electricityUsage = electricityBill / electricityRate; // kWh per month
      final annualElectricityUsage = electricityUsage * 12; // kWh per year

      // Calculate gas usage from bill
      final gasUsage = gasBill / gasRate; // m³ per month
      final annualGasUsage = gasUsage * 12; // m³ per year

      // Apply housing type modifier
      final housingMultiplier = housingMultipliers[selectedHousingType.value] ?? 1.0;

      // Calculate emissions
      final electricityEmissions = annualElectricityUsage * electricityEmissionFactor * housingMultiplier;
      final gasEmissions = annualGasUsage * gasEmissionFactor;

      calculatedEmissions.value = electricityEmissions + gasEmissions;
    } else {
      calculatedEmissions.value = 0.0;
    }
  }

  void saveEmissions() {
    final emissionData = {
      'housingType': selectedHousingType.value,
      'householdSize': householdSize.value,
      'monthlyElectricityBill': double.tryParse(electricityBillController.text) ?? 0.0,
      'monthlyGasBill': double.tryParse(gasBillController.text) ?? 0.0,
      'annualEmissions': calculatedEmissions.value,
    };

    // Update emissions profile
    final profileController = Get.find<EmissionsProfileController>();
    profileController.updateCategoryEmission('energy', calculatedEmissions.value);

    FHelperFunctions.showSnackBar('Energy emissions saved successfully!');
    Get.back();
  }

  @override
  void onClose() {
    electricityBillController.dispose();
    gasBillController.dispose();
    super.onClose();
  }
}