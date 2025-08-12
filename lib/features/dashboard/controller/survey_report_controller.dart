import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:survey_app/data/services/auth_service.dart';
import 'package:survey_app/data/models/survey_report_model.dart';

class SurveyReportController extends GetxController {
  final _reportList = <SurveyReportModel>[].obs;
  List<SurveyReportModel> get reportList => _reportList;

  final RxBool isLoading = false.obs;
  final String baseUrl = 'https://survey-backend.shwapno.app';

  Future<void> fetchReports({
    required String level,
    required String startDate,
    required String endDate,
  }) async {
    try {
      isLoading.value = true;
      final token = AuthService.instance.getToken();

      final url = '$baseUrl/survey/api/survey/report/';
      print('🔗 Requesting: $url?level=$level&start_date=$startDate&end_date=$endDate');

      final response = await Dio().get(
        url,
        queryParameters: {
          'level': level,
          'start_date': startDate,
          'end_date': endDate,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      print('✅ Raw API response: $data');

      final List<SurveyReportModel> result = [];

      if (level == 'myoutlet') {
        final results = data['results'];
        if (results is List) {
          for (var item in results) {
            try {
              print('➡️ Parsing myoutlet item: $item');
              final parsed = SurveyReportModel.fromMyOutletJson(item);
              result.add(parsed);
            } catch (e) {
              print('❌ Error parsing myoutlet item: $item\nError: $e');
            }
          }
        } else {
          print('❌ `results` is not a List. Got: ${results.runtimeType}');
        }
      } else if (level == 'national') {
        final sites = data['sites'];
        if (sites is List) {
          for (var site in sites) {
            final String siteCode = site['site_code'] ?? '';
            final responses = site['responses'];
            if (responses is List) {
              for (var item in responses) {
                try {
                  print('➡️ Parsing national item: $item');
                  final parsed = SurveyReportModel.fromNationalJson(item, siteCode);
                  result.add(parsed);
                } catch (e) {
                  print('❌ Error parsing national item: $item\nError: $e');
                }
              }
            }
          }
        }
      }

      _reportList.value = result;
      print('✅ Report fetched: ${_reportList.length} items');
    } catch (e) {
      print('❌ Error fetching reports: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
