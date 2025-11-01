import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

import '../../controllers/profile_camera_controller.dart';

class ProfileCameraScreen extends StatelessWidget {
  const ProfileCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileCameraController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Stack(
        fit: StackFit.expand,
        children: [
          // Error State
          if (controller.hasError) _buildErrorState(controller, context),

          // Loading State
          if (controller.isLoading) _buildLoadingState(),

          // Camera Preview
          if (controller.isInitialized && controller.controller != null)
            _buildCameraPreview(controller),

          // Control Buttons
          if (!controller.isLoading && !controller.hasError)
            _buildControlButtons(controller, context),

          // Close Button
          if (!controller.isLoading && !controller.hasError)
            _buildCloseButton(context),

          // Zoom Indicator
          if (controller.isInitialized && controller.currentZoom.value > controller.minZoom.value)
            _buildZoomIndicator(controller),
        ],
      )),
    );
  }

  Widget _buildCameraPreview(ProfileCameraController controller) {
    return GestureDetector(
      onScaleStart: controller.onScaleStart,
      onScaleUpdate: controller.onScaleUpdate,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.controller!.value.aspectRatio,
          child: CameraPreview(controller.controller!),
        ),
      ),
    );
  }

  Widget _buildZoomIndicator(ProfileCameraController controller) {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + 80,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${controller.currentZoom.value.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildControlButtons(ProfileCameraController controller, BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 32,
          top: 32,
          left: 32,
          right: 32,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flash Button
            SizedBox(
              width: 60,
              height: 60,
              child: controller.isRearCamera && controller.isFlashSupported
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: controller.toggleFlash,
                  tooltip: controller.flashTooltip,
                  icon: Icon(
                    controller.flashIcon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )
                  : const SizedBox(),
            ),

            // Capture Button
            Obx(() => GestureDetector(
              onTap: controller.isCapturing ? null : () => controller.capturePhoto(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: controller.isCapturing
                        ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: FColors.primary,
                      ),
                    )
                        : null,
                  ),
                ),
              ),
            )),

            // Switch Camera Button
            SizedBox(
              width: 60,
              height: 60,
              child: controller.cameras.length > 1
                  ? Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: controller.switchCamera,
                  icon: const Icon(Iconsax.repeat, color: Colors.white, size: 28),
                ),
              )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: FColors.primary, strokeWidth: 3),
          const SizedBox(height: FSizes.md),
          Text(
            'Initializing Camera...',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProfileCameraController controller, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.camera_slash, color: FColors.error, size: 50),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Text(
              'Camera Error',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              controller.errorMessage,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: const Text('Go Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.retryInitialize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

