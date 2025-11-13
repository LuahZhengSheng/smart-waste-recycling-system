import 'env_config.dart';

class JWTConfig {
  // Secret Key from environment configuration
  static final String secretKey = EnvConfig.jwtSecretKey;

  // JWT Configuration
  static const String algorithm = 'HS256';
  static const String tokenType = 'JWT';

  // Token expiration times
  static const Duration accessTokenExpiration = Duration(minutes: 15);
  static const Duration refreshTokenExpiration = Duration(days: 7);
  static const Duration qrTokenExpiration = Duration(seconds: 30);

  // Token types
  static const String accessTokenType = 'access';
  static const String refreshTokenType = 'refresh';
  static const String qrTokenType = 'qr';

  // Standard claims
  static const String issuer = 'recycling_app';
  static const String audience = 'app_users';

  // Early expiration warning (1 minute before actual expiration)
  static const Duration expirationWarning = Duration(minutes: 1);
}