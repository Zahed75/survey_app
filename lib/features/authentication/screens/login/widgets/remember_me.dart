import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_app/features/authentication/controllers/login/login_controller.dart';

class URememberMeCheckbox extends StatelessWidget {
  const URememberMeCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Obx(
      () => Row(
        children: [
          Checkbox(
            value: controller.rememberMe.value,
            onChanged: (value) => controller.rememberMe.value = value ?? false,
          ),
          const Text("Remember Me"),
        ],
      ),
    );
  }
}
