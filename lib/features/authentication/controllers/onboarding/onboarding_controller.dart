import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp/features/authentication/screens/login/login.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex = index;

  /// Jump to the specific dot selected page
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Update Current Index & jump to next page
  void nextPage() {
    if(currentPageIndex.value == 2) {
      final storage = GetStorage();

      if (kDebugMode) {
        print('======================== GET STORAGE NEXT PAGE ========================');
        print(storage.read('IsFirstTime'));
      }

      storage.write('IsFirstTime', false);

      Get.offAll(() => const LoginScreen());
    } else {
      // int page = currentPageIndex.value + 1;
      // currentPageIndex.value = page;
      pageController.jumpToPage(++currentPageIndex.value);
    }
  }

  /// Update Current Index & jump to the last page
  void skipPage() {
    // currentPageIndex.value = 2;
    // pageController.jumpToPage(2);
    final storage = GetStorage();

    if (kDebugMode) {
      print('======================== GET STORAGE NEXT PAGE ========================');
      print(storage.read('IsFirstTime'));
    }

    storage.write('IsFirstTime', false);
    Get.offAll(const LoginScreen());
  }
}