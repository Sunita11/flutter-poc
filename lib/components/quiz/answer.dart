import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final Function onPressed;
  final String title;
  final int score;
  Answer({this.onPressed, this.title, this.score});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.all(8.0),
        child: RaisedButton(
          color: Colors.blueAccent,
          onPressed: onPressed != null
              ? () {
                  onPressed(score);
                }
              : null,
          child: Text(title),
        ));
  }
}
