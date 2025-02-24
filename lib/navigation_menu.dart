import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/authentication/controllers/login/login_controller.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:fyp/features/waste_classification/screens/home/home.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final accountController = Get.put(LoginController());
    final dark = MyHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: dark ? MyColors.black : MyColors.white,
          indicatorColor: dark ? MyColors.white.withOpacity(0.1) : MyColors.black.withOpacity(0.1),
          destinations: [
            const NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            const NavigationDestination(icon: Icon(Iconsax.shop), label: 'Store'),
            const NavigationDestination(icon: Icon(Iconsax.heart), label: 'Wishlist'),
            const NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
            NavigationDestination(
              icon: IconButton(
                onPressed: () => AuthenticationRepository.instance.logout(),
                icon: const Icon(Iconsax.logout),
              ),
              label: 'Logout',
            ),

          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    Container(color: Colors.purple),
    Container(color: Colors.orange),
    Container(color: Colors.blue),
  ];
}