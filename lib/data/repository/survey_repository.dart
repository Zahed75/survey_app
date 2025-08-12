import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';

class SurveyRepository {
  final Dio _dio = Dio();
  final String _endpoint =
      'https://survey-backend.shwapno.app/survey/api/surveys/user/';

  /// Method to fetch user surveys with filtering by site code


  Future<List<dynamic>> fetchUserSurveys() async {
    final token = AuthService.instance.getToken();
    final siteCode = GetStorage().read('selected_site_code') ?? '';

    final url = 'https://survey-backend.shwapno.app/survey/api/user/accessible-sites/';

    final response = await Dio().get(
      url,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    final data = response.data['data'] as List<dynamic>;

    // Split the selected site_code and check if any of the codes match
    final selectedSiteCodes = siteCode.split(',').map((e) => e.trim()).toSet();

    final filtered = data.where((e) {
      // Ensure e['site_code'] is a String and handle it properly
      final surveySiteCodes = (e['site_code'] as String?)?.split(',').map((code) => code.trim()).toSet() ?? <String>{};

      // Ensure that the filtering returns a boolean value (true or false)
      return surveySiteCodes.any((code) => selectedSiteCodes.contains(code));
    }).toList();

    return filtered;
  }


}
