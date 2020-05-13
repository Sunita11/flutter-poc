import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import './landing_page.dart';

class UserLogin extends StatefulWidget {
  final bool shouldPop;
  final Function continuation;
  UserLogin({Key key, this.shouldPop = false, this.continuation})
      : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: GestureDetector(
          onTap: () {
            login(context);
          },
          child: Image.asset(
            "assets/images/google_signin_button.png",
            width: 225.0,
          ),
        ),
      ),
    );
  }

  void login(BuildContext context) async {
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount != null) {
      final googleAuth = await signInAccount.authentication;
      final credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      final result = await auth.signInWithCredential(credential);
      if (widget.shouldPop) {
        Navigator.of(context).pop(result != null);
        return;
      }
      if (widget.continuation != null) {
        widget.continuation();
        return;
      }
      if (result.user != null) {
        await tryCreateUserRecord(
            context: context,);
      }
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed'),
          duration: Duration(seconds: 2),
        ),
      );
      if (widget.shouldPop) {
        Navigator.of(context).pop(false);
        return;
      }
    }
  }
}
