import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import '../../../config/jwt_config.dart';

/// 统一的JWT服务，包含所有JWT相关功能
class JWTService extends GetxService {
  static JWTService get instance => Get.find();

  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    print('🎯 JWTService onInit() called');
    _initializeService();
  }

  void _initializeService() {
    try {
      print('=== 🔧 JWTService Initialization Start ===');

      // 1. 测试配置加载
      print('1. Testing JWTConfig...');
      _testJWTConfig();

      // 2. 测试密钥
      print('2. Testing Secret Key...');
      _testSecretKey();

      // 3. 测试加密功能
      print('3. Testing Crypto Functions...');
      _testCryptoFunctions();

      // 4. 标记为已初始化
      _isInitialized = true;
      print('✅ JWTService Initialization COMPLETED');

      // 5. 自检生成测试token（在初始化完成后）
      print('4. Self-test Token Generation...');
      _selfTestTokenGeneration();

      print('=== 🔧 Initialization End ===');

    } catch (e) {
      print('💥 JWTService Initialization FAILED: $e');
      print('💥 Error type: ${e.runtimeType}');
      // 即使初始化失败，也标记为已初始化，让应用继续运行
      _isInitialized = true;
      print('⚠️ Service will continue with potential limitations');
    }
  }

  void _testJWTConfig() {
    try {
      print('   🔧 Checking JWTConfig.algorithm...');
      final algorithm = JWTConfig.algorithm;
      print('      ✅ Algorithm: $algorithm');

      print('   🔧 Checking JWTConfig.tokenType...');
      final tokenType = JWTConfig.tokenType;
      print('      ✅ Token Type: $tokenType');

      print('   🔧 Checking JWTConfig.qrTokenExpiration...');
      final qrExpiration = JWTConfig.qrTokenExpiration;
      print('      ✅ QR Expiration: $qrExpiration');

      print('   🔧 Checking JWTConfig.issuer...');
      final issuer = JWTConfig.issuer;
      print('      ✅ Issuer: $issuer');

      print('   🔧 Checking JWTConfig.audience...');
      final audience = JWTConfig.audience;
      print('      ✅ Audience: $audience');

      print('   🔧 Checking JWTConfig.qrTokenType...');
      final qrTokenType = JWTConfig.qrTokenType;
      print('      ✅ QR Token Type: $qrTokenType');

    } catch (e) {
      print('   ❌ JWTConfig Test FAILED: $e');
      rethrow;
    }
  }

  void _testSecretKey() {
    try {
      print('   🔐 Testing JWTConfig.secretKey...');
      final secretKey = JWTConfig.secretKey;
      print('      ✅ Secret Key Length: ${secretKey.length} chars');
      print('      🔐 Secret Key Preview: "${secretKey.substring(0, min)}..."');

      if (secretKey.isEmpty) {
        throw Exception('Secret key is empty!');
      }
      if (secretKey.length < 32) {
        print('      ⚠️ Warning: Secret key is shorter than recommended 32 chars');
      }

    } catch (e) {
      print('   ❌ Secret Key Test FAILED: $e');
      rethrow;
    }
  }

  void _testCryptoFunctions() {
    try {
      print('   🔐 Testing HMAC-SHA256...');
      final testData = 'test_data';
      final testSecret = 'test_secret';

      final key = utf8.encode(testSecret);
      final bytes = utf8.encode(testData);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);

      print('      ✅ HMAC-SHA256 working: ${digest.bytes.length} bytes');

      print('   🔐 Testing Base64 Encoding...');
      final testEncode = base64Url.encode(utf8.encode('test'));
      print('      ✅ Base64 Encoding working: $testEncode');

    } catch (e) {
      print('   ❌ Crypto Functions Test FAILED: $e');
      rethrow;
    }
  }

  void _selfTestTokenGeneration() {
    try {
      print('   🧪 Generating test token...');
      final testToken = generateQRToken('jwt_service_self_test');
      print('      ✅ Test token generated: ${testToken.length} chars');

      print('   🧪 Validating test token...');
      final validatedUserId = validateQRToken(testToken);
      print('      ✅ Test token validation: $validatedUserId');

      if (validatedUserId == 'jwt_service_self_test') {
        print('      ✅ Self-test PASSED!');
      } else {
        print('      ⚠️ Self-test: User ID mismatch');
      }

    } catch (e) {
      print('   ⚠️ Self-test had issues (but service will continue): $e');
      // 不自测失败不影响服务运行
    }
  }

  int get min => 0;

  /// 生成标准JWT token
  String generateToken({
    required String userId,
    required String type,
    Map<String, dynamic>? additionalClaims,
  }) {
    try {
      print('=== 🔐 JWTService.generateToken() START ===');
      print('📝 Parameters: userId=$userId, type=$type');

      final now = DateTime.now();
      final expiry = now.add(_getExpirationForType(type));

      // JWT Header
      final header = {
        'alg': JWTConfig.algorithm,
        'typ': JWTConfig.tokenType,
      };
      print('✅ Header created: $header');

      // JWT Payload
      final payload = {
        'sub': userId,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': expiry.millisecondsSinceEpoch ~/ 1000,
        'type': type,
        'iss': JWTConfig.issuer,
        'aud': JWTConfig.audience,
        ...?additionalClaims,
      };
      print('✅ Payload created: $payload');

      // 编码和签名
      print('🔄 Encoding header and payload...');
      final encodedHeader = _base64UrlEncode(json.encode(header));
      final encodedPayload = _base64UrlEncode(json.encode(payload));
      print('✅ Encoded Header: ${encodedHeader.length} chars');
      print('✅ Encoded Payload: ${encodedPayload.length} chars');

      print('✍️ Creating signature...');
      final signature = _createSignature('$encodedHeader.$encodedPayload');
      print('✅ Signature created: ${signature.length} chars');

      final token = '$encodedHeader.$encodedPayload.$signature';

      print('🎉 Token Generation SUCCESS!');
      print('📏 Total Token Length: ${token.length} chars');
      print('🔍 Token Preview: ${token.substring(0, min)}...');
      print('=== 🔐 generateToken() END ===');

      return token;

    } catch (e) {
      print('💥 Token Generation FAILED: $e');
      print('💥 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// 专门生成QR token的便捷方法
  String generateQRToken(String userId) {
    print('🔄 generateQRToken() called for user: $userId');
    final token = generateToken(
      userId: userId,
      type: JWTConfig.qrTokenType,
      additionalClaims: {
        'purpose': 'qr_authentication',
        'version': '1.0',
        'generated_at': DateTime.now().toIso8601String(),
      },
    );
    print('✅ generateQRToken() completed');
    return token;
  }

  /// 创建签名
  String _createSignature(String data) {
    print('   ✍️ _createSignature() START');
    print('   📝 Data to sign length: ${data.length} chars');

    try {
      print('   1. 🔑 Getting secret key...');
      final secret = JWTConfig.secretKey;
      print('      ✅ Secret key length: ${secret.length} chars');

      print('   2. 🔄 Encoding key and data...');
      final key = utf8.encode(secret);
      final bytes = utf8.encode(data);
      print('      ✅ Key bytes: ${key.length}');
      print('      ✅ Data bytes: ${bytes.length}');

      print('   3. 🔐 Creating HMAC-SHA256...');
      final hmac = Hmac(sha256, key);
      print('      ✅ HMAC created');

      print('   4. 📊 Generating digest...');
      final digest = hmac.convert(bytes);
      print('      ✅ Digest bytes: ${digest.bytes.length}');

      print('   5. 📄 Encoding signature...');
      final signature = _base64UrlEncodeBytes(digest.bytes);
      print('      ✅ Signature length: ${signature.length} chars');

      print('   ✍️ _createSignature() END');
      return signature;

    } catch (e) {
      print('   💥 _createSignature FAILED: $e');
      rethrow;
    }
  }

  /// 验证JWT token
  Map<String, dynamic>? validateToken(String token) {
    print('=== 🔍 JWTService.validateToken() START ===');
    print('🔍 Token length: ${token.length} chars');

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid token format: expected 3 parts, got ${parts.length}');
        return null;
      }
      print('✅ Token has 3 parts');

      final encodedHeader = parts[0];
      final encodedPayload = parts[1];
      final signature = parts[2];

      // 验证签名
      print('1. 🔐 Verifying signature...');
      final expectedSignature = _createSignature('$encodedHeader.$encodedPayload');
      if (signature != expectedSignature) {
        print('❌ Invalid signature');
        print('   Expected: ${expectedSignature.length} chars');
        print('   Actual: ${signature.length} chars');
        return null;
      }
      print('✅ Signature valid');

      // 解码payload
      print('2. 📖 Decoding payload...');
      final payloadJson = _base64UrlDecode(encodedPayload);
      final payload = json.decode(payloadJson) as Map<String, dynamic>;
      print('✅ Payload decoded: $payload');

      // 检查过期时间
      print('3. ⏰ Checking expiration...');
      final exp = payload['exp'] as int?;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (exp == null || now > exp) {
        print('❌ Token expired: exp=$exp, now=$now');
        return null;
      }
      print('✅ Token not expired');

      // 验证issuer和audience
      print('4. 🏷️ Verifying issuer and audience...');
      if (payload['iss'] != JWTConfig.issuer || payload['aud'] != JWTConfig.audience) {
        print('❌ Invalid issuer or audience');
        return null;
      }
      print('✅ Issuer and audience valid');

      print('🎉 Token Validation SUCCESS!');
      print('=== 🔍 validateToken() END ===');
      return payload;

    } catch (e) {
      print('💥 Token validation error: $e');
      return null;
    }
  }

  /// 专门验证QR token的便捷方法
  String? validateQRToken(String token) {
    print('🔄 validateQRToken() called');

    try {
      final payload = validateToken(token);

      if (payload != null) {
        final type = payload['type'] as String?;
        if (type != JWTConfig.qrTokenType) {
          print('❌ Invalid token type for QR: $type');
          return null;
        }

        final userId = payload['sub'] as String?;
        if (userId != null) {
          print('✅ QR token valid for user: $userId');
          return userId; // 直接返回用户ID字符串
        } else {
          print('❌ User ID not found in token');
          return null;
        }
      }

      print('❌ QR token validation failed');
      return null;

    } catch (e) {
      print('💥 Error in validateQRToken: $e');
      return null;
    }
  }

  /// 从token中提取用户ID
  String? getUserIdFromToken(String token) {
    final payload = validateToken(token);
    return payload?['sub'] as String?;
  }

  /// 检查token是否即将过期
  bool isTokenExpiringSoon(String token) {
    try {
      final payload = validateToken(token);
      if (payload == null) return true;

      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeLeft = exp - now;

      return timeLeft <= 10;
    } catch (e) {
      return true;
    }
  }

  /// 获取QR token剩余时间
  int getQRTokenRemainingTime(String token) {
    try {
      final payload = validateToken(token);
      if (payload == null) return 0;

      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeLeft = exp - now;

      return timeLeft > 0 ? timeLeft : 0;
    } catch (e) {
      return 0;
    }
  }

  // 私有方法
  Duration _getExpirationForType(String type) {
    final duration = switch (type) {
      JWTConfig.qrTokenType => JWTConfig.qrTokenExpiration,
      JWTConfig.refreshTokenType => JWTConfig.refreshTokenExpiration,
      _ => JWTConfig.accessTokenExpiration,
    };
    print('   ⏰ Expiration for type "$type": $duration');
    return duration;
  }

  String _base64UrlEncode(String text) {
    final encoded = base64Url.encode(utf8.encode(text)).replaceAll('=', '');
    return encoded;
  }

  String _base64UrlEncodeBytes(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _base64UrlDecode(String text) {
    final padded = text.padRight((text.length + 3) & ~3, '=');
    return utf8.decode(base64Url.decode(padded));
  }

  /// 调试方法：检查服务状态
  void debugServiceStatus() {
    print('=== 🛠️ JWTService Debug Status ===');
    print('✅ Initialized: $_isInitialized');
    print('✅ Secret Key Length: ${JWTConfig.secretKey.length}');
    print('✅ Algorithm: ${JWTConfig.algorithm}');
    print('=== 🛠️ Debug End ===');
  }
}