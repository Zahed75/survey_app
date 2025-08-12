import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  static late AuthService instance;

  final _box = GetStorage();
  final _tokenKey = 'access_token';

  String? _token;
  late Dio dio;

  Future<AuthService> init() async {
    _token = _box.read(_tokenKey);
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://api.shwapno.app', // Set your base URL here
        headers: {
          'Authorization': 'Bearer $_token', // Attach the token to each request
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request to: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response from: ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Error on: ${e.requestOptions.uri}');
          return handler.next(e);
        },
      ),
    );
    AuthService.instance = this;
    print('✅ AuthService initialized. Token: $_token');
    return this;
  }


  Future<void> saveToken(String newToken, {bool remember = false}) async {
    _token = newToken;
    await _box.write(_tokenKey, newToken);
    await _box.write('remember_me', remember);

    dio.options.headers['Authorization'] = 'Bearer $newToken';
    print('🔐 Token saved: $newToken | remember=$remember');
  }


  String? getToken() {
    _token ??= _box.read(_tokenKey);
    print('📦 Retrieved token: $_token');
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    await _box.remove(_tokenKey);
    await _box.remove('remember_me');
    await _box.remove('user_info');
    await _box.remove('assigned_sites');
    await _box.remove('selected_site_code');
    await _box.remove('access_info');
    dio.options.headers['Authorization'] = ''; // Clear the token in Dio headers
    print('🧹 Token and user info cleared');
  }

  Future<bool> isLoggedIn() async {
    _token = _box.read(_tokenKey);
    final rememberMe = _box.read('remember_me') ?? false;
    print('🔍 Checking login: token=$_token, rememberMe=$rememberMe');
    return _token != null && rememberMe == true;
  }

  List<dynamic>? getUserAccessInfo() {
    final accessInfo = _box.read('access_info');
    print('🧾 Retrieved access_info: $accessInfo');
    return accessInfo;
  }
}
