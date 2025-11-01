import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: dark ? FColors.dark : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg + 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FColors.primary,
                    FColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.borderRadiusLg + 4),
                  topRight: Radius.circular(FSizes.borderRadiusLg + 4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      color: FColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: const Icon(
                      Iconsax.info_circle,
                      color: FColors.white,
                      size: FSizes.iconLg,
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Text(
                      'Map Legend',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: FColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: FColors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(FSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marker Colors',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? FColors.white : FColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),

                  // Cyan Marker
                  _buildLegendItem(
                    context,
                    color: Colors.cyan,
                    title: 'Partner Recycling Centers',
                    description: 'Centers where you can earn reward points for recycling activities',
                    icon: Iconsax.medal_star,
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.md),

                  // Red Marker
                  _buildLegendItem(
                    context,
                    color: Colors.red,
                    title: 'Other Recycling Centers',
                    description: 'General recycling centers found nearby (no reward points)',
                    icon: Iconsax.location,
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Additional Info
                  Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: FColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Iconsax.information,
                          color: FColors.info,
                          size: FSizes.iconMd,
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pro Tip',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: FColors.info,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: FSizes.xs),
                              Text(
                                'Tap on any marker to view center details and get directions.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(FSizes.lg, 0, FSizes.lg, FSizes.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.white,
                    padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: FSizes.fontSizeMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context, {
        required Color color,
        required String title,
        required String description,
        required IconData icon,
        required bool dark,
      }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marker Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Icon(
              icon,
              color: color,
              size: FSizes.iconMd,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}