import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable variables for slideshow
  final RxInt currentSlideIndex = 0.obs;
  final RxList<SlideModel> slides = <SlideModel>[].obs;

  // PageController for slideshow
  late PageController pageController;
  Timer? autoSlideTimer;

  // Observable variables for user stats
  final RxInt rewardPoints = 1200.obs;
  final RxDouble kgCO2e = 0.0.obs;
  final RxDouble totalKg = 0.0.obs;
  final RxInt frequency = 0.obs;

  // Loading states
  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingSlides = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadSlides();
    loadUserStats();

    // Start auto slideshow after a short delay to allow slides to load
    Future.delayed(const Duration(seconds: 1), () {
      if (slides.isNotEmpty) {
        startAutoSlideshow();
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    autoSlideTimer?.cancel();
    super.onClose();
  }

  // Load slideshow data
  void loadSlides() {
    isLoadingSlides.value = true;

    // Simulate loading slides data
    slides.value = [
      SlideModel(
        title: "Welcome\ncollectors and\nmerchants.",
        subtitle: "Join us today!",
        backgroundColor: const Color(0xFFF8E1E1), // Light pink/peach
        image: "assets/images/slides/welcome_slide.png",
      ),
      SlideModel(
        title: "Earn Points\nfor Every\nRecycle!",
        subtitle: "Start collecting today",
        backgroundColor: const Color(0xFFE1F8E1), // Light green
        image: "assets/images/slides/earn_points_slide.png",
      ),
      SlideModel(
        title: "Track Your\nEnvironmental\nImpact",
        subtitle: "Make a difference",
        backgroundColor: const Color(0xFFE1E8F8), // Light blue
        image: "assets/images/slides/track_impact_slide.png",
      ),
    ];

    isLoadingSlides.value = false;

    // Start auto slideshow after slides are loaded
    if (slides.isNotEmpty) {
      startAutoSlideshow();
    }
  }

  // Load user statistics
  void loadUserStats() async {
    isLoadingStats.value = true;

    try {
      // Simulate API call to get user stats
      await Future.delayed(const Duration(milliseconds: 500));

      // Update stats (these would come from your backend)
      rewardPoints.value = 1200;
      kgCO2e.value = 0.0;
      totalKg.value = 0.0;
      frequency.value = 0;

    } catch (e) {
      // Handle error
      print('Error loading user stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  // Start auto slideshow
  void startAutoSlideshow() {
    // Cancel any existing timer first
    stopAutoSlideshow();

    autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (slides.isEmpty) return;

      // 检查 PageController 是否已附加到 PageView
      if (!pageController.hasClients) {
        timer.cancel(); // 如果 PageController 未附加，停止定时器
        return;
      }

      int nextIndex = (currentSlideIndex.value + 1) % slides.length;

      // Use pageController to animate to next slide
      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // Stop auto slideshow
  void stopAutoSlideshow() {
    autoSlideTimer?.cancel();
    autoSlideTimer = null;
  }

  // Navigate to slideshow page / Handle manual slide change
  void onSlideChanged(int index) {
    currentSlideIndex.value = index;
    // Restart auto-slideshow timer when user manually changes slide
    startAutoSlideshow();
  }

  // Handle user interaction with slideshow
  void onSlideInteractionStart() {
    stopAutoSlideshow();
  }

  void onSlideInteractionEnd() {
    startAutoSlideshow();
  }

  // Handle redeem points
  void onRedeemPressed() {
    // Navigate to redeem points page
    Get.toNamed('/redeem');
  }

  // Handle calculate emission
  void onCalculateEmissionPressed() {
    // Navigate to emission calculator page
    Get.toNamed('/emission-calculator');
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      Future(() => loadSlides()),
      Future(() => loadUserStats()),
    ]);
  }
}

// Model for slideshow data
class SlideModel {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String image;

  SlideModel({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.image,
  });
}