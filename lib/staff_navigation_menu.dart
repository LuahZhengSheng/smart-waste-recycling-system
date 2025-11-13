import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import 'features/recycling_center/screens/profile/staff_profile.dart';
import 'features/recycling_center/screens/staff_home/staff_home.dart';

class StaffNavigationMenu extends StatelessWidget {
  const StaffNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Create and store NavigationController in GetX dependency system
    final controller = Get.put(NavigationController());

    // Detect if the current theme is dark mode
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        // Reactive widgets that rebuilds when selectedIndex changes
        () => NavigationBar(
          height: 70, // Navigation bar height
          elevation: 0, // No shadow
          selectedIndex: controller.selectedIndex.value, // Current active tab
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index;
          },
          backgroundColor:
              dark ? FColors.black : FColors.white, // Background color
          indicatorColor:
              Colors.transparent, // No highlight background on selection
          // 添加选中状态的颜色配置
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow, // 始终显示标签
          // 设置标签文字样式
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: dark
                    ? FColors.staffDarkPrimary
                    : FColors.staffLightPrimary, // 选中时青色
                fontWeight: FontWeight.w600,
              );
            }
            return TextStyle(
              color: FColors.darkGrey, // 未选中时灰色
              fontWeight: FontWeight.normal,
            );
          }),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Iconsax.home,
                color: controller.selectedIndex.value == 0
                    ? dark
                        ? FColors.staffDarkPrimary
                        : FColors.staffLightPrimary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Home',
              selectedIcon: Icon(
                Iconsax.home,
                color:
                    dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
              ), // 选中时的图标
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.user,
                color: controller.selectedIndex.value == 1
                    ? dark
                        ? FColors.staffDarkPrimary
                        : FColors.staffLightPrimary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Profile',
              selectedIcon: Icon(Iconsax.user,
                  color: dark
                      ? FColors.staffDarkPrimary
                      : FColors.staffLightPrimary), // 选中时的图标
            ),
          ],
        ),
      ),
      // Show the active screen based on selectedIndex
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  // Observable integer for the currently selected navigation index
  final Rx<int> selectedIndex = 0.obs;

  // List of screens corresponding to navigation destinations
  final screens = [
    const StaffHomeScreen(),
    const StaffProfileScreen(),
  ];
}
