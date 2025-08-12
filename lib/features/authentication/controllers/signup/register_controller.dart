import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_app/data/repository/auth_repository.dart';
import 'package:survey_app/features/authentication/screens/verify_otp/otp_verify.dart';
import '../../../../common/widgets/alerts/u_alert.dart';

class RegisterController extends GetxController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final staffId = TextEditingController();
  final designation = TextEditingController();
  final password = TextEditingController();
  final isLoading = false.obs;

  final _repo = AuthRepository();

  Future<void> registerUser() async {
    /// ✅ Human-readable, user-friendly validations

    if (name.text.trim().isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter your full name.",
        icon: Icons.person_outline,
        iconColor: Colors.red,
      );
      return;
    }

    if (email.text.trim().isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter your email address.",
        icon: Icons.email_outlined,
        iconColor: Colors.red,
      );
      return;
    }

    if (!GetUtils.isEmail(email.text.trim())) {
      UAlert.show(
        title: "Invalid Email",
        message: "Please enter a valid email address.",
        icon: Icons.email_outlined,
        iconColor: Colors.orange,
      );
      return;
    }

    if (phoneNumber.text.trim().isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter your phone number.",
        icon: Icons.phone_android_outlined,
        iconColor: Colors.red,
      );
      return;
    }

    if (phoneNumber.text.trim().length != 11) {
      UAlert.show(
        title: "Invalid Phone",
        message: "Phone number must be exactly 11 digits.",
        icon: Icons.phone_android_outlined,
        iconColor: Colors.orange,
      );
      return;
    }

    if (staffId.text.trim().isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter your Staff ID.",
        icon: Icons.badge_outlined,
        iconColor: Colors.red,
      );
      return;
    }

    if (int.tryParse(staffId.text.trim()) == null) {
      UAlert.show(
        title: "Invalid ID",
        message: "Staff ID should be numeric (e.g. 6 digits).",
        icon: Icons.badge_outlined,
        iconColor: Colors.orange,
      );
      return;
    }

    if (designation.text.trim().isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please select your designation.",
        icon: Icons.work_outline,
        iconColor: Colors.red,
      );
      return;
    }

    if (password.text.trim().isEmpty) {
      UAlert.show(
        title: "Required",
        message: "Please enter a password.",
        icon: Icons.lock_outline,
        iconColor: Colors.red,
      );
      return;
    }

    // if (password.text.trim().length < 6) {
    //   UAlert.show(
    //     title: "Weak Password",
    //     message: "Password must be at least 6 characters long.",
    //     icon: Icons.lock_outline,
    //     iconColor: Colors.orange,
    //   );
    //   return;
    // }

    try {
      isLoading.value = true;

      final body = {
        "name": name.text.trim(),
        "phone_number": phoneNumber.text.trim(),
        "password": password.text.trim(),
        "email": email.text.trim(),
        "staff_id": int.tryParse(staffId.text.trim()) ?? 0,
        "designation": designation.text.trim(),
      };

      final data = await _repo.registerUser(body);

      if (data.containsKey("message")) {
        UAlert.show(
          title: "Success",
          message: data["message"],
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        );

        String otp = "12345";

        Get.to(() => OtpVerifyScreen(
          phoneNumber: phoneNumber.text.trim(),
          otp: otp,
        ));
      } else {
        UAlert.show(
          title: "Error",
          message: "Unexpected response from the server.",
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.redAccent,
        );
      }
    } catch (e) {
      if (e.toString().contains('DioException')) {
        try {
          final errorData = (e as dynamic).response?.data;
          final firstError = errorData.values.first;
          String errorMessage =
          firstError is List ? firstError.first : "$firstError";

          UAlert.show(
            title: "Server Error",
            message: errorMessage,
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        } catch (_) {
          UAlert.show(
            title: "Error",
            message: "Failed to read server error.",
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.red,
          );
        }
      } else {
        UAlert.show(
          title: "Error",
          message: e.toString().replaceAll("Exception:", "").trim(),
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    phoneNumber.dispose();
    staffId.dispose();
    designation.dispose();
    password.dispose();
    super.onClose();
  }
}
