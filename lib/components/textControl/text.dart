import 'package:flutter/material.dart';

class TextShow extends StatelessWidget {
  final String text;
  TextShow(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      margin: EdgeInsets.all(24.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.0, color: Colors.blue),
      ),
    ));
  }
}
