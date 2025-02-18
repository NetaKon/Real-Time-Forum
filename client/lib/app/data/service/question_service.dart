import 'package:forum/app/data/models/question.dart';
import 'package:forum/app/data/provider/questions_api.dart';

class QuestionService {
  final _api = QuestionsApi();

  Future<QuestionsResponse?> getAllQuestions() async {
    return _api.getAllQuestions();
  }

  Future<Question?> getQuestionById(String id) async {
    return _api.getQuestionById(id);
  }

  Future<void> postQuestion(String title, String content) async {
    return _api.postQuestion(title, content);
  }

  Future<void> postAnswer(String questionId, String content) async {
    return _api.postAnswer(questionId, content);
  }
}
