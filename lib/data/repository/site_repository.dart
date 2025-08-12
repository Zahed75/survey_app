import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../models/site_model.dart';

class SiteRepository {
  final Dio _dio = Dio();
  final _box = GetStorage();

  String? get _token => _box.read('access_token');

  /// 🔐 Get site codes user has access to
  Future<List<String>> fetchAccessibleSiteCodes() async {
    final response = await _dio.get(
      'https://survey-backend.shwapno.app/survey/api/user/accessible-sites/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final accessInfo = response.data['access_info'] ?? [];
      return accessInfo
          .map<String>((e) => e['site']['site_code'].toString())
          .toList();
    } else {
      throw Exception('Failed to load accessible site codes');
    }
  }

  /// 🌐 Get full list of all sites
  Future<List<Site>> fetchAllSites() async {
    final response = await _dio.get(
      'https://api.shwapno.app/api/sites',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final rawData = response.data['data'];
      if (rawData == null || rawData is! List) {
        throw Exception('Invalid site list format');
      }

      return rawData.map<Site>((e) => Site.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load all sites');
    }
  }
}
