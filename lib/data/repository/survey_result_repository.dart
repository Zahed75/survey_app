import 'package:dio/dio.dart';
import 'package:survey_app/data/models/survey_result_model.dart';
import 'package:survey_app/data/services/auth_service.dart';

class SurveyResultRepository {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://survey-backend.shwapno.app';

  Future<SurveyResult> fetchResultByCategory(int responseId) async {
    final token = AuthService.instance.getToken();

    if (token == null || token.isEmpty) {
      print("❌ [SurveyResultRepository] Token missing.");
      throw Exception("Authentication token is missing.");
    }

    final url = '$_baseUrl/survey/survey-result/$responseId/by-category/';
    print("📡 [SurveyResultRepository] Requesting: $url");
    print("🔐 Token: $token");

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("✅ [SurveyResultRepository] Status: ${response.statusCode}");
      print("📥 [SurveyResultRepository] Data: ${response.data}");

      return SurveyResult.fromJson(response.data);
    } catch (e, stacktrace) {
      print("❌ [SurveyResultRepository] Error: $e");
      print("🪜 Stacktrace: $stacktrace");
      throw Exception("Failed to load survey result.");
    }
  }
}
