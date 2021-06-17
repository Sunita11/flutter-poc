import 'package:flutter/material.dart';
import 'components/buttons/button.dart';
import 'components/quiz/index.dart';
import 'components/textControl/index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select your language',
      home: HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'quiz':
            return MaterialPageRoute(builder: (ctx) => QuizPage());
            break;
          case 'assignment1':
            return MaterialPageRoute(builder: (ctx) => AssignmentPage());
            break;
          default:
            throw Exception('route does not exists');
            break;
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter'),
          backgroundColor: Colors.grey[800],
        ),
        body: Buttons());
  }
}
