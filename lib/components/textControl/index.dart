import 'package:flutter/material.dart';
import './text.dart';
import './textControl.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  List<String> text = ['Hello', 'World', 'Random', 'Text'];
  int selectedIndex = 0;

  _textChangeHandler() {
    int index = selectedIndex;
    if (index < text.length - 1) {
      index += 1;
    } else {
      index = 0;
    }

    this.setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Assignment 1'),
          backgroundColor: Colors.grey[800],
        ),
        body: Column(children: [
          TextShow(text[selectedIndex]),
          TextControl(
            onPressed: _textChangeHandler,
          )
        ]));
  }
}
