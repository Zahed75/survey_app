// import 'package:dio/dio.dart';
// import 'package:get_storage/get_storage.dart';
// import '../models/site_model.dart';
//
// class SiteRepository {
//   final Dio _dio = Dio();
//   final _box = GetStorage();
//
//   String? get _token => _box.read('access_token');
//
//   /// 🔐 Get site codes user has access to
//   Future<List<String>> fetchAccessibleSiteCodes() async {
//     final response = await _dio.get(
//       'https://survey-backend.shwapno.app/survey/api/user/accessible-sites/',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       final accessInfo = response.data['access_info'] ?? [];
//       return accessInfo
//           .map<String>((e) => e['site']['site_code'].toString())
//           .toList();
//     } else {
//       throw Exception('Failed to load accessible site codes');
//     }
//   }
//
//   /// 🌐 Get full list of all sites
//   Future<List<Site>> fetchAllSites() async {
//     final response = await _dio.get(
//       'https://api.shwapno.app/api/sites',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer $_token',
//           'Accept': 'application/json',
//         },
//       ),
//     );
//
//     if (response.statusCode == 200) {
//       final rawData = response.data['data'];
//       if (rawData == null || rawData is! List) {
//         throw Exception('Invalid site list format');
//       }
//
//       return rawData.map<Site>((e) => Site.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load all sites');
//     }
//   }
// }





// survey_repository.dart
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

  String? get _authToken {
    // primary source
    final t = AuthService.instance.getToken();
    if (t != null && t.isNotEmpty) return t;
    // fallback (same value some parts of app write)
    final s = (_box.read('access_token') as String?)?.trim();
    return (s != null && s.isNotEmpty) ? s : null;
  }

  Future<List<dynamic>> fetchUserSurveys() async {
    // normalize site code before sending
    final raw = (_box.read('selected_site_code') as String?)?.trim();
    final siteCode = (raw == null || raw.isEmpty) ? null : raw.toUpperCase();

    final params = <String, dynamic>{
      // tiny cache-buster to avoid any proxy caching oddities
      't': DateTime.now().millisecondsSinceEpoch,
    };
    if (siteCode != null) params['site_code'] = siteCode;

    final token = _authToken;
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }

    final resp = await _dio.get(
      '$_base/survey/api/survey_by_user/',
      queryParameters: params,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
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

