import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:survey_app/features/authentication/controllers/login/login_controller.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';

class ULoginForm extends StatelessWidget {
  const ULoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Phone Number
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.direct_right),
              prefixText: '+88 ',
              labelText: UTexts.number,
              counterText: '', // Hide counter
            ),
          ),
          const SizedBox(height: USizes.spaceBtwInputFields),

          /// Password
          TextFormField(
            controller: controller.passwordController,
            obscureText: controller.hidePassword.value,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.password_check),
              labelText: UTexts.password,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.hidePassword.value
                      ? Iconsax.eye
                      : Iconsax.eye_slash,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
