// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get_storage/get_storage.dart';
// import '../services/auth_service.dart';
//
// class SurveyRepository {
//   final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(seconds: 15),
//     receiveTimeout: const Duration(seconds: 30),
//   ));
//
//   static const String _base = 'https://survey-backend.shwapno.app';
//   final _box = GetStorage();
//
//   String? get _token => AuthService.instance.getToken();
//
//   /// Uses new optimized API. If a site is selected, sends `?site_code=...`
//   // Future<List<dynamic>> fetchUserSurveys() async {
//   //   final siteCode = (_box.read('selected_site_code') as String?)?.trim();
//   //   final resp = await _dio.get(
//   //     '$_base/survey/api/survey_by_user/',
//   //     queryParameters:
//   //     (siteCode != null && siteCode.isNotEmpty) ? {'site_code': siteCode} : null,
//   //     options: Options(headers: {
//   //       'Authorization': 'Bearer $_token',
//   //       'Accept': 'application/json',
//   //     }),
//   //   );
//   //
//   //   if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
//   //     final data = (resp.data as Map<String, dynamic>)['data'];
//   //     if (data is List) return List<dynamic>.from(data);
//   //   }
//   //
//   //   throw Exception('Failed to load surveys');
//   // }
//
//
// // survey_repository.dart
//
//   Future<List<dynamic>> fetchUserSurveys() async {
//     final siteCode = (GetStorage().read('selected_site_code') as String?)?.trim();
//     final tokenPresent = AuthService.instance.getToken()?.isNotEmpty == true;
//
//     debugPrint('[SurveyRepository] fetchUserSurveys site_code="$siteCode" '
//         'tokenPresent=$tokenPresent');
//
//     final resp = await _dio.get(
//       '$_base/survey/api/survey_by_user/',
//       queryParameters: (siteCode != null && siteCode.isNotEmpty)
//           ? {'site_code': siteCode}
//           : null,
//       options: Options(headers: {
//         'Authorization': 'Bearer ${AuthService.instance.getToken()}',
//         'Accept': 'application/json',
//       }),
//     );
//
//     debugPrint('[SurveyRepository] status=${resp.statusCode}');
//
//     if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
//       final map = resp.data as Map<String, dynamic>;
//       final data = map['data'];
//       final count = map['survey_count'];
//       final filtered = map['filtered_by_site_code'];
//       debugPrint('[SurveyRepository] survey_count=$count filtered_by="$filtered" '
//           'dataType=${data.runtimeType}');
//
//       if (data is List) return List<dynamic>.from(data);
//     }
//
//     debugPrint('[SurveyRepository] throw: Failed to load surveys');
//     throw Exception('Failed to load surveys');
//   }
//
// }





// survey_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class SurveyRepository {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static const String _base = 'https://survey-backend.shwapno.app';
  final _box = GetStorage();

  String? get _token => AuthService.instance.getToken();

  Future<List<dynamic>> fetchUserSurveys() async {
    final rawSite = (_box.read('selected_site_code') as String?) ?? '';
    final siteCode = rawSite.trim(); // don’t alter case here; just trim
    final token = _token;

    debugPrint('[SurveyRepository] fetchUserSurveys site_code="$siteCode" '
        'tokenPresent=${token != null && token.isNotEmpty}');

    Map<String, dynamic>? firstJson;

    // 1) Fast path: ask server to filter by site_code
    try {
      final resp = await _dio.get(
        '$_base/survey/api/survey_by_user/',
        queryParameters: siteCode.isNotEmpty ? {'site_code': siteCode} : null,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      debugPrint('[SurveyRepository] status=${resp.statusCode} (with site_code)');

      if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
        firstJson = resp.data as Map<String, dynamic>;
        final count = firstJson['survey_count'];
        final filtered = firstJson['filtered_by_site_code'];
        final data = firstJson['data'];

        debugPrint('[SurveyRepository] server says survey_count=$count '
            'filtered_by="$filtered" type=${data.runtimeType}');

        // If server already returned items, use them.
        if (data is List && data.isNotEmpty) {
          return List<dynamic>.from(data);
        }
      } else {
        debugPrint('[SurveyRepository] non-200 on first call -> ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('[SurveyRepository] first call error: $e');
      // continue to fallback
    }

    // 2) Fallback: fetch ALL surveys then filter locally by site_code
    //    (workaround for backend filter returning 0 unexpectedly)
    try {
      debugPrint('[SurveyRepository] fallback -> fetching unfiltered then local-filter…');

      final resp2 = await _dio.get(
        '$_base/survey/api/survey_by_user/',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      debugPrint('[SurveyRepository] fallback status=${resp2.statusCode}');

      if (resp2.statusCode == 200 && resp2.data is Map<String, dynamic>) {
        final map2 = resp2.data as Map<String, dynamic>;
        final data2 = map2['data'];

        if (data2 is List) {
          // normalize compare: trim on both sides, case-insensitive
          final want = siteCode.toLowerCase();
          final filteredList = data2.where((item) {
            try {
              final it = (item as Map<String, dynamic>);
              final sc = (it['site_code'] ?? '').toString().trim().toLowerCase();
              return want.isEmpty ? true : sc == want;
            } catch (_) {
              return false;
            }
          }).toList();

          debugPrint('[SurveyRepository] fallback filtered '
              '${filteredList.length} / ${data2.length} for "$siteCode"');

          return filteredList;
        }
      }
    } catch (e) {
      debugPrint('[SurveyRepository] fallback error: $e');
    }

    // Nothing found either path
    debugPrint('[SurveyRepository] returning empty list (no surveys found)');
    return const <dynamic>[];
  }
}
