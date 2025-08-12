import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_app/data/models/survey_result_model.dart';
import 'package:survey_app/data/repository/survey_result_repository.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/services/site-service.dart'; // For location

class SurveyResultController extends GetxController {
  final _repo = SurveyResultRepository();
  final _storage = GetStorage();
  final _siteService = SiteService(dio: Dio()); // Initialize SiteService

  final result = Rxn<SurveyResult>();
  final isLoading = false.obs;
  final isSurveyDisabled =
      false.obs; // Track if the survey is disabled due to location

  static const String cacheKey = 'last_survey_result';

  // Fetches the result from the backend and handles uncategorized categories
  Future<void> loadResult(int responseId, {bool updateCache = true}) async {
    try {
      isLoading.value = true;
      print("📡 Fetching survey result...");
      final data = await _repo.fetchResultByCategory(responseId);

      // Create a new list with updated category names
      final updatedCategories = data.categories.map((category) {
        // Create a new CategoryResult with the updated name if it's 'Uncategorized'
        if (category.name == "Uncategorized") {
          return CategoryResult(
            name: "General",
            // Rename 'Uncategorized' to 'General'
            obtainedMarks: category.obtainedMarks,
            totalMarks: category.totalMarks,
            percentage: category.percentage,
            questions: category.questions,
          );
        } else {
          return category; // Leave other categories unchanged
        }
      }).toList();

      // Manually create a new SurveyResult object with the updated categories
      result.value = SurveyResult(
        responseId: data.responseId,
        surveyTitle: data.surveyTitle,
        submittedByUserId: data.submittedByUserId,
        submittedAt: data.submittedAt,
        overall: data.overall,
        categories: updatedCategories, // Use the modified categories
        siteCode: data.siteCode,       // ✅ add this
        siteName: data.siteName,       // ✅ add this
        timestamp: data.timestamp,     // ✅ optional, keep if you use it
      );


      // ✅ Cache if requested
      if (updateCache) {
        _storage.write(
          cacheKey,
          jsonEncode({"responseId": responseId, "data": data.toJson()}),
        );
        print("✅ Survey result loaded and cached.");
      }
    } catch (e) {
      print("❌ Error: $e");
      Get.snackbar("Error", "Failed to load result");
    } finally {
      isLoading.value = false;
    }
  }

  // Loads the cached result, if available
  Future<bool> loadCachedResult() async {
    try {
      final cached = _storage.read(cacheKey);
      if (cached != null) {
        final map = jsonDecode(cached);
        final resultJson = map["data"];
        result.value = SurveyResult.fromJson(resultJson);
        print("📦 Loaded cached survey result.");
        return true;
      }
    } catch (e) {
      print("⚠️ Error loading cache: $e");
    }
    return false;
  }

  // Checks the user's location to enable or disable survey based on proximity to sites
  Future<void> checkLocationAndEnableSurvey() async {
    final Position position = await Geolocator.getCurrentPosition();
    final userLat = position.latitude;
    final userLon = position.longitude;

    try {
      final sites = await _siteService.fetchSites();
      bool isWithinRange = false;

      // Check if the user is within 2km of any site
      for (var site in sites) {
        final siteLat = site['latitude'];
        final siteLon = site['longitude'];

        final distance = _siteService.calculateDistance(
          userLat,
          userLon,
          siteLat,
          siteLon,
        );

        if (distance <= 2) {
          isWithinRange = true;
          break; // No need to check further if one site is within range
        }
      }

      // Enable or disable survey based on proximity
      isSurveyDisabled.value = !isWithinRange;
    } catch (e) {
      print("Error checking location: $e");
    }
  }

  // Clears the result data
  void clearResult() {
    result.value = null;
  }
}
