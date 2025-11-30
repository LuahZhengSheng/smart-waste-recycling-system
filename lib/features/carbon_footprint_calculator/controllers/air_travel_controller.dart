import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/emission_config/air_travel.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/emission_model.dart';

class AirTravelController extends GetxController {
  static AirTravelController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());

  // Controllers for inputs - 5 classes
  final economyDistanceController = TextEditingController();
  final premiumEconomyDistanceController = TextEditingController();
  final businessDistanceController = TextEditingController();
  final firstDistanceController = TextEditingController();
  final averageDistanceController = TextEditingController();

  // Observable state
  final isLoading = true.obs;
  final isSaving = false.obs;

  // Round trip flags
  final economyRoundTrip = false.obs;
  final premiumEconomyRoundTrip = false.obs;
  final businessRoundTrip = false.obs;
  final firstRoundTrip = false.obs;
  final averageRoundTrip = false.obs;

  // Calculated emissions for each class
  final economyEmissions = 0.0.obs;
  final premiumEconomyEmissions = 0.0.obs;
  final businessEmissions = 0.0.obs;
  final firstEmissions = 0.0.obs;
  final averageEmissions = 0.0.obs;
  final totalEmissions = 0.0.obs;

  // Breakdown
  final fuelCombustion = 0.0.obs;
  final wellToTank = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingData();
  }

  @override
  void onClose() {
    economyDistanceController.dispose();
    premiumEconomyDistanceController.dispose();
    businessDistanceController.dispose();
    firstDistanceController.dispose();
    averageDistanceController.dispose();
    super.onClose();
  }

  /// Load existing air travel data
  Future<void> _loadExistingData() async {
    isLoading.value = true;
    try {
      final existingEmission =
          await _emissionRepo.getLatestEmissionByCategory('Air Travel');

      if (existingEmission != null) {
        final inputs = existingEmission.inputs;

        // Load saved inputs for all 5 classes
        economyDistanceController.text =
            inputs['economy_distance']?.toString() ?? '0';
        premiumEconomyDistanceController.text =
            inputs['premium_economy_distance']?.toString() ?? '0';
        businessDistanceController.text =
            inputs['business_distance']?.toString() ?? '0';
        firstDistanceController.text =
            inputs['first_distance']?.toString() ?? '0';
        averageDistanceController.text =
            inputs['average_distance']?.toString() ?? '0';

        // Load round trip flags
        economyRoundTrip.value = inputs['economy_round_trip'] ?? false;
        premiumEconomyRoundTrip.value =
            inputs['premium_economy_round_trip'] ?? false;
        businessRoundTrip.value = inputs['business_round_trip'] ?? false;
        firstRoundTrip.value = inputs['first_round_trip'] ?? false;
        averageRoundTrip.value = inputs['average_round_trip'] ?? false;

        // Calculate emissions with loaded data
        calculateEmissions();
      }
    } catch (e) {
      print('Error loading air travel data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate emissions for all classes
  void calculateEmissions() {
    // Parse distances and apply round trip multiplier
    final economyDist = _getEffectiveDistance(
      economyDistanceController.text,
      economyRoundTrip.value,
    );
    final premiumDist = _getEffectiveDistance(
      premiumEconomyDistanceController.text,
      premiumEconomyRoundTrip.value,
    );
    final businessDist = _getEffectiveDistance(
      businessDistanceController.text,
      businessRoundTrip.value,
    );
    final firstDist = _getEffectiveDistance(
      firstDistanceController.text,
      firstRoundTrip.value,
    );
    final averageDist = _getEffectiveDistance(
      averageDistanceController.text,
      averageRoundTrip.value,
    );

    // Calculate emissions for each class
    economyEmissions.value = economyDist *
        AirTravelEmissionConfig.getAirTravelEmissionFactor('economy');

    premiumEconomyEmissions.value = premiumDist *
        AirTravelEmissionConfig.getAirTravelEmissionFactor('premium_economy');

    businessEmissions.value = businessDist *
        AirTravelEmissionConfig.getAirTravelEmissionFactor('business');

    firstEmissions.value =
        firstDist * AirTravelEmissionConfig.getAirTravelEmissionFactor('first');

    averageEmissions.value = averageDist *
        AirTravelEmissionConfig.getAirTravelEmissionFactor('average');

    // Calculate total
    totalEmissions.value = economyEmissions.value +
        premiumEconomyEmissions.value +
        businessEmissions.value +
        firstEmissions.value +
        averageEmissions.value;

    // Calculate breakdown
    _calculateBreakdown(
        economyDist, premiumDist, businessDist, firstDist, averageDist);
  }

  /// Get effective distance (considering round trip)
  double _getEffectiveDistance(String distanceText, bool isRoundTrip) {
    final distance = double.tryParse(distanceText) ?? 0.0;
    return isRoundTrip ? distance * 2 : distance;
  }

  /// Calculate fuel combustion and well-to-tank breakdown
  void _calculateBreakdown(double economyDist, double premiumDist,
      double businessDist, double firstDist, double averageDist) {
    fuelCombustion.value = (economyDist *
            AirTravelEmissionConfig.getAirTravelFuelCombustion('economy')) +
        (premiumDist *
            AirTravelEmissionConfig.getAirTravelFuelCombustion(
                'premium_economy')) +
        (businessDist *
            AirTravelEmissionConfig.getAirTravelFuelCombustion('business')) +
        (firstDist *
            AirTravelEmissionConfig.getAirTravelFuelCombustion('first')) +
        (averageDist *
            AirTravelEmissionConfig.getAirTravelFuelCombustion('average'));

    wellToTank.value = (economyDist *
            AirTravelEmissionConfig.getAirTravelWellToTank('economy')) +
        (premiumDist *
            AirTravelEmissionConfig.getAirTravelWellToTank('premium_economy')) +
        (businessDist *
            AirTravelEmissionConfig.getAirTravelWellToTank('business')) +
        (firstDist * AirTravelEmissionConfig.getAirTravelWellToTank('first')) +
        (averageDist *
            AirTravelEmissionConfig.getAirTravelWellToTank('average'));
  }

  /// Breakdown for UI (by class)
  Map<String, double> get breakdownByClass => {
    if (economyEmissions.value > 0) 'Economy Class': economyEmissions.value,
    if (premiumEconomyEmissions.value > 0)
      'Premium Economy': premiumEconomyEmissions.value,
    if (businessEmissions.value > 0) 'Business Class': businessEmissions.value,
    if (firstEmissions.value > 0) 'First Class': firstEmissions.value,
    if (averageEmissions.value > 0) 'Average Class': averageEmissions.value,
  };

  /// Save emissions to Firestore
  Future<void> saveEmissions() async {
    if (totalEmissions.value == 0) {
      FHelperFunctions.showSnackBar(
          'Please enter at least one flight distance');
      return;
    }

    isSaving.value = true;
    try {
      // Get existing emission or create new
      final existingEmission =
          await _emissionRepo.getLatestEmissionByCategory('Air Travel');

      // Prepare inputs (save one-way distances and round trip flags)
      final inputs = {
        'economy_distance':
            double.tryParse(economyDistanceController.text) ?? 0.0,
        'premium_economy_distance':
            double.tryParse(premiumEconomyDistanceController.text) ?? 0.0,
        'business_distance':
            double.tryParse(businessDistanceController.text) ?? 0.0,
        'first_distance': double.tryParse(firstDistanceController.text) ?? 0.0,
        'average_distance':
            double.tryParse(averageDistanceController.text) ?? 0.0,
        'economy_round_trip': economyRoundTrip.value,
        'premium_economy_round_trip': premiumEconomyRoundTrip.value,
        'business_round_trip': businessRoundTrip.value,
        'first_round_trip': firstRoundTrip.value,
        'average_round_trip': averageRoundTrip.value,
        'fuel_combustion': fuelCombustion.value,
        'well_to_tank': wellToTank.value,
        'data_source': AirTravelEmissionConfig.dataSource,
        'data_year': AirTravelEmissionConfig.dataYear,
      };

      EmissionModel emission;
      if (existingEmission != null) {
        // Update existing
        emission = existingEmission.copyWith(
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      } else {
        // Create new
        emission = EmissionModel.create(
          userId: AuthenticationRepository
              .instance.authUser!.uid, // Will be set by repository
          category: 'Air Travel',
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      }

      await _emissionRepo.saveEmission(emission);

      FHelperFunctions.showSnackBar('Air travel emissions saved successfully!');
      Get.back();
    } catch (e) {
      FHelperFunctions.showSnackBar('Error saving emissions: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear all inputs
  void clearInputs() {
    economyDistanceController.text = '0';
    premiumEconomyDistanceController.text = '0';
    businessDistanceController.text = '0';
    firstDistanceController.text = '0';
    averageDistanceController.text = '0';

    economyRoundTrip.value = false;
    premiumEconomyRoundTrip.value = false;
    businessRoundTrip.value = false;
    firstRoundTrip.value = false;
    averageRoundTrip.value = false;

    calculateEmissions();
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
