import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  _onPressed(BuildContext context) {
    Navigator.of(context).pushNamed('quiz');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Container(
                width: 300.0,
                alignment: Alignment.center,
                child: Text('Raised button - Quiz!'),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('quiz');
              },
            ),
            // new button flutter2
            ElevatedButton(
              child: Container(
                width: 300.0,
                alignment: Alignment.center,
                child: Text('Elevated button - assignment1!'),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('assignment1');
              },
            ),
            FlatButton(
              child: Container(
                width: 300.0,
                alignment: Alignment.center,
                child: Text('Flat button!'),
              ),
              textColor: Colors.blue,
              onPressed: () {
                _onPressed(context);
              },
            ),
            TextButton(
              child: Container(
                width: 300.0,
                alignment: Alignment.center,
                child: Text('Text button!'),
              ),
              style: TextButton.styleFrom(primary: Colors.orange),
              onPressed: () {
                _onPressed(context);
              },
            ),
            OutlineButton(
              child: Container(
                width: 300.0,
                alignment: Alignment.center,
                child: Text('Outline button!'),
              ),
              borderSide: BorderSide(color: Colors.blue),
              textColor: Colors.blue,
              onPressed: () {
                _onPressed(context);
              },
            ),
            OutlinedButton(
              child: Container(
                width: 300.0,
                alignment: Alignment.center,
                child: Text('Outlined button!'),
              ),
              style: OutlinedButton.styleFrom(primary: Colors.orange),
              onPressed: () {
                _onPressed(context);
              },
            )
          ]),
    );
  }
}
