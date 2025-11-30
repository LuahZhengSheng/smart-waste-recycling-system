import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/emission_config/air_travel.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/air_travel_emission_validator.dart';
import '../../controllers/air_travel_controller.dart';
import '../../utils/emission_common_widgets.dart';
import '../../utils/emission_info_dialog.dart';

class AirTravelInputScreen extends StatelessWidget {
  const AirTravelInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AirTravelController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Air Travel'),
        showBackArrow: true,
        actionButtonText: 'Clear',
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
                title: 'Annual Air Travel',
                subtitle: 'Track your flight emissions by class',
                icon: Iconsax.airplane,
                color: FColors.airTravel,
                dark: dark,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              CommonEmissionWidgets.buildInfoCard(
                context: context,
                dataSource: AirTravelEmissionConfig.dataSource,
                dataSet: AirTravelEmissionConfig.dataSet,
                dataYear: AirTravelEmissionConfig.dataYear,
                dark: dark,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              CommonEmissionWidgets.buildInstructionsCard(
                context: context,
                instructions: [
                  'Enter one-way distance for each flight class',
                  'Check "Round Trip" if applicable (doubles the distance)',
                  'Leave at 0 for classes you didn\'t fly',
                  'Use "Average Class" if class is unknown',
                ],
                dark: dark,
              ),
              const SizedBox(height: FSizes.spaceBtwSections),

              _buildClassSection(
                context,
                controller,
                'Economy Class',
                'economy',
                controller.economyDistanceController,
                controller.economyRoundTrip,
                controller.economyEmissions,
                dark,
              ),
              const SizedBox(height: FSizes.md),

              _buildClassSection(
                context,
                controller,
                'Premium Economy',
                'premium_economy',
                controller.premiumEconomyDistanceController,
                controller.premiumEconomyRoundTrip,
                controller.premiumEconomyEmissions,
                dark,
              ),
              const SizedBox(height: FSizes.md),

              _buildClassSection(
                context,
                controller,
                'Business Class',
                'business',
                controller.businessDistanceController,
                controller.businessRoundTrip,
                controller.businessEmissions,
                dark,
              ),
              const SizedBox(height: FSizes.md),

              _buildClassSection(
                context,
                controller,
                'First Class',
                'first',
                controller.firstDistanceController,
                controller.firstRoundTrip,
                controller.firstEmissions,
                dark,
              ),
              const SizedBox(height: FSizes.md),

              _buildAverageClassSection(
                context,
                controller,
                dark,
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              Obx(
                    () => CommonEmissionWidgets.buildResultsCard(
                  context: context,
                  totalEmissions: controller.totalEmissions.value,
                  color: FColors.airTravel,
                  formatEmission: controller.formatEmissionTons,
                  breakdown: controller.breakdownByClass,
                  dark: dark,
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              Obx(
                    () => CommonEmissionWidgets.buildSaveButton(
                  context: context,
                  onPressed: () => controller.saveEmissions(),
                  isSaving: controller.isSaving.value,
                  text: 'Save Air Travel Data',
                  color: FColors.airTravel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSection(
      BuildContext context,
      AirTravelController controller,
      String title,
      String classId,
      TextEditingController textController,
      RxBool roundTripObs,
      RxDouble emissions,
      bool dark,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color:
          dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + info
          Row(
            children: [
              Icon(
                Iconsax.airplane,
                color: FColors.airTravel,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: AirTravelEmissionConfig
                    .airTravelEmissionFactors[classId]!['metadata']
                as Map<String, dynamic>,
                dark: dark,
                color: FColors.airTravel,
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          TextFormField(
            controller: textController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              labelText: 'One-Way Distance (km)',
              hintText: '0',
              prefixIcon: const Icon(Iconsax.global),
              suffixText: 'km',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
            validator: (value) => EmissionValidator.validateDistance(value),
            onChanged: (value) => controller.calculateEmissions(),
          ),
          const SizedBox(height: FSizes.md),

          Obx(
                () => CheckboxListTile(
              title: Text(
                'Round Trip',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Check if this is a return journey (doubles distance)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark
                      ? FColors.darkGrey
                      : FColors.textSecondary,
                ),
              ),
              value: roundTripObs.value,
              onChanged: (value) {
                roundTripObs.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: FColors.airTravel,
            ),
          ),

          Obx(
                () => CommonEmissionWidgets.buildEmissionPreview(
              context: context,
              emissions: emissions.value,
              formatEmission: controller.formatEmissionTons,
              color: FColors.airTravel,
              dark: dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageClassSection(
      BuildContext context,
      AirTravelController controller,
      bool dark,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.airTravel.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + badge + info
          Row(
            children: [
              Icon(
                Iconsax.airplane,
                color: FColors.airTravel,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  'Average Class',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: FColors.airTravel.withOpacity(0.2),
                  borderRadius:
                  BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  'Unknown Class',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FColors.airTravel,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: FSizes.xs),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: AirTravelEmissionConfig
                    .airTravelEmissionFactors['average']!['metadata']
                as Map<String, dynamic>,
                dark: dark,
                color: FColors.airTravel,
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),

          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.airTravel.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: FColors.airTravel,
                  size: FSizes.iconSm,
                ),
                const SizedBox(width: FSizes.xs),
                Expanded(
                  child: Text(
                    'Use this option when you don\'t know the flight class. It calculates based on average passenger emissions.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark
                          ? FColors.darkGrey
                          : FColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),

          TextFormField(
            controller: controller.averageDistanceController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              labelText: 'One-Way Distance (km)',
              hintText: '0',
              prefixIcon: const Icon(Iconsax.global),
              suffixText: 'km',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
            validator: (value) => EmissionValidator.validateDistance(value),
            onChanged: (value) => controller.calculateEmissions(),
          ),
          const SizedBox(height: FSizes.md),

          Obx(
                () => CheckboxListTile(
              title: Text(
                'Round Trip',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Check if this is a return journey (doubles distance)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark
                      ? FColors.darkGrey
                      : FColors.textSecondary,
                ),
              ),
              value: controller.averageRoundTrip.value,
              onChanged: (value) {
                controller.averageRoundTrip.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: FColors.airTravel,
            ),
          ),

          Obx(
                () => CommonEmissionWidgets.buildEmissionPreview(
              context: context,
              emissions: controller.averageEmissions.value,
              formatEmission: controller.formatEmissionTons,
              color: FColors.airTravel,
              dark: dark,
            ),
          ),
        ],
      ),
    );
  }
}
