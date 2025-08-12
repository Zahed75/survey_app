// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import '../../../data/repository/survey_repository.dart';
//
// class SurveyController extends GetxController {
//   final SurveyRepository _repo = SurveyRepository();
//
//   // 🔄 Store survey as List<Map<String, dynamic>> for UI compatibility
//   var surveys = <Map<String, dynamic>>[].obs;
//   var answers = <int, dynamic>{}.obs;
//   var uploadedImages = <int, String?>{}.obs;
//   var detectedLocations = <int, Map<String, double>>{}.obs;
//   var isLoading = false.obs;
//   var latitude = 0.0.obs;
//   var longitude = 0.0.obs;
//
//   final storage = GetStorage();
//
//   @override
//   void onInit() {
//     super.onInit();
//   }
//
//   Future<void> fetchSurveys() async {
//     try {
//       isLoading.value = true;
//       final result = await _repo.fetchUserSurveys();
//       final selectedSiteCode = storage.read('selected_site_code') ?? '';
//
//       final filtered = result.where((survey) {
//         final siteCodes =
//             (survey['site_code'] as String?)
//                 ?.split(',')
//                 .map((code) => code.trim())
//                 .toSet() ??
//             {};
//         return siteCodes.contains(selectedSiteCode);
//       }).toList();
//
//       surveys.assignAll(filtered.cast<Map<String, dynamic>>()); // ✅
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to load surveys');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void updateLocation(double lat, double lon) {
//     latitude.value = lat;
//     longitude.value = lon;
//   }
//
//   void updateAnswer(int questionId, dynamic answer) {
//     answers[questionId] = answer;
//   }
//
//   void updateUploadedImage(int questionId, String? imagePath) {
//     uploadedImages[questionId] = imagePath;
//   }
//
//   void updateDetectedLocation(int questionId, double lat, double lon) {
//     detectedLocations[questionId] = {"latitude": lat, "longitude": lon};
//   }
// }




// survey_controller.dart
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

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchSurveys() async {
    try {
      isLoading.value = true;
      final result = await _repo.fetchUserSurveys();
      final selectedSiteCode = storage.read('selected_site_code') ?? '';

      final filtered = result.where((survey) {
        final siteCodes =
            (survey['site_code'] as String?)
                ?.split(',')
                .map((code) => code.trim())
                .toSet() ??
                {};
        return siteCodes.contains(selectedSiteCode);
      }).toList();

      surveys.assignAll(filtered.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar('Error', 'Failed to load surveys');
    } finally {
      isLoading.value = false;
    }
  }

  void updateLocation(double lat, double lon) {
    latitude.value = lat;
    longitude.value = lon;
  }

  void updateAnswer(int questionId, dynamic answer) {
    answers[questionId] = answer;
  }

  void updateUploadedImage(int questionId, String? imagePath) {
    uploadedImages[questionId] = imagePath;
  }

  void updateDetectedLocation(int questionId, double lat, double lon) {
    detectedLocations[questionId] = {"latitude": lat, "longitude": lon};
  }

  /// 🔄 Clear all in-memory answers/files/locations so the next survey opens clean
  void resetAll() {
    answers.clear();
    uploadedImages.clear();
    detectedLocations.clear();
    latitude.value = 0.0;
    longitude.value = 0.0;
  }
}
