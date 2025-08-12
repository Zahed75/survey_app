import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:survey_app/data/repository/otp_repository.dart';
import 'package:survey_app/navigation_menu.dart';

class OtpController extends GetxController {
  final storage = const FlutterSecureStorage();
  final _repo = OtpRepository();

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final data = await _repo.verifyOtp(phoneNumber: phoneNumber, otp: otp);

      // Save verified user info
      await storage.write(key: 'user', value: data['user'].toString());

      Get.snackbar('Success', 'OTP Verified');
      Get.offAll(() => const NavigationMenu());
    } catch (e) {
      Get.snackbar(
        'Verification Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
