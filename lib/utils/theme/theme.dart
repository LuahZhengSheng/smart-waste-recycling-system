import 'package:flutter/material.dart';
import 'package:fyp/utils/theme/custom_themes/appbar_theme.dart';
import 'package:fyp/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:fyp/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:fyp/utils/theme/custom_themes/chip_theme.dart';
import 'package:fyp/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:fyp/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:fyp/utils/theme/custom_themes/text_field_theme.dart';
import 'package:fyp/utils/theme/custom_themes/text_theme.dart';

/// -- Light & Dark App Themes
class MyAppTheme {
  MyAppTheme._();

  /// -- Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: MyAppBarTheme.lightAppBarTheme,
    textTheme: MyTextTheme.lightTextTheme,
    chipTheme: MyChipTheme.lightChipTheme,
    checkboxTheme: MyCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: MyBottomSheetTheme.lightBottomSheetTheme,
    inputDecorationTheme: MyTextFormFieldTheme.lightInputDecorationTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: MyOutlinedButtonTheme.lightOutlinedButtonTheme
  );

  /// -- Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: MyAppBarTheme.darkAppBarTheme,
    textTheme: MyTextTheme.darkTextTheme,
    chipTheme: MyChipTheme.darkChipTheme,
    checkboxTheme: MyCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: MyBottomSheetTheme.darkBottomSheetTheme,
    inputDecorationTheme: MyTextFormFieldTheme.darkInputDecorationTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: MyOutlinedButtonTheme.darkOutlinedButtonTheme
  );
}