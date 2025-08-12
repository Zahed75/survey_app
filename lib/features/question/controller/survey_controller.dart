import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repository/survey_repository.dart';

class SurveyController extends GetxController {
  final SurveyRepository _repo = SurveyRepository();

  var surveys = <Map<String, dynamic>>[].obs;
  var answers = <int, dynamic>{}.obs;
  var uploadedImages = <int, String?>{}.obs;
  var detectedLocations = <int, Map<String, double>>{}.obs;
  var isLoading = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  final storage = GetStorage();

  Future<void> fetchSurveys() async {
    try {
      isLoading.value = true;

      // New fast API (already filtered by site if selected)
      final result = await _repo.fetchUserSurveys();

      // Keep type consistent with your UI
      surveys.assignAll(result.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load surveys');
      surveys.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void updateLocation(double lat, double lon) {
    latitude.value = lat; longitude.value = lon;
  }

  void updateAnswer(int qId, dynamic answer) => answers[qId] = answer;

  void updateUploadedImage(int qId, String? path) => uploadedImages[qId] = path;

  void updateDetectedLocation(int qId, double lat, double lon) {
    detectedLocations[qId] = {"latitude": lat, "longitude": lon};
  }

  void resetAll() {
    answers.clear();
    uploadedImages.clear();
    detectedLocations.clear();
    latitude.value = 0.0;
    longitude.value = 0.0;
  }
}
