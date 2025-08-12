import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:survey_app/features/authentication/screens/login/login.dart';
import 'package:get_storage/get_storage.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// variables

  final pageController = PageController();
  RxInt currentIndex = 0.obs;

  /// Update Current Index when page scroll

  void updatePageIndicator(index) {
    currentIndex.value = index;
  }

  /// Jump to specific dot selected page

  void dotNavigationClick(index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Update Current Index and jump to next page

  void nextPage() {
    final box = GetStorage(); // <-- Add this
    if (currentIndex.value == 2) {
      box.write(
        'onboardingSeen',
        true,
      ); // <-- Save flag to persist onboarding state
      Get.offAll(() => const LoginScreen());
    } else {
      currentIndex.value++;
      pageController.jumpToPage(currentIndex.value);
    }
  }

  /// Update Current Index and jump to the last Page
  void skipPage() {
    currentIndex.value = 2;
    pageController.jumpToPage(currentIndex.value);
  }
}
