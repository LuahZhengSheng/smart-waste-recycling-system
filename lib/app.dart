import 'package:flutter/material.dart';
import 'package:fyp/bindings/general_bindings.dart';
import 'package:fyp/features/authentication/screens/onboarding/onboarding.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/theme/theme.dart';
import 'package:get/get.dart';

/// -- Use this Class to setup themes, initial Bindings, any animations and much more using Material Widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: MyAppTheme.lightTheme,
      darkTheme: MyAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      /// Show Loader or Circular Progress Indicator meanwhile Authentication Repository is deciding to show relevant screen
      home: const Scaffold(backgroundColor: MyColors.primary, body: Center(child: CircularProgressIndicator(color: Colors.white))),
    );
  }
}
