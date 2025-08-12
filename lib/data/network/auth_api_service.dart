import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.shwapno.app'));

  Future<Response> registerUser(Map<String, dynamic> body) async {
    return await _dio.post('/api/user/register', data: body);
  }

  Future<Response> verifyOtp(String phone, String otp) async {
    return await _dio.post(
      '/api/verify-otp',
      data: {"phone_number": phone, "otp": otp},
    );
  }
}
