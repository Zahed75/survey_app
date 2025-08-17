import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// ---- API MODELS / PARSERS --------------------------------------------------

class _DownloadApiData {
  final String versionName; // e.g. "1.0.0+58"
  final int versionCode; // e.g. 58
  final String apkUrl;
  final bool isMandatory;
  final String changelog;

  _DownloadApiData({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    required this.isMandatory,
    required this.changelog,
  });

  factory _DownloadApiData.fromJson(Map<String, dynamic> json) {
    final d = json['data'] ?? {};
    return _DownloadApiData(
      versionName: (d['versionName'] ?? d['version'] ?? '').toString(),
      versionCode: (d['versionCode'] ?? d['build_number'] ?? 0) is int
          ? d['versionCode'] ?? d['build_number']
          : int.tryParse(
                  (d['versionCode'] ?? d['build_number'] ?? '0').toString(),
                ) ??
                0,
      apkUrl: (d['apkUrl'] ?? d['apk_url'] ?? '').toString(),
      isMandatory: (d['isMandatory'] ?? d['is_mandatory'] ?? false) == true,
      changelog: (d['changelog'] ?? '').toString(),
    );
  }
}

/// ---- SERVICE ---------------------------------------------------------------

class UpdateService {
  // Your endpoints (download is canonical)
  static const String _downloadEndpoint =
      'https://survey-backend.shwapno.app/survey/api/app/download/';
  // old shape (if still used anywhere)
  static const String _updateEndpoint =
      'https://survey-backend.shwapno.app/survey/api/app/update/';

  /// Backward compat: used by LoginScreen and AppRoot
  static Future<void> forceUpdateIfAvailable(BuildContext context) async {
    await _promptIfUpdateAvailable(context);
  }

  /// Backward compat: used by LoginScreen footer for showing version text.
  /// Returns a map with keys: version, buildNumber, is_mandatory, apk_url, changelog
  static Future<Map<String, dynamic>?> fetchAppVersion() async {
    try {
      final dio = Dio();
      // Prefer the download endpoint
      final resp = await dio.get(
        _downloadEndpoint,
        options: Options(
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (resp.statusCode == 200 && resp.data != null) {
        final d = _DownloadApiData.fromJson(resp.data);
        return {
          'version': d.versionName.split('+').first,
          'buildNumber': d.versionCode,
          'is_mandatory': d.isMandatory,
          'apk_url': d.apkUrl,
          'changelog': d.changelog,
        };
      }

      // Fallback to the update endpoint if needed
      final resp2 = await dio.get(
        _updateEndpoint,
        options: Options(
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (resp2.statusCode == 200 && resp2.data != null) {
        final d = _DownloadApiData.fromJson(resp2.data);
        return {
          'version': d.versionName.split('+').first,
          'buildNumber': d.versionCode,
          'is_mandatory': d.isMandatory,
          'apk_url': d.apkUrl,
          'changelog': d.changelog,
        };
      }
    } catch (_) {}
    return null;
  }

  /// Backward compat: used in main() to block the app if mandatory update exists.
  /// Returns true if we triggered an install (so you can early-return from main()).
  static Future<bool> checkAndInstallBlockingUpdate() async {
    try {
      final info = await _fetchRemote();
      if (info == null) return false;

      final localCode = await _localVersionCode();
      final updateAvailable = info.versionCode > localCode;

      if (updateAvailable && info.isMandatory) {
        final apk = await _downloadApk(info.apkUrl, info.versionName);
        // hand off to installer (system UI takes over)
        await _install(apk);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// ---- Internals shared by all flows --------------------------------------

  static Future<_DownloadApiData?> _fetchRemote() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        followRedirects: true,
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    final resp = await dio.get(_downloadEndpoint);
    if (resp.statusCode == 200 && resp.data != null) {
      return _DownloadApiData.fromJson(resp.data);
    }

    final resp2 = await dio.get(_updateEndpoint);
    if (resp2.statusCode == 200 && resp2.data != null) {
      return _DownloadApiData.fromJson(resp2.data);
    }
    return null;
  }

  static Future<int> _localVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }

  static Future<File> _downloadApk(
    String url,
    String versionName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception('No external storage directory');

    final path = '${dir.path}/app-$versionName.apk';
    final file = File(path);
    if (await file.exists()) await file.delete();

    final dio = Dio();
    // Optionally HEAD to validate content-type; most servers are fine:
    final resp = await dio.download(
      url,
      path,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 3),
        sendTimeout: const Duration(minutes: 3),
        headers: {"Accept": "application/vnd.android.package-archive, */*"},
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    if (resp.statusCode != 200) {
      throw Exception('Download failed (${resp.statusCode})');
    }

    // Guard against HTML/partial downloads → avoids “parsing package”
    final len = await file.length();
    if (len < 1 * 1024 * 1024) {
      throw Exception(
        'Downloaded file too small ($len bytes) – not a valid APK',
      );
    }

    return file;
  }

  static Future<void> _install(File apk) async {
    final installer = FlutterAppInstaller();
    await installer.installApk(filePath: apk.path);
  }

  /// UI dialog flow used across screens
  static Future<void> _promptIfUpdateAvailable(BuildContext context) async {
    // Prefer a stable, top-level context
    final dlgContext = Get.overlayContext ?? context;

    final info = await _fetchRemote();
    if (info == null) return;

    final local = await _localVersionCode();
    final should = info.versionCode > local;
    if (!should || !(dlgContext.mounted)) return;

    bool downloading = false;
    double progress = 0.0;
    String? error;

    await showDialog(
      context: dlgContext,
      barrierDismissible: !info.isMandatory,
      useRootNavigator: true, // ✅ important
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            info.isMandatory ? 'Update required' : 'Update available',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: ${info.versionName}'),
              if (info.changelog.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(info.changelog, style: Theme.of(ctx).textTheme.bodySmall),
              ],
              if (downloading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (progress > 0 && progress < 1) ? progress : null,
                ),
                const SizedBox(height: 8),
                Text(
                  (progress > 0 && progress <= 1)
                      ? '${(progress * 100).toStringAsFixed(0)}%'
                      : 'Preparing…',
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            if (!info.isMandatory)
              TextButton(
                onPressed: downloading
                    ? null
                    : () => Navigator.of(ctx, rootNavigator: true).pop(),
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: downloading
                  ? null
                  : () async {
                      setState(() {
                        downloading = true;
                        progress = 0;
                        error = null;
                      });
                      try {
                        final apk = await _downloadApk(
                          info.apkUrl,
                          info.versionName,
                          onProgress: (r, t) {
                            if (t > 0) setState(() => progress = r / t);
                          },
                        );
                        if (ctx.mounted)
                          Navigator.of(ctx, rootNavigator: true).pop();
                        await _install(apk);
                      } catch (e) {
                        setState(() {
                          downloading = false;
                          error = e.toString();
                        });
                      }
                    },
              child: const Text('Download & Install'),
            ),
          ],
        ),
      ),
    );
  }
}
