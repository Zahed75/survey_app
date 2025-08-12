import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:survey_app/common/widgets/button/elevated_button.dart';
import 'package:survey_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:survey_app/utils/constants/sizes.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Positioned(
      left: 0,
      right: 0,

      bottom: USizes.spaceBtwItems * 7,
      child: UElevatedButton(
        onPressed: controller.nextPage,
        child: Obx(
          () =>
              Text(controller.currentIndex.value == 2 ? 'Get Started' : "Next"),
        ),
      ),
    );
  }
}
