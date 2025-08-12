import 'package:dio/dio.dart';

class LoginApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.shwapno.app'))
    ..interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

  Future<Response> login(String phone, String password) async {
    return await _dio.post(
      '/api/user/login',
      data: {"phone_number": phone, "password": password},
    );
  }
}
