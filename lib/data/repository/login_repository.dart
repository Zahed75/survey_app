import 'package:survey_app/data/network/login_api_service.dart';

class LoginRepository {
  final _api = LoginApiService();

  Future<Map<String, dynamic>> loginUser(String phone, String password) async {
    final response = await _api.login(phone, password);
    return response.data;
  }
}
