import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class UserRepository {
  final Dio _dio = Dio();
  final _box = GetStorage();

  /// ✅ Fetch user profile from API
  Future<UserModel> fetchUserProfile() async {
    final token = _box.read('access_token');
    print('📡 Fetching user profile with token: $token');

    final response = await _dio.get(
      'https://api.shwapno.app/api/user/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print('✅ fetchUserProfile response: ${response.data}');
    return UserModel.fromJson(response.data['data']['user']); // Adjust if needed
  }

  /// ✅ Update profile
  Future<UserModel> updateUserProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    final token = _box.read('access_token');

    final data = {
      "name": name,
      "email": email,
    };

    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }

    print('📤 Updating profile with data: $data');

    final response = await _dio.post(
      'https://api.shwapno.app/api/user/profile/update',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    print('✅ updateUserProfile response: ${response.data}');
    return UserModel.fromJson(response.data['data']['user']); // Adjust if needed
  }
}
