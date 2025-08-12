import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SiteController extends GetxController {
  final storage = GetStorage();

  var assignedSites = <Map<String, dynamic>>[].obs;
  var selectedSiteCode = ''.obs;
  var isLoading = false.obs;

  // 🔎 search state
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedSitesFromToken();
    selectedSiteCode.value = storage.read('selected_site_code') ?? '';
  }

  /// Call from UI search field
  void setSearchQuery(String q) => searchQuery.value = q;

  /// Filtered view (code OR name matches)
  List<Map<String, dynamic>> get sites {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      return List<Map<String, dynamic>>.from(assignedSites); // snapshot
    }
    return assignedSites.where((s) {
      final code = (s['site_code'] ?? '').toString().toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      return code.contains(q) || name.contains(q);
    }).toList();
  }


  Future<void> fetchAssignedSitesFromToken() async {
    try {
      isLoading.value = true;

      final tokenData = storage.read('user_info');

      // Normalize: tokenData might be { access_info: [...] } OR just a list
      List<dynamic> accessInfoList = [];
      if (tokenData is Map && tokenData['access_info'] is List) {
        accessInfoList = tokenData['access_info'] as List<dynamic>;
      } else if (tokenData is List) {
        accessInfoList = tokenData;
      } else {
        assignedSites.clear();
        return;
      }

      final uniqueSites = <String, Map<String, dynamic>>{};
      for (var access in accessInfoList) {
        final site = (access is Map) ? access['site'] : null;
        if (site != null && site is Map && site['site_code'] != null) {
          final code = site['site_code'].toString();
          uniqueSites[code] = site as Map<String, dynamic>;
        }
      }

      assignedSites.value = uniqueSites.values.toList();

      // ✅ Clear any stale search so the grid isn't empty when opening the selector
      searchQuery.value = '';
    } catch (e) {
      print('❌ Error loading assigned sites: $e');
      assignedSites.clear();
      searchQuery.value = ''; // also clear on error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSelectedSite(String code) async {
    selectedSiteCode.value = code;
    await storage.write('selected_site_code', code);
  }
}
