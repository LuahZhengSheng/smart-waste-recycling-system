import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FLoaders {
  static void hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  /// Safely close any open snackbars without causing initialization errors
  static void safeCloseSnackBar() {
    try {
      if (Get.isSnackbarOpen == true) {
        Get.back();
      }
    } catch (e) {
      print('Safe snackbar close: $e');
    }
  }

  static void customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.darkerGrey.withOpacity(0.9) : FColors.grey.withOpacity(0.9),
          ),
          child: Center(child: Text(message, style: Theme.of(Get.context!).textTheme.labelLarge)),
        ),
      ),
    );
  }

  static void successSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: FColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Iconsax.check, color: FColors.white),
    );
  }

  static void warningSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: FColors.white,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.warning_2, color: FColors.white),
    );
  }

  static void errorSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: FColors.white,
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.warning_2, color: FColors.white),
    );
  }

  /// Show loading dialog
  static void showLoading([String? message]) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.darkerGrey : FColors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: FColors.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Loading...',
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.white : FColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Stop loading dialog
  static void stopLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = FColors.primary,
    Color cancelColor = FColors.darkGrey,
  }) async {
    return await Get.dialog<bool>(
      Dialog(
        backgroundColor: FHelperFunctions.isDarkMode(Get.context!) ? FColors.darkerGrey : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.white : FColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.lightGrey : FColors.darkGrey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    style: TextButton.styleFrom(
                      foregroundColor: cancelColor,
                    ),
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: FColors.white,
                    ),
                    child: Text(confirmText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show event registration confirmation dialog
  static Future<void> showRegistrationDialog({
    required String eventTitle,
    required Future<void> Function() onConfirm,
  }) async {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    await Get.dialog(
      Dialog(
        backgroundColor: dark ? FColors.darkContainer : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.calendar_tick,
                  size: 40,
                  color: FColors.primary,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Confirm Registration',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Are you sure you want to register for "$eventTitle"?',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark ? FColors.darkGrey : FColors.borderPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primary,
                        foregroundColor: FColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show event cancellation confirmation dialog
  static Future<void> showCancellationDialog({
    required Future<void> Function() onConfirm,
  }) async {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    await Get.dialog(
      Dialog(
        backgroundColor: dark ? FColors.darkContainer : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.calendar_remove,
                  size: 40,
                  color: FColors.error,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Cancel Registration?',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Are you sure you want to cancel your registration? This action cannot be undone.',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark ? FColors.darkGrey : FColors.borderPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: Text(
                        'Keep',
                        style: TextStyle(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.error,
                        foregroundColor: FColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: const Text(
                        'Cancel Registration',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show Google Maps navigation confirmation dialog
  static Future<void> showMapNavigationDialog({
    required Future<void> Function() onConfirm,
  }) async {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    await Get.dialog(
      Dialog(
        backgroundColor: dark ? FColors.darkContainer : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.location,
                  size: 40,
                  color: FColors.primary,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Open in Google Maps',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Would you like to view this location in Google Maps for directions?',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark ? FColors.darkGrey : FColors.borderPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primary,
                        foregroundColor: FColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: const Text(
                        'Open Maps',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Show reward redemption confirmation dialog
  static Future<void> showRewardRedemptionDialog({
    required String rewardTitle,
    required int pointsRequired,
    required int currentPoints,
    required Future<void> Function() onConfirm,
  }) async {
    final dark = FHelperFunctions.isDarkMode(Get.context!);
    final afterRedemption = currentPoints - pointsRequired;

    await Get.dialog(
      Dialog(
        backgroundColor: dark ? FColors.darkContainer : FColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.gift,
                  size: 40,
                  color: FColors.primary,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Confirm Redemption',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Are you sure you want to redeem this reward?',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: dark ? FColors.dark : FColors.lightContainer,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rewardTitle,
                      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        color: dark ? FColors.white : FColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: FSizes.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Points Required:',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$pointsRequired',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: FColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FSizes.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Balance:',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$currentPoints',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.white : FColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: FSizes.spaceBtwItems),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'After Redemption:',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$afterRedemption',
                          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                            color: FColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark ? FColors.darkGrey : FColors.borderPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FColors.primary,
                        foregroundColor: FColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: const Text(
                        'Redeem',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show bottom sheet with custom content
  static void showBottomSheet(Widget content, {bool isDismissible = true}) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.darkerGrey : FColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FHelperFunctions.isDarkMode(Get.context!) ? FColors.darkGrey : FColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            content,
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
    );
  }
}