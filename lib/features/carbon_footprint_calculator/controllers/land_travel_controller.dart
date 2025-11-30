import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/emission_config/land_travel.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/emission_model.dart';

class LandTravelController extends GetxController {
  static LandTravelController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());

  // Observable state
  final isLoading = true.obs;
  final isSaving = false.obs;

  // 1. Private Fuel Vehicles
  final hasFuelVehicle = Rx<String?>('none'); // 'petrol', 'diesel', 'none'
  final fuelInputMethod = Rx<String?>('fuel'); // 'fuel' or 'distance'

  // Fuel-based inputs
  final petrolLitersController = TextEditingController();
  final dieselLitersController = TextEditingController();

  // Distance-based inputs for fuel vehicles
  final carKmController = TextEditingController();
  final motorcycleKmController = TextEditingController();

  // 2. Electric Vehicles
  final hasEV = false.obs;
  final evKmController = TextEditingController();
  final evKwhPer100KmController = TextEditingController();
  final evChargingLocation = 'peninsular'.obs; // 'peninsular', 'sabah', 'sarawak'

  // 3. Public Transport
  final busKmController = TextEditingController();
  final trainKmController = TextEditingController();

  // 4. Walking & Cycling
  final bikeKmPerWeekController = TextEditingController();
  final walkKmPerWeekController = TextEditingController();

  // Calculated emissions
  final petrolEmissions = 0.0.obs;
  final dieselEmissions = 0.0.obs;
  final carEmissions = 0.0.obs;
  final motorcycleEmissions = 0.0.obs;
  final evEmissions = 0.0.obs;
  final busEmissions = 0.0.obs;
  final trainEmissions = 0.0.obs;
  final bikeEmissions = 0.0.obs;
  final walkEmissions = 0.0.obs;
  final totalEmissions = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingData();

    // Set default value for EV kWh
    evKwhPer100KmController.text = '18';
  }

  @override
  void onClose() {
    petrolLitersController.dispose();
    dieselLitersController.dispose();
    carKmController.dispose();
    motorcycleKmController.dispose();
    evKmController.dispose();
    evKwhPer100KmController.dispose();
    busKmController.dispose();
    trainKmController.dispose();
    bikeKmPerWeekController.dispose();
    walkKmPerWeekController.dispose();
    super.onClose();
  }

  /// Load existing land travel data
  Future<void> _loadExistingData() async {
    isLoading.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Land Travel');

      if (existingEmission != null) {
        final inputs = existingEmission.inputs;

        // Load fuel vehicle data
        hasFuelVehicle.value = inputs['has_fuel_vehicle'] ?? 'none';
        fuelInputMethod.value = inputs['fuel_input_method'] ?? 'fuel';

        petrolLitersController.text =
            inputs['petrol_liters']?.toString() ?? '0';
        dieselLitersController.text =
            inputs['diesel_liters']?.toString() ?? '0';
        carKmController.text = inputs['car_km']?.toString() ?? '0';
        motorcycleKmController.text =
            inputs['motorcycle_km']?.toString() ?? '0';

        // Load EV data
        hasEV.value = inputs['has_ev'] ?? false;
        evKmController.text = inputs['ev_km']?.toString() ?? '0';
        evKwhPer100KmController.text =
            inputs['ev_kwh_per_100km']?.toString() ?? '18';
        evChargingLocation.value = inputs['ev_charging_location'] ?? 'peninsular';

        // Load public transport data
        busKmController.text = inputs['bus_km']?.toString() ?? '0';
        trainKmController.text = inputs['train_km']?.toString() ?? '0';

        // Load walking & cycling data
        bikeKmPerWeekController.text =
            inputs['bike_km_per_week']?.toString() ?? '0';
        walkKmPerWeekController.text =
            inputs['walk_km_per_week']?.toString() ?? '0';

        calculateEmissions();
      }
    } catch (e) {
      print('Error loading land travel data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate all emissions
  void calculateEmissions() {
    // 1. Fuel vehicles
    if (hasFuelVehicle.value == 'petrol' || hasFuelVehicle.value == 'diesel') {
      if (fuelInputMethod.value == 'fuel') {
        _calculateFuelBasedEmissions();
      } else {
        _calculateDistanceBasedEmissions();
      }
    } else {
      petrolEmissions.value = 0.0;
      dieselEmissions.value = 0.0;
      carEmissions.value = 0.0;
      motorcycleEmissions.value = 0.0;
    }

    // 2. Electric vehicles
    if (hasEV.value) {
      _calculateEVEmissions();
    } else {
      evEmissions.value = 0.0;
    }

    // 3. Public transport
    _calculatePublicTransportEmissions();

    // 4. Walking & Cycling (always 0)
    bikeEmissions.value = 0.0;
    walkEmissions.value = 0.0;

    // Total
    _calculateTotal();
  }

  /// Calculate fuel-based emissions
  void _calculateFuelBasedEmissions() {
    final petrolLiters = double.tryParse(petrolLitersController.text) ?? 0.0;
    final dieselLiters = double.tryParse(dieselLitersController.text) ?? 0.0;

    petrolEmissions.value = petrolLiters *
        LandTravelEmissionConfig
            .landTravelEmissionFactors['fuel']!['petrol']!['ef_per_liter'];

    dieselEmissions.value = dieselLiters *
        LandTravelEmissionConfig
            .landTravelEmissionFactors['fuel']!['diesel']!['ef_per_liter'];

    // Reset distance-based
    carEmissions.value = 0.0;
    motorcycleEmissions.value = 0.0;
  }

  /// Calculate distance-based emissions for fuel vehicles
  void _calculateDistanceBasedEmissions() {
    final carKm = double.tryParse(carKmController.text) ?? 0.0;
    final motorcycleKm = double.tryParse(motorcycleKmController.text) ?? 0.0;

    carEmissions.value = carKm *
        LandTravelEmissionConfig.landTravelEmissionFactors['by_distance']!
        ['by_car']!['ef_per_km'];

    motorcycleEmissions.value = motorcycleKm *
        LandTravelEmissionConfig.landTravelEmissionFactors['by_distance']!
        ['by_motorcycle']!['ef_per_km'];

    // Reset fuel-based
    petrolEmissions.value = 0.0;
    dieselEmissions.value = 0.0;
  }

  /// Calculate EV emissions
  void _calculateEVEmissions() {
    final evKm = double.tryParse(evKmController.text) ?? 0.0;
    final evKwh = double.tryParse(evKwhPer100KmController.text) ?? 18.0;

    final totalKwh = evKm * evKwh / 100;
    final gridEF = LandTravelEmissionConfig
        .landTravelEmissionFactors['electric_vehicle']!['grid_ef_my'];

    evEmissions.value = totalKwh * gridEF;
  }

  /// Calculate public transport emissions
  void _calculatePublicTransportEmissions() {
    final busKm = double.tryParse(busKmController.text) ?? 0.0;
    final trainKm = double.tryParse(trainKmController.text) ?? 0.0;

    busEmissions.value = busKm *
        LandTravelEmissionConfig.landTravelEmissionFactors['public_transport']!
        ['by_bus']!['ef_per_passenger_km'];

    trainEmissions.value = trainKm *
        LandTravelEmissionConfig.landTravelEmissionFactors['public_transport']!
        ['by_train']!['ef_per_passenger_km'];
  }

  /// Calculate total emissions
  void _calculateTotal() {
    totalEmissions.value = petrolEmissions.value +
        dieselEmissions.value +
        carEmissions.value +
        motorcycleEmissions.value +
        evEmissions.value +
        busEmissions.value +
        trainEmissions.value;
  }

  /// Save emissions to Firestore
  Future<void> saveEmissions() async {
    if (totalEmissions.value == 0) {
      FHelperFunctions.showSnackBar(
          'Please enter at least one transportation method');
      return;
    }

    isSaving.value = true;
    try {
      final existingEmission =
      await _emissionRepo.getLatestEmissionByCategory('Land Travel');

      final inputs = {
        // Fuel vehicles
        'has_fuel_vehicle': hasFuelVehicle.value,
        'fuel_input_method': fuelInputMethod.value,
        'petrol_liters': double.tryParse(petrolLitersController.text) ?? 0.0,
        'diesel_liters': double.tryParse(dieselLitersController.text) ?? 0.0,
        'car_km': double.tryParse(carKmController.text) ?? 0.0,
        'motorcycle_km': double.tryParse(motorcycleKmController.text) ?? 0.0,

        // EV
        'has_ev': hasEV.value,
        'ev_km': double.tryParse(evKmController.text) ?? 0.0,
        'ev_kwh_per_100km':
        double.tryParse(evKwhPer100KmController.text) ?? 18.0,
        'ev_charging_location': evChargingLocation.value,

        // Public transport
        'bus_km': double.tryParse(busKmController.text) ?? 0.0,
        'train_km': double.tryParse(trainKmController.text) ?? 0.0,

        // Walking & Cycling
        'bike_km_per_week':
        double.tryParse(bikeKmPerWeekController.text) ?? 0.0,
        'walk_km_per_week':
        double.tryParse(walkKmPerWeekController.text) ?? 0.0,

        // Emissions breakdown
        'petrol_emissions': petrolEmissions.value,
        'diesel_emissions': dieselEmissions.value,
        'car_emissions': carEmissions.value,
        'motorcycle_emissions': motorcycleEmissions.value,
        'ev_emissions': evEmissions.value,
        'bus_emissions': busEmissions.value,
        'train_emissions': trainEmissions.value,

        'data_source': 'GHG Protocol & DEFRA',
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
          category: 'Land Travel',
          inputs: inputs,
          emissionValue: totalEmissions.value,
        );
      }

      await _emissionRepo.saveEmission(emission);

      FHelperFunctions.showSnackBar(
          'Land travel emissions saved successfully!');
      Get.back();
    } catch (e) {
      FHelperFunctions.showSnackBar('Error saving emissions: $e');
    } finally {
      isSaving.value = false;
    }
  }

  /// Clear all inputs
  void clearInputs() {
    hasFuelVehicle.value = 'none';
    fuelInputMethod.value = 'fuel';

    petrolLitersController.text = '0';
    dieselLitersController.text = '0';
    carKmController.text = '0';
    motorcycleKmController.text = '0';

    hasEV.value = false;
    evKmController.text = '0';
    evKwhPer100KmController.text = '18';
    evChargingLocation.value = 'peninsular';

    busKmController.text = '0';
    trainKmController.text = '0';

    bikeKmPerWeekController.text = '0';
    walkKmPerWeekController.text = '0';

    calculateEmissions();
  }

  /// Get breakdown for results card
  Map<String, double> get emissionsBreakdown {
    final breakdown = <String, double>{};

    if (petrolEmissions.value > 0) {
      breakdown['Petrol'] = petrolEmissions.value;
    }
    if (dieselEmissions.value > 0) {
      breakdown['Diesel'] = dieselEmissions.value;
    }
    if (carEmissions.value > 0) {
      breakdown['Car'] = carEmissions.value;
    }
    if (motorcycleEmissions.value > 0) {
      breakdown['Motorcycle'] = motorcycleEmissions.value;
    }
    if (evEmissions.value > 0) {
      breakdown['EV'] = evEmissions.value;
    }
    if (busEmissions.value > 0) {
      breakdown['Bus'] = busEmissions.value;
    }
    if (trainEmissions.value > 0) {
      breakdown['Train'] = trainEmissions.value;
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