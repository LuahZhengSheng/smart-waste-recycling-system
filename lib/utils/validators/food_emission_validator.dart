import 'package:flutter/services.dart';

/// Validator for food emission inputs
class FoodEmissionValidator {
  FoodEmissionValidator._();

  /// Validate portions per week (0-30)
  static String? validatePortionsPerWeek(String? value, {String foodName = 'Food'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return 'Portions cannot be negative';
    }

    if (number > 30) {
      return 'Portions per week seems too high (max 30)';
    }

    return null;
  }

  /// Validate servings per day (0-10)
  static String? validateServingsPerDay(String? value, {String foodName = 'Food'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return 'Servings cannot be negative';
    }

    if (number > 10) {
      return 'Servings per day seems too high (max 10)';
    }

    return null;
  }

  /// Validate servings per week (0-50)
  static String? validateServingsPerWeek(String? value, {String foodName = 'Food'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return 'Servings cannot be negative';
    }

    if (number > 50) {
      return 'Servings per week seems too high (max 50)';
    }

    return null;
  }

  /// Get decimal number input formatters
  static List<TextInputFormatter> get decimalNumberFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  /// Get integer number input formatters
  static List<TextInputFormatter> get integerNumberFormatters => [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Parse number safely
  static double parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(value) ?? 0.0;
  }
}