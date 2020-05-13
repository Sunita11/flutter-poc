import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
import "main.dart";
import 'util.dart'; //for current user

class CommentScreen extends StatefulWidget {
  final String postId;
  final String postOwner;
  final String postMediaUrl;

  const CommentScreen({this.postId, this.postOwner, this.postMediaUrl});
  @override
  _CommentScreenState createState() => _CommentScreenState(
      postId: this.postId,
      postOwner: this.postOwner,
      postMediaUrl: this.postMediaUrl);
}

class _CommentScreenState extends State<CommentScreen> {
  final String postId;
  final String postOwner;
  final String postMediaUrl;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0);

  _CommentScreenState({this.postId, this.postOwner, this.postMediaUrl});

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comments",
        ),
      ),
      body: buildPage(),
    );
  }


  Widget buildPage() {
    return Column(
      children: [
        Expanded(
          child: buildComments(),
        ),
        Divider(),
        if(currentUserModel ==null)
         Container()
        else 
        ListTile(
          title: TextFormField(
            controller: _commentController,
            decoration: InputDecoration(labelText: 'Write a comment...'),
            onFieldSubmitted: addComment,
          ),
          trailing: OutlineButton(
            onPressed: () {
              addComment(_commentController.text);
            },
            borderSide: BorderSide.none,
            child: Text("Post"),
          ),
        ),
      ],
    );
  }

  Widget buildComments() {
    return FutureBuilder<List<Comment>>(
        future: getComments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          return ListView(
            controller: _scrollController ,
            children: snapshot.data,
            reverse: true,
            shrinkWrap: true,
          );
        });
  }
  //TODO: move this to api
  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];
    printInDebugMode(postId);
    QuerySnapshot data = await Firestore.instance
        .collection("dejavu_comments")
        .document(postId)
        .collection("comments")
        .orderBy('timestamp', descending: true)
        .getDocuments();

    comments.addAll(data.documents.map((d) => Comment.fromDocument(d)));

    //     printInDebugMode(data.documents.length).

    // data.documents.forEach((DocumentSnapshot doc) {
    //   printInDebugMode(Comment.fromDocument(doc));
    //   comments.add(Comment.fromDocument(doc));
    // });
    printInDebugMode(comments.toString());
    return comments;
  }

  addComment(String comment) async {
    _commentController.clear();
    await Firestore.instance
        .collection("dejavu_comments")
        .document(postId)
        .collection("comments")
        .add({
      "username": currentUserModel.username,
      "comment": comment,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "avatarUrl": currentUserModel.photoUrl,
      "userId": currentUserModel.id
    }); 

    //adds to postOwner's activity feed
    if (postOwner == null || postOwner == '') {
      setState(() {});
      return;
    }
    Firestore.instance
        .collection("dejavu_a_feed")
        .document(postOwner)
        .collection("items")
        .add({
      "username": currentUserModel.username,
      "userId": currentUserModel.id,
      "type": "comment",
      "userProfileImg": currentUserModel.photoUrl,
      "commentData": comment,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "postId": postId,
      "mediaUrl": postMediaUrl,
    });
    setState(() {});
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final int timestamp;

  Comment(
      {this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      username: document['username'],
      userId: document['userId'],
      comment: document["comment"],
      timestamp: document["timestamp"],
      avatarUrl: document["avatarUrl"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        Divider(),
      ],
    );
  }
}
