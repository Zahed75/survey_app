import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:survey_app/common/styles/padding.dart';
import 'package:survey_app/common/widgets/button/elevated_button.dart';
import 'package:survey_app/features/authentication/screens/login/login.dart';
import 'package:survey_app/utils/constants/images.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';
import 'package:survey_app/utils/helpers/device_helpers.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => LoginScreen()),
            icon: Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                UImages.mailSentImage,
                height: UDeviceHelper.getScreenWidth(context) * 0.6,
              ),
              SizedBox(height: USizes.spaceBtwItems),
              Text(
                UTexts.resetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: USizes.spaceBtwItems),
              Text(
                'example@gmail.com',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: USizes.spaceBtwItems),
              Text(
                UTexts.resetPasswordSubTitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: USizes.spaceBtwSections),
              UElevatedButton(onPressed: () {}, child: Text(UTexts.done)),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: Text(UTexts.resendEmail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
