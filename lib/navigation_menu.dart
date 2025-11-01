import 'package:flutter/material.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/features/personalization/screens/home/home.dart';
import 'package:fyp/features/personalization/screens/recycle_activity/recycle_activity.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import 'data/repositories/authentication/authentication_repository.dart';
import 'features/event/screens/event/event.dart';
import 'features/event/screens/test_reminder.dart';
import 'features/personalization/screens/profile/profile.dart';
import 'features/waste_classification/controllers/scan_sort_camera_controller.dart';
import 'features/waste_classification/screens/scan_sort_camera/scan_sort_camera.dart';
import 'features/waste_classification/screens/waste_category_guideline/waste_category_guide.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

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
            // 在切换页面之前，如果当前是相机页面，释放相机
            if (controller.selectedIndex.value == 2) {
              final cameraController = Get.find<ScanSortCameraController>();
              cameraController.disposeCameraForPage();
            }

            controller.selectedIndex.value = index;

            // 如果切换到相机页面，初始化相机
            if (index == 2) {
              final cameraController = Get.find<ScanSortCameraController>();
              cameraController.initializeCameraForPage();
            }
          },
          backgroundColor:
          dark ? FColors.black : FColors.white, // Background color
          indicatorColor:
          Colors.transparent, // No highlight background on selection
          // 添加选中状态的颜色配置
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // 始终显示标签
          // 设置标签文字样式
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: FColors.primary, // 选中时青色
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
              icon: Icon(Iconsax.home,
                color: controller.selectedIndex.value == 0
                    ? FColors.primary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Home',
              selectedIcon: Icon(Iconsax.home, color: FColors.primary), // 选中时的图标
            ),
            NavigationDestination(
              icon: Icon(Iconsax.calendar,
                color: controller.selectedIndex.value == 1
                    ? FColors.primary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Event',
              selectedIcon: Icon(Iconsax.calendar, color: FColors.primary), // 选中时的图标
            ),
            NavigationDestination(
              icon: Icon(Iconsax.repeat,
                color: controller.selectedIndex.value == 2
                    ? FColors.primary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Scan & Sort',
              selectedIcon: Icon(Iconsax.repeat, color: FColors.primary), // 选中时的图标
            ),
            NavigationDestination(
              icon: Icon(Iconsax.people,
                color: controller.selectedIndex.value == 3
                    ? FColors.primary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Community',
              selectedIcon: Icon(Iconsax.people, color: FColors.primary), // 选中时的图标
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user,
                color: controller.selectedIndex.value == 4
                    ? FColors.primary // 选中时青色
                    : FColors.darkGrey, // 未选中时灰色
              ),
              label: 'Profile',
              selectedIcon: Icon(Iconsax.user, color: FColors.primary), // 选中时的图标
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
    const HomeScreen(),
    const EventsScreen(),
    ScanSortCameraScreen(),
    const PostsScreen(),
    const ProfileScreen(),
  ];
}