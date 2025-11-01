import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageCropperScreen extends StatelessWidget {
  final File imageFile;

  const ImageCropperScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageCropperController(imageFile: imageFile));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image with interactive crop
          Center(
            child: Obx(() {
              if (!controller.isImageLoaded.value) {
                return const CircularProgressIndicator(color: FColors.primary);
              }

              return GestureDetector(
                onScaleStart: controller.onScaleStart,
                onScaleUpdate: controller.onScaleUpdate,
                onScaleEnd: controller.onScaleEnd,
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Image with transformation
                      Center(
                        child: Transform(
                          transform: controller.imageMatrix.value,
                          alignment: Alignment.center,
                          child: Image.file(
                            controller.imageFile,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Crop overlay
                      CustomPaint(
                        size: Size(Get.width, Get.height),
                        painter: CropOverlayPainter(
                          cropRect: controller.cropRect.value,
                          viewportSize: Size(Get.width, Get.height),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),

                  // Done button
                  Obx(() => ElevatedButton.icon(
                    onPressed: controller.isCropping.value
                        ? null
                        : () => controller.cropAndSaveImage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: controller.isCropping.value
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Iconsax.tick_circle, color: Colors.white),
                    label: Text(
                      controller.isCropping.value ? 'Processing...' : 'Done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rotate left
                  _buildControlButton(
                    icon: Iconsax.rotate_left,
                    label: 'Rotate',
                    onTap: controller.rotateLeft,
                  ),

                  // Flip horizontal
                  _buildControlButton(
                    icon: Iconsax.arrange_square_2,
                    label: 'Flip',
                    onTap: controller.flipHorizontal,
                  ),

                  // Reset
                  _buildControlButton(
                    icon: Iconsax.refresh,
                    label: 'Reset',
                    onTap: controller.reset,
                  ),
                ],
              ),
            ),
          ),

          // Zoom indicator
          Obx(() {
            if (controller.currentScale.value > 1.0) {
              return Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.currentScale.value.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCropperController extends GetxController {
  final File imageFile;

  ImageCropperController({required this.imageFile});

  // Observable variables
  final isImageLoaded = false.obs;
  final isCropping = false.obs;
  final imageMatrix = Matrix4.identity().obs;
  final cropRect = Rx<Rect>(Rect.zero);
  final currentScale = 1.0.obs;

  // Image transformation variables
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  double _rotation = 0.0;
  bool _flipHorizontal = false;

  img.Image? _originalImage;
  Size _imageSize = Size.zero;

  @override
  void onInit() {
    super.onInit();
    _loadImage();
    _initializeCropRect();
  }

  @override
  void onClose() {
    _originalImage = null;
    super.onClose();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await imageFile.readAsBytes();
      _originalImage = img.decodeImage(bytes);
      if (_originalImage != null) {
        _imageSize = Size(
          _originalImage!.width.toDouble(),
          _originalImage!.height.toDouble(),
        );
      }
      isImageLoaded.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image: $e');
      Get.back();
    }
  }

  void _initializeCropRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = Get.size;
      final cropSize = size.width * 0.8;
      final left = (size.width - cropSize) / 2;
      final top = (size.height - cropSize) / 2;

      cropRect.value = Rect.fromLTWH(left, top, cropSize, cropSize);
    });
  }

  void onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _previousOffset = _offset;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    // Update scale
    _scale = (_previousScale * details.scale).clamp(0.5, 4.0);
    currentScale.value = _scale;

    // Update offset (pan)
    _offset = _previousOffset + details.focalPointDelta;

    // Update transformation matrix
    _updateMatrix();
  }

  void onScaleEnd(ScaleEndDetails details) {
    // Finalize the transformation
  }

  void _updateMatrix() {
    final matrix = Matrix4.identity();

    // Apply translation
    matrix.translate(_offset.dx, _offset.dy);

    // Apply scale
    matrix.scale(_scale, _scale);

    // Apply rotation
    if (_rotation != 0) {
      matrix.rotateZ(_rotation * (3.14159 / 180));
    }

    // Apply flip
    if (_flipHorizontal) {
      matrix.scale(-1.0, 1.0);
    }

    imageMatrix.value = matrix;
  }

  void rotateLeft() {
    _rotation = (_rotation - 90) % 360;
    _updateMatrix();
  }

  void flipHorizontal() {
    _flipHorizontal = !_flipHorizontal;
    _updateMatrix();
  }

  void reset() {
    _scale = 1.0;
    _previousScale = 1.0;
    _offset = Offset.zero;
    _previousOffset = Offset.zero;
    _rotation = 0.0;
    _flipHorizontal = false;
    currentScale.value = 1.0;
    _updateMatrix();
  }

  Future<void> cropAndSaveImage() async {
    if (_originalImage == null) return;

    try {
      isCropping.value = true;

      // Get the crop rect in screen coordinates
      final cropRectScreen = cropRect.value;

      // Calculate the transformation from screen to image coordinates
      final screenSize = Size(Get.width, Get.height);

      // Get image display size (considering fit: BoxFit.contain)
      final imageDisplaySize = _calculateImageDisplaySize(
        _imageSize,
        screenSize,
      );

      // Calculate offset of image on screen
      final imageOffset = Offset(
        (screenSize.width - imageDisplaySize.width) / 2,
        (screenSize.height - imageDisplaySize.height) / 2,
      );

      // Convert crop rect from screen to image display coordinates
      final cropInDisplay = Rect.fromLTWH(
        cropRectScreen.left - imageOffset.dx - _offset.dx,
        cropRectScreen.top - imageOffset.dy - _offset.dy,
        cropRectScreen.width,
        cropRectScreen.height,
      );

      // Convert from display coordinates to actual image coordinates
      final scaleX = _imageSize.width / (imageDisplaySize.width * _scale);
      final scaleY = _imageSize.height / (imageDisplaySize.height * _scale);

      final cropInImage = Rect.fromLTWH(
        (cropInDisplay.left * scaleX).clamp(0, _imageSize.width),
        (cropInDisplay.top * scaleY).clamp(0, _imageSize.height),
        (cropInDisplay.width * scaleX).clamp(0, _imageSize.width),
        (cropInDisplay.height * scaleY).clamp(0, _imageSize.height),
      );

      // Perform the actual crop
      img.Image croppedImage = img.copyCrop(
        _originalImage!,
        x: cropInImage.left.toInt(),
        y: cropInImage.top.toInt(),
        width: cropInImage.width.toInt(),
        height: cropInImage.height.toInt(),
      );

      // Apply rotation if needed
      if (_rotation == 90 || _rotation == -270) {
        croppedImage = img.copyRotate(croppedImage, angle: 90);
      } else if (_rotation == 180 || _rotation == -180) {
        croppedImage = img.copyRotate(croppedImage, angle: 180);
      } else if (_rotation == 270 || _rotation == -90) {
        croppedImage = img.copyRotate(croppedImage, angle: 270);
      }

      // Apply flip if needed
      if (_flipHorizontal) {
        croppedImage = img.flipHorizontal(croppedImage);
      }

      // Resize to 500x500 for profile picture
      croppedImage = img.copyResize(
        croppedImage,
        width: 500,
        height: 500,
        interpolation: img.Interpolation.cubic,
      );

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Encode and save
      final pngBytes = img.encodePng(croppedImage);
      await tempFile.writeAsBytes(pngBytes);

      // Return cropped image
      Get.back(result: tempFile);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to crop image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCropping.value = false;
    }
  }

  Size _calculateImageDisplaySize(Size imageSize, Size screenSize) {
    final imageAspect = imageSize.width / imageSize.height;
    final screenAspect = screenSize.width / screenSize.height;

    double displayWidth, displayHeight;

    if (imageAspect > screenAspect) {
      // Image is wider than screen
      displayWidth = screenSize.width;
      displayHeight = screenSize.width / imageAspect;
    } else {
      // Image is taller than screen
      displayHeight = screenSize.height;
      displayWidth = screenSize.height * imageAspect;
    }

    return Size(displayWidth, displayHeight);
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Size viewportSize;

  CropOverlayPainter({
    required this.cropRect,
    required this.viewportSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dimmed overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Top
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, cropRect.top),
      overlayPaint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.bottom, size.width, size.height),
      overlayPaint,
    );
    // Left
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.top, cropRect.left, cropRect.bottom),
      overlayPaint,
    );
    // Right
    canvas.drawRect(
      Rect.fromLTRB(cropRect.right, cropRect.top, size.width, cropRect.bottom),
      overlayPaint,
    );

    // Draw crop border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(cropRect, borderPaint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Vertical lines
    final thirdWidth = cropRect.width / 3;
    canvas.drawLine(
      Offset(cropRect.left + thirdWidth, cropRect.top),
      Offset(cropRect.left + thirdWidth, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + thirdWidth * 2, cropRect.top),
      Offset(cropRect.left + thirdWidth * 2, cropRect.bottom),
      gridPaint,
    );

    // Horizontal lines
    final thirdHeight = cropRect.height / 3;
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight),
      Offset(cropRect.right, cropRect.top + thirdHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight * 2),
      Offset(cropRect.right, cropRect.top + thirdHeight * 2),
      gridPaint,
    );

    // Draw corner handles
    final handleSize = 20.0;
    final handlePaint = Paint()
      ..color = FColors.primary
      ..style = PaintingStyle.fill;

    // Top-left
    canvas.drawRect(
      Rect.fromLTWH(cropRect.left - 2, cropRect.top - 2, handleSize, 4),
      handlePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cropRect.left - 2, cropRect.top - 2, 4, handleSize),
      handlePaint,
    );

    // Top-right
    canvas.drawRect(
      Rect.fromLTWH(cropRect.right - handleSize + 2, cropRect.top - 2, handleSize, 4),
      handlePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cropRect.right - 2, cropRect.top - 2, 4, handleSize),
      handlePaint,
    );

    // Bottom-left
    canvas.drawRect(
      Rect.fromLTWH(cropRect.left - 2, cropRect.bottom - 2, handleSize, 4),
      handlePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cropRect.left - 2, cropRect.bottom - handleSize + 2, 4, handleSize),
      handlePaint,
    );

    // Bottom-right
    canvas.drawRect(
      Rect.fromLTWH(cropRect.right - handleSize + 2, cropRect.bottom - 2, handleSize, 4),
      handlePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cropRect.right - 2, cropRect.bottom - handleSize + 2, 4, handleSize),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}