import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

class EnvConfig {
  static bool _initialized = false;
  static bool _usingFallback = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 Loading environment configuration...');
      await _loadEnvFile();
      _initialized = true;
      print('✅ Environment configuration loaded successfully');

    } catch (e) {
      print('❌ Environment configuration failed: $e');
      _usingFallback = true;
      _initialized = true;
      print('🔄 Using fallback values');
    }
  }

  static Future<void> _loadEnvFile() async {
    try {
      // 从 assets 加载
      await dotenv.load(fileName: "assets/.env");
      print('✅ .env file loaded');

      // 验证必需变量
      _validateRequiredVariables();

    } catch (e) {
      print('❌ Failed to load .env: $e');
      rethrow;
    }
  }

  static void _validateRequiredVariables() {
    final requiredVars = {
      'JWT_SECRET_KEY': 'T5cxX81iKPRQMGkfNJsXhH5Jlqh9p4Y1OUoZnIodGFfnZ2szX30sYKC957RPTRiohIDh827D+X8MKCJLqdQTWQ==',
      'BASE_URL': 'https://api.saveearth.com',
      'API_KEY': 'saveearth_api_key_2024',
      'API_SECRET': 'saveearth_api_secret_2024',
      'GOOGLE_PLACES_API_KEY': 'MyAPI',
    };

    for (final entry in requiredVars.entries) {
      final key = entry.key;
      final fallback = entry.value;

      try {
        var value = dotenv.get(key);

        // 如果值为空，使用回退值
        if (value.isEmpty) {
          print('⚠️ $key is empty, using fallback');
          dotenv.env[key] = fallback;
        } else {
          // 清理值（移除空格等）
          value = value.trim();
          if (value.contains(' ')) {
            print('⚠️ $key contains spaces, using fallback');
            dotenv.env[key] = fallback;
          } else {
            print('✅ $key: ${value.substring(0, min)}...');
          }
        }
      } catch (e) {
        print('⚠️ $key not found, using fallback');
        dotenv.env[key] = fallback;
      }
    }
  }

  static int get min => 0;

  // Getter 方法
  static String get jwtSecretKey => _getKey('JWT_SECRET_KEY');
  static String get baseUrl => _getKey('BASE_URL');
  static String get apiKey => _getKey('API_KEY');
  static String get apiSecret => _getKey('API_SECRET');
  static String get googlePlacesApiKey => _getKey('GOOGLE_PLACES_API_KEY');
  static bool get debug => _getBool('DEBUG', true);

  static String _getKey(String key) {
    if (!_initialized) {
      throw Exception('EnvConfig not initialized. Call initialize() first.');
    }

    try {
      return dotenv.get(key);
    } catch (e) {
      print('⚠️ Error getting $key: $e');
      // 返回安全的回退值
      return _getFallbackValue(key);
    }
  }

  static String _getFallbackValue(String key) {
    final fallbacks = {
      'JWT_SECRET_KEY': 'T5cxX81iKPRQMGkfNJsXhH5Jlqh9p4Y1OUoZnIodGFfnZ2szX30sYKC957RPTRiohIDh827D+X8MKCJLqdQTWQ==',
      'BASE_URL': 'https://api.saveearth.com',
      'API_KEY': 'saveearth_api_key_2024',
      'API_SECRET': 'saveearth_api_secret_2024',
      'GOOGLE_PLACES_API_KEY': 'MyAPI',
    };
    return fallbacks[key] ?? 'fallback_value';
  }

  static bool _getBool(String key, bool fallback) {
    try {
      if (!_initialized) return fallback;
      final value = dotenv.get(key, fallback: fallback.toString());
      return value.toLowerCase() == 'true';
    } catch (e) {
      return fallback;
    }
  }
}

class AppConfig {
  static String get appName => 'SaveEarth App';
  static String get version => '1.0.0';
}