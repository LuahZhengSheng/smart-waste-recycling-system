import 'package:flutter/material.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/features/personalization/screens/home/home.dart';
import 'package:fyp/features/personalization/screens/recycle_activity/recycle_activity.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/community/screens/posts/post_list_screen.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import 'features/event/screens/event/event.dart';

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
          onDestinationSelected: (index) =>
          controller.selectedIndex.value = index, // Change active tab
          backgroundColor: dark ? FColors.black : FColors.white, // Background color
          indicatorColor: Colors.transparent, // No highlight background on selection
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.calendar), label: 'Event'),
            NavigationDestination(icon: Icon(Iconsax.repeat), label: 'Scan & Sort'),
            NavigationDestination(icon: Icon(Iconsax.people), label: 'Community'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
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
    Container(),
    const PostsScreen(),
    const RecycleHistoryScreen(),
    // const EventsScreen(),       // Events page
    // const ScanSortScreen(),     // Scan & Sort page
    // const PostListScreen(),     // Community page
    // const ProfileScreen(),      // Profile page
  ];
}

// NavigationDestination(
// icon: IconButton(
// onPressed: () => AuthenticationRepository.instance.logout(),
// icon: const Icon(Iconsax.logout),
// ),
// label: 'Logout',
// ),