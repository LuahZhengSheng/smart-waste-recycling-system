import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/app.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/firebase_options.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'data/services/notification/fcm_service.dart';

void mainApp() async {
  /// Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// -- GetX Local Storage
  await GetStorage.init();

  /// -- Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then(
        (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );

  /// -- Initialize FCM Service for push notifications
  await FCMService().initialize();

  // Load all the Material Design / Themes / Localizations / Bindings
  runApp(const App());
}

// class App extends StatelessWidget {
//   const App({super.key});
//
//   // This widgets is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: FAppTheme.lightTheme,
//       darkTheme: FAppTheme.darkTheme,
//     );
//
//     // return GetMaterialApp(
//     //   debugShowCheckedModeBanner: false,
//     //   home: const SplashScreen(),
//     // );
//   }
// }
