import 'package:flutter/material.dart';
import 'package:fyp/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:fyp/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:fyp/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:fyp/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:fyp/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: MyImages.onBoardingImage1,
                title: MyTexts.onBoardingTitle1,
                subTitle: MyTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: MyImages.onBoardingImage2,
                title: MyTexts.onBoardingTitle2,
                subTitle: MyTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: MyImages.onBoardingImage3,
                title: MyTexts.onBoardingTitle3,
                subTitle: MyTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          /// Skip Button
          const OnBoardingSkip(),

          /// Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          /// Circular Button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}








