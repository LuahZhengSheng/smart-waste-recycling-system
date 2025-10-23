import 'package:flutter/material.dart';
import 'package:fyp/features/carbon_footprint_calculator/screens/emission/emission.dart';
import 'package:fyp/features/personalization/controllers/home_controller.dart';
import 'package:fyp/features/personalization/screens/notification/widgets/notification_icon.dart';
import 'package:fyp/features/reward_redemption/screens/reward_redemption/reward_redemption.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../reward_redemption/screens/my_reward_point/my_reward_point.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom App Bar
              _buildAppBar(context, isDark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Slideshow Section
              _buildSlideshow(controller, isDark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Reward Points Section
              _buildRewardPointsCard(controller, isDark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Statistics Section
              _buildStatisticsSection(controller, isDark),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Emissions Section
              _buildEmissionsSection(controller, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Title
          Text(
            'SaveEarth',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: FColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: FSizes.appBarFontSize,
            ),
          ),

          // Notification Icon
          const NotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildSlideshow(HomeController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoadingSlides.value) {
        return _buildSlideshowSkeleton();
      }

      return SizedBox(
        height: 200,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              controller.onSlideInteractionStart();
            } else if (notification is ScrollEndNotification) {
              controller.onSlideInteractionEnd();
            }
            return false;
          },
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onSlideChanged,
            physics: const PageScrollPhysics(), // 使用默认的页面滚动物理效果
            itemCount: controller.slides.length,
            itemBuilder: (context, index) {
              final slide = controller.slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: slide.backgroundColor,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                ),
                child: Stack(
                  children: [
                    // Background decoration with leaves
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                        child: CustomPaint(
                          painter: LeafBackgroundPainter(isDark: isDark),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(FSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: FColors.darkGreen,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: FSizes.sm),
                          Text(
                            slide.subtitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: FColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildSlideshowSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: FColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
    );
  }

  Widget _buildRewardPointsCard(HomeController controller, bool isDark) {
    return Obx(() => GestureDetector(
      onTap: () => Get.to(() => const MyRewardPointsScreen()),
      child: Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? FColors.darkContainer : const Color(0xFFE8F5E8),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: FColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Reward Points',
                  style: TextStyle(
                    fontSize: 18,
                    color: FColors.primary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: FColors.primary.withOpacity(0.6),
                  size: FSizes.iconSm,
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.rewardPoints.value.toString()} Points',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: FColors.primary,
                      ),
                    ),
                    Text(
                      'Tap to view history',
                      style: TextStyle(
                        fontSize: 12,
                        color: FColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Get.to(() => const RewardRedemptionScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                    ),
                  ),
                  child: Text(
                    'Redeem',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatisticsSection(HomeController controller, bool isDark) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.co2_outlined,
            value: controller.kgCO2e.value.toString(),
            unit: 'kgCO2e',
            iconColor: FColors.accent, // Changed to cyan
            isDark: isDark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.recycling_outlined, // Changed to recycle triangle icon
            value: controller.totalKg.value.toString(),
            unit: 'KG',
            iconColor: FColors.accent, // Changed to cyan
            isDark: isDark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.refresh,
            value: controller.frequency.value.toString(),
            unit: 'Freq',
            iconColor: FColors.accent, // Changed to cyan
            isDark: isDark,
          ),
        ),
      ],
    ));
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: isDark ? FColors.borderPrimary.withOpacity(0.1) : FColors.borderPrimary,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: FSizes.iconLg,
            color: iconColor,
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FColors.primary,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? FColors.textSecondary : FColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmissionsSection(HomeController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emissions',
            style: TextStyle(
              fontSize: 18,
              color: FColors.primary.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Calculate Your Emission',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? FColors.textSecondary : FColors.textSecondary,
            ),
          ),
          const SizedBox(height: FSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(EmissionsScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
                foregroundColor: FColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.buttonRadius * 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
              ),
              child: const Text(
                'Calculate Emission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for leaf background decoration
class LeafBackgroundPainter extends CustomPainter {
  final bool isDark;

  LeafBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? FColors.darkGreen : FColors.accent).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw decorative leaf shapes
    final path = Path();

    // Right side leaves
    path.moveTo(size.width * 0.7, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.1,
      size.width * 0.95, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.4,
      size.width * 0.8, size.height * 0.35,
    );
    path.close();

    // Bottom right leaves
    path.moveTo(size.width * 0.6, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.6,
      size.width, size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.9,
      size.width * 0.7, size.height * 0.8,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}