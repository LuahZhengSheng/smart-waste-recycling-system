import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/login/login_controller.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class MySocialButtons extends StatelessWidget {
  const MySocialButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
              onPressed: () => controller.googleSignIn(),
              icon: const Image(
                width: MySizes.iconMd,
                height: MySizes.iconMd,
                image: AssetImage(MyImages.google),
              )),
        ),
        const SizedBox(width: MySizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
              onPressed: () => controller.facebookSignIn(),
              icon: const Image(
                width: MySizes.iconMd,
                height: MySizes.iconMd,
                image: AssetImage(MyImages.facebook),
              )),
        ),
      ],
    );
  }
}