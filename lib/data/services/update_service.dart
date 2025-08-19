import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class _DownloadApiData {
  final String versionName; // e.g., "1.0.0+24"
  final int versionCode; // e.g., 24
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
    final d = json['data'] ?? json;
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

class UpdateService {
  // Canonical + fallback endpoints
  static const String _downloadEndpoint =
      'https://survey-backend.shwapno.app/survey/api/app/download/';
  static const String _updateEndpoint =
      'https://survey-backend.shwapno.app/survey/api/app/update/';

  /// Public helper used by UI:
  /// Shows a dialog **only when server build != local build**.
  static Future<void> promptIfVersionMismatch(BuildContext context) async {
    // Optional guard to avoid re-prompt within the same run after we already launched installer
    try {
      if (GetStorage().read('update_installed_once') == true) {
        debugPrint('[UpdateService] Suppressed (update_installed_once=true)');
        return;
      }
    } catch (_) {}

    final remote = await _fetchRemote();
    if (remote == null) return;

    final local = await _localVersionCode();
    debugPrint('[UpdateService] local=$local, server=${remote.versionCode}');

    if (remote.versionCode == local) {
      // equal → do nothing
      return;
    }

    if (remote.versionCode > local) {
      // Newer on server → offer download & install
      await _showDownloadInstallDialog(context, remote);
      return;
    }

    // Device ahead of server → informative dialog
    final ctx = Get.overlayContext ?? context;
    if (!ctx.mounted) return;
    await showDialog(
      context: ctx,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('App is newer than server'),
        content: Text(
          'This device build: $local\nServer build: ${remote.versionCode}\n\n'
          'No update is required. Downgrades are not supported by Android.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Used by any footer/version UI; also helps your gatekeeper if needed.
  static Future<Map<String, dynamic>?> fetchAppVersion() async {
    try {
      final info = await _fetchRemote();
      if (info == null) return null;
      // Persist latest to storage for any gatekeeper
      _persistLatestBuild(info.versionCode);
      return {
        'version': info.versionName.split('+').first,
        'buildNumber': info.versionCode,
        'is_mandatory': info.isMandatory,
        'apk_url': info.apkUrl,
        'changelog': info.changelog,
      };
    } catch (e) {
      debugPrint('[UpdateService] fetchAppVersion error: $e');
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // Internals
  // ----------------------------------------------------------------------

  static Future<_DownloadApiData?> _fetchRemote() async {
    final pkg = await PackageInfo.fromPlatform();
    final appId = pkg.packageName; // e.g., com.shwapno.survey2
    final current = int.tryParse(pkg.buildNumber) ?? 0;

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        followRedirects: true,
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    // Prefer /download/ and include track hints
    final url1 = '$_downloadEndpoint?app_id=$appId&current=$current';
    try {
      final r1 = await dio.get(url1);
      if (r1.statusCode == 200 && r1.data != null) {
        final info = _DownloadApiData.fromJson(r1.data);
        _persistLatestBuild(info.versionCode);
        return info;
      }
    } catch (e) {
      debugPrint('[UpdateService] _fetchRemote /download error: $e');
    }

    // Fallback /update/
    final url2 = '$_updateEndpoint?app_id=$appId&current=$current';
    try {
      final r2 = await dio.get(url2);
      if (r2.statusCode == 200 && r2.data != null) {
        final info = _DownloadApiData.fromJson(r2.data);
        _persistLatestBuild(info.versionCode);
        return info;
      }
    } catch (e) {
      debugPrint('[UpdateService] _fetchRemote /update error: $e');
    }

    return null;
  }

  static void _persistLatestBuild(int build) {
    try {
      GetStorage().write('latest_build', build);
    } catch (_) {}
  }

  static Future<int> _localVersionCode() async {
    final p = await PackageInfo.fromPlatform();
    return int.tryParse(p.buildNumber) ?? 0;
  }

  static Future<void> _showDownloadInstallDialog(
    BuildContext context,
    _DownloadApiData info,
  ) async {
    final ctx = Get.overlayContext ?? context;
    if (!ctx.mounted) return;

    bool downloading = false;
    double progress = 0.0;
    String? error;

    await showDialog(
      context: ctx,
      barrierDismissible: !info.isMandatory,
      useRootNavigator: true,
      builder: (dlg) => StatefulBuilder(
        builder: (dlgCtx, setState) => AlertDialog(
          title: Text(
            info.isMandatory ? 'Update required' : 'Update available',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: ${info.versionName} (${info.versionCode})'),
              if (info.changelog.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  info.changelog,
                  style: Theme.of(dlgCtx).textTheme.bodySmall,
                ),
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
                  style: TextStyle(color: Theme.of(dlgCtx).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            if (!info.isMandatory)
              TextButton(
                onPressed: downloading
                    ? null
                    : () => Navigator.of(dlgCtx, rootNavigator: true).pop(),
                child: const Text('Later'),
              ),
            // Use ElevatedButton to ensure visibility across themes
            ElevatedButton(
              onPressed: downloading
                  ? null
                  : () async {
                      setState(() {
                        downloading = true;
                        progress = 0.0;
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

                        if (dlgCtx.mounted) {
                          Navigator.of(dlgCtx, rootNavigator: true).pop();
                        }

                        // Mark flags BEFORE handing off to the system installer
                        _markInstallFlags();

                        await _install(apk);
                      } catch (e) {
                        setState(() {
                          downloading = false;
                          error = e.toString();
                        });
                      }
                    },
              child: Text('Download & Install')
            ),
          ],
        ),
      ),
    );
  }

  static Future<File> _downloadApk(
    String url,
    String versionName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      throw Exception('No external storage directory available');
    }

    final path = '${dir.path}/app-$versionName.apk';
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    final dio = Dio(
      BaseOptions(
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 3),
        sendTimeout: const Duration(minutes: 3),
        validateStatus: (s) => s != null && s < 500,
        headers: const {
          'Accept':
              'application/vnd.android.package-archive,application/octet-stream,*/*',
        },
      ),
    );

    final resp = await dio.download(
      url,
      path,
      onReceiveProgress: onProgress,
      options: Options(responseType: ResponseType.bytes),
    );

    if (resp.statusCode != 200) {
      throw Exception('Download failed (${resp.statusCode})');
    }

    final bytes = await file.length();
    if (bytes < 1 * 1024 * 1024) {
      try {
        await file.delete();
      } catch (_) {}
      throw Exception('Downloaded file too small ($bytes bytes) – invalid APK');
    }

    return file;
  }

  static Future<void> _install(File apk) async {
    final installer = FlutterAppInstaller();
    await installer.installApk(filePath: apk.path);
  }

  static void _markInstallFlags() {
    try {
      final box = GetStorage();
      box.write('update_installed_once', true);
      box.write('post_install_prompt_uninstall_old', true);
      debugPrint(
        '[UpdateService] Flags set: update_installed_once=true, post_install_prompt_uninstall_old=true',
      );
    } catch (e) {
      debugPrint('[UpdateService] Failed to set install flags: $e');
    }
  }
}
