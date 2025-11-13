import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

import '../../../../personalization/controllers/qr_controller.dart';

class CustomQRScanner extends StatefulWidget {
  final Function(String) onQRScanned;
  final bool dark;

  const CustomQRScanner({
    super.key,
    required this.onQRScanned,
    this.dark = false,
  });

  @override
  State<CustomQRScanner> createState() => _CustomQRScannerState();
}

class _CustomQRScannerState extends State<CustomQRScanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;
  bool _isFlashOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => isScanned = true);

        try {
          // 验证 JWT token
          final qrController = Get.find<QRController>();
          final validationResult = qrController.validateScannedToken(barcode.rawValue!);

          print('🔍 Validation result: $validationResult (type: ${validationResult?.runtimeType})');

          // 确保结果是字符串类型
          if (validationResult is String) {
            final userId = validationResult;
            print('✅ Valid JWT token scanned for user: $userId');

            // 添加短暂延迟以确保扫描状态被更新
            Future.delayed(Duration(milliseconds: 500), () {
              print('🚀 Calling onQRScanned with user ID: $userId');
              widget.onQRScanned(userId);
            });

          } else {
            throw Exception('Expected String but got ${validationResult?.runtimeType}');
          }

        } catch (e) {
          print('💥 QR Scan processing error: $e');
          print('💥 Error type: ${e.runtimeType}');

          // 显示错误信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to process QR code: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          // 重置扫描状态
          Future.delayed(Duration(seconds: 2), () {
            setState(() => isScanned = false);
          });
        }
        break;
      }
    }
  }

  void _toggleFlash() async {
    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await cameraController.toggleTorch();
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
            // 添加错误处理
            // onScannerError: (error) {
            //   if (error.error is MobileScannerException) {
            //     final exception = error.error as MobileScannerException;
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         content: Text('Camera error: ${exception.errorDetails}'),
            //         backgroundColor: Colors.red,
            //       ),
            //     );
            //   }
            // },
          ),

          // Overlay with scanning area
          _buildOverlay(),

          // Top bar with title and close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(FSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan QR Code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.lg,
                  vertical: FSizes.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                ),
                child: const Text(
                  'Position QR code within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Flash toggle button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashOn ? Colors.yellow : Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          // Scanning indicator
          if (isScanned)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Processing...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  Widget _buildOverlay() {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        Colors.black54,
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: widget.dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}