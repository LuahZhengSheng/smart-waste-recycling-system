import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/common/widgets/list_tiles/emissions_category_item_tile.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/carbon_footprint_calculator/land_travel.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/food/food_input.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CarbonFootprintCalculatorScreen extends StatelessWidget {
  const CarbonFootprintCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FAppBar(
        title: Text('Refine my emissions profile', style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: false,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B46), // 深蓝色背景
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
        ),
        child: ListView(
          children: [
            FEmissionsCategoryItemTile(icon: Iconsax.home, title: "Home", emissionValue: "1.3 t", onTap: (){}),
            FEmissionsCategoryItemTile(icon: Iconsax.car, title: "Land Travel", emissionValue: "0 t", onTap: () => Get.to(LandTravelScreen())),
            FEmissionsCategoryItemTile(icon: Iconsax.airplane, title: "Air Travel", emissionValue: "0.68 t", onTap: (){}),
            FEmissionsCategoryItemTile(icon: Iconsax.reserve, title: "Food", emissionValue: "1.15 t", onTap: () => Get.to(FoodInputScreen())),
            FEmissionsCategoryItemTile(icon: Iconsax.flash, title: "Energy", emissionValue: "1.2 t", onTap: (){}),
            FEmissionsCategoryItemTile(icon: Iconsax.gift, title: "Stuff", emissionValue: "0.4 t", onTap: (){}),
            FEmissionsCategoryItemTile(icon: Iconsax.trash, title: "Waste", emissionValue: "1.75 t", onTap: (){}),
          ],
        ),
      ),
    );
  }
}

