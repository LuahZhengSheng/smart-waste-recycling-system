import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/emission_config/energy.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/emission_model.dart';

class EnergyController extends GetxController {
  static EnergyController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());

  // Observable state
  final isLoading = true.obs;
  final isSaving = false.obs;

  // 1. Grid Electricity
  final region = 'peninsular'.obs; // 'peninsular', 'sabah', 'sarawak'
  final knowsKwh = true.obs;
  final monthlyKwhController = TextEditingController();
  final monthlyBillRmController = TextEditingController();
  // usageLevel 不再用于计算，但为了兼容已存数据先保留字段（UI 可不再使用）
  final usageLevel = 'unknown'.obs; // 'below', 'above', 'unknown'

  // 2. Solar PV
  final hasSolarPV = false.obs;
  final solarKwhPerMonthController = TextEditingController();

  // 3. LPG
  final hasLPG = false.obs;
  final lpgKgPerMonthController = TextEditingController();

  // 4. Natural Gas
  final hasNaturalGas = false.obs;
  final gasInputType = 'kwh'.obs; // 'kwh' or 'm3'
  final gasKwhPerMonthController = TextEditingController();
  final gasM3PerMonthController = TextEditingController();

  // 5. Diesel Generator
  final hasDieselGen = false.obs;
  final dieselLitersPerMonthController = TextEditingController();

  // 6. Biomass
  final biomassType = 'none'.obs; // 'none', 'firewood', 'charcoal'
  final biomassKgPerMonthController = TextEditingController();

  // Calculated emissions
  final gridEmissions = 0.0.obs;
  final solarEmissions = 0.0.obs;
  final solarAvoidedEmissions = 0.0.obs;
  final lpgEmissions = 0.0.obs;
  final gasEmissions = 0.0.obs;
  final dieselEmissions = 0.0.obs;
  final biomassEmissions = 0.0.obs;
  final totalEmissions = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingData();

    // Listen to changes
    region.listen((_) => calculateEmissions());
    knowsKwh.listen((_) => calculateEmissions());
    // usageLevel 不再影响计算，但保留监听兼容旧数据（可以删除）
    usageLevel.listen((_) => calculateEmissions());
    hasSolarPV.listen((_) => calculateEmissions());
    hasLPG.listen((_) => calculateEmissions());
    hasNaturalGas.listen((_) => calculateEmissions());
    gasInputType.listen((_) => calculateEmissions());
    hasDieselGen.listen((_) => calculateEmissions());
    biomassType.listen((_) => calculateEmissions());
  }

  @override
  void onClose() {
    monthlyKwhController.dispose();
    monthlyBillRmController.dispose();
    solarKwhPerMonthController.dispose();
    lpgKgPerMonthController.dispose();
    gasKwhPerMonthController.dispose();
    gasM3PerMonthController.dispose();
    dieselLitersPerMonthController.dispose();
    biomassKgPerMonthController.dispose();
    super.onClose();
  }

  /// Load existing data
  Future<void> _loadExistingData() async {
    isLoading.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Energy');

      if (existingEmission != null) {
        final inputs = existingEmission.inputs;

        // Grid electricity
        region.value = inputs['region'] ?? 'peninsular';
        knowsKwh.value = inputs['knows_kwh'] ?? true;
        monthlyKwhController.text = inputs['monthly_kwh']?.toString() ?? '0';
        monthlyBillRmController.text =
            inputs['monthly_bill_rm']?.toString() ?? '0';
        usageLevel.value = inputs['usage_level'] ?? 'unknown';

        // Solar PV
        hasSolarPV.value = inputs['has_solar_pv'] ?? false;
        solarKwhPerMonthController.text =
            inputs['solar_kwh_per_month']?.toString() ?? '0';

        // LPG
        hasLPG.value = inputs['has_lpg'] ?? false;
        lpgKgPerMonthController.text =
            inputs['lpg_kg_per_month']?.toString() ?? '0';

        // Natural gas
        hasNaturalGas.value = inputs['has_natural_gas'] ?? false;
        gasInputType.value = inputs['gas_input_type'] ?? 'kwh';
        gasKwhPerMonthController.text =
            inputs['gas_kwh_per_month']?.toString() ?? '0';
        gasM3PerMonthController.text =
            inputs['gas_m3_per_month']?.toString() ?? '0';

        // Diesel generator
        hasDieselGen.value = inputs['has_diesel_gen'] ?? false;
        dieselLitersPerMonthController.text =
            inputs['diesel_liters_per_month']?.toString() ?? '0';

        // Biomass
        biomassType.value = inputs['biomass_type'] ?? 'none';
        biomassKgPerMonthController.text =
            inputs['biomass_kg_per_month']?.toString() ?? '0';

        calculateEmissions();
      }
    } catch (e) {
      print('Error loading energy data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate all emissions
  void calculateEmissions() {
    _calculateGridEmissions();
    _calculateSolarEmissions();
    _calculateLPGEmissions();
    _calculateGasEmissions();
    _calculateDieselEmissions();
    _calculateBiomassEmissions();
    _calculateTotal();
  }

  /// Calculate grid electricity emissions
  ///
  /// 方案：
  /// A. 如果 knowsKwh = true  → 使用每月 kWh 直接计算
  /// B. 如果 knowsKwh = false → 使用每月电费 (RM) 估算 kWh，再计算排放
  ///
  /// 电费估算规则（三档）：
  /// - monthlyBill < 300   → 用 0.4443 RM/kWh
  /// - 300 ≤ bill < 700    → 用 0.47 RM/kWh（中间估值）
  /// - bill ≥ 700          → 用 0.5443 RM/kWh
  void _calculateGridEmissions() {
    final gridConfig = _getGridConfig();
    final gridEf = gridConfig['grid_ef'] as double;

    double annualKwh;

    if (knowsKwh.value) {
      // 用户知道每月用电量 (kWh)
      final monthlyKwh = double.tryParse(monthlyKwhController.text) ?? 0.0;
      annualKwh = monthlyKwh * 12;
    } else {
      // 用户只知道每月电费 (RM)
      final monthlyBillRm =
          double.tryParse(monthlyBillRmController.text) ?? 0.0;

      // 三档电费估算逻辑（可根据实际情况微调分界）
      double tariffRate;
      if (monthlyBillRm < 300) {
        // 明显低用电家庭
        tariffRate = 0.4443;
      } else if (monthlyBillRm < 700) {
        // 中等到偏高用电，使用折衷平均价
        tariffRate = 0.47;
      } else {
        // 高用电家庭，落入较高费率区间
        tariffRate = 0.5443;
      }

      // 估算每月 kWh，再换成年 kWh
      final estimatedMonthlyKwh =
      tariffRate > 0 ? (monthlyBillRm / tariffRate) : 0.0;
      annualKwh = estimatedMonthlyKwh * 12;
    }

    gridEmissions.value = annualKwh * gridEf;
  }

  /// Get grid config based on region
  Map<String, dynamic> _getGridConfig() {
    if (region.value == 'peninsular') {
      return EnergyEmissionConfig
          .energyEmissionFactors['electricity_peninsular']!;
    } else if (region.value == 'sabah') {
      return EnergyEmissionConfig.energyEmissionFactors['electricity_sabah']!;
    } else {
      return EnergyEmissionConfig
          .energyEmissionFactors['electricity_sarawak']!;
    }
  }

  /// Calculate solar PV emissions
  void _calculateSolarEmissions() {
    if (!hasSolarPV.value) {
      solarEmissions.value = 0.0;
      solarAvoidedEmissions.value = 0.0;
      return;
    }

    final solarKwhMonth =
        double.tryParse(solarKwhPerMonthController.text) ?? 0.0;
    final solarKwhYear = solarKwhMonth * 12;

    solarEmissions.value = 0.0; // 太阳能自用视为零排放

    // 计算避免的电网排放
    final gridConfig = _getGridConfig();
    final gridEf = gridConfig['grid_ef'] as double;
    solarAvoidedEmissions.value = solarKwhYear * gridEf;
  }

  /// Calculate LPG emissions
  void _calculateLPGEmissions() {
    if (!hasLPG.value) {
      lpgEmissions.value = 0.0;
      return;
    }

    final lpgKgMonth = double.tryParse(lpgKgPerMonthController.text) ?? 0.0;
    final lpgKgYear = lpgKgMonth * 12;
    final lpgKwhYear = lpgKgYear * 13.8; // 1 kg LPG ≈ 13.8 kWh

    final lpgEf =
    EnergyEmissionConfig.energyEmissionFactors['lpg']!['ef_per_kwh']
    as double;

    lpgEmissions.value = lpgKwhYear * lpgEf;
  }

  /// Calculate natural gas emissions
  void _calculateGasEmissions() {
    if (!hasNaturalGas.value) {
      gasEmissions.value = 0.0;
      return;
    }

    double gasKwhYear;

    if (gasInputType.value == 'kwh') {
      final gasKwhMonth =
          double.tryParse(gasKwhPerMonthController.text) ?? 0.0;
      gasKwhYear = gasKwhMonth * 12;
    } else {
      final gasM3Month =
          double.tryParse(gasM3PerMonthController.text) ?? 0.0;
      gasKwhYear = gasM3Month * 10.55 * 12; // 1 m³ ≈ 10.55 kWh
    }

    final gasEf = EnergyEmissionConfig
        .energyEmissionFactors['natural_gas']!['ef_per_kwh'] as double;

    gasEmissions.value = gasKwhYear * gasEf;
  }

  /// Calculate diesel generator emissions
  void _calculateDieselEmissions() {
    if (!hasDieselGen.value) {
      dieselEmissions.value = 0.0;
      return;
    }

    final dieselLitersMonth =
        double.tryParse(dieselLitersPerMonthController.text) ?? 0.0;
    final dieselLitersYear = dieselLitersMonth * 12;

    final dieselEf = EnergyEmissionConfig
        .energyEmissionFactors['diesel_generator']!['ef_per_liter'] as double;

    dieselEmissions.value = dieselLitersYear * dieselEf;
  }

  /// Calculate biomass emissions
  void _calculateBiomassEmissions() {
    if (biomassType.value == 'none') {
      biomassEmissions.value = 0.0;
      return;
    }

    final biomassKgMonth =
        double.tryParse(biomassKgPerMonthController.text) ?? 0.0;
    final biomassKgYear = biomassKgMonth * 12;

    final biomassEf = EnergyEmissionConfig
        .energyEmissionFactors[biomassType.value]!['ef_per_kg'] as double;

    biomassEmissions.value = biomassKgYear * biomassEf;
  }

  /// Calculate total emissions
  void _calculateTotal() {
    totalEmissions.value = gridEmissions.value +
        solarEmissions.value +
        lpgEmissions.value +
        gasEmissions.value +
        dieselEmissions.value +
        biomassEmissions.value;
  }

  /// Save emissions
  Future<void> saveEmissions() async {
    if (totalEmissions.value == 0) {
      FHelperFunctions.showSnackBar('Please enter at least one energy source');
      return;
    }

    isSaving.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Energy');

      final inputs = {
        // Grid electricity
        'region': region.value,
        'knows_kwh': knowsKwh.value,
        'monthly_kwh': double.tryParse(monthlyKwhController.text) ?? 0.0,
        'monthly_bill_rm':
        double.tryParse(monthlyBillRmController.text) ?? 0.0,
        'usage_level': usageLevel.value, // 兼容旧数据，可考虑以后移除

        // Solar PV
        'has_solar_pv': hasSolarPV.value,
        'solar_kwh_per_month':
        double.tryParse(solarKwhPerMonthController.text) ?? 0.0,

        // LPG
        'has_lpg': hasLPG.value,
        'lpg_kg_per_month':
        double.tryParse(lpgKgPerMonthController.text) ?? 0.0,

        // Natural gas
        'has_natural_gas': hasNaturalGas.value,
        'gas_input_type': gasInputType.value,
        'gas_kwh_per_month':
        double.tryParse(gasKwhPerMonthController.text) ?? 0.0,
        'gas_m3_per_month':
        double.tryParse(gasM3PerMonthController.text) ?? 0.0,

        // Diesel generator
        'has_diesel_gen': hasDieselGen.value,
        'diesel_liters_per_month':
        double.tryParse(dieselLitersPerMonthController.text) ?? 0.0,

        // Biomass
        'biomass_type': biomassType.value,
        'biomass_kg_per_month':
        double.tryParse(biomassKgPerMonthController.text) ?? 0.0,

        // Emissions breakdown
        'grid_emissions': gridEmissions.value,
        'solar_emissions': solarEmissions.value,
        'solar_avoided_emissions': solarAvoidedEmissions.value,
        'lpg_emissions': lpgEmissions.value,
        'gas_emissions': gasEmissions.value,
        'diesel_emissions': dieselEmissions.value,
        'biomass_emissions': biomassEmissions.value,

        'data_source': 'Energy Commission MY & DEFRA',
        'data_year': 2023,
      };

      EmissionModel emission;
      if (existingEmission != null) {
        emission = existingEmission.copyWith(
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      } else {
        emission = EmissionModel.create(
          userId: AuthenticationRepository.instance.authUser!.uid,
          category: 'Energy',
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      }

      await _emissionRepo.saveEmission(emission);

      FHelperFunctions.showSnackBar('Energy emissions saved successfully!');
      Get.back();
    } catch (e) {
      FHelperFunctions.showSnackBar('Error saving emissions: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear all inputs
  void clearInputs() {
    region.value = 'peninsular';
    knowsKwh.value = true;
    monthlyKwhController.text = '0';
    monthlyBillRmController.text = '0';
    usageLevel.value = 'unknown';

    hasSolarPV.value = false;
    solarKwhPerMonthController.text = '0';

    hasLPG.value = false;
    lpgKgPerMonthController.text = '0';

    hasNaturalGas.value = false;
    gasInputType.value = 'kwh';
    gasKwhPerMonthController.text = '0';
    gasM3PerMonthController.text = '0';

    hasDieselGen.value = false;
    dieselLitersPerMonthController.text = '0';

    biomassType.value = 'none';
    biomassKgPerMonthController.text = '0';

    calculateEmissions();
  }

  /// Get breakdown for results card
  Map<String, double> get emissionsBreakdown {
    final breakdown = <String, double>{};

    if (gridEmissions.value > 0) {
      breakdown['Grid Electricity'] = gridEmissions.value;
    }
    if (lpgEmissions.value > 0) {
      breakdown['LPG'] = lpgEmissions.value;
    }
    if (gasEmissions.value > 0) {
      breakdown['Natural Gas'] = gasEmissions.value;
    }
    if (dieselEmissions.value > 0) {
      breakdown['Diesel Generator'] = dieselEmissions.value;
    }
    if (biomassEmissions.value > 0) {
      breakdown[biomassType.value == 'firewood' ? 'Firewood' : 'Charcoal'] =
          biomassEmissions.value;
    }

    return breakdown;
  }

  /// Get formatted emission with unit
  String formatEmissionTons(double emissionKg) {
    // emissionKg 是 kg
    final tons = emissionKg / 1000.0;

    // 阈值：小于 0.01 t（10 kg）时，用 kg 显示
    if (tons < 0.01) {
      return '${emissionKg.toStringAsFixed(1)} kg';
    }

    // 否则用 t 显示
    return '${tons.toStringAsFixed(2)} t';
  }

  /// Preview 专用：一律用 kg，保留 1–2 位小数
  String formatPreviewKg(double emission) {
    return '${emission.toStringAsFixed(1)} kg';
  }
}
