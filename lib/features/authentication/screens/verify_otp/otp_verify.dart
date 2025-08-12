import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:survey_app/data/repository/auth_repository.dart';
import 'package:survey_app/utils/constants/colors.dart';
import 'package:survey_app/utils/constants/images.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';

import '../../../../common/styles/padding.dart';
import '../../../../utils/helpers/device_helpers.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../../site/screens/site/home_site_location.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;
  final String? otp; // Add optional OTP parameter for autofill

  const OtpVerifyScreen({super.key, required this.phoneNumber, this.otp});

  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(
      text: widget.otp,
    ); // Auto-fill OTP if available

    // Automatically verify OTP if it's provided
    if (widget.otp != null) {
      _verifyOtp(widget.otp!); // Trigger OTP verification automatically
    }
  }

  Future<void> _verifyOtp(String otp) async {
    final authRepo = AuthRepository();

    try {
      final result = await authRepo.verifyOtp(widget.phoneNumber, otp);
      Get.snackbar("Success", result["message"]);

      // Navigate to HomeSiteLocation after successful OTP verification
      Get.offAll(
        () => HomeSiteLocation(isSelectionMode: false),
      ); // Navigate to HomeSiteLocation
    } catch (e) {
      Get.snackbar(
        "OTP Failed",
        e.toString().replaceAll("Exception:", "").trim(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = UHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
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
              /// Lottie Animation
              Image.asset(
                UImages.mailSentImage,
                height: UDeviceHelper.getScreenWidth(context) * 0.6,
              ),
              SizedBox(height: USizes.spaceBtwItems),

              /// Title
              Text(
                UTexts.verifyYourOtp,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: USizes.spaceBtwItems),

              /// Phone number display
              Text(
                '+88${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: USizes.spaceBtwItems),

              /// Subtitle
              Text(
                'Enter the 5-digit code sent to your number',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: USizes.spaceBtwSections),

              /// OTP Pinput with autofill
              Center(
                child: Pinput(
                  length: 5,
                  controller: _otpController, // Bind the OTP controller here
                  defaultPinTheme: PinTheme(
                    height: 56,
                    width: 56,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                    decoration: BoxDecoration(
                      color: dark ? UColors.darkGrey : UColors.light,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: UColors.primary),
                    ),
                  ),
                  onCompleted: (otp) async {
                    // Trigger OTP verification after completion
                    await _verifyOtp(otp); // Trigger verification
                  },
                ),
              ),

              const SizedBox(height: USizes.spaceBtwItems),

              /// Resend button
              TextButton(
                onPressed: () {
                  // TODO: Add resend logic here
                },
                child: Text(UTexts.resendOTP),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
