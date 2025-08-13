// survey_result_controller.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_app/data/models/survey_result_model.dart';
import 'package:survey_app/data/repository/survey_result_repository.dart';
import 'package:geolocator/geolocator.dart';
import '../../../common/widgets/alerts/u_alert.dart';
import '../../../data/services/site-service.dart';

class SurveyResultController extends GetxController {
  final _repo = SurveyResultRepository();
  final _storage = GetStorage();
  final _siteService = SiteService(dio: Dio());

  final result = Rxn<SurveyResult>();
  final isLoading = false.obs;
  final isSurveyDisabled = false.obs;

  // ---- Helpers for per-id cache ----
  // String _cacheKeyFor(int id) => 'result_$id';
  //
  // Future<bool> loadCachedResult(int responseId) async {
  //   try {
  //     final cached = _storage.read(_cacheKeyFor(responseId));
  //     if (cached != null) {
  //       final map = jsonDecode(cached) as Map<String, dynamic>;
  //       final data = SurveyResult.fromJson(map);
  //       result.value = data;
  //       return true;
  //     }
  //   } catch (_) {}
  //   return false;
  // }
  //
  //
  //
  // // survey_result_controller.dart
  // Future<void> loadResult(int responseId, {bool updateCache = true}) async {
  //   // local keys so you don't need extra class fields
  //   const String cacheKeyLocal = 'last_survey_result';
  //   final String responseSiteKey = 'response_site_code_$responseId';
  //   final String responseSiteNameKey = 'response_site_name_$responseId'; //
  //
  //   try {
  //     isLoading.value = true;
  //
  //     // 1) Fetch result from API
  //     final data = await _repo.fetchResultByCategory(responseId);
  //
  //     // 2) Rename "Uncategorized" -> "General" (keeps your UX)
  //     final updatedCategories = data.categories.map((category) {
  //       if (category.name == "Uncategorized") {
  //         return CategoryResult(
  //           name: "General",
  //           obtainedMarks: category.obtainedMarks,
  //           totalMarks: category.totalMarks,
  //           percentage: category.percentage,
  //           questions: category.questions,
  //         );
  //       }
  //       return category;
  //     }).toList();
  //
  //     // 3) Prefer the site_code captured at submit time for this response
  //     final savedSiteCode = _storage.read(responseSiteKey);
  //     final savedSiteName = _storage.read(responseSiteNameKey);
  //     final String? effectiveSiteCode = (savedSiteCode is String && savedSiteCode.trim().isNotEmpty)
  //         ? savedSiteCode.trim()
  //         : data.siteCode;
  //
  //     final String? effectiveSiteName =
  //     (savedSiteName is String && savedSiteName.trim().isNotEmpty)
  //         ? savedSiteName.trim()
  //         : data.siteName;
  //
  //     // 4) Build the final model (only swapping the siteCode)
  //     final patched = SurveyResult(
  //       responseId: data.responseId,
  //       surveyTitle: data.surveyTitle,
  //       submittedByUserId: data.submittedByUserId,
  //       submittedAt: data.submittedAt,
  //       overall: data.overall,
  //       categories: updatedCategories,
  //       siteCode: effectiveSiteCode,   // fixed site code source
  //       siteName: effectiveSiteName,
  //       timestamp: data.timestamp,
  //     );
  //     print(patched.siteName);
  //     // 5) Set reactive value so UI updates immediately
  //     result.value = patched;
  //
  //     // 6) Cache (optional)
  //     if (updateCache) {
  //       _storage.write(
  //         cacheKeyLocal,
  //         jsonEncode({"responseId": responseId, "data": patched.toJson()}),
  //       );
  //     }
  //   } catch (e) {
  //     // Show the same UX message you use elsewhere
  //     Get.snackbar("Error", "Failed to load result");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }




  // ---- Helpers for per-id cache ----
//   String _cacheKeyFor(int id) => 'result_$id';
//
// // Read a per-id cached result if present.
// // Does NOT toggle isLoading (so the spinner is controlled by the caller).
//   Future<bool> loadCachedResult(int responseId) async {
//     try {
//       final cached = _storage.read(_cacheKeyFor(responseId));
//       if (cached != null && cached is String && cached.isNotEmpty) {
//         final map = jsonDecode(cached) as Map<String, dynamic>;
//         result.value = SurveyResult.fromJson(map);
//         return true;
//       }
//     } catch (_) {}
//     return false;
//   }
//
//   Future<void> loadResult(int responseId, {bool updateCache = true}) async {
//     const String lastCacheKey = 'last_survey_result';
//     final String responseSiteKey = 'response_site_code_$responseId';
//     final String responseSiteNameKey = 'response_site_name_$responseId';
//
//     try {
//       isLoading.value = true;
//
//       // 1) Fetch result from API
//       final data = await _repo.fetchResultByCategory(responseId);
//
//       // 2) Rename "Uncategorized" -> "General"
//       final updatedCategories = data.categories.map((c) {
//         if (c.name == "Uncategorized") {
//           return CategoryResult(
//             name: "General",
//             obtainedMarks: c.obtainedMarks,
//             totalMarks: c.totalMarks,
//             percentage: c.percentage,
//             questions: c.questions,
//           );
//         }
//         return c;
//       }).toList();
//
//       // 3) Prefer submitted site code/name captured at submit time
//       final savedSiteCode = _storage.read(responseSiteKey);
//       final savedSiteName = _storage.read(responseSiteNameKey);
//
//       final String? effectiveSiteCode =
//       (savedSiteCode is String && savedSiteCode.trim().isNotEmpty)
//           ? savedSiteCode.trim()
//           : data.siteCode;
//
//       final String? effectiveSiteName =
//       (savedSiteName is String && savedSiteName.trim().isNotEmpty)
//           ? savedSiteName.trim()
//           : data.siteName;
//
//       // 4) Build final model
//       final patched = SurveyResult(
//         responseId: data.responseId,
//         surveyTitle: data.surveyTitle,
//         submittedByUserId: data.submittedByUserId,
//         submittedAt: data.submittedAt,
//         overall: data.overall,
//         categories: updatedCategories,
//         siteCode: effectiveSiteCode,
//         siteName: effectiveSiteName,
//         timestamp: data.timestamp,
//       );
//
//       // 5) Update UI
//       result.value = patched;
//
//       // 6) Cache consistently
//       if (updateCache) {
//         // per-id cache (used by loadCachedResult)
//         _storage.write(_cacheKeyFor(responseId), jsonEncode(patched.toJson()));
//
//         // optional: keep your legacy "last" cache too (harmless)
//         _storage.write(
//           lastCacheKey,
//           jsonEncode({"responseId": responseId, "data": patched.toJson()}),
//         );
//       }
//     } catch (e) {
//       // Only show error if we truly have nothing to display
//       if (result.value == null) {
//         Get.snackbar("Error", "Failed to load result");
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }



  String _cacheKeyFor(int id) => 'result_$id';

  Future<bool> loadCachedResult(int responseId) async {
    try {
      final cached = _storage.read(_cacheKeyFor(responseId));
      if (cached is String && cached.isNotEmpty) {
        result.value = SurveyResult.fromJson(jsonDecode(cached));
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> loadResult(int responseId, {bool updateCache = true}) async {
    const String lastCacheKey = 'last_survey_result';
    final String responseSiteKey = 'response_site_code_$responseId';
    final String responseSiteNameKey = 'response_site_name_$responseId';

    try {
      isLoading.value = true;

      final data = await _repo.fetchResultByCategory(responseId);

      final updatedCategories = data.categories.map((c) {
        if (c.name == "Uncategorized") {
          return CategoryResult(
            name: "General",
            obtainedMarks: c.obtainedMarks,
            totalMarks: c.totalMarks,
            percentage: c.percentage,
            questions: c.questions,
          );
        }
        return c;
      }).toList();

      final savedSiteCode = _storage.read(responseSiteKey);
      final savedSiteName = _storage.read(responseSiteNameKey);

      final String? effectiveSiteCode =
      (savedSiteCode is String && savedSiteCode.trim().isNotEmpty)
          ? savedSiteCode.trim()
          : data.siteCode;

      final String? effectiveSiteName =
      (savedSiteName is String && savedSiteName.trim().isNotEmpty)
          ? savedSiteName.trim()
          : data.siteName;

      final patched = SurveyResult(
        responseId: data.responseId,
        surveyTitle: data.surveyTitle,
        submittedByUserId: data.submittedByUserId,
        submittedAt: data.submittedAt,
        overall: data.overall,
        categories: updatedCategories,
        siteCode: effectiveSiteCode,
        siteName: effectiveSiteName,
        timestamp: data.timestamp,
      );

      result.value = patched;

      if (updateCache) {
        // Per‑id cache (what loadCachedResult reads)
        _storage.write(_cacheKeyFor(responseId), jsonEncode(patched.toJson()));
        // Legacy “last” cache (optional)
        _storage.write(
          lastCacheKey,
          jsonEncode({"responseId": responseId, "data": patched.toJson()}),
        );
      }
    } catch (e) {
      // Only show error if we truly have nothing on screen
      if (result.value == null) {
        // Get.snackbar("Error", "Failed to load result");
        UAlert.show(title: 'Network Issues', message: 'Try Again');
      }
    } finally {
      isLoading.value = false;
    }
  }




  Future<void> checkLocationAndEnableSurvey() async {
    final Position position = await Geolocator.getCurrentPosition();
    final userLat = position.latitude;
    final userLon = position.longitude;

    try {
      final sites = await _siteService.fetchSites();
      bool isWithinRange = false;

      for (var site in sites) {
        final siteLat = site['latitude'];
        final siteLon = site['longitude'];
        final distance = _siteService.calculateDistance(
          userLat, userLon, siteLat, siteLon,
        );
        if (distance <= 2) {
          isWithinRange = true;
          break;
        }
      }
      isSurveyDisabled.value = !isWithinRange;
    } catch (e) {

    }
  }

  void clearResult() {
    result.value = null;
  }
}
