import 'dart:convert';

import 'package:BlogApp/core/analytics.dart';
import 'package:BlogApp/models/post_entity.dart';
import 'package:BlogApp/pages/landing_page.dart';
import 'package:BlogApp/pages/user_login_page.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart';
import 'core/navigation_service.dart';
import 'feed_page.dart';
import 'pages/category_list_page.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
//import 'create_account.dart';
import 'dart:io' show HttpClient, Platform;
import 'models/user.dart';
import 'util.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
final ref = Firestore.instance.collection('dejavu_users');
final GetIt locator = GetIt();

User currentUserModel;
HttpClient httpClient = HttpClient();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // after upgrading flutter this is now necessary
  setLocaleMessages('en', EnShortMessages());
  locator.registerLazySingleton(() => NavigationService());
  // enable timestamps in firebase
  Firestore.instance
      .settings()
      .then((_) {
        printInDebugMode('[Main] Firestore timestamps in snapshots set');
      })
      .then((value) => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
            runApp(BlogApp());
          }))
      .catchError((onError) => printInDebugMode('[Main] Error setting timestamps in snapshots'));
}

class BlogApp extends StatelessWidget {
  // This widget is the root of your application.
  final httpClient = HttpClient();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: Analytics().analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlogApp',
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
          primaryIconTheme: ThemeData.dark().primaryIconTheme.copyWith(
                color: Color.fromARGB(255, 140, 162, 183),
              ),
          primaryColorBrightness: Brightness.dark,
          cardColor: Color.fromARGB(255, 6, 7, 9),
          accentColor: Color.fromARGB(255, 0, 204, 118),
          floatingActionButtonTheme: ThemeData.dark().floatingActionButtonTheme.copyWith(backgroundColor: Color.fromARGB(255, 0, 204, 118))),
      initialRoute: '/',
      // }
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (ctx) => LandingPage());
            break;

          case 'home':
            return MaterialPageRoute(builder: (ctx) => HomePage());
            break;
          case 'category_list':
            return MaterialPageRoute(
              builder: (ctx) => CategoryListPage(
                httpClient: httpClient,
              ),
            );
            break;
          case 'login':
            return MaterialPageRoute(
              builder: (ctx) => UserLoginPage(),
            );
            break;
          case 'create_username':
            return MaterialPageRoute(
              builder: (ctx) => CreateUsername(),
            );
            break;
          case 'notifications_page':
            return MaterialPageRoute(
              builder: (ctx) => NotificationsPage(),
            );
            break;
          case 'profile_page':
            return MaterialPageRoute(builder: (ctx) => ProfilePage(userId: settings.arguments));
            break;
          default:
            throw Exception('route does not exists');
            break;
        }
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => LandingPage());
      },
      navigatorObservers: <NavigatorObserver>[BlogApp.observer],
      debugShowCheckedModeBanner: false,
      navigatorKey: locator<NavigationService>().navigatorKey,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bool isUserRecordChecked = false;
  bool isUserRecordChecked = true;
  @override
  void initState() {
    super.initState();
    // checkForMissingInfo();
  }

  checkForMissingInfo() async {
    await tryCreateUserRecord(
      context: context,
    );
    setState(() {
      isUserRecordChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    printInDebugMode('build called for homestate');
    return isUserRecordChecked
        ? HomePageInternal(title: "BlogApp Sunita")
        : Scaffold(
            body: Center(
                child: Container(
              child: CircularProgressIndicator(),
              width: 40,
              height: 40,
            )),
          );
  }
}

class HomePageInternal extends StatefulWidget {
  HomePageInternal({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageInternalState createState() => _HomePageInternalState();
}

StackedPageController pageController;

class _HomePageInternalState extends State<HomePageInternal> {
  final httpClient = HttpClient();

  Future<bool> _popPage() async {
    return await pageController.popPage();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _popPage,
      child: Scaffold(
        body: FeedPage(
          key: ValueKey('MainFeed'),
          appendCommunityFeed: true,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    pageController = StackedPageController(keepPage: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class StackedPageController extends PageController {
  final List<int> backstack = List();
  StackedPageController({
    initialPage = 0,
    keepPage = true,
    viewportFraction = 1.0,
  }) : super(initialPage: initialPage, keepPage: keepPage, viewportFraction: viewportFraction);

  Future<bool> popPage() async {
    if (backstack.isEmpty) {
      return Future.value(true);
    } else {
      int pageNumber = backstack.removeLast();
      super.jumpToPage(pageNumber);
      return Future.value(false);
    }
  }

  @override
  void jumpToPage(int page) {
    if (this.page == page) return;
    backstack.add(this.page.round());
    super.jumpToPage(page);
  }

  @override
  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    if (this.page == page) return Future.value();
    backstack.add(this.page.round());
    return super.animateToPage(page, duration: duration, curve: curve);
  }

  @override
  Future<void> nextPage({Duration duration, Curve curve}) {
    backstack.add(this.page.round());
    return super.nextPage(duration: duration, curve: curve);
  }

  @override
  Future<void> previousPage({Duration duration, Curve curve}) {
    backstack.add(this.page.round());
    return super.previousPage(duration: duration, curve: curve);
  }
}
