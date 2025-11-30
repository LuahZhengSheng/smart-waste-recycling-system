import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/emission_config/food.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/emission_model.dart';

class FoodController extends GetxController {
  static FoodController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());
  final _storage = GetStorage();

  // Observable state
  final isLoading = true.obs;
  final isSaving = false.obs;

  // ==================== Simplified Frequencies ====================
  final frequencies = {
    'beef': 0.0.obs, // Red meat per week
    'poultry': 0.0.obs, // Chicken only (no pork) per week
    'seafood': 0.0.obs, // Fish + seafood per week
    'dairy': 0.0.obs, // Dairy + eggs per day
    'grains': 0.0.obs, // Rice + wheat per day
    'plants': 0.0.obs, // Vegetables + fruits per day
  };

  // ==================== Portion Weights (user-adjustable) ====================
  final portionWeights = {
    'beef': 0.15.obs, // kg
    'poultry': 0.15.obs, // kg
    'seafood': 0.15.obs, // kg
    'dairy': 0.1.obs, // kg
    'grains': 0.15.obs, // kg
    'plants': 0.1.obs, // kg
  };

  // ==================== Calculated Emissions ====================
  final beefEmissions = 0.0.obs;
  final poultryEmissions = 0.0.obs;
  final seafoodEmissions = 0.0.obs;
  final dairyEmissions = 0.0.obs;
  final grainsEmissions = 0.0.obs;
  final plantsEmissions = 0.0.obs;
  final totalEmissions = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPortionWeights();
    _loadExistingData();

    // Listen to frequency changes
    frequencies.forEach((key, obs) {
      obs.listen((_) => calculateEmissions());
    });

    // Listen to portion weight changes
    portionWeights.forEach((key, obs) {
      obs.listen((_) {
        _savePortionWeights();
        calculateEmissions();
      });
    });
  }

  /// Load portion weights from storage
  void _loadPortionWeights() {
    portionWeights.forEach((key, obs) {
      final saved = _storage.read('portion_$key');
      if (saved != null) {
        obs.value = (saved as num).toDouble();
      }
    });
  }

  /// Save portion weights to storage
  void _savePortionWeights() {
    portionWeights.forEach((key, obs) {
      _storage.write('portion_$key', obs.value);
    });
  }

  /// Reset portion weights to defaults
  void resetPortionWeights() {
    portionWeights['beef']!.value = 0.15;
    portionWeights['poultry']!.value = 0.15;
    portionWeights['seafood']!.value = 0.15;
    portionWeights['dairy']!.value = 0.1;
    portionWeights['grains']!.value = 0.15;
    portionWeights['plants']!.value = 0.1;
    FHelperFunctions.showSnackBar('Portion sizes reset to defaults');
  }

  /// Update frequency
  void updateFrequency(String key, double value) {
    if (frequencies.containsKey(key)) {
      frequencies[key]!.value = value;
    }
  }

  /// Update portion weight
  void updatePortionWeight(String key, double value) {
    if (portionWeights.containsKey(key)) {
      portionWeights[key]!.value = value;
    }
  }

  /// Load existing data
  Future<void> _loadExistingData() async {
    isLoading.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Food');

      if (existingEmission != null) {
        final inputs = existingEmission.inputs;

        frequencies['beef']!.value =
            inputs['beef_frequency']?.toDouble() ?? 0.0;
        frequencies['poultry']!.value =
            inputs['poultry_frequency']?.toDouble() ?? 0.0;
        frequencies['seafood']!.value =
            inputs['seafood_frequency']?.toDouble() ?? 0.0;
        frequencies['dairy']!.value =
            inputs['dairy_frequency']?.toDouble() ?? 0.0;
        frequencies['grains']!.value =
            inputs['grains_frequency']?.toDouble() ?? 0.0;
        frequencies['plants']!.value =
            inputs['plants_frequency']?.toDouble() ?? 0.0;

        calculateEmissions();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading food data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate all emissions
  void calculateEmissions() {
    _calculateBeefEmissions();
    _calculatePoultryEmissions();
    _calculateSeafoodEmissions();
    _calculateDairyEmissions();
    _calculateGrainsEmissions();
    _calculatePlantsEmissions();
    _calculateTotal();
  }

  /// Calculate beef emissions
  void _calculateBeefEmissions() {
    final frequency = frequencies['beef']!.value;
    final portionWeight = portionWeights['beef']!.value;

    final avgEF = (
        (FoodEmissionConfig.foodEmissionFactors['beef']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['lamb_mutton']!['ef_per_kg'] as num).toDouble()
    ) / 2.0;

    final kgPerYear = frequency * portionWeight * 52;
    beefEmissions.value = kgPerYear * avgEF;
  }


  /// Calculate poultry emissions (chicken only, NO PORK)
  void _calculatePoultryEmissions() {
    final frequency = frequencies['poultry']!.value;
    final portionWeight = portionWeights['poultry']!.value;

    // Only chicken, no pork for Malaysia
    final chickenEF =
    FoodEmissionConfig.foodEmissionFactors['chicken']!['ef_per_kg'] as double;

    final kgPerYear = frequency * portionWeight * 52;
    poultryEmissions.value = kgPerYear * chickenEF;
  }

  /// Calculate seafood emissions
  void _calculateSeafoodEmissions() {
    final frequency = frequencies['seafood']!.value;
    final portionWeight = portionWeights['seafood']!.value;

    final avgEF = (
        (FoodEmissionConfig.foodEmissionFactors['fish_farmed']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['prawns_farmed']!['ef_per_kg'] as num).toDouble()
    ) / 2.0;

    final kgPerYear = frequency * portionWeight * 52;
    seafoodEmissions.value = kgPerYear * avgEF;
  }

  /// Calculate dairy emissions
  void _calculateDairyEmissions() {
    final frequency = frequencies['dairy']!.value;
    final portionWeight = portionWeights['dairy']!.value;

    final avgEF = (
        (FoodEmissionConfig.foodEmissionFactors['milk']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['cheese']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['eggs']!['ef_per_kg'] as num).toDouble()
    ) / 3.0;

    final kgPerYear = frequency * portionWeight * 365;
    dairyEmissions.value = kgPerYear * avgEF;
  }

  /// Calculate grains emissions
  void _calculateGrainsEmissions() {
    final frequency = frequencies['grains']!.value;
    final portionWeight = portionWeights['grains']!.value;

    final avgEF = (
        (FoodEmissionConfig.foodEmissionFactors['rice']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['wheat_products']!['ef_per_kg'] as num).toDouble()
    ) / 2.0;

    final kgPerYear = frequency * portionWeight * 365;
    grainsEmissions.value = kgPerYear * avgEF;
  }

  /// Calculate plants emissions
  void _calculatePlantsEmissions() {
    final frequency = frequencies['plants']!.value;
    final portionWeight = portionWeights['plants']!.value;

    final avgEF = (
        (FoodEmissionConfig.foodEmissionFactors['vegetable_mix']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['fruit_mix']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['other_pulses']!['ef_per_kg'] as num).toDouble() +
            (FoodEmissionConfig.foodEmissionFactors['nuts']!['ef_per_kg'] as num).toDouble()
    ) / 4.0;

    final kgPerYear = frequency * portionWeight * 365;
    plantsEmissions.value = kgPerYear * avgEF;
  }

  /// Calculate total
  void _calculateTotal() {
    totalEmissions.value = beefEmissions.value +
        poultryEmissions.value +
        seafoodEmissions.value +
        dairyEmissions.value +
        grainsEmissions.value +
        plantsEmissions.value;
  }

  /// Save emissions
  Future<void> saveEmissions() async {
    if (totalEmissions.value == 0) {
      FHelperFunctions.showSnackBar('Please select at least one food category');
      return;
    }

    isSaving.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Food');

      final inputs = {
        'beef_frequency': frequencies['beef']!.value,
        'poultry_frequency': frequencies['poultry']!.value,
        'seafood_frequency': frequencies['seafood']!.value,
        'dairy_frequency': frequencies['dairy']!.value,
        'grains_frequency': frequencies['grains']!.value,
        'plants_frequency': frequencies['plants']!.value,
        'beef_emissions': beefEmissions.value,
        'poultry_emissions': poultryEmissions.value,
        'seafood_emissions': seafoodEmissions.value,
        'dairy_emissions': dairyEmissions.value,
        'grains_emissions': grainsEmissions.value,
        'plants_emissions': plantsEmissions.value,
        'data_source': 'Poore & Nemecek (2018)',
        'data_year': 2010,
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
          category: 'Food',
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      }

      await _emissionRepo.saveEmission(emission);
      FHelperFunctions.showSnackBar('Food emissions saved successfully!');
      Get.back();
    } catch (e) {
      FHelperFunctions.showSnackBar('Error saving emissions: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear inputs
  void clearInputs() {
    frequencies.forEach((key, obs) {
      obs.value = 0.0;
    });
    calculateEmissions();
  }

  /// Get breakdown
  Map<String, double> get emissionsBreakdown {
    final breakdown = <String, double>{};

    if (beefEmissions.value > 0) breakdown['Red Meat'] = beefEmissions.value;
    if (poultryEmissions.value > 0) breakdown['Poultry'] = poultryEmissions.value;
    if (seafoodEmissions.value > 0) {
      breakdown['Fish & Seafood'] = seafoodEmissions.value;
    }
    if (dairyEmissions.value > 0) breakdown['Dairy & Eggs'] = dairyEmissions.value;
    if (grainsEmissions.value > 0) breakdown['Rice & Grains'] = grainsEmissions.value;
    if (plantsEmissions.value > 0) breakdown['Plant-Based'] = plantsEmissions.value;

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
