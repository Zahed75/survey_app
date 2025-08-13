// site_controller.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SiteController extends GetxController {
  final storage = GetStorage();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.shwapno.app'));

  /// List shown on screen (kept same name to avoid UI changes)
  var assignedSites = <Map<String, dynamic>>[].obs;

  /// Selected code
  var selectedSiteCode = ''.obs;

  /// Loading flags
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  /// Search state
  var searchQuery = ''.obs;

  /// Pagination (IMPORTANT: keep page size CONSTANT to avoid missing ranges)
  static const int _kPageSize = 21; // choose 21 to preserve your first-page UX
  int _page = 1;
  int _numPages = 1;
  bool _hasMore = true;

  /// ScrollController to detect bottom
  final ScrollController scrollController = ScrollController();

  /// Debounce for search-driven fetch-ahead (so we don't spam API while typing)
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();

    // restore selected site (if any)
    selectedSiteCode.value = storage.read('selected_site_code') ?? '';

    // Attach listener for infinite scroll
    scrollController.addListener(_onScroll);

    // Initial load
    loadFirstPage();

    // React to search input: if not found yet and has more pages, fetch ahead
    ever<String>(searchQuery, (q) {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 250), () {
        _fetchAheadUntilMatchedOrExhausted(q.trim());
      });
    });
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  /// Setter used by UI as-is
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
    _hasMore = true;
    assignedSites.clear();
    await _fetchPage();
  }

  /// Load next page — keeps the SAME page size for all pages
  Future<void> loadNextPage() async {
    if (!_hasMore || isLoadingMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    _page += 1;
    try {
      await _fetchPage();
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Future<void> _fetchPage() async {
  //   try {
  //     if (_page == 1) isLoading.value = true;
  //
  //     final token = storage.read('access_token');
  //     if (token == null || token.toString().isEmpty) {
  //       assignedSites.clear();
  //       _hasMore = false;
  //       return;
  //     }
  //
  //     final resp = await _dio.get(
  //       '/api/user/get_site_access_by_user',
  //       queryParameters: {
  //         'page': _page,
  //         'page_size': _kPageSize, // <-- CONSTANT page size (no skipping)
  //       },
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Accept': 'application/json',
  //         },
  //       ),
  //     );
  //
  //     if (resp.statusCode == 200 && resp.data is Map) {
  //       final map = resp.data as Map;
  //       final List sites = (map['sites'] ?? []) as List;
  //       _numPages = (map['num_pages'] ?? 1) as int;
  //
  //       // De-dup by site_code (handles back/forward navigation)
  //       final existing = {
  //         for (var s in assignedSites) (s['site_code']?.toString() ?? ''): s,
  //       };
  //
  //       for (final raw in sites) {
  //         if (raw is Map && raw['site_code'] != null) {
  //           final code = raw['site_code'].toString();
  //           existing[code] = Map<String, dynamic>.from(raw);
  //         }
  //       }
  //
  //       assignedSites.value = existing.values.toList();
  //       _hasMore = _page < _numPages;
  //     } else {
  //       _hasMore = false; // stop trying on non-200
  //     }
  //   } catch (_) {
  //     _hasMore = false; // fail safe
  //   } finally {
  //     if (_page == 1) isLoading.value = false;
  //   }
  // }



  // site_controller.dart

  Future<void> _fetchPage() async {
    try {
      if (_page == 1) isLoading.value = true;

      final token = storage.read('access_token');
      debugPrint('[SiteController] _fetchPage page=$_page size=$_kPageSize '
          'tokenPresent=${token != null && token.toString().isNotEmpty}');

      if (token == null || token.toString().isEmpty) {
        assignedSites.clear();
        _hasMore = false;
        debugPrint('[SiteController] no token -> stop');
        return;
      }

      final resp = await _dio.get(
        '/api/user/get_site_access_by_user',
        queryParameters: {'page': _page, 'page_size': _kPageSize},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      debugPrint('[SiteController] response status=${resp.statusCode}');

      if (resp.statusCode == 200 && resp.data is Map) {
        final map = resp.data as Map;
        final List sites = (map['sites'] ?? []) as List;
        _numPages = (map['num_pages'] ?? 1) as int;

        debugPrint('[SiteController] got ${sites.length} sites '
            '(now have=${assignedSites.length}) num_pages=$_numPages');

        final existing = {
          for (var s in assignedSites) (s['site_code']?.toString() ?? ''): s,
        };
        for (final raw in sites) {
          if (raw is Map && raw['site_code'] != null) {
            final code = raw['site_code'].toString();
            existing[code] = Map<String, dynamic>.from(raw);
          }
        }
        assignedSites.value = existing.values.toList();
        _hasMore = _page < _numPages;
        debugPrint('[SiteController] merged -> total=${assignedSites.length} '
            'hasMore=$_hasMore');
      } else {
        _hasMore = false;
        debugPrint('[SiteController] non-200 -> stop paging');
      }
    } catch (e) {
      _hasMore = false;
      debugPrint('[SiteController] _fetchPage error: $e');
    } finally {
      if (_page == 1) isLoading.value = false;
    }
  }

// selection write with logging
  Future<void> setSelectedSite(String code) async {
    final normalized = (code).toString().trim().toUpperCase();
    debugPrint('[SiteController] setSelectedSite request="$code" -> "$normalized"');
    selectedSiteCode.value = normalized;
    await storage.write('selected_site_code', normalized);
    final rb = storage.read('selected_site_code');
    debugPrint('[SiteController] setSelectedSite wrote="$rb"');
  }



  /// When user searches e.g. "D016" and it's not in the loaded pages yet,
  /// progressively load more pages (with same page size) until:x
  ///  - we find at least one match, or
  ///  - we run out of pages.
  Future<void> _fetchAheadUntilMatchedOrExhausted(String q) async {
    if (q.isEmpty) return;
    if (sites.isNotEmpty) return; // already matched in current data

    // Do a quick probe against currently loaded (unfiltered) list;
    // if it's there but filtered list is empty, we’re done.
    final lower = q.toLowerCase();
    final existsInLoaded = assignedSites.any((s) {
      final code = (s['site_code'] ?? '').toString().toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      return code.contains(lower) || name.contains(lower);
    });
    if (existsInLoaded) return;

    // Otherwise fetch forward while there are more pages and still no match.
    while (_hasMore) {
      await loadNextPage();

      final foundNow = assignedSites.any((s) {
        final code = (s['site_code'] ?? '').toString().toLowerCase();
        final name = (s['name'] ?? '').toString().toLowerCase();
        return code.contains(lower) || name.contains(lower);
      });
      if (foundNow) break;
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

  // Future<void> setSelectedSite(String code) async {
  //   selectedSiteCode.value = code;
  //   await storage.write('selected_site_code', code);
  // }


  // site_controller.dart
  // Future<void> setSelectedSite(String code) async {
  //   final normalized = (code).toString().trim().toUpperCase();
  //   selectedSiteCode.value = normalized;
  //   await storage.write('selected_site_code', normalized);
  // }



  /// Back-compat for old calls (no-op now)
  Future<void> fetchAssignedSitesFromToken() async {
    await loadFirstPage();
  }
}
