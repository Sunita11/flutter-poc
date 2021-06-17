import 'package:flutter/material.dart';

class TextControl extends StatelessWidget {
  final Function onPressed;
  TextControl({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: OutlinedButton(
      child: Text('Change text!'),
      style: OutlinedButton.styleFrom(primary: Colors.blue),
      onPressed: onPressed ?? null,
    ));
  }
}
