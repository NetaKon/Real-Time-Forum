import 'package:flutter/material.dart';
import 'package:forum/app/data/models/question.dart';
import 'package:forum/app/data/service/question_service.dart';
import '../../data/service/socket_service.dart';
import '../../styles/app_styles.dart';

class QuestionPage extends StatefulWidget {
  final String questionId;

  const QuestionPage({super.key, required this.questionId});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final QuestionService _questionService = QuestionService();
  final TextEditingController _answerController = TextEditingController();

  Question? _question;
  List<Answer> _answers = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestion();

    // Register the client to the question room
    SocketService.socket.emit('join_room', {'question_id': widget.questionId});

    // Listen for new answers
    SocketService.socket.on('new_answer', (event) {
      NewAnswerResponse res = NewAnswerResponse.fromJson(event);

      setState(() {
        _answers = res.answers;
      });
    });
  }

  @override
  void dispose() {
    // Unregister the client when leaving the screen
    SocketService.socket.emit('leave_room', {'question_id': widget.questionId});
    SocketService.socket.off('new_answer');
    super.dispose();
  }

  Future<void> _fetchQuestion() async {
    final questionData = await _questionService.getQuestionById(
      widget.questionId,
    );
    setState(() {
      _question = questionData;
      _answers = questionData!.answers;
    });
  }

  Future<void> _submitAnswer() async {
    final content = _answerController.text.trim();
    if (content.isEmpty) {
      _showSnackbar('Please enter an answer');
      return;
    }

    try {
      await _questionService.postAnswer(widget.questionId, content);
      _answerController.clear();
    } catch (e) {
      _showSnackbar('Failed to post answer');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answers', style: AppStyles.appBarTitleStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            _question == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionHeader(),
                      const SizedBox(height: 16),
                      _buildAnswersList(),
                      const SizedBox(height: 16),
                      _buildAnswerInput(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _question?.title ?? 'No Title',
          style: AppStyles.questionTitleStyle.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          _question!.content,
          style: AppStyles.questionDescriptionStyle.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildAnswersList() {
    if (_answers.isEmpty) {
      return const Center(child: Text('No answers have been posted yet.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _answers.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              _answers[index].content,
              style: AppStyles.questionDescriptionStyle.copyWith(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      children: [
        TextField(
          controller: _answerController,
          decoration: const InputDecoration(
            labelText: 'Write your answer',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitAnswer,
          child: const Text('Post Answer'),
        ),
      ],
    );
  }
}
