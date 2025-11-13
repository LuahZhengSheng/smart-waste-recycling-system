/// Configuration file for emission factors and constants
/// Based on BEIS Greenhouse gas reporting: conversion factors 2025
class EmissionConfig {
  EmissionConfig._();

  // Data year
  static const int dataYear = 2025;
  static const String dataSource = 'BEIS';
  static const String dataSet = 'Greenhouse gas reporting: conversion factors 2025';

  // Cache duration for average emissions (20 minutes)
  static const Duration avgEmissionsCacheDuration = Duration(minutes: 20);

  // ==================== Air Travel Emission Factors ====================
  // Unit: kg CO2e per passenger per km
  // Includes both fuel_combustion and well_to_tank

  static const Map<String, Map<String, double>> airTravelEmissionFactors = {
    'economy': {
      'fuel_combustion': 0.06449, // kg CO2e/passenger-km
      'well_to_tank': 0.01656, // kg CO2e/passenger-km
      'total': 0.08105, // Sum of above
    },
    'premium_economy': {
      'fuel_combustion': 0.10318, // kg CO2e/passenger-km
      'well_to_tank': 0.02649, // kg CO2e/passenger-km
      'total': 0.12967, // Sum of above
    },
    'business': {
      'fuel_combustion': 0.18701, // kg CO2e/passenger-km
      'well_to_tank': 0.04802, // kg CO2e/passenger-km
      'total': 0.23503, // Sum of above
    },
    'first': {
      'fuel_combustion': 0.28052, // kg CO2e/passenger-km - 估算值
      'well_to_tank': 0.07203, // kg CO2e/passenger-km - 估算值
      'total': 0.35255, // Sum of above - 估算值
    },
    'average': {
      'fuel_combustion': 0.0842, // kg CO2e/passenger-km
      'well_to_tank': 0.02162, // kg CO2e/passenger-km
      'total': 0.10582, // Sum of above
    },
  };

  // Distance presets for common routes (in km)
  static const Map<String, double> commonFlightDistances = {
    'Domestic Short (KUL-PEN)': 350.0,
    'Domestic Medium (KUL-KCH)': 1100.0,
    'Regional (KUL-SIN)': 320.0,
    'Regional (KUL-BKK)': 1200.0,
    'Regional (KUL-HKG)': 2500.0,
    'International (KUL-DXB)': 6500.0,
    'Long-haul (KUL-LHR)': 10500.0,
    'Long-haul (KUL-JFK)': 15500.0,
  };

  // ==================== Land Travel Emission Factors ====================
  // Unit: kg CO2e per km
  static const Map<String, double> landTravelEmissionFactors = {
    'small_car': 0.14,
    'medium_car': 0.19,
    'large_car': 0.28,
    'motorcycle': 0.10,
    'bus': 0.10,
    'train': 0.04,
    'electric_car': 0.05,
  };

  // ==================== Energy Emission Factors ====================
  // Unit: kg CO2e per kWh
  static const Map<String, double> energyEmissionFactors = {
    'electricity_grid': 0.50, // Malaysia grid average
    'natural_gas': 0.18,
    'lpg': 0.21,
  };

  // ==================== Food Emission Factors ====================
  // Unit: kg CO2e per kg of food
  static const Map<String, double> foodEmissionFactors = {
    'beef': 27.0,
    'lamb': 39.2,
    'pork': 12.1,
    'chicken': 6.9,
    'fish': 6.1,
    'eggs': 4.8,
    'dairy': 3.2,
    'rice': 2.7,
    'vegetables': 0.4,
    'fruits': 0.9,
  };

  // ==================== Stuff/Consumer Goods Emission Factors ====================
  // Unit: kg CO2e per item or per spending
  static const Map<String, double> stuffEmissionFactors = {
    'smartphone': 70.0,
    'laptop': 200.0,
    'clothing_per_kg': 10.0,
    'furniture_per_kg': 15.0,
    'general_spending_per_ringgit': 0.5,
  };

  // ==================== Category Display Names ====================
  static const Map<String, String> categoryNames = {
    'land_travel': 'Land Travel',
    'air_travel': 'Air Travel',
    'energy': 'Energy',
    'food': 'Food',
    'stuff': 'Stuff',
  };

  // ==================== Helper Methods ====================

  /// Get total emission factor for air travel class
  static double getAirTravelEmissionFactor(String travelClass) {
    return airTravelEmissionFactors[travelClass.toLowerCase()]?['total'] ??
        airTravelEmissionFactors['average']!['total']!;
  }

  /// Get fuel combustion emission factor for air travel
  static double getAirTravelFuelCombustion(String travelClass) {
    return airTravelEmissionFactors[travelClass.toLowerCase()]?['fuel_combustion'] ??
        airTravelEmissionFactors['average']!['fuel_combustion']!;
  }

  /// Get well-to-tank emission factor for air travel
  static double getAirTravelWellToTank(String travelClass) {
    return airTravelEmissionFactors[travelClass.toLowerCase()]?['well_to_tank'] ??
        airTravelEmissionFactors['average']!['well_to_tank']!;
  }

  /// Get land travel emission factor
  static double getLandTravelEmissionFactor(String vehicleType) {
    return landTravelEmissionFactors[vehicleType.toLowerCase()] ?? 0.19;
  }

  /// Get energy emission factor
  static double getEnergyEmissionFactor(String energyType) {
    return energyEmissionFactors[energyType.toLowerCase()] ?? 0.50;
  }

  /// Get food emission factor
  static double getFoodEmissionFactor(String foodType) {
    return foodEmissionFactors[foodType.toLowerCase()] ?? 1.0;
  }

  /// Get stuff emission factor
  static double getStuffEmissionFactor(String itemType) {
    return stuffEmissionFactors[itemType.toLowerCase()] ?? 0.5;
  }
}