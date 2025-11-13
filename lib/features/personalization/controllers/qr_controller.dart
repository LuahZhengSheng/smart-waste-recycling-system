import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import '../../../data/services/qr_code/jwt_service.dart';
import '../../../config/jwt_config.dart'; // 添加这行

class QRController extends GetxController {
  // 使用安全的getter
  JWTService get _jwtService => Get.find<JWTService>();

  final RxString currentToken = ''.obs;
  final RxInt secondsRemaining = 30.obs;
  final RxBool isDialogOpen = false.obs;

  Timer? _refreshTimer;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    print('✅ QRController initialized');
  }

  @override
  void onClose() {
    print('🛑 QRController onClose() called');
    _stopTimers();
    super.onClose();
  }

  /// Start token refresh and countdown
  void startAutoRefresh() {
    print('=== 🔄 QRController.startAutoRefresh() START ===');

    // 停止现有计时器
    _stopTimers();

    // 生成初始JWT token
    _generateNewToken();

    // 标记对话框为打开状态
    isDialogOpen.value = true;
    print('✅ Dialog state: OPEN');

    // 设置30秒刷新计时器
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isDialogOpen.value) {
        print('🕒 30-second auto-refresh triggered');
        _generateNewToken();
      }
    });

    // 设置UI倒计时计时器
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isDialogOpen.value) {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          secondsRemaining.value = 30;
        }
      }
    });

    print('✅ Auto-refresh system STARTED');
    print('=== 🔄 startAutoRefresh() END ===');
  }

  /// Stop timers
  void _stopTimers() {
    print('🛑 Stopping all timers...');

    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }

    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
      _countdownTimer = null;
    }

    print('✅ All timers stopped');
  }

  /// Stop auto-refresh (when dialog is closed)
  void stopAutoRefresh() {
    print('=== 🛑 QRController.stopAutoRefresh() ===');
    isDialogOpen.value = false;
    _stopTimers();
    // 清除JWT token以保安全
    currentToken.value = '';
    print('✅ Auto-refresh stopped and token cleared');
  }

  /// Generate new JWT token for the current user
  void _generateNewToken() {
    print('=== 🎯 QRController._generateNewToken() START ===');

    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;

      if (userId != null && userId.isNotEmpty) {
        // 使用JWTService生成token
        currentToken.value = _jwtService.generateQRToken(userId);
        secondsRemaining.value = 30;

        print('🎉 TOKEN GENERATION SUCCESS!');
        print('📏 Token Length: ${currentToken.value.length} chars');

      } else {
        print('❌ No valid user ID available for token generation');
        currentToken.value = '';
      }
    } catch (e) {
      print('💥 CRITICAL ERROR in _generateNewToken: $e');
      currentToken.value = 'ERROR: ${e.toString()}';
    }

    print('=== 🎯 _generateNewToken() END ===');
  }

  /// Manual refresh (when user clicks refresh button)
  void manualRefresh() {
    print('🔄 Manual refresh triggered by user');
    _generateNewToken();
  }

  /// Check if token is about to expire
  bool get isExpiringSoon => secondsRemaining.value <= 10;

  /// Validate scanned JWT token and extract user ID - 修复版本
  String? validateScannedToken(String scannedToken) {
    print('=== 🔍 QRController.validateScannedToken() START ===');
    print('📏 Scanned token length: ${scannedToken.length} chars');

    try {
      // 方法1: 使用JWTService的便捷方法
      final result = _jwtService.validateQRToken(scannedToken);

      print('🔍 Validation result type: ${result.runtimeType}');
      print('🔍 Validation result value: $result');

      if (result is String) {
        print('✅ Scan validation successful for user: $result');
        return result;
      }

      // 方法2: 如果方法1返回了意外类型，使用手动验证
      print('🔄 Falling back to manual validation...');
      final payload = _jwtService.validateToken(scannedToken);

      if (payload != null) {
        final type = payload['type'] as String?;
        if (type == JWTConfig.qrTokenType) {
          final userId = payload['sub'] as String?;
          print('✅ Manual validation successful for user: $userId');
          return userId;
        } else {
          print('❌ Invalid token type: $type');
        }
      }

      print('❌ All validation methods failed');
      return null;

    } catch (e) {
      print('❌ Scan validation failed with error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Get token information for debugging
  Map<String, dynamic>? getTokenInfo(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payloadBase64 = parts[1];
      final padded = payloadBase64.padRight((payloadBase64.length + 3) & ~3, '=');
      final payloadJson = utf8.decode(base64Url.decode(padded));
      return json.decode(payloadJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}