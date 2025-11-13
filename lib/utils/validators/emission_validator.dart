import 'package:flutter/services.dart';

/// Validator class for emission-related inputs
class EmissionValidator {
  EmissionValidator._();

  /// Validate positive number input
  static String? validatePositiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty for optional fields
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }

    if (number < 0) {
      return '$fieldName must be positive';
    }

    return null;
  }

  /// Validate required positive number
  static String? validateRequiredPositiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return validatePositiveNumber(value, fieldName: fieldName);
  }

  /// Validate number within range
  static String? validateNumberInRange(
      String? value, {
        required double min,
        required double max,
        String fieldName = 'Value',
      }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final validation = validatePositiveNumber(value, fieldName: fieldName);
    if (validation != null) return validation;

    final number = double.parse(value);
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }

  /// Validate distance input (0 - 50000 km)
  static String? validateDistance(String? value) {
    return validateNumberInRange(
      value,
      min: 0,
      max: 50000,
      fieldName: 'Distance',
    );
  }

  /// Validate flight count (0 - 100 trips)
  static String? validateFlightCount(String? value) {
    return validateNumberInRange(
      value,
      min: 0,
      max: 100,
      fieldName: 'Number of flights',
    );
  }

  /// Validate energy consumption (0 - 50000 kWh)
  static String? validateEnergyConsumption(String? value) {
    return validateNumberInRange(
      value,
      min: 0,
      max: 50000,
      fieldName: 'Energy consumption',
    );
  }

  /// Get number-only input formatters
  static List<TextInputFormatter> get numberOnlyFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  ];

  /// Get decimal number input formatters
  static List<TextInputFormatter> get decimalNumberFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    // Prevent multiple decimal points
    TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.split('.').length > 2) {
        return oldValue;
      }
      return newValue;
    }),
  ];

  /// Validate and parse number input
  static double? parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return double.tryParse(value);
  }

  /// Validate empty text
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}