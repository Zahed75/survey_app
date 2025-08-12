import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_app/common/widgets/alerts/u_alert.dart';
import 'package:survey_app/data/repository/login_repository.dart';
import 'package:survey_app/data/services/auth_service.dart';
import 'package:survey_app/features/site/controller/site_controller.dart';
import '../../../site/screens/site/home_site_location.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final rememberMe = false.obs;
  final hidePassword = true.obs;

  final _repo = LoginRepository();
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    final authService = Get.find<AuthService>();
    authService.isLoggedIn().then((loggedIn) async {
      if (loggedIn) {
        final siteController = Get.find<SiteController>();
        await siteController.fetchAssignedSitesFromToken();
        Get.offAll(() => const HomeSiteLocation(isSelectionMode: true));
      }
    });
  }

  Future<void> loginUser() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty) {
      UAlert.show(
        title: 'Validation Error',
        message: 'Phone number is required',
      );
      return;
    }

    if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(phone)) {
      UAlert.show(
        title: 'Validation Error',
        message: 'Enter a valid 11-digit phone number',
      );
      return;
    }

    if (password.isEmpty) {
      UAlert.show(title: 'Validation Error', message: 'Password is required');
      return;
    }

    try {
      isLoading.value = true;

      final data = await _repo.loginUser(phone, password);

      final authService = Get.find<AuthService>();
      await authService.saveToken(
        data['access_token'],
        remember: rememberMe.value,
      );
      await storage.write('user_info', data);

      final siteController = Get.find<SiteController>();
      await siteController.fetchAssignedSitesFromToken();

      Get.offAll(() => const HomeSiteLocation(isSelectionMode: true));
    } catch (e) {
      try {
        final errorData = (e as dynamic).response?.data;
        final firstError = errorData.values.first;
        String errorMessage = firstError is List
            ? firstError.first
            : "$firstError";
        UAlert.show(
          title: "Login Failed",
          message: errorMessage,
          bgColor: Colors.red.shade50,
        );
      } catch (_) {
        UAlert.show(
          title: "Login Failed",
          message: "An unexpected error occurred.",
          bgColor: Colors.red.shade50,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
