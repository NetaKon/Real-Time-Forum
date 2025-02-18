import 'dart:convert';
import 'package:forum/app/data/models/question.dart';
import 'package:http/http.dart' as http;

class QuestionsApi {
  static const String baseUrl = 'http://localhost:5000/questions';

  Future<QuestionsResponse> getAllQuestions() async {
    var response = await http.get(Uri.parse(baseUrl));

    return questionsResponseFromJson(
      const Utf8Decoder().convert(response.bodyBytes),
    );
  }

  Future<Question> getQuestionById(String id) async {
    var response = await http.get(Uri.parse('$baseUrl/$id'));

    return questionFromJson(const Utf8Decoder().convert(response.bodyBytes));
  }

  Future<void> postQuestion(String title, String content) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'content': content}),
    );
  }

  Future<void> postAnswer(String questionId, String content) async {
    await http.post(
      Uri.parse('$baseUrl/$questionId'),
      body: jsonEncode({'content': content}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
