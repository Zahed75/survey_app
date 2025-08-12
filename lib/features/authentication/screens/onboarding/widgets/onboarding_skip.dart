import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:survey_app/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:survey_app/utils/helpers/device_helpers.dart';

class OnBoardingSkipButton extends StatelessWidget {
  const OnBoardingSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Obx(
      () => controller.currentIndex.value == 2
          ? SizedBox()
          : Positioned(
              top: UDeviceHelper.getAppBarHeight(),
              right: 0,
              child: TextButton(
                onPressed: controller.skipPage,
                child: Text("Skip"),
              ),
            ),
    );
  }
}
