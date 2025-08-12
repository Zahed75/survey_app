import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_app/common/styles/padding.dart';
import 'package:survey_app/common/widgets/button/elevated_button.dart';
import 'package:survey_app/features/authentication/controllers/login/login_controller.dart';
import 'package:survey_app/features/authentication/screens/forgot_password/forget_password.dart';
import 'package:survey_app/features/authentication/screens/login/widgets/login_form.dart';
import 'package:survey_app/features/authentication/screens/login/widgets/login_header.dart';
import 'package:survey_app/features/authentication/screens/login/widgets/remember_me.dart';
import 'package:survey_app/features/authentication/screens/signup/signUp.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';

import '../../../../data/services/update_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController());

  String appVersion = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();

    // 🔁 Run update check after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UpdateService.forceUpdateIfAvailable(context);

      // ⬇️ Fetch version info and set state
      final result = await UpdateService.fetchAppVersion();
      if (result != null) {
        setState(() {
          appVersion = result['version'] ?? '';
          buildNumber = '+${result['buildNumber'] ?? ''}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: UPadding.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: USizes.spaceBtwSections * 2),
                const Center(
                  child: Image(
                    image: AssetImage('assets/icons/circleIcon.png'),
                    height: 80,
                    width: 80,
                  ),
                ),
                SizedBox(height: USizes.spaceBtwSections * 2.4),
                const ULoginHeader(),
                const SizedBox(height: USizes.spaceBtwSections),
                const ULoginForm(),
                const SizedBox(height: USizes.spaceBtwInputFields / 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    URememberMeCheckbox(),
                    TextButton(
                      onPressed: () => Get.to(() => ForgetPasswordScreen()),
                      child: const Text(UTexts.forgetPassword),
                    ),
                  ],
                ),
                const SizedBox(height: USizes.spaceBtwSections),
                UElevatedButton(
                  onPressed: controller.loginUser,
                  child: Obx(
                        () => controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(UTexts.signIn),
                  ),
                ),
                const SizedBox(height: USizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => SignUpScreen()),
                    child: const Text(UTexts.createAccount),
                  ),
                ),

                /// 👇 App Version Info (minimal addition)
                const SizedBox(height: USizes.spaceBtwSections),
                if (appVersion.isNotEmpty)
                  Center(
                    child: Text(
                      'v$appVersion • Build $buildNumber',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

