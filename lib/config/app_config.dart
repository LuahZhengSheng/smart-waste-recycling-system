class AppConfig {
  static String get appName => 'SaveEarth App';
  static String get version => '1.0.0';

  /// Get environment-based configuration
  static bool get isProduction => bool.fromEnvironment('dart.vm.product');

  static String get environment {
    return isProduction ? 'Production' : 'Development';
  }
}