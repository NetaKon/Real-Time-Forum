import 'package:flutter/material.dart';
import 'package:forum/app/data/models/question.dart';
import 'package:forum/app/data/service/question_service.dart';
import 'package:forum/app/presentation/widgets/question_card.dart';

class QuestionList extends StatefulWidget {
  const QuestionList({super.key});

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  final QuestionService questionService = QuestionService();

  Future<List<Question>> fetchQuestions() async {
    final data = await questionService.getAllQuestions();
    return data?.data ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FutureBuilder<List<Question>>(
        future: fetchQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading questions'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return QuestionCard(question: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}
