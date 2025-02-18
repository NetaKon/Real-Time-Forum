import 'dart:convert';

QuestionsResponse questionsResponseFromJson(String str) =>
    QuestionsResponse.fromJson(json.decode(str));

Question questionFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  if (jsonData.containsKey("data")) {
    // If the JSON contains "data", extract the first question
    return Question.fromJson(jsonData["data"][0]);
  }
  return Question.fromJson(jsonData);
}

List<Answer> answersFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  return List<Answer>.from(jsonData["answers"].map((x) => Answer.fromJson(x)));
}

class QuestionsResponse {
  List<Question> data;
  int? page;
  bool? hasNext;
  String? next;
  int? totalResults;

  QuestionsResponse({
    required this.data,
    this.page,
    this.hasNext,
    this.next,
    this.totalResults,
  });

  factory QuestionsResponse.fromJson(Map<String, dynamic> json) =>
      QuestionsResponse(
        data: List<Question>.from(
          json["data"].map((x) => Question.fromJson(x)),
        ),
        page: json["page"],
        hasNext: json["has_next"],
        next: json["next"],
        totalResults: json["total_results"],
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "page": page,
    "has_next": hasNext,
    "next": next,
    "total_results": totalResults,
  };
}

class Question {
  String id;
  String title;
  String content;
  DateTime createdAt;
  List<Answer> answers;

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    createdAt: DateTime.parse(json["created_at"]),
    answers: List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "created_at": createdAt.toIso8601String(),
    "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
  };
}

class Answer {
  String content;
  DateTime createdAt;

  Answer({required this.content, required this.createdAt});

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    content: json["content"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "content": content,
    "created_at": createdAt.toIso8601String(),
  };
}

class NewAnswerResponse {
  String questionId;
  List<Answer> answers;

  NewAnswerResponse({required this.answers, required this.questionId});

  factory NewAnswerResponse.fromJson(Map<String, dynamic> json) =>
      NewAnswerResponse(
        questionId: json["question_id"],
        answers: List<Answer>.from(
          json["answers"].map((x) => Answer.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
  };
}
