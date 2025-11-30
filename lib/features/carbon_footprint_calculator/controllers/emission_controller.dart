import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../screens/emission_profile/emission_profile.dart';

class EmissionsController extends GetxController {
  static EmissionsController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());

  // Observable state
  final hasCalculatedEmissions = false.obs;
  final isLoading = true.obs;
  final userEmissions = <String, double>{}.obs;
  final avgEmissions = <String, double>{}.obs;
  final comparisonPercentage = 0.0.obs;
  final selectedCategory = Rx<String?>(null);

  /// 图表是否可以解锁：需要用户有数据，且平均值也已加载
  bool get canShowChart => hasCalculatedEmissions.value && avgEmissions.isNotEmpty;

  StreamSubscription? _emissionsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeEmissionsStream();
    _loadAverageEmissions();
  }

  @override
  void onClose() {
    _emissionsSubscription?.cancel();
    super.onClose();
  }

  /// Initialize real-time emissions stream
  void _initializeEmissionsStream() {
    _emissionsSubscription = _emissionRepo
        .streamUserEmissionsByCategories()
        .listen((categoryEmissions) {
      userEmissions.value = categoryEmissions;
      hasCalculatedEmissions.value = categoryEmissions.isNotEmpty;
      isLoading.value = false;

      // Recalculate comparison when user emissions change
      if (hasCalculatedEmissions.value && avgEmissions.isNotEmpty) {
        _calculateComparison();
      }
    }, onError: (error) {
      isLoading.value = false;
      print('Error streaming emissions: $error');
    });
  }

  /// Load average emissions (with caching)
  Future<void> _loadAverageEmissions() async {
    try {
      final averages = await _emissionRepo.getAverageEmissions();
      avgEmissions.value = averages;

      // Calculate comparison if user has emissions
      if (hasCalculatedEmissions.value) {
        _calculateComparison();
      }
    } catch (e) {
      print('Error loading average emissions: $e');
    }
  }

  /// Force refresh average emissions
  Future<void> refreshAverageEmissions() async {
    try {
      final averages = await _emissionRepo.getAverageEmissions(forceRefresh: true);
      avgEmissions.value = averages;

      if (hasCalculatedEmissions.value) {
        _calculateComparison();
      }
    } catch (e) {
      print('Error refreshing average emissions: $e');
    }
  }

  /// Calculate comparison percentage
  void _calculateComparison() {
    final userTotal = userEmissions.values.fold(0.0, (sum, value) => sum + value);
    final avgTotal = avgEmissions.values.fold(0.0, (sum, value) => sum + value);

    if (avgTotal > 0) {
      comparisonPercentage.value = ((userTotal - avgTotal) / avgTotal) * 100;
    } else {
      comparisonPercentage.value = 0.0;
    }
  }

  /// Get total emissions for a type (user or average)
  double getTotalEmissions(Map<String, double> emissions) {
    return emissions.values.fold(0.0, (sum, value) => sum + value);
  }

  /// Select category for detailed view
  void selectCategory(String? category) {
    selectedCategory.value = category;
  }

  /// Check if category has emissions
  bool hasCategoryEmissions(String category) {
    return (userEmissions[category] ?? 0.0) > 0;
  }

  /// Get number of completed categories
  int getCompletedCategoriesCount() {
    return userEmissions.entries.where((e) => e.value > 0).length;
  }

  /// Check if all categories are completed
  bool get allCategoriesCompleted => getCompletedCategoriesCount() >= 5;

  /// Navigate to emissions profile
  void navigateToEmissionsProfile() {
    Get.to(() => const EmissionsProfileScreen());
  }

  /// Get comparison text
  String get comparisonText {
    // 还没满足比较条件：要么用户没有数据，要么平均值还没加载
    if (!canShowChart) {
      return 'No comparison available yet';
    }

    final percentage = comparisonPercentage.value.abs();
    if (comparisonPercentage.value > 0) {
      return '${percentage.toStringAsFixed(0)}% more than average';
    } else if (comparisonPercentage.value < 0) {
      return '${percentage.toStringAsFixed(0)}% less than average';
    } else {
      return 'Equal to average';
    }
  }

  /// Get comparison color
  Color getComparisonColor(bool darkMode) {
    if (comparisonPercentage.value > 0) {
      return Colors.red;
    } else if (comparisonPercentage.value < 0) {
      return Colors.green;
    } else {
      return darkMode ? Colors.grey[400]! : Colors.grey[700]!;
    }
  }
}