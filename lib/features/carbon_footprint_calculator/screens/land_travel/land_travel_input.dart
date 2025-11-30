import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/emission_config/land_travel.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/air_travel_emission_validator.dart';
import '../../controllers/land_travel_controller.dart';
import '../../utils/emission_common_widgets.dart';
import '../../utils/emission_info_dialog.dart';
import 'widgets/fuel_segment_button.dart';

class LandTravelInputScreen extends StatelessWidget {
  const LandTravelInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LandTravelController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Land Travel'),
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
                      title: 'Annual Land Travel',
                      subtitle: 'Track your ground transportation emissions',
                      icon: Iconsax.car,
                      color: FColors.landTravel,
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    CommonEmissionWidgets.buildInfoCard(
                      context: context,
                      dataSource: 'GHG Protocol & DEFRA',
                      dataSet: 'Cross-sector tools & Conversion factors',
                      dataYear: 2023,
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    CommonEmissionWidgets.buildInstructionsCard(
                      context: context,
                      instructions: const [
                        'Answer each section based on your annual transportation habits',
                        'You can skip sections that don\'t apply to you',
                        'For fuel vehicles, choose either fuel amount OR distance',
                        'Leave fields at 0 if you don\'t use that transport mode',
                      ],
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildFuelVehiclesSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildEVSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildPublicTransportSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildActiveTransportSection(context, controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Obx(
                      () => CommonEmissionWidgets.buildResultsCard(
                        context: context,
                        totalEmissions: controller.totalEmissions.value,
                        color: FColors.landTravel,
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
                        text: 'Save Land Travel Data',
                        color: FColors.landTravel,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFuelVehiclesSection(
      BuildContext context, LandTravelController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.car,
                color: FColors.landTravel,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  '1. Fuel Vehicles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Step 1 · Do you use a petrol or diesel car / motorcycle?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: FSizes.sm),
          Row(
            children: [
              Obx(
                () => FuelSegmentButton(
                  label: 'Petrol',
                  icon: Icons.local_gas_station,
                  selected: controller.hasFuelVehicle.value == 'petrol',
                  dark: dark,
                  onTap: () {
                    controller.hasFuelVehicle.value = 'petrol';
                    controller.calculateEmissions();
                  },
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Obx(
                () => FuelSegmentButton(
                  label: 'Diesel',
                  icon: Icons.local_shipping,
                  selected: controller.hasFuelVehicle.value == 'diesel',
                  dark: dark,
                  onTap: () {
                    controller.hasFuelVehicle.value = 'diesel';
                    controller.calculateEmissions();
                  },
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Obx(
                () => FuelSegmentButton(
                  label: 'None',
                  icon: Icons.block,
                  selected: controller.hasFuelVehicle.value == 'none',
                  dark: dark,
                  onTap: () {
                    controller.hasFuelVehicle.value = 'none';
                    controller.calculateEmissions();
                  },
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.hasFuelVehicle.value == 'none' ||
                controller.hasFuelVehicle.value!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: FSizes.sm),
                child: Text(
                  'No fuel vehicle selected. This section will not add emissions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            final hasFuel = controller.hasFuelVehicle.value == 'petrol' ||
                controller.hasFuelVehicle.value == 'diesel';
            if (!hasFuel) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: FSizes.md),
                const Divider(),
                const SizedBox(height: FSizes.md),
                Text(
                  'Step 2 · Which is easier for you?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: FSizes.sm),
                Wrap(
                  spacing: FSizes.sm,
                  runSpacing: FSizes.sm,
                  children: [
                    Obx(
                      () => ChoiceChip(
                        label: const Text('Fuel (litres per year)'),
                        selected: controller.fuelInputMethod.value == 'fuel',
                        onSelected: (_) {
                          controller.fuelInputMethod.value = 'fuel';
                          controller.calculateEmissions();
                        },
                        selectedColor: FColors.landTravel.withOpacity(0.15),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: controller.fuelInputMethod.value == 'fuel'
                                  ? FColors.landTravel
                                  : (dark
                                      ? FColors.darkTextSecondary
                                      : FColors.textSecondary),
                              fontWeight:
                                  controller.fuelInputMethod.value == 'fuel'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                        backgroundColor: dark
                            ? FColors.darkContainer
                            : FColors.lightContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusMd),
                          side: BorderSide(
                            color: controller.fuelInputMethod.value == 'fuel'
                                ? FColors.landTravel
                                : (dark
                                    ? FColors.borderDark
                                    : FColors.borderSecondary),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => ChoiceChip(
                        label: const Text('Distance (km per year)'),
                        selected:
                            controller.fuelInputMethod.value == 'distance',
                        onSelected: (_) {
                          controller.fuelInputMethod.value = 'distance';
                          controller.calculateEmissions();
                        },
                        selectedColor: FColors.landTravel.withOpacity(0.15),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color:
                                  controller.fuelInputMethod.value == 'distance'
                                      ? FColors.landTravel
                                      : (dark
                                          ? FColors.darkTextSecondary
                                          : FColors.textSecondary),
                              fontWeight:
                                  controller.fuelInputMethod.value == 'distance'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                        backgroundColor: dark
                            ? FColors.darkContainer
                            : FColors.lightContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(FSizes.borderRadiusMd),
                          side: BorderSide(
                            color:
                                controller.fuelInputMethod.value == 'distance'
                                    ? FColors.landTravel
                                    : (dark
                                        ? FColors.borderDark
                                        : FColors.borderSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.md),
                Obx(
                  () => Text(
                    controller.fuelInputMethod.value == 'fuel'
                        ? 'Tip: Add up your petrol/diesel receipts or monthly top-ups × 12.'
                        : 'Tip: Use your odometer difference between two years, or estimate weekly km × 52.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(
                  () => controller.fuelInputMethod.value == 'fuel'
                      ? _buildFuelInputs(context, controller, dark)
                      : _buildDistanceInputs(context, controller, dark),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFuelInputs(
      BuildContext context, LandTravelController controller, bool dark) {
    return Column(
      children: [
        if (controller.hasFuelVehicle.value == 'petrol') ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Annual petrol consumption (litres)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: LandTravelEmissionConfig.landTravelEmissionFactors[
                    'fuel']!['petrol']!['metadata'] as Map<String, dynamic>,
                dark: dark,
                color: FColors.landTravel,
              ),
            ],
          ),
          const SizedBox(height: FSizes.xs),
          TextFormField(
            controller: controller.petrolLitersController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: const Icon(Iconsax.gas_station),
              suffixText: 'litres',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onChanged: (value) => controller.calculateEmissions(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(
              () => CommonEmissionWidgets.buildEmissionPreview(
                context: context,
                emissions: controller.petrolEmissions.value,
                formatEmission: controller.formatEmissionTons,
                color: FColors.landTravel,
                dark: dark,
              ),
            ),
          ),
        ],
        if (controller.hasFuelVehicle.value == 'diesel') ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Annual diesel consumption (litres)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: LandTravelEmissionConfig.landTravelEmissionFactors[
                    'fuel']!['diesel']!['metadata'] as Map<String, dynamic>,
                dark: dark,
                color: FColors.landTravel,
              ),
            ],
          ),
          const SizedBox(height: FSizes.xs),
          TextFormField(
            controller: controller.dieselLitersController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: const Icon(Iconsax.gas_station),
              suffixText: 'litres',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onChanged: (value) => controller.calculateEmissions(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(
              () => CommonEmissionWidgets.buildEmissionPreview(
                context: context,
                emissions: controller.dieselEmissions.value,
                formatEmission: controller.formatEmissionTons,
                color: FColors.landTravel,
                dark: dark,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDistanceInputs(
      BuildContext context, LandTravelController controller, bool dark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Annual car driving distance (km)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            EmissionInfoDialog.buildInfoIcon(
              context: context,
              metadata: LandTravelEmissionConfig.landTravelEmissionFactors[
              'by_distance']!['by_car']!['metadata']
              as Map<String, dynamic>,
              dark: dark,
              color: FColors.landTravel,
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),
        TextFormField(
          controller: controller.carKmController,
          keyboardType: TextInputType.number,
          inputFormatters: EmissionValidator.decimalNumberFormatters,
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Iconsax.car),
            suffixText: 'km',
            suffixStyle: Theme.of(context).textTheme.bodySmall,
          ),
          onChanged: (value) => controller.calculateEmissions(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Obx(
                () => CommonEmissionWidgets.buildEmissionPreview(
              context: context,
              emissions: controller.carEmissions.value,
              formatEmission: controller.formatEmissionTons,
              color: FColors.landTravel,
              dark: dark,
            ),
          ),
        ),
        const SizedBox(height: FSizes.md),

        Row(
          children: [
            Expanded(
              child: Text(
                'Annual motorcycle/scooter distance (km)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            EmissionInfoDialog.buildInfoIcon(
              context: context,
              metadata: LandTravelEmissionConfig.landTravelEmissionFactors[
              'by_distance']!['by_motorcycle']!['metadata']
              as Map<String, dynamic>,
              dark: dark,
              color: FColors.landTravel,
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),
        TextFormField(
          controller: controller.motorcycleKmController,
          keyboardType: TextInputType.number,
          inputFormatters: EmissionValidator.decimalNumberFormatters,
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: const Icon(Iconsax.cpu_charge),
            suffixText: 'km',
            suffixStyle: Theme.of(context).textTheme.bodySmall,
          ),
          onChanged: (value) => controller.calculateEmissions(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Obx(
                () => CommonEmissionWidgets.buildEmissionPreview(
              context: context,
              emissions: controller.motorcycleEmissions.value,
              formatEmission: controller.formatEmissionTons,
              color: FColors.landTravel,
              dark: dark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEVSection(
      BuildContext context, LandTravelController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.electricity,
                color: FColors.landTravel,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  '2. Electric Vehicles (EV)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Obx(
            () => CheckboxListTile(
              title: const Text('I own or regularly drive an EV'),
              value: controller.hasEV.value,
              onChanged: (value) {
                controller.hasEV.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              activeColor: FColors.landTravel,
            ),
          ),
          Obx(() {
            if (controller.hasEV.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: FSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Annual EV driving distance (km)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      EmissionInfoDialog.buildInfoIcon(
                        context: context,
                        metadata: LandTravelEmissionConfig
                                .landTravelEmissionFactors['electric_vehicle']![
                            'metadata'] as Map<String, dynamic>,
                        dark: dark,
                        color: FColors.landTravel,
                      ),
                    ],
                  ),
                  const SizedBox(height: FSizes.xs),
                  TextFormField(
                    controller: controller.evKmController,
                    keyboardType: TextInputType.number,
                    inputFormatters: EmissionValidator.decimalNumberFormatters,
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixIcon: const Icon(Iconsax.car),
                      suffixText: 'km',
                      suffixStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                    onChanged: (value) => controller.calculateEmissions(),
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Average electricity use (kWh per 100 km)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: FSizes.xs),
                  TextFormField(
                    controller: controller.evKwhPer100KmController,
                    keyboardType: TextInputType.number,
                    inputFormatters: EmissionValidator.decimalNumberFormatters,
                    decoration: InputDecoration(
                      hintText: '18',
                      prefixIcon: const Icon(Iconsax.battery_charging),
                      suffixText: 'kWh/100km',
                      suffixStyle: Theme.of(context).textTheme.bodySmall,
                      helperText: 'Leave at 18 if unsure',
                      helperStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                    onChanged: (value) => controller.calculateEmissions(),
                  ),
                  Obx(
                    () => CommonEmissionWidgets.buildEmissionPreview(
                      context: context,
                      emissions: controller.evEmissions.value,
                      formatEmission: controller.formatEmissionTons,
                      color: FColors.landTravel,
                      dark: dark,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildPublicTransportSection(
      BuildContext context, LandTravelController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.borderDark
              : FColors.borderPrimary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.bus,
                color: FColors.landTravel,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  '3. Public Transport',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Annual bus travel (city & intercity) (km)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: LandTravelEmissionConfig.landTravelEmissionFactors[
                        'public_transport']!['by_bus']!['metadata']
                    as Map<String, dynamic>,
                dark: dark,
                color: FColors.landTravel,
              ),
            ],
          ),
          const SizedBox(height: FSizes.xs),
          TextFormField(
            controller: controller.busKmController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: const Icon(Iconsax.bus),
              suffixText: 'km',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onChanged: (value) => controller.calculateEmissions(),
          ),
          Obx(
            () => CommonEmissionWidgets.buildEmissionPreview(
              context: context,
              emissions: controller.busEmissions.value,
              formatEmission: controller.formatEmissionTons,
              color: FColors.landTravel,
              dark: dark,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Annual train/MRT/LRT travel (km)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: LandTravelEmissionConfig.landTravelEmissionFactors[
                        'public_transport']!['by_train']!['metadata']
                    as Map<String, dynamic>,
                dark: dark,
                color: FColors.landTravel,
              ),
            ],
          ),
          const SizedBox(height: FSizes.xs),
          TextFormField(
            controller: controller.trainKmController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: const Icon(Iconsax.ship),
              suffixText: 'km',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onChanged: (value) => controller.calculateEmissions(),
          ),
          Obx(
            () => CommonEmissionWidgets.buildEmissionPreview(
              context: context,
              emissions: controller.trainEmissions.value,
              formatEmission: controller.formatEmissionTons,
              color: FColors.landTravel,
              dark: dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTransportSection(
      BuildContext context, LandTravelController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.landTravel.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.heart,
                color: FColors.landTravel,
                size: FSizes.iconSm,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  '4. Walking & Cycling',
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
                  color: FColors.landTravel.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  'Zero Emissions',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: FColors.landTravel,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.landTravel.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: FColors.landTravel,
                  size: FSizes.iconSm,
                ),
                const SizedBox(width: FSizes.xs),
                Expanded(
                  child: Text(
                    'Great job! Walking and cycling produce zero emissions. Track them here to see your eco-friendly habits!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Average weekly cycling distance (km)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: FSizes.xs),
          TextFormField(
            controller: controller.bikeKmPerWeekController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: Icon(
                Iconsax.car,
                color: FColors.landTravel,
              ),
              suffixText: 'km/week',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Average weekly walking distance (km)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: FSizes.xs),
          TextFormField(
            controller: controller.walkKmPerWeekController,
            keyboardType: TextInputType.number,
            inputFormatters: EmissionValidator.decimalNumberFormatters,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: Icon(
                Iconsax.user,
                color: FColors.landTravel,
              ),
              suffixText: 'km/week',
              suffixStyle: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
