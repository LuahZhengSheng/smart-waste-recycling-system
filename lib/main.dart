import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fyp/app.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/firebase_options.dart';
import 'package:fyp/screens/splash_screen.dart';
import 'package:fyp/screens/wrapper.dart';
import 'package:fyp/utils/theme/theme.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
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

  // Load all the Material Design / Themes / Localizations / Bindings
  runApp(const App());
}

// class App extends StatelessWidget {
//   const App({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       themeMode: ThemeMode.system,
//       theme: MyAppTheme.lightTheme,
//       darkTheme: MyAppTheme.darkTheme,
//     );
//
//     // return GetMaterialApp(
//     //   debugShowCheckedModeBanner: false,
//     //   home: const SplashScreen(),
//     // );
//   }
// }
