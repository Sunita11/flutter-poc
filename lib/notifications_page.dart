import 'package:BlogApp/pages/user_login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ui_post.dart'; //needed to open image when clicked
import 'profile_page.dart'; // to open the profile page when username clicked
import 'main.dart'; //needed for currentuser id

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    {

  @override
  Widget build(BuildContext context) {
    if (currentUserModel == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Login'),
          ),
          body: UserLogin(continuation: _setStateInternal,));
    }
    //super.build(context); // reloads state when opened again
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
        ),
      ),
      body: buildActivityFeed(),
    );
  }
  
  _setStateInternal () {
    setState(() {
      
    });
  }

  buildActivityFeed() {
    return Container(
      child: FutureBuilder(
          future: getFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CircularProgressIndicator());
            else {
              return ListView(children: snapshot.data);
            }
          }),
    );
  }

  getFeed() async {
    List<NotificationsItem> items = [];
    var snap = await Firestore.instance
        .collection('dejavu_a_feed')
        .document(currentUserModel.id)
        .collection("items")
        .orderBy("timestamp")
        .getDocuments();

    for (var doc in snap.documents) {
      items.add(NotificationsItem.fromDocument(doc));
    }
    return items;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}

class NotificationsItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // types include liked photo, follow user, comment on photo
  final String mediaUrl;
  final String mediaId;
  final String userProfileImg;
  final String commentData;

  NotificationsItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.mediaId,
      this.userProfileImg,
      this.commentData,
      this.actionText});

  factory NotificationsItem.fromDocument(DocumentSnapshot document) {
    final type = document['type'];
    String actionText;
    if (type == "like") {
      actionText = " updooted your post.";
    } else if (type == "follow") {
      actionText = " starting following you.";
    } else if (type == "comment") {
      actionText = " commented: ${document["commentData"]}";
    } else {
      actionText = "Error - invalid activityFeed type: $type";
    }

    return NotificationsItem(
      username: document['username'],
      userId: document['userId'],
      type: document['type'],
      mediaUrl: document['mediaUrl'],
      mediaId: document['postId'],
      userProfileImg: document['userProfileImg'],
      commentData: document["commentData"],
      actionText: actionText,
    );
  }

  final String actionText;

  Widget configureItem(BuildContext context) {
    if (type == "like" || type == "comment") {
      return GestureDetector(
        onTap: () {
          openPost(context, mediaId);
        },
        child: Container(
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fill,
                alignment: FractionalOffset.topCenter,
                image: NetworkImage(mediaUrl),
              )),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 70,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 15.0),
              child: CircleAvatar(
                radius: 23.0,
                backgroundImage: NetworkImage(userProfileImg),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      openProfile(context, userId);
                    },
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        actionText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
                child: Align(
                    child: Padding(
                      child: configureItem(context),
                      padding: EdgeInsets.all(15.0),
                    ),
                    alignment: AlignmentDirectional.bottomEnd))
          ],
        ),
      ),
    );
  }
}

openPost(BuildContext context, String postId) {
  Navigator.of(context)
      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
    return Center(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Photo',
            ),
          ),
          body: ListView(
            children: <Widget>[
              Container(
                child: UIPostFromPostId(
                  id: postId,
                  cardColor: Theme.of(context).cardColor,
                ),
              ),
            ],
          )),
    );
  }));
}
