// apk_update_model.dart
class UpdateModel {
  /// Displayed as "App Version" in Profile
  final String version;        // maps from API: versionName, e.g. "1.0.0+4"

  /// Displayed as "+<buildNumber>" in Profile
  final int buildNumber;       // maps from API: versionCode, e.g. 4

  UpdateModel({
    required this.version,
    required this.buildNumber,
  });

  /// New API shape:
  /// {
  ///   "code":200,
  ///   "message":"OK",
  ///   "data":{
  ///     "versionName":"1.0.0+4",
  ///     "versionCode":4,
  ///     "minSupportedCode":1,
  ///     "apkUrl":"https://.../survey-v-4.apk",
  ///     "isMandatory":true,
  ///     "changelog":"Latest Changes",
  ///     "releasedAt":"2025-08-11T21:58:24Z"
  ///   }
  /// }
  factory UpdateModel.fromNewApi(Map<String, dynamic> data) {
    return UpdateModel(
      version: (data['versionName'] ?? '').toString(),
      buildNumber: (data['versionCode'] ?? 0) as int,
    );
  }
}
