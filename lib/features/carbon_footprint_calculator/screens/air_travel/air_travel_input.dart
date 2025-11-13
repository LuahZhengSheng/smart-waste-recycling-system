import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/controllers/air_travel_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/emission_config.dart';
import '../../../../utils/validators/emission_validator.dart';

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
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Info Card
            _buildInfoCard(context, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Instructions Card
            _buildInstructionsCard(context, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Economy Class Section
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

            // Premium Economy Section
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

            // Business Class Section
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

            // First Class Section
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

            // Average Class Section (with special note)
            _buildAverageClassSection(
              context,
              controller,
              dark,
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Results Card
            Obx(() => _buildResultsCard(context, controller, dark)),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Save Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSaving.value
                    ? null
                    : () => controller.saveEmissions(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(
                      vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: controller.isSaving.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        FColors.white),
                  ),
                )
                    : Text(
                  'Save Air Travel Data',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color: FColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ],
        ),
      )),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.2),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: const Icon(
              Iconsax.airplane,
              color: Color(0xFFE91E63),
              size: FSizes.iconLg,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annual Air Travel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Track your flight emissions by class',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.info.withOpacity(0.1)
            : FColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.info_circle,
            color: FColors.info,
            size: FSizes.iconMd,
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Source',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FColors.info,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  '${EmissionConfig.dataSource} - ${EmissionConfig.dataSet} (${EmissionConfig.dataYear})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.warning.withOpacity(0.1)
            : FColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.warning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.lamp_charge,
                color: FColors.warning,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'How to Use',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: FColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            '1. Enter one-way distance for each flight class\n'
                '2. Check "Round Trip" if applicable (doubles the distance)\n'
                '3. Leave at 0 for classes you didn\'t fly\n'
                '4. Use "Average Class" if class is unknown',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
          ),
        ],
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
          color: dark ? FColors.borderDark : FColors.borderPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Iconsax.airplane,
                color: const Color(0xFFE91E63),
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
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Distance Input
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

          // Round Trip Checkbox
          Obx(() => CheckboxListTile(
            title: Text(
              'Round Trip',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              'Check if this is a return journey (doubles distance)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            value: roundTripObs.value,
            onChanged: (value) {
              roundTripObs.value = value ?? false;
              controller.calculateEmissions();
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFFE91E63),
          )),

          // Emissions Preview
          Obx(() => emissions.value > 0
              ? Padding(
            padding: const EdgeInsets.only(top: FSizes.sm),
            child: Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.flash_1,
                    color: Color(0xFFE91E63),
                    size: FSizes.iconSm,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    controller.getFormattedEmission(emissions.value),
                    style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE91E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ' CO₂e',
                    style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox.shrink()),
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
          color: const Color(0xFFE91E63).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title with Special Badge
          Row(
            children: [
              Icon(
                Iconsax.airplane,
                color: const Color(0xFFE91E63),
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
                  color: const Color(0xFFE91E63).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  'Unknown Class',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),

          // Special Note
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: const Color(0xFFE91E63),
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

          // Distance Input
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

          // Round Trip Checkbox
          Obx(() => CheckboxListTile(
            title: Text(
              'Round Trip',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              'Check if this is a return journey (doubles distance)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            value: controller.averageRoundTrip.value,
            onChanged: (value) {
              controller.averageRoundTrip.value = value ?? false;
              controller.calculateEmissions();
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: const Color(0xFFE91E63),
          )),

          // Emissions Preview
          Obx(() => controller.averageEmissions.value > 0
              ? Padding(
            padding: const EdgeInsets.only(top: FSizes.sm),
            child: Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.flash_1,
                    color: Color(0xFFE91E63),
                    size: FSizes.iconSm,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    controller.getFormattedEmission(
                        controller.averageEmissions.value),
                    style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE91E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ' CO₂e',
                    style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildResultsCard(
      BuildContext context, AirTravelController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63),
            const Color(0xFFE91E63).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Annual Emissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            controller.getFormattedEmission(controller.totalEmissions.value),
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

          // Breakdown
          if (controller.totalEmissions.value > 0) ...[
            const SizedBox(height: FSizes.md),
            const Divider(color: Colors.white24),
            const SizedBox(height: FSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBreakdownItem(
                  context,
                  'Fuel Combustion',
                  controller
                      .getFormattedEmission(controller.fuelCombustion.value),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white24,
                ),
                _buildBreakdownItem(
                  context,
                  'Well-to-Tank',
                  controller.getFormattedEmission(controller.wellToTank.value),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
      BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: FColors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: FColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}