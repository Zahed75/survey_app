import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:survey_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:survey_app/features/authentication/screens/onboarding/widgets/onBoardingNextButton.dart';
import 'package:survey_app/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:survey_app/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:survey_app/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:survey_app/utils/constants/images.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: USizes.defaultSpace),
        child: Stack(
          children: [
            PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndicator,
              children: [
                OnBoardingPage(
                  animation: UImages.onboarding1Animation,
                  title: UTexts.onBoardingTitle1,
                  Subtitle: UTexts.onBoardingSubTitle1,
                ),
                OnBoardingPage(
                  animation: UImages.onboarding2Animation,
                  title: UTexts.onBoardingTitle2,
                  Subtitle: UTexts.onBoardingSubTitle2,
                ),
                OnBoardingPage(
                  animation: UImages.onboarding3Animation,
                  title: UTexts.onBoardingTitle3,
                  Subtitle: UTexts.onBoardingSubTitle3,
                ),
              ],
            ),

            /// Indicator
            OnBoardingDotNavigation(),

            /// Next Button
            OnBoardingNextButton(),

            /// Skip Button
            OnBoardingSkipButton(),
          ],
        ),
      ),
    );
  }
}
