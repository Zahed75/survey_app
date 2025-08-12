class UpdateModel {
  final String version;
  final int buildNumber;

  UpdateModel({
    required this.version,
    required this.buildNumber,
  });

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      version: json['version'],
      buildNumber: json['build_number'],
    );
  }
}
