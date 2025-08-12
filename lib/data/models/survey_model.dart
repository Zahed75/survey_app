class Survey {
  final int id;
  final String title;
  final String description;
  final List<Question> questions;
  final String siteCode;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.siteCode,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      siteCode: json['site_code'] ?? '',
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'site_code': siteCode,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final int id;
  final String text;
  final String type;
  final bool isRequired;
  final bool hasMarks;
  final int? marks;
  final List<Choice> choices;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.isRequired,
    required this.hasMarks,
    this.marks,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      isRequired: json['is_required'],
      hasMarks: json['has_marks'],
      marks: json['marks'],
      choices: (json['choices'] as List)
          .map((c) => Choice.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'is_required': isRequired,
      'has_marks': hasMarks,
      'marks': marks,
      'choices': choices.map((c) => c.toJson()).toList(),
    };
  }
}

class Choice {
  final int id;
  final String text;
  final bool isCorrect;

  Choice({required this.id, required this.text, required this.isCorrect});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'is_correct': isCorrect};
  }
}
