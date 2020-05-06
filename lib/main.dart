import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feed-page.dart';

void main() => runApp(BlogApp());

class BlogApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select your language',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        primaryColor: Color.fromARGB(255, 27, 34, 39),
        primaryColorDark: Color.fromARGB(255, 27, 34, 39),
        scaffoldBackgroundColor: Color.fromARGB(255, 34, 36, 38),
        primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(
          bodyColor: Color.fromARGB(255, 140, 162, 183),
          displayColor: Color.fromARGB(255, 140, 162, 183),
          fontFamily: 'Poppins',
        ),
        primaryColorBrightness: Brightness.dark,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (ctx) => HomePage());
            break;
          case 'home':
            return MaterialPageRoute(builder: (ctx) => HomePage());
            break;
          default:
            throw Exception('route does not exists');
            break;
        }
      },
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isUserRecordChecked = true;

  void initState() {
    super.initState();
    // checkForMissingInfo();
  }

  checkForMissingInfo() async {
      /*await tryCreateUserRecord (
        context: context,
      );
      setState((){
        isUserRecordChecked = true;
      })*/
  }

  @override
  Widget build(BuildContext context) {
    return isUserRecordChecked ?
        HomePageInternal(title: 'HomePage')
        : Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
          width: 40,
          height: 40
        )
      )
    );
  }
}

class HomePageInternal extends StatefulWidget {
  HomePageInternal({Key key, this.title}): super(key: key);

  final String title;

  @override
  _HomePageInternalState createState() => _HomePageInternalState();
}

class _HomePageInternalState extends State<HomePageInternal> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: WrapperPage(
              key: ValueKey('MainFeed'),
        ),
      )
    );
  }
}