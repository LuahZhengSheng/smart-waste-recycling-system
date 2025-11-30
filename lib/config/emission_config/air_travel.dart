/// ==================== Air Travel Carbon Footprint Calculation ====================
/// For each class (economy, premium economy, business, first, average class):
///   - 用户输入 one-way distance (公里)；可勾选 round-trip（实际里程 × 2）
///   - 排放系数 (per km): 查表，含 fuel_combustion + well_to_tank，总和为 total
///   - 年度排放 = 总里程 × class 总排放系数 (kg CO2e per passenger-km)
/// 示例流程：
///   1. 输入：Economy 2000km，round trip，Business 0km
///   2. 计算里程：Economy = 2000 × 2 = 4000 km
///   3. 查 “Economy” 排放系数 total = 0.08105 kg CO2e/km
///   4. 排放：4000 km × 0.08105 = 324.2 kg CO2e
/// 总排放 = 各类累加
/// Breakdown 按 class 类型展示每类排放量
///
/// 来源: BEIS Greenhouse gas reporting: conversion factors 2025
/// ===============================================================================
/// Configuration file for emission factors and constants
/// Based on BEIS Greenhouse gas reporting: conversion factors 2025
class AirTravelEmissionConfig {
  AirTravelEmissionConfig._();

  // Data year
  static const int dataYear = 2025;
  static const String dataSource = 'BEIS';
  static const String dataSet = 'Greenhouse gas reporting: conversion factors 2025';

  // Cache duration for average emissions (20 minutes)
  static const Duration avgEmissionsCacheDuration = Duration(minutes: 20);

  // ==================== Air Travel Emission Factors ====================
  // Unit: kg CO2e per passenger per km
  // Includes both fuel_combustion and well_to_tank

  // ==================== Air Travel Emission Factors ====================
  // Unit: kg CO2e per passenger-km
  // Data source: BEIS 2025 via Climatiq (Global factors, AR5)
  // Explorer link (filtered to Transport/Air Travel, 2025):
  // https://www.climatiq.io/data/explorer?region=GLOBAL&region=MY&year_valid=2025&data_version=%5E27&page=1&sector=Transport

  static const Map<String, Map<String, dynamic>> airTravelEmissionFactors = {
    'economy': {
      'fuel_combustion': 0.06449,
      'well_to_tank': 0.01656,
      'total': 0.08105,
      'metadata': {
        'source': 'BEIS – Greenhouse gas reporting: conversion factors 2025',
        'year': 2025,
        'link':
        'https://www.climatiq.io/data/explorer?region=GLOBAL&year_valid=2025&sector=Transport&category=Air%20Travel',
        'activity_ids': {
          'fuel_combustion':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_economy-rf_excluded-distance_uplift_included (ID: 03fc49e4-36e8-46d9-a84f-3556894c7176)',
          'well_to_tank':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_economy-rf_excluded-distance_uplift_included (ID: a35b1c51-b9c8-440b-96d2-2387c4aead51)',
        },
        'lca_activity': {
          'fuel_combustion': 'fuel_combustion',
          'well_to_tank': 'well_to_tank',
        },
        'method': 'AR5',
        'region': 'Global',
      },
    },
    'premium_economy': {
      'fuel_combustion': 0.10318,
      'well_to_tank': 0.02649,
      'total': 0.12967,
      'metadata': {
        'source': 'BEIS – Greenhouse gas reporting: conversion factors 2025',
        'year': 2025,
        'link':
        'https://www.climatiq.io/data/explorer?region=GLOBAL&year_valid=2025&sector=Transport&category=Air%20Travel',
        'activity_ids': {
          'fuel_combustion':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_premium_economy-rf_excluded-distance_uplift_included (ID: ad488895-b961-4802-88e6-118134b8d277)',
          'well_to_tank':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_premium_economy-rf_excluded-distance_uplift_included (ID: b3c09d62-5097-4833-9d1f-38527d289ab8)',
        },
        'lca_activity': {
          'fuel_combustion': 'fuel_combustion',
          'well_to_tank': 'well_to_tank',
        },
        'method': 'AR5',
        'region': 'Global',
      },
    },
    'business': {
      'fuel_combustion': 0.18701,
      'well_to_tank': 0.04802,
      'total': 0.23503,
      'metadata': {
        'source': 'BEIS – Greenhouse gas reporting: conversion factors 2025',
        'year': 2025,
        'link':
        'https://www.climatiq.io/data/explorer?region=GLOBAL&year_valid=2025&sector=Transport&category=Air%20Travel',
        'activity_ids': {
          'fuel_combustion':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_business-rf_excluded-distance_uplift_included (ID: 80c109d8-a2d2-4c54-a588-f0e0a912ebc9)',
          'well_to_tank':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_business-rf_excluded-distance_uplift_included (ID: 0ceae349-817c-42cc-b927-82f30f99c886)',
        },
        'lca_activity': {
          'fuel_combustion': 'fuel_combustion',
          'well_to_tank': 'well_to_tank',
        },
        'method': 'AR5',
        'region': 'Global',
      },
    },
    'first': {
      // 估算：按 business 座位空间放大约 1.5x
      'fuel_combustion': 0.28052,
      'well_to_tank': 0.07203,
      'total': 0.35255,
      'metadata': {
        'source':
        'Estimated from BEIS 2025 business-class factors (no dedicated first-class factor)',
        'year': 2025,
        'link':
        'https://www.climatiq.io/data/explorer?region=GLOBAL&year_valid=2025&sector=Transport&category=Air%20Travel',
        'activity_ids': {
          'fuel_combustion': 'derived_from_business_class',
          'well_to_tank': 'derived_from_business_class',
        },
        'lca_activity': {
          'fuel_combustion': 'fuel_combustion',
          'well_to_tank': 'well_to_tank',
        },
        'method': 'AR5',
        'region': 'Global',
        'notes':
        'First-class factor estimated by scaling business-class BEIS 2025 factors (approx. 1.5x seat space).',
      },
    },
    'average': {
      'fuel_combustion': 0.0842,
      'well_to_tank': 0.02162,
      'total': 0.10582,
      'metadata': {
        'source': 'BEIS – Greenhouse gas reporting: conversion factors 2025',
        'year': 2025,
        'link':
        'https://www.climatiq.io/data/explorer?region=GLOBAL&year_valid=2025&sector=Transport&category=Air%20Travel',
        'activity_ids': {
          'fuel_combustion':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_na-rf_excluded-distance_uplift_included (ID: 8129f967-5c2f-4c3b-9b88-5ef48f117792)',
          'well_to_tank':
          'passenger_flight-route_type_outside_uk-aircraft_type_na-distance_na-class_na-rf_excluded-distance_uplift_included (ID: 199ffb85-4826-4644-9e32-0e75428c1f0f)',
        },
        'lca_activity': {
          'fuel_combustion': 'fuel_combustion',
          'well_to_tank': 'well_to_tank',
        },
        'method': 'AR5',
        'region': 'Global',
      },
    },
  };

  static const Map<String, Map<String, double>> airTravelEmissionFactors2 = {
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