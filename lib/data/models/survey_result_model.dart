class SurveyResult {
  final int responseId;
  final String surveyTitle;
  final int submittedByUserId;
  final DateTime submittedAt;
  final ResultSummary overall;
  final List<CategoryResult> categories;
  final String? siteCode;
  final String? siteName;
  final DateTime? timestamp;

  SurveyResult({
    required this.responseId,
    required this.surveyTitle,
    required this.submittedByUserId,
    required this.submittedAt,
    required this.overall,
    required this.categories,
    this.siteCode,
    this.siteName,
    this.timestamp,
  });

  factory SurveyResult.fromJson(Map<String, dynamic> json) => SurveyResult(
    responseId: json['response_id'],
    surveyTitle: json['survey_title'],
    submittedByUserId: json['submitted_by_user_id'],
    submittedAt: DateTime.parse(json['submitted_at']),
    overall: ResultSummary.fromJson(json['overall']),
    categories: List<CategoryResult>.from(
      json['categories'].map((x) => CategoryResult.fromJson(x)),
    ),
    siteCode: json['site_code'],        // ✅ already present
    siteName: json['site_name'],        // ✅ new
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'])
        : null,
  );



  Map<String, dynamic> toJson() => {
    'response_id': responseId,
    'survey_title': surveyTitle,
    'submitted_by_user_id': submittedByUserId,
    'submitted_at': submittedAt.toIso8601String(),
    'overall': overall.toJson(),
    'categories': categories.map((x) => x.toJson()).toList(),
    'site_code': siteCode,
    'site_name': siteName,
    'timestamp': timestamp?.toIso8601String(),
  };
}

class ResultSummary {
  final double obtainedMarks;
  final double totalMarks;
  final double percentage;

  ResultSummary({
    required this.obtainedMarks,
    required this.totalMarks,
    required this.percentage,
  });

  factory ResultSummary.fromJson(Map<String, dynamic> json) => ResultSummary(
    obtainedMarks: (json['obtained_marks'] as num).toDouble(),
    totalMarks: (json['total_marks'] as num).toDouble(),
    percentage: (json['percentage'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'obtained_marks': obtainedMarks,
    'total_marks': totalMarks,
    'percentage': percentage,
  };
}

class CategoryResult {
  final String name;
  final double obtainedMarks;
  final double totalMarks;
  final double percentage;
  final List<QuestionResult> questions;

  CategoryResult({
    required this.name,
    required this.obtainedMarks,
    required this.totalMarks,
    required this.percentage,
    required this.questions,
  });

  factory CategoryResult.fromJson(Map<String, dynamic> json) => CategoryResult(
    name: json['name'],
    obtainedMarks: (json['obtained_marks'] as num).toDouble(),
    totalMarks: (json['total_marks'] as num).toDouble(),
    percentage: (json['percentage'] as num).toDouble(),
    questions: List<QuestionResult>.from(
      json['questions'].map((x) => QuestionResult.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'obtained_marks': obtainedMarks,
    'total_marks': totalMarks,
    'percentage': percentage,
    'questions': questions.map((x) => x.toJson()).toList(),
  };
}



class QuestionResult {
  final String text;
  final String type;
  final double marks;
  final double obtained;
  final String? answer;
  final SelectedChoice? selectedChoice;
  final String? imageUrl;
  final Location? location;

  QuestionResult({
    required this.text,
    required this.type,
    required this.marks,
    required this.obtained,
    this.answer,
    this.selectedChoice,
    this.imageUrl,
    this.location,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
    text: json['text'],
    type: json['type'],
    marks: (json['marks'] as num).toDouble(),
    obtained: (json['obtained'] as num).toDouble(),
    answer: json['answer'],
    selectedChoice: json['selected_choice'] != null
        ? SelectedChoice.fromJson(json['selected_choice'])
        : null,
    imageUrl: json['image_url'],
    location: json['location'] != null
        ? Location.fromJson(json['location'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'type': type,
    'marks': marks,
    'obtained': obtained,
    'answer': answer,
    'selected_choice': selectedChoice?.toJson(),
    'image_url': imageUrl,
    'location': location?.toJson(),
  };
}


class SelectedChoice {
  final int id;
  final String text;

  SelectedChoice({
    required this.id,
    required this.text,
  });

  factory SelectedChoice.fromJson(Map<String, dynamic> json) =>
      SelectedChoice(
        id: json['id'],
        text: json['text'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
  };
}

class Location {
  final double lat;
  final double lon;

  Location({
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
  };
}




