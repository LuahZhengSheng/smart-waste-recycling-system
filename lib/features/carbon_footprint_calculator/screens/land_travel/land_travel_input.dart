import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission_profile/emission_profile.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/emission_profile_controller.dart';

class LandTravelInputScreen extends StatelessWidget {
  const LandTravelInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LandTravelController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        title: Text(
          'Land Travel',
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
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: FColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: const Icon(
                      Iconsax.car,
                      color: FColors.primary,
                      size: FSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Land Travel Emissions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Calculate emissions from cars, buses, trains',
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

            // Vehicle Type Selection
            Text(
              'Vehicle Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Obx(() => Wrap(
              spacing: FSizes.sm,
              children: controller.vehicleTypes.map((type) {
                final isSelected = controller.selectedVehicleType.value == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.selectedVehicleType.value = type;
                  },
                  selectedColor: FColors.primary.withOpacity(0.2),
                  backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Fuel Type Selection
            Text(
              'Fuel Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Obx(() => Wrap(
              spacing: FSizes.sm,
              children: controller.fuelTypes.map((type) {
                final isSelected = controller.selectedFuelType.value == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) controller.selectedFuelType.value = type;
                  },
                  selectedColor: FColors.primary.withOpacity(0.2),
                  backgroundColor: dark ? FColors.darkContainer : FColors.lightContainer,
                );
              }).toList(),
            )),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Distance Input
            Text(
              'Weekly Distance (km)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            TextFormField(
              controller: controller.distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter weekly distance in km',
                prefixIcon: const Icon(Iconsax.location),
                suffixText: 'km',
              ),
              onChanged: (value) => controller.calculateEmissions(),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Fuel Efficiency Input
            Text(
              'Fuel Efficiency (L/100km)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.md),
            TextFormField(
              controller: controller.efficiencyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter fuel efficiency',
                prefixIcon: const Icon(Iconsax.gas_station),
                suffixText: 'L/100km',
              ),
              onChanged: (value) => controller.calculateEmissions(),
            ),

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
                          color: FColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Iconsax.airplane,
                        color: FColors.primary,
                        size: FSizes.iconLg,
                      ),
                    ],
                  ),
                  if (controller.calculatedEmissions.value > 0) ...[
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Based on ${controller.distanceController.text} km/week',
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
                  backgroundColor: FColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Text(
                  'Save Land Travel Emissions',
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

class LandTravelController extends GetxController {
  final distanceController = TextEditingController();
  final efficiencyController = TextEditingController();

  final vehicleTypes = ['Car', 'Bus', 'Train', 'Motorcycle', 'Bicycle'].obs;
  final fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'].obs;

  final selectedVehicleType = 'Car'.obs;
  final selectedFuelType = 'Petrol'.obs;
  final calculatedEmissions = 0.0.obs;

  // Emission factors (kg CO2e per liter of fuel)
  final Map<String, double> emissionFactors = {
    'Petrol': 2.31,
    'Diesel': 2.68,
    'Electric': 0.0, // Varies by grid, simplified to 0
    'Hybrid': 1.85,
  };

  // Vehicle efficiency modifiers
  final Map<String, double> vehicleModifiers = {
    'Car': 1.0,
    'Bus': 0.3, // Per person
    'Train': 0.2, // Per person
    'Motorcycle': 1.5,
    'Bicycle': 0.0,
  };

  @override
  void onInit() {
    super.onInit();
    // Set default values
    efficiencyController.text = '8.0';
  }

  void calculateEmissions() {
    final distance = double.tryParse(distanceController.text) ?? 0.0;
    final efficiency = double.tryParse(efficiencyController.text) ?? 0.0;

    if (distance > 0 && efficiency > 0) {
      // Weekly to annual conversion
      final annualDistance = distance * 52;

      // Calculate fuel consumption (L/year)
      final fuelConsumption = (annualDistance * efficiency) / 100;

      // Get emission factor and vehicle modifier
      final emissionFactor = emissionFactors[selectedFuelType.value] ?? 2.31;
      final vehicleModifier = vehicleModifiers[selectedVehicleType.value] ?? 1.0;

      // Calculate emissions (kg CO2e per year)
      calculatedEmissions.value = fuelConsumption * emissionFactor * vehicleModifier;
    } else {
      calculatedEmissions.value = 0.0;
    }
  }

  void saveEmissions() {
    // Save to local storage and update emissions profile
    final emissionData = {
      'vehicleType': selectedVehicleType.value,
      'fuelType': selectedFuelType.value,
      'weeklyDistance': double.tryParse(distanceController.text) ?? 0.0,
      'fuelEfficiency': double.tryParse(efficiencyController.text) ?? 0.0,
      'annualEmissions': calculatedEmissions.value,
    };

    // Update emissions profile
    final profileController = Get.find<EmissionsProfileController>();
    profileController.updateCategoryEmission('land_travel', calculatedEmissions.value);

    FHelperFunctions.showSnackBar('Land travel emissions saved successfully!');
    Get.back();
  }

  @override
  void onClose() {
    distanceController.dispose();
    efficiencyController.dispose();
    super.onClose();
  }
}