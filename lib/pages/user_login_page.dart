import 'package:BlogApp/pages/user_login.dart';
import 'package:flutter/material.dart';

class UserLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: UserLogin(shouldPop: true,),      
    );
  }
}