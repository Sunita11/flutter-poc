import 'package:flutter/material.dart';
import 'package:flutter_twitter/flutter_twitter.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

_signInTwitter(context) async {
  var twitterLogin = new TwitterLogin(
    consumerKey: 'O9AvyC4qDvCCdxn1LaypRVF8E',
    consumerSecret: '4qAEinQ6L3Wba25sZVllSEtb8vx6i1zuwIHnD3vT4MyDBgd0CI',
  );

  final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        print('login successfull');
        Navigator.of(context).pushNamed('home');
        // _sendTokenAndSecretToServer(session.token, session.secret);
        break;
      case TwitterLoginStatus.cancelledByUser:
        print('login cancelled');
        // _showCancelMessage();
        break;
      case TwitterLoginStatus.error:
        var msg = result.errorMessage;
        print('error occurred: $msg');
        // _showErrorMessage(result.error);
        break;
    }
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text('Login page header', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    letterSpacing: -0.01,
                    color: Color(0xFFDADFE7),
                  ),
                      textAlign: TextAlign.left),
                ]
            )
        ),
        ),
        body: Center(
          child: Container(
          height: 50.0,
          child: RaisedButton(
            onPressed: () {
              _signInTwitter(context);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
            padding: EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0)
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                alignment: Alignment.center,
                child: Text(
                  "Login twitter",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        ),
        )
    );
  }
}