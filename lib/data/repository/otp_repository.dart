import 'package:dio/dio.dart';

class OtpRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.shwapno.app'));

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await _dio.post(
      '/api/verify-otp',
      data: {"phone_number": phoneNumber, "otp": int.parse(otp)},
    );
    return response.data;
  }
}
