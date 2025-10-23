import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/posts/camera_controller.dart';

class CustomCameraScreen extends StatelessWidget {
  const CustomCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraController = Get.put(CustomCameraController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Stack(
        fit: StackFit.expand,
        children: [
          // Error State
          if (cameraController.hasError)
            _buildErrorState(cameraController, context),

          // Loading State
          if (cameraController.isLoading)
            _buildLoadingState(),

          // Camera Preview
          if (cameraController.isInitialized && cameraController.controller != null)
            _buildCameraPreview(cameraController),

          // Recording Timer (Top Center) - 只在录制时显示
          if (cameraController.isRecording)
            _buildRecordingTimer(context, cameraController),

          // Control Buttons
          if (!cameraController.isLoading && !cameraController.hasError)
            _buildControlButtons(cameraController, context),

          // Close Button (Top Left)
          if (!cameraController.isLoading && !cameraController.hasError)
            _buildCloseButton(context),
        ],
      )),
    );
  }

  Widget _buildCameraPreview(CustomCameraController cameraController) {
    return Center(
      child: AspectRatio(
        aspectRatio: cameraController.controller!.value.aspectRatio,
        child: CameraPreview(cameraController.controller!),
      ),
    );
  }

  Widget _buildRecordingTimer(BuildContext context, CustomCameraController cameraController) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 录制指示器
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // 录制时间
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    cameraController.recordingTimer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // 如果暂停录制，显示暂停图标
                  if (cameraController.isRecordingPaused) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Iconsax.pause,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(CustomCameraController cameraController, BuildContext context) {
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
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // 模式切换按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // 拍照模式按钮
                      _buildModeButton(
                        context,
                        icon: Iconsax.camera,
                        label: 'PHOTO',
                        isActive: !cameraController.isVideoMode,
                        onTap: () {
                          if (cameraController.isVideoMode) {
                            cameraController.toggleCameraMode();
                          }
                        },
                      ),
                      // 录像模式按钮
                      _buildModeButton(
                        context,
                        icon: Iconsax.video,
                        label: 'VIDEO',
                        isActive: cameraController.isVideoMode,
                        onTap: () {
                          if (!cameraController.isVideoMode) {
                            cameraController.toggleCameraMode();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧按钮区域 - 录制期间显示闪光灯按钮，非录制期间显示闪光灯或翻转镜头按钮
                SizedBox(
                  width: 60,
                  height: 60,
                  child: _buildLeftButtons(cameraController),
                ),

                // 拍照/录像按钮
                GestureDetector(
                  onTap: () async {
                    if (cameraController.isVideoMode) {
                      if (cameraController.isRecording) {
                        // 停止录像并返回文件
                        final file = await cameraController.stopVideoRecording();
                        if (file != null) {
                          Get.back(result: file);
                        }
                      } else {
                        // 开始录像
                        await cameraController.startVideoRecording();
                      }
                    } else {
                      // 拍照
                      final file = await cameraController.capturePhoto();
                      if (file != null) {
                        Get.back(result: file);
                      }
                    }
                  },
                  onLongPress: cameraController.isVideoMode && !cameraController.isRecording
                      ? () async {
                    // 长按开始录像
                    await cameraController.startVideoRecording();
                  }
                      : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cameraController.recordButtonColor,
                        width: 5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cameraController.recordButtonInnerColor,
                          shape: BoxShape.circle,
                        ),
                        child: _buildCaptureButtonContent(cameraController),
                      ),
                    ),
                  ),
                ),

                // 右侧按钮区域 - 录制期间显示暂停/继续按钮，非录制期间显示翻转镜头按钮
                SizedBox(
                  width: 60,
                  height: 60,
                  child: _buildRightButtons(cameraController),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建左侧按钮区域
  Widget _buildLeftButtons(CustomCameraController cameraController) {
    // 录制期间显示闪光灯按钮（如果支持）
    if (cameraController.isRecording) {
      if (cameraController.isRearCamera && cameraController.isFlashSupported) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: cameraController.toggleFlash,
            tooltip: cameraController.flashTooltip,
            icon: Icon(
              cameraController.flashIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      } else {
        // 如果不支持闪光灯，显示空的占位符
        return const SizedBox();
      }
    }
    // 非录制期间显示闪光灯按钮（如果支持）或翻转镜头按钮
    else {
      if (cameraController.isRearCamera && cameraController.isFlashSupported) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: cameraController.toggleFlash,
            tooltip: cameraController.flashTooltip,
            icon: Icon(
              cameraController.flashIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      } else if (cameraController.cameras.length > 1) {
        // 如果不支持闪光灯但有多个摄像头，显示翻转镜头按钮
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: cameraController.switchCamera,
            icon: const Icon(
              Iconsax.repeat,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    }
  }

  // 构建右侧按钮区域
  Widget _buildRightButtons(CustomCameraController cameraController) {
    // 录制期间显示暂停/继续按钮
    if (cameraController.isVideoMode && cameraController.isRecording) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: cameraController.toggleRecordingPause,
          tooltip: cameraController.pauseResumeTooltip,
          icon: Icon(
            cameraController.pauseResumeIcon,
            color: Colors.white,
            size: 28,
          ),
        ),
      );
    }
    // 非录制期间显示翻转镜头按钮（如果有多个摄像头）
    else if (cameraController.cameras.length > 1) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: cameraController.switchCamera,
          icon: const Icon(
            Iconsax.repeat,
            color: Colors.white,
            size: 28,
          ),
        ),
      );
    }
    return const SizedBox();
  }

  // 构建模式切换按钮
  Widget _buildModeButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isActive,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? FColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建拍照/录像按钮内容
  Widget _buildCaptureButtonContent(CustomCameraController cameraController) {
    if (cameraController.isCapturing) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: FColors.primary,
        ),
      );
    } else if (cameraController.isVideoMode && cameraController.isRecording) {
      // 录像中显示停止图标
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else if (cameraController.isVideoMode) {
      // 录像模式显示录像图标
      return Icon(
        Iconsax.video5,
        color: Colors.red,
        size: 32,
      );
    } else {
      // 拍照模式不显示内容（使用默认白色圆形）
      return const SizedBox();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: FColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CustomCameraController cameraController, BuildContext context) {
    final errorMessageLower = cameraController.errorMessage.toLowerCase();
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
              child: const Icon(
                Iconsax.camera_slash,
                color: FColors.error,
                size: 50,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),
            Text(
              isPermissionError ? 'Camera Permission Required' : 'Camera Error',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              cameraController.errorMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
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
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.white,
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
                        ? cameraController.openSettings
                        : cameraController.retryInitialize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      ),
                    ),
                    child: Text(
                      isPermissionError ? 'Settings' : 'Retry',
                      style: const TextStyle(
                        color: Colors.white,
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