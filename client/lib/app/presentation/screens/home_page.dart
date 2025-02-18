import 'package:flutter/material.dart';
import 'package:forum/app/presentation/screens/new_question_page.dart';
import 'package:forum/app/presentation/widgets/question_list.dart';
import '../../styles/app_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum', style: AppStyles.appBarTitleStyle),
      ),
      body: const QuestionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewQuestionPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
