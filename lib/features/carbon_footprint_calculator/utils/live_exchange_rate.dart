import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../config/emission_config/new_stuff.dart';

class LiveExchange {
  // ==================== Helper: Get live USD to MYR exchange rate ====================

  /// Fetches live USD → MYR exchange rate from exchangerate-api.com
  /// Returns the rate, or falls back to a default value if API fails.
  static Future<double> getUsdToMyrRate() async {
    const String apiUrl = 'https://open.er-api.com/v6/latest/USD';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final myrRate = rates['MYR'] as num;
        return myrRate.toDouble(); // e.g. 4.72
      } else {
        print('Exchange rate API error: ${response.statusCode}');
        return _fallbackRate;
      }
    } catch (e) {
      print('Failed to fetch exchange rate: $e');
      return _fallbackRate;
    }
  }

  // Fallback rate in case API is unavailable
  static const double _fallbackRate = 4.13; // 1 USD ≈ 4.13 MYR (approximate default)

  // ==================== Helper: Calculate emissions with live rate ====================

  /// Calculate emissions from RM spend using live USD/MYR rate
  /// Usage:
  /// ```
  /// final emissions = await LiveExchange.calculateEmissions(
  ///   'clothing',
  ///   spendRM: 500,
  /// );
  /// ```
  static Future<double> calculateEmissions(
      String category, {
        required double spendRM,
        double? customRate, // Optional: provide your own rate to skip API call
      }) async {
    // 改这里：加上 NewStuffEmissionConfig. 前缀
    if (!NewStuffEmissionConfig.newStuffEmissionFactors.containsKey(category)) {
      throw ArgumentError('Category "$category" not found in emission factors.');
    }

    final efPerUsd = NewStuffEmissionConfig.newStuffEmissionFactors[category]!['ef_per_usd'] as double;

    // Use custom rate if provided, otherwise fetch live rate
    final usdToMyrRate = customRate ?? await getUsdToMyrRate();

    final spendUsd = spendRM / usdToMyrRate;
    return spendUsd * efPerUsd; // kg CO2e
  }

  /// Synchronous version: calculate emissions with a provided rate (no API call)
  /// Usage:
  /// ```
  /// final emissions = LiveExchange.calculateEmissionsSync(
  ///   'clothing',
  ///   spendRM: 500,
  ///   usdToMyrRate: 4.72,
  /// );
  /// ```
  static double calculateEmissionsSync(
      String category, {
        required double spendRM,
        required double usdToMyrRate,
      }) {
    // 改这里：加上 NewStuffEmissionConfig. 前缀
    if (!NewStuffEmissionConfig.newStuffEmissionFactors.containsKey(category)) {
      throw ArgumentError('Category "$category" not found in emission factors.');
    }

    final efPerUsd = NewStuffEmissionConfig.newStuffEmissionFactors[category]!['ef_per_usd'] as double;
    final spendUsd = spendRM / usdToMyrRate;
    return spendUsd * efPerUsd; // kg CO2e
  }
}

