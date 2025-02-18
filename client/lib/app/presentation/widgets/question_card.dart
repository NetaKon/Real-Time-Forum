import 'package:flutter/material.dart';
import 'package:forum/app/data/models/question.dart';
import 'package:forum/app/presentation/screens/question_page.dart';
import '../../styles/app_styles.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionPage(questionId: question.id),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                style: AppStyles.questionTitleStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                question.content,
                style: AppStyles.questionDescriptionStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
