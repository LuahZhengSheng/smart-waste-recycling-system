import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/app.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'config/env_config.dart';
import 'data/services/notification/fcm_service.dart';
import 'data/services/qr_code/jwt_service.dart';
import 'features/personalization/controllers/qr_controller.dart';

void mainApp() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  print('🚀 Initializing environment configuration...');
  await EnvConfig.initialize();

  /// -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthenticationRepository(), permanent: true);

  /// -- Initialize FCM Service for push notifications
  await FCMService().initialize();

  /// -- Initialize other services
  await initializeServices();

  // 等待确保 JWTService 完全初始化
  await Future.delayed(Duration(milliseconds: 100));

  runApp(const App());
}

Future<void> initializeServices() async {
  print('=== 🚀 SERVICE INITIALIZATION START ===');

  // 确保环境变量已加载
  if (!_isEnvConfigInitialized()) {
    print('⚠️ EnvConfig not initialized, attempting to load...');
    await EnvConfig.initialize();
  }

  print('1. 🔧 Initializing JWTService...');
  Get.put(JWTService(), permanent: true);

  // 等待JWTService完全初始化
  await Future.delayed(Duration(milliseconds: 500));

  print('2. 🔧 Initializing QRController...');
  Get.put(QRController(), permanent: true);

  print('✅ All services initialized successfully');
  _verifyAllServices();
}

bool _isEnvConfigInitialized() {
  try {
    // 尝试访问一个环境变量来检查是否已初始化
    final testKey = EnvConfig.jwtSecretKey;
    return testKey.isNotEmpty;
  } catch (e) {
    return false;
  }
}

void _verifyAllServices() {
  print('=== 🔍 FINAL SERVICE VERIFICATION ===');

  final services = [
    'JWTService',
    'QRController',
    'AuthenticationRepository',
  ];

  for (final service in services) {
    final isRegistered = Get.isRegistered(tag: service);
    print('${isRegistered ? '✅' : '❌'} $service: $isRegistered');
  }

  // 功能测试
  try {
    final jwtService = Get.find<JWTService>();
    final qrController = Get.find<QRController>();

    print('✅ Service functionality: PASSED');
    print('✅ JWTService: ${jwtService.runtimeType}');
    print('✅ QRController: ${qrController.runtimeType}');

  } catch (e) {
    print('❌ Service functionality: FAILED - $e');
  }

  print('=== 🔍 VERIFICATION COMPLETE ===');
}

// void _verifyServices() {
//   print('🔍 FINAL SERVICE VERIFICATION:');
//   print('   JWTService: ${Get.isRegistered<JWTService>()}');
//   print('   QRController: ${Get.isRegistered<QRController>()}');
//
//   try {
//     final jwtService = Get.find<JWTService>();
//     final qrController = Get.find<QRController>();
//     print('   ✅ Both services accessible');
//   } catch (e) {
//     print('   ❌ Service access failed: $e');
//   }
// }

// 在 main.dart 的 initializeServices() 中
// void initializeServices() {
//   print('=== 🚀 SERVICE INITIALIZATION START ===');
//
//   print('1. 🔧 Initializing JWTService...');
//   Get.put(JWTService(), permanent: true);
//
//   // 等待JWTService完全初始化
//   Future.delayed(Duration(milliseconds: 1000), () {
//     print('2. 🔧 Initializing QRController...');
//     Get.put(QRController(), permanent: true);
//
//     print('✅ All services initialized successfully');
//     _verifyAllServices();
//   });
// }

// void _verifyAllServices() {
//   print('=== 🔍 FINAL SERVICE VERIFICATION ===');
//
//   final services = [
//     'JWTService',
//     'QRController',
//     'AuthenticationRepository',
//   ];
//
//   for (final service in services) {
//     final isRegistered = Get.isRegistered(tag: service);
//     print('${isRegistered ? '✅' : '❌'} $service: $isRegistered');
//   }
//
//   // 功能测试
//   try {
//     final jwtService = Get.find<JWTService>();
//     final qrController = Get.find<QRController>();
//
//     print('✅ Service functionality: PASSED');
//     print('✅ JWTService: ${jwtService.runtimeType}');
//     print('✅ QRController: ${qrController.runtimeType}');
//
//   } catch (e) {
//     print('❌ Service functionality: FAILED - $e');
//   }
//
//   print('=== 🔍 VERIFICATION COMPLETE ===');
// }
