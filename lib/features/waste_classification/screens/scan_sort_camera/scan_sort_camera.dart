import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/scan_sort_camera_controller.dart';

class ScanSortCameraScreen extends StatelessWidget {
  const ScanSortCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanSortCameraController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      body: Obx(() => Stack(
        fit: StackFit.expand,
        children: [
          // Error State
          if (controller.hasError)
            _buildErrorState(controller, context, dark),

          // Loading State
          if (controller.isLoading)
            _buildLoadingState(dark),

          // Camera Preview with Gesture Detector for Zoom
          if (controller.isInitialized && controller.controller != null)
            GestureDetector(
              onScaleStart: controller.onScaleStart,
              onScaleUpdate: controller.onScaleUpdate,
              child: _buildCameraPreview(controller),
            ),

          // Top Buttons (Drop Off & Categories)
          if (!controller.isLoading && !controller.hasError)
            _buildTopButtons(context, dark),

          // Camera Frame Overlay with Text
          if (controller.isInitialized && !controller.isLoading)
            _buildCameraFrameOverlay(context, dark),

          // Bottom Controls
          if (!controller.isLoading && !controller.hasError)
            _buildBottomControls(controller, context, dark),

          // Zoom Indicator
          if (controller.isInitialized && controller.currentZoom > controller.minZoom)
            _buildZoomIndicator(controller, context, dark),
        ],
      )),
    );
  }

  Widget _buildCameraPreview(ScanSortCameraController controller) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.controller!.value.previewSize?.height ?? 100,
          height: controller.controller!.value.previewSize?.width ?? 100,
          child: CameraPreview(controller.controller!),
        ),
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context, bool dark) {
    final controller = Get.find<ScanSortCameraController>();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drop Off Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.navigateToDropOff(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: FColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 20,
                      color: FColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Drop Off',
                      style: TextStyle(
                        color: FColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.navigateToCategories(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: FColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.category,
                      size: 20,
                      color: FColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Categories',
                      style: TextStyle(
                        color: FColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraFrameOverlay(BuildContext context, bool dark) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.width * 0.75,
        child: Stack(
          children: [
            // 左上角L形
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: FColors.white, width: 3),
                    left: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            // 右上角L形
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: FColors.white, width: 3),
                    right: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            // 左下角L形
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: FColors.white, width: 3),
                    left: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            // 右下角L形
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: FColors.white, width: 3),
                    right: BorderSide(color: FColors.white, width: 3),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(FSizes.borderRadiusMd),
                  ),
                ),
              ),
            ),
            // 文字内容 - 使用 Center 包裹
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Point your camera at',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'recycling objects and',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'take a photo',
                    style: TextStyle(
                      color: FColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
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
    );
  }

  Widget _buildBottomControls(
      ScanSortCameraController controller,
      BuildContext context,
      bool dark,
      ) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gallery Button
            _buildControlButton(
              icon: Iconsax.gallery,
              onTap: () async {
                final file = await controller.pickFromGallery();
                if (file != null) {
                  Get.back(result: file);
                }
              },
              dark: dark,
            ),

            // Capture Button
            GestureDetector(
              onTap: () async {
                final file = await controller.capturePhoto();
                if (file != null) {
                  Get.back(result: file);
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? FColors.white : FColors.primary,
                    width: 5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? FColors.white : FColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: controller.isCapturing
                        ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: dark ? FColors.primary : FColors.white,
                      ),
                    )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),

            // Flash Toggle Button
            _buildControlButton(
              icon: controller.isFlashOn ? Iconsax.flash_15 : Iconsax.flash_slash,
              onTap: controller.toggleFlash,
              dark: dark,
              isActive: controller.isFlashOn,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool dark,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive
              ? FColors.primary
              : (dark ? FColors.darkContainer : FColors.white),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? FColors.primary
                : (dark ? FColors.borderPrimary.withOpacity(0.3) : FColors.borderPrimary),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (dark ? Colors.black : Colors.grey).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive
              ? FColors.white
              : (dark ? FColors.white : FColors.textPrimary),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildZoomIndicator(
      ScanSortCameraController controller,
      BuildContext context,
      bool dark,
      ) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm,
          vertical: FSizes.xs,
        ),
        decoration: BoxDecoration(
          color: dark
              ? Colors.black.withOpacity(0.6)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FColors.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.search_zoom_in,
              size: 16,
              color: FColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              controller.zoomText,
              style: TextStyle(
                color: dark ? FColors.white : FColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: FColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              color: dark ? FColors.white : FColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      ScanSortCameraController controller,
      BuildContext context,
      bool dark,
      ) {
    final errorMessageLower = controller.errorMessage.toLowerCase();
    final isPermissionError = errorMessageLower.contains('permission') ||
        errorMessageLower.contains('denied');

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
              child: Icon(
                Iconsax.camera_slash,
                color: FColors.error,
                size: 50,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Text(
              isPermissionError ? 'Camera Permission Required' : 'Camera Error',
              style: TextStyle(
                color: dark ? FColors.white : FColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              controller.errorMessage,
              style: TextStyle(
                color: dark ? FColors.lightGrey : FColors.textSecondary,
                fontSize: 14,
              ),
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
                      backgroundColor: dark ? FColors.darkGrey : FColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        color: dark ? FColors.white : FColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isPermissionError
                        ? controller.openSettings
                        : controller.retryInitialize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: Text(
                      isPermissionError ? 'Settings' : 'Retry',
                      style: const TextStyle(
                        color: FColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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