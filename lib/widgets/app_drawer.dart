import 'package:BlogApp/core/analytics.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../category_list.dart';
import '../main.dart';

class AppDrawer extends StatefulWidget {
  final HttpClient httpClient;

  const AppDrawer({Key key, this.httpClient}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  @override
  void initState() {
    super.initState();
    Analytics().drawerShown();
  }

  @override
  void dispose() {
    super.dispose();
    Analytics().drawerClosed();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: CategoryList(
        httpClient: widget.httpClient,
        userId: googleSignIn?.currentUser?.id,
      ),
    );
  }
}
