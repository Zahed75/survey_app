import 'package:flutter/services.dart';

class MigrationHelper {
  static const _ch = MethodChannel('app.migration');
  static const oldPackage = 'com.shwapno.survey'; // OLD app id

  static Future<bool> isOldInstalled() async {
    try {
      final ok = await _ch.invokeMethod<bool>('isInstalled', {'package': oldPackage});
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> uninstallOld() async {
    await _ch.invokeMethod('uninstall', {'package': oldPackage});
  }
}
