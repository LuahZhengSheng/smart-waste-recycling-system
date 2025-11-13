// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:get/get.dart';
//
// /// Service for generating and validating JWT tokens for QR codes
// class QRService extends GetxController {
//   static QRService get instance => Get.find();
//
//   // Secret key for JWT signing (should be stored securely in production)
//   static const String _secretKey = 'your_secret_key_here_change_in_production';
//
//   // Token expiration time (30 seconds)
//   static const Duration _tokenExpiration = Duration(seconds: 30);
//
//   /// Generate JWT token for user
//   String generateToken(String userId) {
//     final now = DateTime.now();
//     final expiry = now.add(_tokenExpiration);
//
//     // Create JWT payload
//     final payload = {
//       'userId': userId,
//       'iat': now.millisecondsSinceEpoch,
//       'exp': expiry.millisecondsSinceEpoch,
//     };
//
//     // Encode payload
//     final payloadJson = json.encode(payload);
//     final payloadBase64 = base64Url.encode(utf8.encode(payloadJson));
//
//     // Create signature
//     final signature = _createSignature(payloadBase64);
//
//     // Combine to create token
//     return '$payloadBase64.$signature';
//   }
//
//   /// Validate JWT token and extract user ID
//   String? validateToken(String token) {
//     try {
//       final parts = token.split('.');
//       if (parts.length != 2) {
//         return null;
//       }
//
//       final payloadBase64 = parts[0];
//       final signature = parts[1];
//
//       // Verify signature
//       final expectedSignature = _createSignature(payloadBase64);
//       if (signature != expectedSignature) {
//         return null;
//       }
//
//       // Decode payload
//       final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
//       final payload = json.decode(payloadJson) as Map<String, dynamic>;
//
//       // Check expiration
//       final exp = payload['exp'] as int;
//       final now = DateTime.now().millisecondsSinceEpoch;
//       if (now > exp) {
//         return null; // Token expired
//       }
//
//       // Return user ID
//       return payload['userId'] as String;
//     } catch (e) {
//       return null;
//     }
//   }
//
//   /// Create HMAC-SHA256 signature
//   String _createSignature(String data) {
//     final key = utf8.encode(_secretKey);
//     final bytes = utf8.encode(data);
//     final hmac = Hmac(sha256, key);
//     final digest = hmac.convert(bytes);
//     return base64Url.encode(digest.bytes);
//   }
//
//   /// Check if token is about to expire (within 5 seconds)
//   bool isTokenExpiringSoon(String token) {
//     try {
//       final parts = token.split('.');
//       if (parts.length != 2) return true;
//
//       final payloadJson = utf8.decode(base64Url.decode(parts[0]));
//       final payload = json.decode(payloadJson) as Map<String, dynamic>;
//
//       final exp = payload['exp'] as int;
//       final now = DateTime.now().millisecondsSinceEpoch;
//       final timeLeft = exp - now;
//
//       return timeLeft <= 5000; // 5 seconds
//     } catch (e) {
//       return true;
//     }
//   }
// }