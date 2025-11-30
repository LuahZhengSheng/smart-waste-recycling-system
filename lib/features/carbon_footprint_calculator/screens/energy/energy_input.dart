import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../config/emission_config/energy.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/air_travel_emission_validator.dart';
import '../../controllers/energy_controller.dart';
import '../../utils/emission_common_widgets.dart';
import '../../utils/emission_info_dialog.dart';

class EnergyInputScreen extends StatelessWidget {
  const EnergyInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnergyController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Home Energy'),
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
                      title: 'Annual Home Energy',
                      subtitle: 'Track your household energy consumption',
                      icon: Iconsax.flash,
                      color: FColors.energy,
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    CommonEmissionWidgets.buildInfoCard(
                      context: context,
                      dataSource: 'Energy Commission MY & DEFRA',
                      dataSet: 'Grid EF & Conversion factors',
                      dataYear: 2023,
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    CommonEmissionWidgets.buildInstructionsCard(
                      context: context,
                      instructions: const [
                        'Select your region for accurate grid emission factors',
                        'If possible, use your monthly kWh from TNB bill',
                        'If you only know your bill amount (RM), we will estimate kWh for you',
                        'Solar PV self-consumption has zero operational emissions',
                      ],
                      dark: dark,
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildGridElectricitySection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildSolarPVSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildLPGSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildNaturalGasSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildDieselGeneratorSection(context, controller, dark),
                    const SizedBox(height: FSizes.md),
                    _buildBiomassSection(context, controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    Obx(
                      () => CommonEmissionWidgets.buildResultsCard(
                        context: context,
                        totalEmissions: controller.totalEmissions.value,
                        color: FColors.energy,
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
                        text: 'Save Energy Data',
                        color: FColors.energy,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// 1. GRID ELECTRICITY SECTION - 新方案
  Widget _buildGridElectricitySection(
      BuildContext context, EnergyController controller, bool dark) {
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.energy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.flash,
                  color: FColors.energy,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  '1. Grid Electricity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: EnergyEmissionConfig.energyEmissionFactors[
                        'electricity_peninsular']!['metadata']
                    as Map<String, dynamic>,
                dark: dark,
                color: FColors.energy,
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Region
          Text(
            'Which region do you live in?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: FSizes.sm),
          Obx(
            () => Wrap(
              spacing: FSizes.sm,
              runSpacing: FSizes.sm,
              children: [
                _buildRegionChip(
                  context: context,
                  label: 'Peninsular',
                  value: 'peninsular',
                  selected: controller.region.value == 'peninsular',
                  dark: dark,
                  onTap: () => controller.region.value = 'peninsular',
                ),
                _buildRegionChip(
                  context: context,
                  label: 'Sabah',
                  value: 'sabah',
                  selected: controller.region.value == 'sabah',
                  dark: dark,
                  onTap: () => controller.region.value = 'sabah',
                ),
                _buildRegionChip(
                  context: context,
                  label: 'Sarawak',
                  value: 'sarawak',
                  selected: controller.region.value == 'sarawak',
                  dark: dark,
                  onTap: () => controller.region.value = 'sarawak',
                ),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          const Divider(),
          const SizedBox(height: FSizes.md),

          // Knows kWh or only bill?
          Text(
            'Do you know your average monthly electricity consumption?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: FSizes.sm),

          Obx(
            () => Column(
              children: [
                RadioListTile<bool>(
                  title: const Text('Yes – I know my monthly usage (kWh)'),
                  value: true,
                  groupValue: controller.knowsKwh.value,
                  onChanged: (value) {
                    controller.knowsKwh.value = value ?? true;
                    controller.calculateEmissions();
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: FColors.energy,
                ),
                RadioListTile<bool>(
                  title:
                      const Text('No – I only know my monthly TNB bill (RM)'),
                  value: false,
                  groupValue: controller.knowsKwh.value,
                  onChanged: (value) {
                    controller.knowsKwh.value = value ?? false;
                    controller.calculateEmissions();
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: FColors.energy,
                ),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),

          Obx(
            () => controller.knowsKwh.value
                ? _buildKwhInput(context, controller, dark)
                : _buildBillInput(context, controller, dark),
          ),
        ],
      ),
    );
  }

  /// A. 用户知道 kWh
  Widget _buildKwhInput(
      BuildContext context, EnergyController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average monthly electricity consumption (kWh)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: FSizes.xs),
        TextFormField(
          controller: controller.monthlyKwhController,
          keyboardType: TextInputType.number,
          inputFormatters: EmissionValidator.decimalNumberFormatters,
          decoration: InputDecoration(
            hintText: 'e.g. 450',
            prefixIcon: const Icon(Iconsax.flash),
            suffixText: 'kWh',
            suffixStyle: Theme.of(context).textTheme.bodySmall,
          ),
          onChanged: (value) => controller.calculateEmissions(),
        ),
        const SizedBox(height: FSizes.sm),
        Obx(
          () => CommonEmissionWidgets.buildEmissionPreview(
            context: context,
            emissions: controller.gridEmissions.value,
            formatEmission: controller.formatEmissionTons,
            color: FColors.energy,
            dark: dark,
          ),
        ),
      ],
    );
  }

  /// B. 用户只知道 RM
  Widget _buildBillInput(
      BuildContext context, EnergyController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average monthly TNB electricity bill (RM)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: FSizes.xs),
        TextFormField(
          controller: controller.monthlyBillRmController,
          keyboardType: TextInputType.number,
          inputFormatters: EmissionValidator.decimalNumberFormatters,
          decoration: InputDecoration(
            hintText: 'e.g. 250',
            prefixIcon: const Icon(Iconsax.wallet),
            suffixText: 'RM',
            suffixStyle: Theme.of(context).textTheme.bodySmall,
          ),
          onChanged: (value) => controller.calculateEmissions(),
        ),
        const SizedBox(height: FSizes.sm),

        // 说明 + Tariff metadata
        Container(
          padding: const EdgeInsets.all(FSizes.sm),
          decoration: BoxDecoration(
            color: FColors.energy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            border: Border.all(
              color: FColors.energy.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmissionInfoDialog.buildInfoIcon(
                context: context,
                metadata: EnergyEmissionConfig.energyEmissionFactors[
                        'electricity_peninsular']!['tariff_metadata']
                    as Map<String, dynamic>,
                dark: dark,
                color: FColors.energy,
              ),
              const SizedBox(width: FSizes.xs),
              Expanded(
                child: Text(
                  'We estimate your kWh from your bill using typical TNB residential tariffs.\n'
                  'This is an approximation, not an exact bill simulator.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FSizes.sm),

        Obx(
          () => CommonEmissionWidgets.buildEmissionPreview(
            context: context,
            emissions: controller.gridEmissions.value,
            formatEmission: controller.formatEmissionTons,
            color: FColors.energy,
            dark: dark,
          ),
        ),
      ],
    );
  }

  /// 2. Solar PV
  Widget _buildSolarPVSection(
      BuildContext context, EnergyController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: FColors.energy.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.energy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.sun_1,
                  color: FColors.energy,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  '2. Solar PV (Optional)',
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
                  color: FColors.energy.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Text(
                  'Zero Emissions',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: FColors.energy,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Obx(
            () => CheckboxListTile(
              title: const Text('I have solar panels installed at home'),
              value: controller.hasSolarPV.value,
              onChanged: (value) {
                controller.hasSolarPV.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              activeColor: FColors.energy,
            ),
          ),
          Obx(() {
            if (!controller.hasSolarPV.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: FSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly self-consumption (kWh)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    EmissionInfoDialog.buildInfoIcon(
                      context: context,
                      metadata: EnergyEmissionConfig
                              .energyEmissionFactors['solar_pv']!['metadata']
                          as Map<String, dynamic>,
                      dark: dark,
                      color: FColors.energy,
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                TextFormField(
                  controller: controller.solarKwhPerMonthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: EmissionValidator.decimalNumberFormatters,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(Iconsax.sun_1),
                    suffixText: 'kWh',
                    suffixStyle: Theme.of(context).textTheme.bodySmall,
                    helperText:
                        'Energy generated and used yourself (not exported)',
                    helperStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  onChanged: (value) => controller.calculateEmissions(),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(() {
                  final avoided = controller.solarAvoidedEmissions.value;
                  if (avoided <= 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: FColors.energy.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.tree,
                          color: FColors.energy,
                          size: FSizes.iconSm,
                        ),
                        const SizedBox(width: FSizes.xs),
                        Expanded(
                          child: Text(
                            'Grid emissions avoided: ${controller.formatEmissionTons(avoided)} CO₂e',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: FColors.energy,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 3. LPG
  Widget _buildLPGSection(
      BuildContext context, EnergyController controller, bool dark) {
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
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.energy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.gas_station,
                  color: FColors.energy,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  '3. LPG (Optional)',
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
              title: const Text('I use LPG for cooking or water heating'),
              value: controller.hasLPG.value,
              onChanged: (value) {
                controller.hasLPG.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              activeColor: FColors.energy,
            ),
          ),
          Obx(() {
            if (!controller.hasLPG.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: FSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly LPG usage (kg)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    EmissionInfoDialog.buildInfoIcon(
                      context: context,
                      metadata: EnergyEmissionConfig
                              .energyEmissionFactors['lpg']!['metadata']
                          as Map<String, dynamic>,
                      dark: dark,
                      color: FColors.energy,
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                TextFormField(
                  controller: controller.lpgKgPerMonthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: EmissionValidator.decimalNumberFormatters,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(Iconsax.gas_station),
                    suffixText: 'kg',
                    suffixStyle: Theme.of(context).textTheme.bodySmall,
                    helperText: 'A typical 14 kg cylinder lasts 1–2 months',
                    helperStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  onChanged: (value) => controller.calculateEmissions(),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(
                  () => CommonEmissionWidgets.buildEmissionPreview(
                    context: context,
                    emissions: controller.lpgEmissions.value,
                    formatEmission: controller.formatEmissionTons,
                    color: FColors.energy,
                    dark: dark,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 4. Natural Gas
  Widget _buildNaturalGasSection(
      BuildContext context, EnergyController controller, bool dark) {
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
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.energy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.health,
                  color: FColors.energy,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  '4. Piped Natural Gas (Optional)',
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
              title: const Text('I have piped natural gas at home'),
              value: controller.hasNaturalGas.value,
              onChanged: (value) {
                controller.hasNaturalGas.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              activeColor: FColors.energy,
            ),
          ),
          Obx(() {
            if (!controller.hasNaturalGas.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: FSizes.md),
                Text(
                  'Input type:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(
                  () => Wrap(
                    spacing: FSizes.sm,
                    runSpacing: FSizes.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('kWh'),
                        selected: controller.gasInputType.value == 'kwh',
                        onSelected: (_) {
                          controller.gasInputType.value = 'kwh';
                          controller.calculateEmissions();
                        },
                        selectedColor: FColors.energy.withOpacity(0.15),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: controller.gasInputType.value == 'kwh'
                                  ? FColors.energy
                                  : (dark
                                      ? FColors.darkTextSecondary
                                      : FColors.textSecondary),
                              fontWeight: controller.gasInputType.value == 'kwh'
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
                            color: controller.gasInputType.value == 'kwh'
                                ? FColors.energy
                                : (dark
                                    ? FColors.borderDark
                                    : FColors.borderSecondary),
                          ),
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('m³'),
                        selected: controller.gasInputType.value == 'm3',
                        onSelected: (_) {
                          controller.gasInputType.value = 'm3';
                          controller.calculateEmissions();
                        },
                        selectedColor: FColors.energy.withOpacity(0.15),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: controller.gasInputType.value == 'm3'
                                  ? FColors.energy
                                  : (dark
                                      ? FColors.darkTextSecondary
                                      : FColors.textSecondary),
                              fontWeight: controller.gasInputType.value == 'm3'
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
                            color: controller.gasInputType.value == 'm3'
                                ? FColors.energy
                                : (dark
                                    ? FColors.borderDark
                                    : FColors.borderSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.gasInputType.value == 'kwh'
                              ? 'Monthly natural gas consumption (kWh)'
                              : 'Monthly natural gas consumption (m³)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    EmissionInfoDialog.buildInfoIcon(
                      context: context,
                      metadata: EnergyEmissionConfig
                              .energyEmissionFactors['natural_gas']!['metadata']
                          as Map<String, dynamic>,
                      dark: dark,
                      color: FColors.energy,
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                Obx(
                  () => TextFormField(
                    controller: controller.gasInputType.value == 'kwh'
                        ? controller.gasKwhPerMonthController
                        : controller.gasM3PerMonthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: EmissionValidator.decimalNumberFormatters,
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixIcon: const Icon(Iconsax.health),
                      suffixText:
                          controller.gasInputType.value == 'kwh' ? 'kWh' : 'm³',
                      suffixStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                    onChanged: (value) => controller.calculateEmissions(),
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(
                  () => CommonEmissionWidgets.buildEmissionPreview(
                    context: context,
                    emissions: controller.gasEmissions.value,
                    formatEmission: controller.formatEmissionTons,
                    color: FColors.energy,
                    dark: dark,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 5. Diesel Generator
  Widget _buildDieselGeneratorSection(
      BuildContext context, EnergyController controller, bool dark) {
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
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.energy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.setting_4,
                  color: FColors.energy,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  '5. Diesel Generator (Optional)',
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
              title: const Text('I regularly use a diesel generator'),
              subtitle: const Text('Common in rural areas'),
              value: controller.hasDieselGen.value,
              onChanged: (value) {
                controller.hasDieselGen.value = value ?? false;
                controller.calculateEmissions();
              },
              contentPadding: EdgeInsets.zero,
              activeColor: FColors.energy,
            ),
          ),
          Obx(() {
            if (!controller.hasDieselGen.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: FSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly diesel usage (litres)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    EmissionInfoDialog.buildInfoIcon(
                      context: context,
                      metadata: EnergyEmissionConfig.energyEmissionFactors[
                              'diesel_generator']!['metadata']
                          as Map<String, dynamic>,
                      dark: dark,
                      color: FColors.energy,
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                TextFormField(
                  controller: controller.dieselLitersPerMonthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: EmissionValidator.decimalNumberFormatters,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(Iconsax.setting_4),
                    suffixText: 'litres',
                    suffixStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  onChanged: (value) => controller.calculateEmissions(),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(
                  () => CommonEmissionWidgets.buildEmissionPreview(
                    context: context,
                    emissions: controller.dieselEmissions.value,
                    formatEmission: controller.formatEmissionTons,
                    color: FColors.energy,
                    dark: dark,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 6. Biomass
  Widget _buildBiomassSection(
      BuildContext context, EnergyController controller, bool dark) {
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
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: FColors.energy.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.tree,
                  color: FColors.energy,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  '6. Biomass (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Do you use firewood or charcoal for cooking?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: FSizes.sm),
          Obx(
            () => Wrap(
              spacing: FSizes.sm,
              runSpacing: FSizes.sm,
              children: [
                ChoiceChip(
                  label: const Text('None'),
                  selected: controller.biomassType.value == 'none',
                  onSelected: (_) {
                    controller.biomassType.value = 'none';
                    controller.calculateEmissions();
                  },
                  selectedColor: Colors.grey.withOpacity(0.15),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: controller.biomassType.value == 'none'
                            ? Colors.grey
                            : (dark
                                ? FColors.darkTextSecondary
                                : FColors.textSecondary),
                        fontWeight: controller.biomassType.value == 'none'
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                  backgroundColor:
                      dark ? FColors.darkContainer : FColors.lightContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    side: BorderSide(
                      color: controller.biomassType.value == 'none'
                          ? Colors.grey
                          : (dark
                              ? FColors.borderDark
                              : FColors.borderSecondary),
                    ),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Firewood'),
                  selected: controller.biomassType.value == 'firewood',
                  onSelected: (_) {
                    controller.biomassType.value = 'firewood';
                    controller.calculateEmissions();
                  },
                  selectedColor: FColors.energy.withOpacity(0.15),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: controller.biomassType.value == 'firewood'
                            ? FColors.energy
                            : (dark
                                ? FColors.darkTextSecondary
                                : FColors.textSecondary),
                        fontWeight: controller.biomassType.value == 'firewood'
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                  backgroundColor:
                      dark ? FColors.darkContainer : FColors.lightContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    side: BorderSide(
                      color: controller.biomassType.value == 'firewood'
                          ? FColors.energy
                          : (dark
                              ? FColors.borderDark
                              : FColors.borderSecondary),
                    ),
                  ),
                ),
                ChoiceChip(
                  label: const Text('Charcoal'),
                  selected: controller.biomassType.value == 'charcoal',
                  onSelected: (_) {
                    controller.biomassType.value = 'charcoal';
                    controller.calculateEmissions();
                  },
                  selectedColor: FColors.energy.withOpacity(0.15),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: controller.biomassType.value == 'charcoal'
                            ? FColors.energy
                            : (dark
                                ? FColors.darkTextSecondary
                                : FColors.textSecondary),
                        fontWeight: controller.biomassType.value == 'charcoal'
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                  backgroundColor:
                      dark ? FColors.darkContainer : FColors.lightContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    side: BorderSide(
                      color: controller.biomassType.value == 'charcoal'
                          ? FColors.energy
                          : (dark
                              ? FColors.borderDark
                              : FColors.borderSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          Obx(() {
            if (controller.biomassType.value == 'none') {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly usage (kg)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    EmissionInfoDialog.buildInfoIcon(
                      context: context,
                      metadata: EnergyEmissionConfig.energyEmissionFactors[
                              controller.biomassType.value]!['metadata']
                          as Map<String, dynamic>,
                      dark: dark,
                      color: FColors.energy,
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                TextFormField(
                  controller: controller.biomassKgPerMonthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: EmissionValidator.decimalNumberFormatters,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(Iconsax.tree),
                    suffixText: 'kg',
                    suffixStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  onChanged: (value) => controller.calculateEmissions(),
                ),
                const SizedBox(height: FSizes.sm),
                Obx(
                  () => CommonEmissionWidgets.buildEmissionPreview(
                    context: context,
                    emissions: controller.biomassEmissions.value,
                    formatEmission: controller.formatEmissionTons,
                    color: FColors.energy,
                    dark: dark,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Region chip
  Widget _buildRegionChip({
    required BuildContext context,
    required String label,
    required String value,
    required bool selected,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? FColors.energy
              : (dark ? FColors.darkContainer : FColors.light),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
          border: Border.all(
            color: selected ? FColors.energy : FColors.energy.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected
                    ? (dark ? FColors.dark : FColors.white)
                    : (dark ? FColors.darkGrey : FColors.textSecondary),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
