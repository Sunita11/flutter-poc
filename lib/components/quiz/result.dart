import 'package:flutter/material.dart';

class Result extends StatelessWidget {
  final int score;
  final Function onPressed;
  Result({this.score, this.onPressed});

  String get resultPhrase {
    String result = 'You did it.';

    if (score <= 12) {
      result = 'You are awesome and innocent';
    }
    if (score <= 16) {
      result = 'Pretty likeable!';
    }
    if (score <= 20) {
      result = 'Strange!';
    }
    if (score <= 30) {
      result = 'So bad!';
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(resultPhrase,
              style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold)),
        ),
        Padding(
            padding: EdgeInsets.all(20.0),
            child: FlatButton(
              child: Text('Restart Quiz!'),
              textColor: Colors.blueAccent,
              onPressed: onPressed ?? null,
            ))
      ],
    );
  }
}
