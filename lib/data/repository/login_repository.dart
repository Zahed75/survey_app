import 'package:survey_app/data/network/login_api_service.dart';

class LoginRepository {
  final _api = LoginApiService();

  /// Returns a normalized user map (includes access_token, refresh_token, etc.)
  Future<Map<String, dynamic>> loginUser(String phone, String password) async {
    final response = await _api.login(phone, password);
    final data = response.data;

    // Accepts both: { user: [ {...} ] } or { data: { user: {...} } } or legacy shapes
    if (data is Map) {
      if (data['user'] is List && (data['user'] as List).isNotEmpty) {
        return Map<String, dynamic>.from(data['user'][0]);
      }
      if (data['user'] is Map) {
        return Map<String, dynamic>.from(data['user']);
      }
      if (data['data'] is Map && data['data']['user'] is Map) {
        return Map<String, dynamic>.from(data['data']['user']);
      }
    }

    throw Exception('Unexpected login response shape');
  }
}
