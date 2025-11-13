// lib/features/qr/views/qr_code_dialog.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../controllers/qr_controller.dart';

class QRCodeDialog extends StatelessWidget {
  const QRCodeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QRController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(FSizes.lg),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      child: const Icon(
                        Iconsax.scan_barcode,
                        color: FColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Text(
                      'My QR Code',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: controller.manualRefresh,
                      icon: const Icon(Iconsax.refresh, size: 20),
                      tooltip: 'Refresh QR Code',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: FSizes.md),

            // QR Code with JWT token
            Obx(() => controller.currentToken.value.isEmpty
                ? const CircularProgressIndicator()
                : Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(color: FColors.grey, width: 2),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: controller.currentToken.value,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                  const SizedBox(height: FSizes.sm),
                  // Token info for debugging (optional)
                  if (kDebugMode)
                    Container(
                      padding: const EdgeInsets.all(FSizes.sm),
                      decoration: BoxDecoration(
                        color: FColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                      ),
                      child: Text(
                        'JWT Token (${controller.currentToken.value.length} chars)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: FColors.darkGrey,
                        ),
                      ),
                    ),
                ],
              ),
            )),

            const SizedBox(height: FSizes.md),

            // Timer with JWT info
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: controller.secondsRemaining.value <= 10
                    ? Colors.red.withOpacity(0.1)
                    : (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.timer_1,
                    size: 18,
                    color: controller.secondsRemaining.value <= 10
                        ? Colors.red
                        : (dark ? FColors.grey : FColors.darkGrey),
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    'JWT expires in ${controller.secondsRemaining.value}s',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: controller.secondsRemaining.value <= 10
                          ? Colors.red
                          : (dark ? FColors.grey : FColors.darkGrey),
                      fontWeight: controller.secondsRemaining.value <= 10
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: FSizes.md),

            // Info text
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: FColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                border: Border.all(
                  color: FColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, size: 18, color: FColors.info),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Text(
                      'Show this secure QR code to staff to start recycling',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static method to show the QR code dialog
  static void show(BuildContext context) {
    // Get or create controller
    final controller = Get.put(QRController());

    // Start auto-refresh when dialog is opened
    controller.startAutoRefresh();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const QRCodeDialog(),
    ).then((_) {
      // Stop auto-refresh when dialog is closed
      controller.stopAutoRefresh();
    });
  }
}