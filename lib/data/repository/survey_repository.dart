import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';

class SurveyRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://survey-backend.shwapno.app',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final _box = GetStorage();

  String? get _authToken {
    // Prefer AuthService, fallback to storage
    final t = AuthService.instance.getToken();
    if (t != null && t.isNotEmpty) return t;
    final s = (_box.read('access_token') as String?)?.trim();
    return (s != null && s.isNotEmpty) ? s : null;
  }

  /// Public API consumed by SurveyController
  Future<List<dynamic>> fetchUserSurveys() async {
    // Read + normalize site code chosen in HomeSiteLocation
    final raw = (_box.read('selected_site_code') as String?) ?? '';
    final siteCode = raw.trim().toUpperCase();

    final token = _authToken;
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }

    if (siteCode.isEmpty) {
      debugPrint('[SurveyRepository] No selected_site_code -> returning []');
      return const <dynamic>[];
    }

    debugPrint(
      '[SurveyRepository] filtered request -> site="$siteCode", tokenPresent=${token.isNotEmpty}',
    );

    // Always call the filtered endpoint. Don’t throw on 403 — handle below.
    final resp = await _dio.get(
      '/survey/api/survey_by_user/',
      queryParameters: {
        'site_code': siteCode,
        // tiny cache-buster
        't': DateTime.now().millisecondsSinceEpoch,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        // Accept any <500 so we can interpret 403/404 gracefully
        validateStatus: (status) => (status ?? 0) < 500,
      ),
    );

    debugPrint('[SurveyRepository] filtered status=${resp.statusCode} site="$siteCode"');

    // === Handle common statuses deterministically ===
    if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
      final map = resp.data as Map<String, dynamic>;
      final data = map['data'];

      // Defensive: if backend already filtered correctly, just return.
      if (data is List) {
        // Optional: reinforce site_code match if the payload may be mixed
        final confirmed = _filterBySiteCode(data, siteCode);
        debugPrint(
          '[SurveyRepository] server says survey_count=${map['survey_count']} '
              'filtered_by="${map['filtered_by_site_code']}" '
              '→ returning ${confirmed.length}',
        );
        return confirmed;
      }

      // Unexpected payload
      debugPrint('[SurveyRepository] 200 but data is not a List -> []');
      return const <dynamic>[];
    }

    if (resp.statusCode == 204) {
      // No content for this site
      debugPrint('[SurveyRepository] 204 No Content for "$siteCode" -> []');
      return const <dynamic>[];
    }

    if (resp.statusCode == 403) {
      // Token has no access for this site on the survey endpoint
      debugPrint(
        '[SurveyRepository] 403 for site "$siteCode" — user does not have survey access for this outlet.',
      );
      return const <dynamic>[]; // show “No surveys available” in UI
    }

    if (resp.statusCode == 404) {
      debugPrint('[SurveyRepository] 404 for "$siteCode" -> []');
      return const <dynamic>[];
    }

    // Anything else we treat as a hard error so it’s visible during QA
    throw Exception(
      'Failed to load surveys (status=${resp.statusCode}) for site "$siteCode"',
    );
  }

  /// Extract a normalized set of site codes present on an item
  Set<String> _extractSiteCodesFromItem(Map item) {
    final out = <String>{};

    // Most common: single 'site_code'
    final sc = (item['site_code'] ?? '').toString().trim();
    if (sc.isNotEmpty) out.add(sc.toUpperCase());

    // Some payloads may include 'site_codes': ['F270','F271']
    final scs = item['site_codes'];
    if (scs is List) {
      for (final v in scs) {
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) out.add(s.toUpperCase());
      }
    }

    return out;
  }

  /// Safety filter in case the payload contains mixed sites
  List<dynamic> _filterBySiteCode(List data, String want) {
    final upperWant = want.toUpperCase();
    final res = <dynamic>[];

    int shown = 0;
    for (final raw in data) {
      if (raw is! Map<String, dynamic>) continue;
      final codes = _extractSiteCodesFromItem(raw);
      if (codes.isEmpty || codes.contains(upperWant)) {
        res.add(raw);
        shown++;
        if (shown <= 3) {
          debugPrint('[SurveyRepository] match#${shown} site_codes=$codes');
        }
      } else {
        if (shown <= 3) {
          debugPrint('[SurveyRepository] skip item site_codes=$codes (want=$upperWant)');
        }
      }
    }
    return res;
  }
}
