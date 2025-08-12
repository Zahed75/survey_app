// update_apk_repository.dart
import 'package:dio/dio.dart';
import '../models/apk_update_model.dart';

class UpdateRepository {
  final Dio _dio = Dio();

  // New endpoint
  static const String _endpoint =
      'https://survey-backend.shwapno.app/survey/api/app/download/';

  Future<UpdateModel?> fetchAppVersion() async {
    try {
      final response = await _dio.get(_endpoint);

      // Expecting top-level { code, message, data: { ... } }
      if (response.statusCode == 200 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'] as Map<String, dynamic>?;
        if (data != null) {
          return UpdateModel.fromNewApi(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ Failed to fetch version: $e');
      return null;
    }
  }
}
