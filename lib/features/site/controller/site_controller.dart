import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SiteController extends GetxController {
  final storage = GetStorage();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.shwapno.app'));

  // List shown on screen (kept name to avoid UI changes)
  var assignedSites = <Map<String, dynamic>>[].obs;

  // Selected code
  var selectedSiteCode = ''.obs;

  // Loading flags
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  // Search state
  var searchQuery = ''.obs;

  // Pagination
  int _page = 1;
  int _pageSize = 21;           // First page must show 21
  int _numPages = 1;
  bool _hasMore = true;

  // ScrollController to detect bottom
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    // restore selected site (if any)
    selectedSiteCode.value = storage.read('selected_site_code') ?? '';

    // Attach listener
    scrollController.addListener(_onScroll);

    // First load when screen opens (also called from LoginController after login)
    loadFirstPage();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  /// Search setter
  void setSearchQuery(String q) => searchQuery.value = q;

  /// Filtered view (code OR name matches)
  List<Map<String, dynamic>> get sites {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return List<Map<String, dynamic>>.from(assignedSites);
    return assignedSites.where((s) {
      final code = (s['site_code'] ?? '').toString().toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      return code.contains(q) || name.contains(q);
    }).toList();
  }

  /// Public: called after login & on init
  Future<void> loadFirstPage() async {
    _page = 1;
    _pageSize = 21;        // ✅ first page 21
    _hasMore = true;
    assignedSites.clear();
    await _fetchPage();
  }

  /// Load next page (after first, use larger page_size=50)
  Future<void> loadNextPage() async {
    if (!_hasMore || isLoadingMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    _page += 1;
    _pageSize = 50;        // ✅ subsequent pages 50
    try {
      await _fetchPage();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _fetchPage() async {
    try {
      if (_page == 1) isLoading.value = true;

      final token = storage.read('access_token');
      if (token == null || token.toString().isEmpty) {
        // Not logged in; nothing to load.
        assignedSites.clear();
        _hasMore = false;
        return;
      }

      final resp = await _dio.get(
        '/api/user/get_site_access_by_user',
        queryParameters: {
          'page': _page,
          'page_size': _pageSize,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (resp.statusCode == 200 && resp.data is Map) {
        final map = resp.data as Map;
        final List sites = (map['sites'] ?? []) as List;
        _numPages = (map['num_pages'] ?? 1) as int;

        // De-dup by site_code as you may navigate back-and-forth
        final existing = { for (var s in assignedSites) s['site_code']?.toString() : s };
        for (final raw in sites) {
          if (raw is Map && raw['site_code'] != null) {
            final code = raw['site_code'].toString();
            existing[code] = Map<String, dynamic>.from(raw);
          }
        }
        assignedSites.value = existing.values.toList();

        _hasMore = _page < _numPages;
      } else {
        // Treat non-200 as end of list
        _hasMore = false;
      }
    } catch (e) {
      // Fail silently but stop endless loading
      _hasMore = false;
    } finally {
      if (_page == 1) isLoading.value = false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;

    // When user reaches near the bottom, load more
    if (current >= max - 200) {
      loadNextPage();
    }
  }

  Future<void> setSelectedSite(String code) async {
    selectedSiteCode.value = code;
    await storage.write('selected_site_code', code);
  }

  /// Back-compat for old calls (no-op now)
  Future<void> fetchAssignedSitesFromToken() async {
    // Now we always load from API (first 21)
    await loadFirstPage();
  }
}
