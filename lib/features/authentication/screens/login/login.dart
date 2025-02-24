import 'package:flutter/material.dart';
import 'package:fyp/common/styles/spacing_styles.dart';
import 'package:fyp/common/widgets/login_signup/form_divider.dart';
import 'package:fyp/common/widgets/login_signup/social_buttons.dart';
import 'package:fyp/features/authentication/screens/login/widgets/login_form.dart';
import 'package:fyp/features/authentication/screens/login/widgets/login_header.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: MySpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              const MyLoginHeader(),

              /// Form
              const MyLoginForm(),

              /// Divider
              MyFormDivider(dividerText: MyTexts.orSignInWith.capitalize!),
              const SizedBox(height: MySizes.spaceBtwSections),
              
              /// Footer
              const MySocialButtons()
            ],
          ),
        ),
      ),
    );
  }
}








