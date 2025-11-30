import 'package:flutter/services.dart';

/// Validator for new stuff emission inputs
class NewStuffEmissionValidator {
  NewStuffEmissionValidator._();

  /// Validate spending amount (0 - 100000 RM)
  static String? validateSpending(String? value, {String itemName = 'Item'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid amount';
    }

    if (number < 0) {
      return 'Amount cannot be negative';
    }

    if (number > 100000) {
      return 'Amount seems too high (max RM 100,000)';
    }

    return null;
  }

  /// Validate required spending
  static String? validateRequiredSpending(String? value, {String itemName = 'Item'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter spending amount';
    }

    return validateSpending(value, itemName: itemName);
  }

  /// Get decimal number input formatters for currency
  static List<TextInputFormatter> get currencyFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  /// Parse spending safely
  static double parseSpending(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(value) ?? 0.0;
  }

  /// Format RM currency
  static String formatRM(double amount) {
    if (amount >= 1000) {
      return 'RM ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'RM ${amount.toStringAsFixed(0)}';
  }
}