import 'package:dio/dio.dart';
import 'package:survey_app/data/network/auth_api_service.dart';

class AuthRepository {
  final _api = AuthApiService();

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    final response = await _api.registerUser(body);
    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _api.verifyOtp(phone, otp);
      return response.data;
    } on DioException catch (e) {
      print('❌ OTP Error: ${e.response?.data}');
      throw Exception(
        e.response?.data?['message'] ?? 'OTP verification failed',
      );
    }
  }
}
