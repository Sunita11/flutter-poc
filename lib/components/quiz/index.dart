import 'package:flutter/material.dart';
import 'quiz.dart';
import 'result.dart';
import '../../common/constants.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _questionId = 0;
  int score = 0;

  void _answerQuestion(int selectedAnswerScore) {
    if (_questionId < Constants.questions.length) {
      setState(() {
        _questionId = _questionId + 1;
        score = score + selectedAnswerScore;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _questionId = 0;
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz!'),
        backgroundColor: Colors.grey[800],
      ),
      body: _questionId < Constants.questions.length
          ? Quiz(
              questions: Constants.questions,
              questionId: _questionId,
              answerQuestion: _answerQuestion,
            )
          : Result(score: score, onPressed: _restartQuiz),
    );
  }
}
