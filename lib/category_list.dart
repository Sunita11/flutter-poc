import 'dart:convert';
import 'dart:io';

import 'package:BlogApp/core/analytics.dart';
import 'package:BlogApp/main.dart';
import 'package:flutter/material.dart';

import 'core/repository.dart';
import 'feed_page.dart';
import 'util.dart';

class CategoryList extends StatefulWidget {
  final String userId;
  final HttpClient httpClient;

  const CategoryList({this.userId, @required this.httpClient})
      : assert(httpClient != null);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          printInDebugMode("category json = ${snapshot.data[0]}");
          printInDebugMode("subscription json = ${snapshot.data[1]}");

          final categoryList = json.decode(snapshot.data[0]);
          final subscribedCategories = snapshot.data[1] as List<String>;
          return Container(
            child: ListView.separated(
                itemBuilder: (ctx, index) {
                  return ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              NetworkImage(categoryList[index]['poster_url'])),
                    ),
                    trailing: CategoryItemAction(
                      subscriptionStatus: subscribedCategories
                          .contains(categoryList[index]['id']),
                      categoryId: categoryList[index]['id'],
                      userId: widget.userId,
                      httpClient: widget.httpClient,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<bool>(
                          builder: (BuildContext context) {
                            return FeedPage(
                              title: categoryList[index]['name'],
                              feedKey: 'category',
                              feedValue: categoryList[index]['id'],
                            );
                          },                          
                        ),
                      );
                    },
                    title: Text(categoryList[index]['name']),
                  );
                },
                separatorBuilder: (ctx, index) => Divider(
                      color: Colors.black12,
                      thickness: 2,
                    ),
                itemCount: categoryList.length),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error while fetching details'));
        }
        return Container();
      },
      future: Future.wait([
        Repository.getResponse(
            widget.httpClient,
            'https://us-central1-dejavu-d75eb.cloudfunctions.net/categories',
            Duration(days: 1).inMinutes),
        widget.userId == null
            ? Future.value(const <String>[])
            : Repository.getResponse(
                widget.httpClient,
                'https://us-central1-dejavu-d75eb.cloudfunctions.net/typeList?uid=${googleSignIn.currentUser.id}&type=categories',
              )
                .then((value) => Future.value(json.decode(value)))
                .then((list) =>
                    (list as List).map<String>((e) => e.toString()).toList())
                .catchError((e) => Future.value([])),
      ]),
      initialData: [[], const <String>[]],
      key: ValueKey('DRAWER_ACTIONS'),
    );
  }
  
}

class CategoryItemAction extends StatefulWidget {
  final bool subscriptionStatus;
  final String userId;
  final String categoryId;
  final HttpClient httpClient;

  const CategoryItemAction(
      {@required this.subscriptionStatus,
      this.userId,
      this.categoryId,
      this.httpClient})
      : assert(
            subscriptionStatus != null && categoryId != null);

  @override
  _CategoryItemActionState createState() =>
      _CategoryItemActionState(subscriptionStatus: subscriptionStatus);
}

class _CategoryItemActionState extends State<CategoryItemAction> {
  bool subscriptionStatus = false;

  _CategoryItemActionState({@required this.subscriptionStatus});

  @override
  Widget build(BuildContext context) {
    final icon = subscriptionStatus
        ? Icons.notifications_active
        : Icons.notifications_none;
//    final label = _subscriptionStatus ? 'Subscribed' : 'Subscribe';
    return IconButton(
      onPressed: () async {
        if(currentUserModel == null) {
          Navigator.of(context).pushNamed('login');
          return;
        }
        bool previousStatus = subscriptionStatus;
        setState(() {
          subscriptionStatus = !subscriptionStatus;
        });

        final subscriptionAction =
            subscriptionStatus ? "subscribe" : "unsubscribe";
        try {
          final response = await Repository.getResponse(
            widget.httpClient,
            'https://us-central1-dejavu-d75eb.cloudfunctions.net/subscriptionHandler?uid=${googleSignIn.currentUser.id}&category=${widget.categoryId}&action=$subscriptionAction',
          );
          printInDebugMode('subscription : $response');
          if(subscriptionStatus)
            Analytics().categorySubscribed(widget.categoryId, );
          else
            Analytics().categoryUnsubscribed(widget.categoryId, );
        } catch (error) {
          setState(() {
            subscriptionStatus = previousStatus;
          });
        }
      },
      icon: Icon(icon),
//      label: Text(label),
    );
  }
}
