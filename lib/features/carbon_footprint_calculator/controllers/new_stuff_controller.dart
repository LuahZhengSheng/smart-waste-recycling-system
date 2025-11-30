import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../utils/live_exchange_rate.dart';
import '../models/emission_model.dart';

class NewStuffController extends GetxController {
  static NewStuffController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());

  // Observable state
  final isLoading = true.obs;
  final isSaving = false.obs;
  final isCalculating = false.obs;

  // Exchange rate
  final usdToMyrRate = 4.13.obs; // Default fallback
  final isRateFetching = false.obs;

  // ==================== Electronics & Appliances ====================
  final computersLaptopsController = TextEditingController();
  final smartphonesTabletsController = TextEditingController();
  final tvsMonitorsController = TextEditingController();
  final smallAppliancesController = TextEditingController();

  // ==================== Clothing & Footwear ====================
  final clothingController = TextEditingController();
  final footwearController = TextEditingController();
  final bagsAccessoriesController = TextEditingController();

  // ==================== Furniture & Homeware ====================
  final furnitureController = TextEditingController();
  final homewareKitchenController = TextEditingController();

  // ==================== Other ====================
  final otherConsumerGoodsController = TextEditingController();

  // ==================== Calculated Emissions ====================
  final computersLaptopsEmissions = 0.0.obs;
  final smartphonesTabletsEmissions = 0.0.obs;
  final tvsMonitorsEmissions = 0.0.obs;
  final smallAppliancesEmissions = 0.0.obs;

  final clothingEmissions = 0.0.obs;
  final footwearEmissions = 0.0.obs;
  final bagsAccessoriesEmissions = 0.0.obs;

  final furnitureEmissions = 0.0.obs;
  final homewareKitchenEmissions = 0.0.obs;

  final otherConsumerGoodsEmissions = 0.0.obs;

  final totalEmissions = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchExchangeRate();
    _loadExistingData();
  }

  @override
  void onClose() {
    computersLaptopsController.dispose();
    smartphonesTabletsController.dispose();
    tvsMonitorsController.dispose();
    smallAppliancesController.dispose();
    clothingController.dispose();
    footwearController.dispose();
    bagsAccessoriesController.dispose();
    furnitureController.dispose();
    homewareKitchenController.dispose();
    otherConsumerGoodsController.dispose();
    super.onClose();
  }

  /// Fetch live USD to MYR exchange rate
  Future<void> _fetchExchangeRate() async {
    isRateFetching.value = true;
    try {
      final rate = await LiveExchange.getUsdToMyrRate();
      usdToMyrRate.value = rate;
    } catch (e) {
      print('Error fetching exchange rate: $e');
      // Keep fallback rate
    } finally {
      isRateFetching.value = false;
    }
  }

  /// Load existing data
  Future<void> _loadExistingData() async {
    isLoading.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Stuff');

      if (existingEmission != null) {
        final inputs = existingEmission.inputs;

        // Load spending data
        computersLaptopsController.text =
            inputs['computers_laptops_spend_rm']?.toString() ?? '0';
        smartphonesTabletsController.text =
            inputs['smartphones_tablets_spend_rm']?.toString() ?? '0';
        tvsMonitorsController.text =
            inputs['tvs_monitors_spend_rm']?.toString() ?? '0';
        smallAppliancesController.text =
            inputs['small_appliances_spend_rm']?.toString() ?? '0';

        clothingController.text =
            inputs['clothing_spend_rm']?.toString() ?? '0';
        footwearController.text =
            inputs['footwear_spend_rm']?.toString() ?? '0';
        bagsAccessoriesController.text =
            inputs['bags_accessories_spend_rm']?.toString() ?? '0';

        furnitureController.text =
            inputs['furniture_spend_rm']?.toString() ?? '0';
        homewareKitchenController.text =
            inputs['homeware_kitchen_spend_rm']?.toString() ?? '0';

        otherConsumerGoodsController.text =
            inputs['other_consumer_goods_spend_rm']?.toString() ?? '0';

        // Load stored exchange rate if available
        if (inputs['usd_to_myr_rate'] != null) {
          usdToMyrRate.value = inputs['usd_to_myr_rate'];
        }

        calculateEmissions();
      }
    } catch (e) {
      print('Error loading new stuff data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate all emissions
  Future<void> calculateEmissions() async {
    isCalculating.value = true;
    try {
      final rate = usdToMyrRate.value;

      // Electronics & Appliances
      computersLaptopsEmissions.value = _calculateEmissionSync(
        'computers_laptops',
        double.tryParse(computersLaptopsController.text) ?? 0.0,
        rate,
      );

      smartphonesTabletsEmissions.value = _calculateEmissionSync(
        'smartphones_tablets',
        double.tryParse(smartphonesTabletsController.text) ?? 0.0,
        rate,
      );

      tvsMonitorsEmissions.value = _calculateEmissionSync(
        'tvs_monitors',
        double.tryParse(tvsMonitorsController.text) ?? 0.0,
        rate,
      );

      smallAppliancesEmissions.value = _calculateEmissionSync(
        'small_appliances',
        double.tryParse(smallAppliancesController.text) ?? 0.0,
        rate,
      );

      // Clothing & Footwear
      clothingEmissions.value = _calculateEmissionSync(
        'clothing',
        double.tryParse(clothingController.text) ?? 0.0,
        rate,
      );

      footwearEmissions.value = _calculateEmissionSync(
        'footwear',
        double.tryParse(footwearController.text) ?? 0.0,
        rate,
      );

      bagsAccessoriesEmissions.value = _calculateEmissionSync(
        'bags_accessories',
        double.tryParse(bagsAccessoriesController.text) ?? 0.0,
        rate,
      );

      // Furniture & Homeware
      furnitureEmissions.value = _calculateEmissionSync(
        'furniture',
        double.tryParse(furnitureController.text) ?? 0.0,
        rate,
      );

      homewareKitchenEmissions.value = _calculateEmissionSync(
        'homeware_kitchen',
        double.tryParse(homewareKitchenController.text) ?? 0.0,
        rate,
      );

      // Other
      otherConsumerGoodsEmissions.value = _calculateEmissionSync(
        'other_consumer_goods',
        double.tryParse(otherConsumerGoodsController.text) ?? 0.0,
        rate,
      );

      _calculateTotal();
    } finally {
      isCalculating.value = false;
    }
  }

  /// Calculate emission for a single category (synchronous)
  double _calculateEmissionSync(String category, double spendRM, double rate) {
    try {
      return LiveExchange.calculateEmissionsSync(
        category,
        spendRM: spendRM,
        usdToMyrRate: rate,
      );
    } catch (e) {
      print('Error calculating $category emissions: $e');
      return 0.0;
    }
  }

  /// Calculate total emissions
  void _calculateTotal() {
    totalEmissions.value = computersLaptopsEmissions.value +
        smartphonesTabletsEmissions.value +
        tvsMonitorsEmissions.value +
        smallAppliancesEmissions.value +
        clothingEmissions.value +
        footwearEmissions.value +
        bagsAccessoriesEmissions.value +
        furnitureEmissions.value +
        homewareKitchenEmissions.value +
        otherConsumerGoodsEmissions.value;
  }

  /// Save emissions
  Future<void> saveEmissions() async {
    if (totalEmissions.value == 0) {
      FHelperFunctions.showSnackBar(
          'Please enter at least one spending category');
      return;
    }

    isSaving.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Stuff');

      final inputs = {
        // Spending data
        'computers_laptops_spend_rm':
        double.tryParse(computersLaptopsController.text) ?? 0.0,
        'smartphones_tablets_spend_rm':
        double.tryParse(smartphonesTabletsController.text) ?? 0.0,
        'tvs_monitors_spend_rm':
        double.tryParse(tvsMonitorsController.text) ?? 0.0,
        'small_appliances_spend_rm':
        double.tryParse(smallAppliancesController.text) ?? 0.0,
        'clothing_spend_rm': double.tryParse(clothingController.text) ?? 0.0,
        'footwear_spend_rm': double.tryParse(footwearController.text) ?? 0.0,
        'bags_accessories_spend_rm':
        double.tryParse(bagsAccessoriesController.text) ?? 0.0,
        'furniture_spend_rm': double.tryParse(furnitureController.text) ?? 0.0,
        'homeware_kitchen_spend_rm':
        double.tryParse(homewareKitchenController.text) ?? 0.0,
        'other_consumer_goods_spend_rm':
        double.tryParse(otherConsumerGoodsController.text) ?? 0.0,

        // Exchange rate used
        'usd_to_myr_rate': usdToMyrRate.value,

        // Emissions breakdown
        'computers_laptops_emissions': computersLaptopsEmissions.value,
        'smartphones_tablets_emissions': smartphonesTabletsEmissions.value,
        'tvs_monitors_emissions': tvsMonitorsEmissions.value,
        'small_appliances_emissions': smallAppliancesEmissions.value,
        'clothing_emissions': clothingEmissions.value,
        'footwear_emissions': footwearEmissions.value,
        'bags_accessories_emissions': bagsAccessoriesEmissions.value,
        'furniture_emissions': furnitureEmissions.value,
        'homeware_kitchen_emissions': homewareKitchenEmissions.value,
        'other_consumer_goods_emissions': otherConsumerGoodsEmissions.value,

        'data_source': 'Climatiq Data Explorer',
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
          category: 'Stuff',
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      }

      await _emissionRepo.saveEmission(emission);
      FHelperFunctions.showSnackBar(
          'New stuff emissions saved successfully!');
      Get.back();
    } catch (e) {
      FHelperFunctions.showSnackBar('Error saving emissions: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear all inputs
  void clearInputs() {
    computersLaptopsController.text = '0';
    smartphonesTabletsController.text = '0';
    tvsMonitorsController.text = '0';
    smallAppliancesController.text = '0';
    clothingController.text = '0';
    footwearController.text = '0';
    bagsAccessoriesController.text = '0';
    furnitureController.text = '0';
    homewareKitchenController.text = '0';
    otherConsumerGoodsController.text = '0';

    calculateEmissions();
  }

  /// Get breakdown for results card
  Map<String, double> get emissionsBreakdown {
    final breakdown = <String, double>{};

    if (computersLaptopsEmissions.value > 0) {
      breakdown['Computers & Laptops'] = computersLaptopsEmissions.value;
    }
    if (smartphonesTabletsEmissions.value > 0) {
      breakdown['Phones & Tablets'] = smartphonesTabletsEmissions.value;
    }
    if (tvsMonitorsEmissions.value > 0) {
      breakdown['TVs & Monitors'] = tvsMonitorsEmissions.value;
    }
    if (smallAppliancesEmissions.value > 0) {
      breakdown['Small Appliances'] = smallAppliancesEmissions.value;
    }
    if (clothingEmissions.value > 0) {
      breakdown['Clothing'] = clothingEmissions.value;
    }
    if (footwearEmissions.value > 0) {
      breakdown['Footwear'] = footwearEmissions.value;
    }
    if (bagsAccessoriesEmissions.value > 0) {
      breakdown['Bags & Accessories'] = bagsAccessoriesEmissions.value;
    }
    if (furnitureEmissions.value > 0) {
      breakdown['Furniture'] = furnitureEmissions.value;
    }
    if (homewareKitchenEmissions.value > 0) {
      breakdown['Homeware & Kitchen'] = homewareKitchenEmissions.value;
    }
    if (otherConsumerGoodsEmissions.value > 0) {
      breakdown['Other Goods'] = otherConsumerGoodsEmissions.value;
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