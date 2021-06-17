import 'package:flutter/material.dart';
import './question.dart';
import './answer.dart';

class Quiz extends StatelessWidget {
  final List<Map<String, Object>> questions;
  final int questionId;
  final Function answerQuestion;
  Quiz({
    @required this.questions,
    @required this.questionId,
    @required this.answerQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Question(question: questions[questionId]['questionText']),
        ...(questions[questionId]["answerText"] as List<Map<String, dynamic>>)
            .map((answer) => Answer(
                  onPressed: answerQuestion,
                  title: answer['text'],
                  score: answer['score'],
                ))
            .toList(),
      ],
    );
  }
}
