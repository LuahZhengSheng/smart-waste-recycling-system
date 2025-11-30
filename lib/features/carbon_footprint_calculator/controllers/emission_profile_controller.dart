import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/repositories/carbon_footprint_calculator/emission_repository.dart';
import '../screens/air_travel/air_travel_input.dart';
import '../screens/energy/energy_input.dart';
import '../screens/food/food_input.dart';
import '../screens/land_travel/land_travel_input.dart';
import '../screens/new_stuff/new_stuff_input.dart';
import '../utils/emission_utils.dart';

class EmissionCategory {
  final String name;
  final String id;
  final IconData icon;
  final double emission;

  EmissionCategory({
    required this.name,
    required this.id,
    required this.icon,
    required this.emission,
  });

  Color getColor({bool darkMode = false}) {
    return EmissionUtils.getCategoryColor(name, darkMode: darkMode);
  }

  Color getBackgroundColor({bool darkMode = false}) {
    return EmissionUtils.getCategoryBackgroundColor(name, darkMode: darkMode);
  }
}

class EmissionsProfileController extends GetxController {
  static EmissionsProfileController get instance => Get.find();

  final _emissionRepo = Get.put(EmissionRepository());

  final categories = <EmissionCategory>[].obs;
  final isLoading = true.obs;

  String get totalEmissionTonsLabel => '${(totalEmissions / 1000).toStringAsFixed(2)} t';

  StreamSubscription? _emissionsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
    _initializeEmissionsStream();
  }

  @override
  void onClose() {
    _emissionsSubscription?.cancel();
    super.onClose();
  }

  void _initializeCategories() {
    categories.value = [
      EmissionCategory(
        name: 'Land Travel',
        id: 'land_travel',
        icon: Iconsax.car,
        emission: 0.0,
      ),
      EmissionCategory(
        name: 'Air Travel',
        id: 'air_travel',
        icon: Iconsax.airplane,
        emission: 0.0,
      ),
      EmissionCategory(
        name: 'Energy',
        id: 'energy',
        icon: Iconsax.flash_1,
        emission: 0.0,
      ),
      EmissionCategory(
        name: 'Food',
        id: 'food',
        icon: Iconsax.shop,
        emission: 0.0,
      ),
      EmissionCategory(
        name: 'Stuff',
        id: 'stuff',
        icon: Iconsax.box,
        emission: 0.0,
      ),
    ];
  }

  void _initializeEmissionsStream() {
    _emissionsSubscription = _emissionRepo
        .streamUserEmissionsByCategories()
        .listen((categoryEmissions) {
      // Update categories with real emissions
      for (int i = 0; i < categories.length; i++) {
        final categoryId = categories[i].id;
        final emission = categoryEmissions[categories[i].name] ?? 0.0;

        categories[i] = EmissionCategory(
          name: categories[i].name,
          id: categoryId,
          icon: categories[i].icon,
          emission: emission,
        );
      }

      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      print('Error streaming category emissions: $error');
    });
  }

  void navigateToCategory(EmissionCategory category) {
    switch (category.id) {
      case 'land_travel':
        Get.to(() => const LandTravelInputScreen());
        break;
      case 'air_travel':
        Get.to(() => const AirTravelInputScreen());
        break;
      case 'energy':
        Get.to(() => const EnergyInputScreen());
        break;
      case 'food':
        Get.to(() => const FoodInputScreen());
        break;
      case 'stuff':
        Get.to(() => const NewStuffInputScreen());
        break;
    }
  }

  void updateCategoryEmission(String categoryId, double newEmission) {
    final index = categories.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      categories[index] = EmissionCategory(
        name: categories[index].name,
        id: categories[index].id,
        icon: categories[index].icon,
        emission: newEmission,
      );
    }
  }

  double get totalEmissions {
    return categories.fold(0.0, (sum, cat) => sum + cat.emission);
  }

  int get completedCategoriesCount {
    return categories.where((cat) => cat.emission > 0).length;
  }
}