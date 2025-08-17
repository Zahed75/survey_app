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

  /// Pagination (keep your UX constants)
  static const int _kPageSize = 21;
  int _page = 1;
  int _numPages = 1;
  bool _hasMore = true;

  /// ScrollController to detect bottom
  final ScrollController scrollController = ScrollController();

  /// Debounce for search-driven fetch-ahead (kept, but won’t be needed as much after full prefetch)
  Timer? _searchDebounce;

  /// Prevent overlapping paging from any source
  bool _isPaging = false;

  /// Tickets to cancel stale loops
  int _searchTicket = 0;
  int _prefetchTicket = 0;

  @override
  void onInit() {
    super.onInit();

    // restore selected site (if any)
    selectedSiteCode.value = storage.read('selected_site_code') ?? '';

    // Attach listener for infinite scroll (kept, harmless after full prefetch)
    scrollController.addListener(_onScroll);

    // Initial load => fast page 1 for UX, then deterministically fetch the rest
    _loadAllPagesDeterministically();

    // React to search input
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
  /// IMPORTANT: reference assignedSites.length to make Obx rebuild on changes.
  List<Map<String, dynamic>> get sites {
    // touch the Rx to register dependency for Obx
    final _touch = assignedSites.length;
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return List<Map<String, dynamic>>.from(assignedSites);
    return assignedSites.where((s) {
      final code = (s['site_code'] ?? '').toString().toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      return code.contains(q) || name.contains(q);
    }).toList();
  }

  /// PUBLIC API kept for back-compat (not used by screen directly)
  Future<void> loadFirstPage() async {
    _page = 1;
    _hasMore = true;
    assignedSites.clear();
    await _fetchPage();
  }

  /// PUBLIC API kept for back-compat (scroll)
  Future<void> loadNextPage() async {
    if (_isPaging || !_hasMore || isLoadingMore.value || isLoading.value)
      return;
    _isPaging = true;
    isLoadingMore.value = true;
    _page += 1;
    try {
      await _fetchPage();
    } finally {
      isLoadingMore.value = false;
      _isPaging = false;
    }
  }

  Future<void> _fetchPage() async {
    try {
      if (_page == 1) isLoading.value = true;

      final token = storage.read('access_token');
      if (token == null || token.toString().isEmpty) {
        assignedSites.clear();
        _hasMore = false;
        debugPrint('[SiteController] no token -> stop');
        return;
      }

      final resp = await _dio.get(
        '/api/user/get_site_access_by_user',
        queryParameters: {'page': _page, 'page_size': _kPageSize},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint(
        '[SiteController] _fetchPage status=${resp.statusCode} page=$_page',
      );

      if (resp.statusCode == 200 && resp.data is Map) {
        final map = resp.data as Map;
        final List sites = (map['sites'] ?? []) as List;
        _numPages = (map['num_pages'] ?? 1) as int;

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

  /// selection write with logging
  Future<void> setSelectedSite(String code) async {
    final normalized = (code).toString().trim().toUpperCase();
    selectedSiteCode.value = normalized;
    await storage.write('selected_site_code', normalized);
    debugPrint('[SiteController] setSelectedSite="$normalized" persisted');
  }

  /// Search-ahead (still here but won’t be needed once full list cached)
  Future<void> _fetchAheadUntilMatchedOrExhausted(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;

    // If filtered view already matches, skip
    if (sites.isNotEmpty) return;

    // If loaded list already contains it, skip
    final lower = query.toLowerCase();
    final existsInLoaded = assignedSites.any((s) {
      final code = (s['site_code'] ?? '').toString().toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      return code.contains(lower) || name.contains(lower);
    });
    if (existsInLoaded) return;

    final myTicket = ++_searchTicket;
    int safety = 0;
    const int kMaxExtraPages = 200;

    while (_hasMore) {
      if (myTicket != _searchTicket) return;
      await loadNextPage();
      if (myTicket != _searchTicket) return;

      final foundNow = assignedSites.any((s) {
        final code = (s['site_code'] ?? '').toString().toLowerCase();
        final name = (s['name'] ?? '').toString().toLowerCase();
        return code.contains(lower) || name.contains(lower);
      });
      if (foundNow) break;

      safety += 1;
      if (safety >= kMaxExtraPages) {
        debugPrint('[SiteController] fetchAhead safety break for "$query"');
        break;
      }
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;
    if (current >= max - 200) {
      loadNextPage();
    }
  }

  /// Back-compat for old calls
  Future<void> fetchAssignedSitesFromToken() async {
    await loadFirstPage();
  }

  /// === KEY FIX: Deterministic full prefetch (no overlaps) ===
  /// 1) Load page 1 quickly to render UI
  /// 2) Then sequentially load pages 2..N (serialized)
  Future<void> _loadAllPagesDeterministically() async {
    // Step 1: fast page 1
    _page = 1;
    _hasMore = true;
    assignedSites.clear();
    await _fetchPage();

    if (!_hasMore) {
      debugPrint('[SiteController] only one page; done');
      return;
    }

    // Step 2: fetch remaining pages in order (no overlap)
    final myTicket = ++_prefetchTicket;
    for (int p = 2; p <= _numPages; p++) {
      if (myTicket != _prefetchTicket) {
        debugPrint('[SiteController] prefetch canceled (newer ticket)');
        return;
      }
      // block overlaps with scroll/search: we drive paging deterministically here
      if (_isPaging || isLoading.value || isLoadingMore.value) {
        // small yield if something else is in-flight (shouldn’t happen often)
        await Future.delayed(const Duration(milliseconds: 120));
      }
      _isPaging = true;
      try {
        _page = p;
        await _fetchPage();
      } finally {
        _isPaging = false;
      }
      // tiny yield for UI/network niceness
      await Future.delayed(const Duration(milliseconds: 40));
    }

    debugPrint(
      '[SiteController] FULL prefetch complete: total=${assignedSites.length}, pages=$_numPages',
    );
  }
}
