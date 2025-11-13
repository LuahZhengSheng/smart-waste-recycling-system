// import 'package:get/get.dart';
//
// import '../../../config/jwt_config.dart';
// import 'jwt_service.dart';
//
// /// Service for generating and validating JWT tokens specifically for QR codes
// class QRJWTService extends GetxService {
//   static QRJWTService get instance => Get.find();
//   final JWTService _jwtService = Get.find<JWTService>();
//
//   /// Generate JWT token for QR code
//   String generateQRToken(String userId) {
//     return _jwtService.generateToken(
//       userId: userId,
//       type: JWTConfig.qrTokenType,
//       additionalClaims: {
//         'purpose': 'qr_authentication',
//         'version': '1.0',
//       },
//     );
//   }
//
//   /// Validate QR JWT token and extract user ID
//   String? validateQRToken(String token) {
//     final payload = _jwtService.validateToken(token);
//
//     // Additional validation for QR tokens
//     if (payload != null) {
//       final type = payload['type'] as String?;
//       if (type != JWTConfig.qrTokenType) {
//         print('❌ Invalid token type for QR');
//         return null;
//       }
//
//       return payload['sub'] as String?;
//     }
//
//     return null;
//   }
//
//   /// Check if QR token is about to expire
//   bool isQRTokenExpiringSoon(String token) {
//     return _jwtService.isTokenExpiringSoon(token);
//   }
//
//   /// Get remaining time for QR token in seconds
//   int getRemainingTime(String token) {
//     try {
//       final payload = _jwtService.validateToken(token);
//       if (payload == null) return 0;
//
//       final exp = payload['exp'] as int;
//       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       final timeLeft = exp - now;
//
//       return timeLeft > 0 ? timeLeft : 0;
//     } catch (e) {
//       return 0;
//     }
//   }
// }