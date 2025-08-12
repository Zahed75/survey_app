class SurveyReportModel {
  final String siteCode;
  final String surveyTitle;
  final int score;
  final DateTime timestamp;
  final int? responseId;

  SurveyReportModel({
    required this.siteCode,
    required this.surveyTitle,
    required this.score,
    required this.timestamp,
    this.responseId,
  });

  factory SurveyReportModel.fromMyOutletJson(Map<String, dynamic> json) {
    print('📦 fromMyOutletJson raw: $json');

    final rawTimestamp = json['timestamp'];
    final DateTime parsedTimestamp = rawTimestamp is String
        ? DateTime.tryParse(rawTimestamp) ?? DateTime.now()
        : DateTime.now();

    final surveyIdRaw = json['survey_id'];
    final int? parsedSurveyId =
    surveyIdRaw is int ? surveyIdRaw : int.tryParse(surveyIdRaw.toString());

    return SurveyReportModel(
      siteCode: json['site_code'] ?? '',
      surveyTitle: json['survey_title'] ?? '',
      score: json['total_score'] ?? 0,
      timestamp: parsedTimestamp,
      responseId: parsedSurveyId,
    );
  }

  factory SurveyReportModel.fromNationalJson(Map<String, dynamic> json, String siteCode) {
    final rawTimestamp = json['timestamp'];
    final DateTime parsedTimestamp = rawTimestamp is String
        ? DateTime.tryParse(rawTimestamp) ?? DateTime.now()
        : DateTime.now();

    final responseIdRaw = json['response_id'];
    final int? parsedResponseId =
    responseIdRaw is int ? responseIdRaw : int.tryParse(responseIdRaw.toString());

    return SurveyReportModel(
      siteCode: siteCode,
      surveyTitle: json['survey_title'] ?? '',
      score: json['score'] ?? 0,
      timestamp: parsedTimestamp,
      responseId: parsedResponseId,
    );
  }
}
