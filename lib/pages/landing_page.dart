import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../create_account.dart';
import '../main.dart';
import '../models/post_entity.dart';
import '../models/user.dart';
import '../profile_page.dart';
import '../util.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool stopAutoNav = false;
  bool checkForLoginCached;
  bool checkForFirstTimeUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool setupNotificationDone = false;
  StreamSubscription iosSubscription;

  @override
  void initState() {
    if (Platform.isIOS) {
      iosSubscription = _firebaseMessaging.onIosSettingsRegistered.listen((data) {});
      _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    printInDebugMode('build called for landing page');
    return Scaffold(
      body: stopAutoNav
          ? Container()
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(blurRadius: 10, color: Theme.of(context).primaryColorDark, offset: Offset(4, 4))],
                        ),
                        child: Image.asset(
                          'assets/images/ic_launcher.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        APP_NAME,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'SourceSansPro',
                          color: Theme.of(context).primaryTextTheme.headline.color,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Theme.of(context).primaryColorDark,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 80),
                      Text(
                        APP_TAGLINE,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryTextTheme.headline.color,
                          fontFamily: 'Open-Sans',
                          fontWeight: FontWeight.w200,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Theme.of(context).primaryColorDark,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 100),
                      FutureBuilder(
                        future: Future.wait([_checkForLogin(), _checkForFirstTimeUser()]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if(!setupNotificationDone)
                              _setUpNotifications();
                            if ((snapshot.data[0] || snapshot.data[1]) && stopAutoNav == false) {
                              Future.delayed(
                                  Duration(
                                    milliseconds: 100,
                                  ), () async {
                                Navigator.of(context).pushReplacementNamed('home');
                              });

                              return Container();
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        stopAutoNav = true;
                                        login();
                                      },
                                      child: Image.asset(
                                        "assets/images/google_signin_button.png",
                                        width: 225.0,
                                      ),
                                    ),
                                  ),
                                  MaterialButton(
                                    minWidth: 215,
                                    onPressed: () {
                                      stopAutoNav = true;
                                      skipForNowClickListener();
                                    },
                                    color: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Text(
                                      'Skip for now',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<bool> _checkForFirstTimeUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('FIRST_LAUNCH') && sharedPreferences.getBool('FIRST_LAUNCH')) {
      return Future.value(true);
    } else {
      sharedPreferences.setBool('FIRST_LAUNCH', true);
      return Future.value(false);
    }
  }

  void login() async {
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount != null) {
      final googleAuth = await signInAccount.authentication;
      final credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      final result = await auth.signInWithCredential(credential);
      if (result.user != null) {
        await tryCreateUserRecord(
          context: context,
          continuation: () async {
            printInDebugMode('pushing home');
            Navigator.of(context).pushNamed('home');
          },
        );
      }
      //Navigator.of(context).pushReplacementNamed('home');
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _checkForLogin() async {
    GoogleSignInAccount user = googleSignIn.currentUser;

    if (user == null) {
      try {
        user = await googleSignIn.signInSilently();
        await tryCreateUserRecord(context: context);
      } on Exception {
        //do nothing
      }
    }

    if (await auth.currentUser() == null && user != null) {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
    }
    return Future.value(currentUserModel != null);
  }

  Future skipForNowClickListener() async {
    printInDebugMode('pushing category list');
    await Navigator.of(context).pushNamed('category_list');
    printInDebugMode('pushing home');
    Navigator.of(context).pushNamed('home');
  }

  _handleNotification(Map<String, dynamic> msg) async {
    Map message = Platform.isIOS ? msg : msg['data'];

    if (message == null) {
      return;
    }
    if (message.containsKey('click_action') && message['click_action'].toString() == 'FLUTTER_NOTIFICATION_CLICK') {
      final type = message['type'];
      if (type == 'post_details') {
        final data = message['data'];
        printInDebugMode('payload data = $data');
        if (data != null) {
          try {
            final postEntity = PostEntity.fromJSON(json.decode(data));
            printInDebugMode('message postEntity = ${postEntity.toString()}');
            expandPostTile(context, postEntity);
            print('shown post to user');
          } catch (e) {
            print(e.toString());
          }
        }
      }
    } else {
      print('message click action = ${message['click_action']}');
    }
  }

  Future<Null> _setUpNotifications() async {
    _firebaseMessaging.setAutoInitEnabled(true);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        int notificationCount = 1;
        if (sharedPreferences.containsKey('NOTIFICATION_COUNT')) {
          notificationCount += sharedPreferences.getInt('NOTIFICATION_COUNT');
        }
        sharedPreferences.setInt('NOTIFICATION_COUNT', notificationCount);
        printInDebugMode2('on message $message');
//          _handleNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        printInDebugMode2('on resume $message');
        _handleNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        printInDebugMode2('on launch $message');
        _handleNotification(message);
      },
    );

    _firebaseMessaging.getToken().then((token) {
      printInDebugMode2("Firebase Messaging Token: " + token);

      if (currentUserModel != null)
        Firestore.instance.collection("dejavu_users").document(currentUserModel.id).updateData({"androidNotificationToken": token});

      printInDebugMode2('notification token = ${token}');
    }).catchError((error) {
      printInDebugMode2('error while getting notification token');
    });

    _firebaseMessaging.onTokenRefresh.listen((newToken) { 
      printInDebugMode2('token refreshed with new token $newToken');
      if (currentUserModel != null)
        Firestore.instance.collection("dejavu_users").document(currentUserModel.id).updateData({"androidNotificationToken": newToken});
    });

    setupNotificationDone = true;
  }

  @override
  void dispose() {
    if (iosSubscription != null) {
      iosSubscription.cancel();
    }
    super.dispose();
  }
}

class CreateUsername extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          automaticallyImplyLeading: false,
          title: Text('Fill out missing data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              child: CreateAccount(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> tryCreateUserRecord({BuildContext context, Function continuation, bool retry = false}) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  printInDebugMode('tryCreateUserRecord');
  if (user == null) {
    return null;
  }
  var userRecord = await ref.document(user.id).get();
  if (userRecord.data == null) {
    // no user record exists, time to create
    printInDebugMode('no userdata');
    var result = await Navigator.of(context).pushNamed('create_username');

    if (result != null) {
      String userName = result.toString();
      await ref.document(user.id).setData(
        {
          "id": user.id,
          "username": userName,
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "followers": {},
          "following": {},
        },
      );
      userRecord = await ref.document(user.id)?.get();
    }
  }
  if (userRecord != null && userRecord.data != null) {
    currentUserModel = User.fromDocument(userRecord);
    if (continuation != null) {
      continuation();
    }
  }
  return null;
}
