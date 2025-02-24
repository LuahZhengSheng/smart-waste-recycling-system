import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/signup/signup_controller.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class MyTermsAndConditionCheckbox extends StatelessWidget {
  const MyTermsAndConditionCheckbox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final dark = MyHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(() => Checkbox(
            value: controller.privacyPolicy.value,
            onChanged: (value) => controller.privacyPolicy.value = !controller.privacyPolicy.value))),
        const SizedBox(width: MySizes.spaceBtwItems),
        Text.rich(
          TextSpan(
              children: [
                TextSpan(text: '${MyTexts.iAgreeTo} ', style: Theme.of(context).textTheme.bodySmall),
                TextSpan(text: MyTexts.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? MyColors.white : MyColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? MyColors.white : MyColors.primary,
                )),
                TextSpan(text: ' ${MyTexts.and} ', style: Theme.of(context).textTheme.bodySmall),
                TextSpan(text: '${MyTexts.termsOfUse} ', style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? MyColors.white : MyColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: dark ? MyColors.white : MyColors.primary,
                )),
              ]
          ),
        ),
      ],
    );
  }
}
