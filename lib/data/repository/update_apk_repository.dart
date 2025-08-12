import 'package:dio/dio.dart';

import '../models/apk_update_model.dart';


class UpdateRepository {
  final Dio _dio = Dio();

  Future<UpdateModel?> fetchAppVersion() async {
    try {
      final response = await _dio.get('https://survey-backend.shwapno.app/survey/api/app/update/');
      return UpdateModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Failed to fetch version: $e');
      return null;
    }
  }
}
