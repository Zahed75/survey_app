import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';

class SurveyRepository {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static const String _base = 'https://survey-backend.shwapno.app';
  final _box = GetStorage();

  String? get _token => AuthService.instance.getToken();

  /// Uses new optimized API. If a site is selected, sends `?site_code=...`
  Future<List<dynamic>> fetchUserSurveys() async {
    final siteCode = (_box.read('selected_site_code') as String?)?.trim();
    final resp = await _dio.get(
      '$_base/survey/api/survey_by_user/',
      queryParameters:
      (siteCode != null && siteCode.isNotEmpty) ? {'site_code': siteCode} : null,
      options: Options(headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      }),
    );

    if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
      final data = (resp.data as Map<String, dynamic>)['data'];
      if (data is List) return List<dynamic>.from(data);
    }

    throw Exception('Failed to load surveys');
  }
}
