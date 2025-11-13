import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class SubmissionSuccessScreen extends StatelessWidget {
  final int activitiesCount;
  final double totalWeight;
  final int totalPoints;
  final String userName;

  const SubmissionSuccessScreen({
    super.key,
    required this.activitiesCount,
    required this.totalWeight,
    required this.totalPoints,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return WillPopScope(
      onWillPop: () async {
        _navigateToHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: dark ? FColors.staffDarkBackground : FColors.staffLightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Animation
                Lottie.asset(
                  'assets/images/animations/72462-check-register.json',
                  width: 300,
                  height: 300,
                  repeat: false,
                ),

                // Success Title
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.staffDarkSuccess : FColors.staffLightSuccess,
                  ),
                ),

                const SizedBox(height: FSizes.md),

                // Success Message
                Text(
                  'All activities submitted successfully',
                  style: TextStyle(
                    fontSize: 16,
                    color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // User Info Card
                Container(
                  padding: const EdgeInsets.all(FSizes.lg),
                  decoration: BoxDecoration(
                    color: dark ? FColors.staffDarkSurface : FColors.staffLightSurface,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // User Name
                      Row(
                        children: [
                          Icon(
                            Iconsax.user,
                            color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                            size: FSizes.iconMd,
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: Text(
                              userName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: dark ? FColors.staffDarkText : FColors.staffLightText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: FSizes.spaceBtwItems),
                      Divider(color: dark ? FColors.staffDarkBorder : FColors.staffLightBorder),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Statistics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Iconsax.task_square,
                            label: 'Activities',
                            value: activitiesCount.toString(),
                            dark: dark,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: dark ? FColors.staffDarkBorder : FColors.staffLightBorder,
                          ),
                          _buildStatItem(
                            icon: Iconsax.weight_1,
                            label: 'Weight',
                            value: '${totalWeight.toStringAsFixed(1)} kg',
                            dark: dark,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: dark ? FColors.staffDarkBorder : FColors.staffLightBorder,
                          ),
                          _buildStatItem(
                            icon: Iconsax.crown1,
                            label: 'Points',
                            value: totalPoints.toString(),
                            dark: dark,
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Points Earned Highlight
                Container(
                  padding: const EdgeInsets.all(FSizes.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: dark
                          ? [FColors.staffDarkSecondary, FColors.staffDarkSecondary.withOpacity(0.7)]
                          : [FColors.staffLightSecondary, FColors.staffLightSecondary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: (dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(FSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                        ),
                        child: const Icon(
                          Iconsax.medal_star5,
                          color: Colors.white,
                          size: FSizes.iconLg,
                        ),
                      ),
                      const SizedBox(width: FSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Points Awarded',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '+$totalPoints points',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Iconsax.tick_circle5,
                        color: Colors.white,
                        size: FSizes.iconLg,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwSections),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.home),
                        SizedBox(width: FSizes.sm),
                        Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required bool dark,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: highlight
              ? (dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary)
              : (dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary),
          size: FSizes.iconMd,
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: highlight
                ? (dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary)
                : (dark ? FColors.staffDarkText : FColors.staffLightText),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
          ),
        ),
      ],
    );
  }

  void _navigateToHome() {
    Get.until((route) => route.isFirst);
  }
}