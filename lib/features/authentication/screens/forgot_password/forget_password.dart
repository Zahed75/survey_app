import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:iconsax/iconsax.dart';
import 'package:survey_app/common/styles/padding.dart';
import 'package:survey_app/common/widgets/button/elevated_button.dart';
import 'package:survey_app/features/authentication/screens/forgot_password/reset_password.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: UPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              UTexts.forgetPassword,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: USizes.spaceBtwItems / 2),

            /// Subtitle
            Text(
              UTexts.forgetPasswordSubTitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: USizes.spaceBtwSections * 2),
            Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: UTexts.email,
                    prefixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
                SizedBox(height: USizes.spaceBtwItems),
                UElevatedButton(
                  onPressed: () => Get.to(() => ResetPasswordScreen()),
                  child: Text(UTexts.submit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
