import 'package:flutter/material.dart';
import 'package:survey_app/common/styles/padding.dart';
import 'package:survey_app/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///-----[Header]---///
              Text(
                UTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: USizes.spaceBtwSections),

              ///-----[Form]---///
              USignupForm(),
            ],
          ),
        ),
      ),
    );
  }
}
