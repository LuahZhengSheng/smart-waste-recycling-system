import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

/// Extension to FColors for emission categories
class EmissionUtils {

  /// Get color by category name
  static Color getCategoryColor(String category, {bool darkMode = false}) {
    final categoryLower = category.toLowerCase();

    if (darkMode) {
      switch (categoryLower) {
        case 'land travel':
        case 'land_travel':
          return FColors.landTravelDark;
        case 'air travel':
        case 'air_travel':
          return FColors.airTravelDark;
        case 'energy':
          return FColors.energyDark;
        case 'food':
          return FColors.foodDark;
        case 'stuff':
          return FColors.stuffDark;
        default:
          return const Color(0xFF9E9E9E);
      }
    } else {
      switch (categoryLower) {
        case 'land travel':
        case 'land_travel':
          return FColors.landTravel;
        case 'air travel':
        case 'air_travel':
          return FColors.airTravel;
        case 'energy':
          return FColors.energy;
        case 'food':
          return FColors.food;
        case 'stuff':
          return FColors.stuff;
        default:
          return const Color(0xFF757575);
      }
    }
  }

  /// Get background color by category
  static Color getCategoryBackgroundColor(String category, {bool darkMode = false}) {
    final color = getCategoryColor(category, darkMode: darkMode);
    return color.withOpacity(darkMode ? 0.15 : 0.1);
  }

  /// Get all category colors in order
  static List<Color> getAllCategoryColors({bool darkMode = false}) {
    if (darkMode) {
      return [FColors.landTravelDark, FColors.airTravelDark, FColors.energyDark, FColors.foodDark, FColors.stuffDark];
    }
    return [FColors.landTravel, FColors.airTravel, FColors.energy, FColors.food, FColors.stuff];
  }

  /// Get category color map
  static Map<String, Color> getCategoryColorMap({bool darkMode = false}) {
    return {
      'Land Travel': getCategoryColor('land_travel', darkMode: darkMode),
      'Air Travel': getCategoryColor('air_travel', darkMode: darkMode),
      'Energy': getCategoryColor('energy', darkMode: darkMode),
      'Food': getCategoryColor('food', darkMode: darkMode),
      'Stuff': getCategoryColor('stuff', darkMode: darkMode),
    };
  }
}