import 'dart:async';

import 'package:BlogApp/post_footer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import 'comment_screen.dart';
import 'core/repository.dart';
import 'main.dart';
import 'models/post_entity.dart';
import 'post_header.dart';
import 'util.dart';
import 'widgets/post_video_player.dart';

class UIPost extends StatefulWidget {
  final String communityId;
  final String communityPostId;
  final String description;
  final int height;
  final bool isVideo;
  final Key key;
  final Map likes;
  final String mediaUrl;
  final String ownerId;
  final Function persists;
  final String postId;
  final String source;
  final List tags;
  final int timestamp;
  final String username;
  final int width;
  final String categoryId;
  final String categoryName;
  final Color cardColor;
  final int commentCount;
  final String author;
  final String dataSource;
  final String audioUrl;
  final String photoUrl;
  UIPost({
    this.key,
    this.mediaUrl,
    this.username,
    this.description,
    this.likes,
    this.postId,
    this.ownerId,
    this.timestamp,
    this.isVideo,
    this.persists,
    this.height,
    this.width,
    this.communityId,
    this.communityPostId,
    this.source = "dejavu",
    this.tags = const [],
    this.categoryId,
    this.categoryName,
    this.cardColor,
    this.commentCount,
    this.audioUrl,
    this.author,
    this.dataSource,
    this.photoUrl,
  }) : super(key: key);

  factory UIPost.fromEntity({PostEntity postEntity, Key key, Function persists, Color cardColor}) {
    return UIPost(
      categoryId: postEntity.categoryId,
      communityId: postEntity.communityId,
      communityPostId: postEntity.communityPostId,
      description: postEntity.description,
      height: postEntity.hashCode,
      isVideo: postEntity.isVideo,
      likes: postEntity.likes,
      mediaUrl: postEntity.mediaUrl,
      ownerId: postEntity.ownerId,
      postId: postEntity.postId,
      source: postEntity.source,
      tags: postEntity.tags,
      timestamp: postEntity.timestamp,
      username: postEntity.username,
      width: postEntity.width,
      key: key,
      categoryName: postEntity.categoryLabel,
      persists: persists,
      cardColor: cardColor,
      commentCount: postEntity.commentCount,
      audioUrl: postEntity.audioUrl,
      author: postEntity.author,
      dataSource: postEntity.dataSource,
      photoUrl: postEntity.photoUrl,
    );
  }

  UIPostState createState() => UIPostState(
        likes: this.likes,
        likeCount: this.likes == null
            ? 0
            : this.likes.values.where((element) => element == true).toList().length -
                this.likes.values.where((element) => element == false).toList().length,
        postId: this.postId,
      );
}

class UIPostState extends State<UIPost> {
  UIPostState({
    this.likes,
    this.postId,
    this.likeCount,
  });

  int likeCount;
  bool liked = false;
  bool disliked = false;
  Map likes;

  Container loadingPlaceHolder = Container(
    height: 300.0,
    child: Center(child: CircularProgressIndicator()),
  );

  String postId;
  var reference = Firestore.instance.collection('dejavu_posts');

  bool doesMediaExists = false;
  bool disposed = false;

  @override
  void initState() {
    super.initState();

    if (widget.mediaUrl.startsWith("https://firebasestorage.googleapis.com/")) {
      doesMediaExists = true;
    } else if (Repository.postMediaValidityMap.containsKey(widget.mediaUrl))
      doesMediaExists = Repository.postMediaValidityMap[widget.mediaUrl];
    else {
      if (!disposed) _validateMediaUrl();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Widget buildLikeableMedia() {
    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 250.0,
      ),
      child: GestureDetector(
        onDoubleTap: _likePost,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            widget.isVideo
                ? PostVideoPlayer(
                    mediaUrl: widget.mediaUrl,
                    postId: postId,
                    height: widget.height == null ? null : widget.height.toDouble(),
                    width: widget.width == null ? null : widget.width.toDouble(),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.mediaUrl,
                    width: widget.width == null ? null : widget.width.toDouble(),
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => loadingPlaceHolder,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
          ],
        ),
      ),
    );
  }

  buildPostHeader({String ownerId}) {
    if (ownerId == null && widget.communityId == null && widget.author == null) {
      return Text("owner error");
    } else if ((widget.communityId != null && widget.communityId.isNotEmpty) || (widget.author != null && widget.author.isNotEmpty)) {
      final postCreator = (widget.author != null && widget.author.isNotEmpty) ? '${widget.author}@${widget.dataSource ?? "community"}' : "community";
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, 2, 8, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).accentColor,
                  backgroundImage: AssetImage('assets/images/ic_launcher.png'),
                ),
                SizedBox(width: 10),
                Text(
                  postCreator,
                  style: Theme.of(context).primaryTextTheme.body1.copyWith(
                        fontSize: 14,
                      ),
                ),
                SizedBox(
                  width: 10,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 120),
                  child: Text(
                    widget.categoryName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 0, 204, 118),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  timeago.format(DateTime.fromMillisecondsSinceEpoch(widget.timestamp)),
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.body1.color,
                  ),
                )
              ],
            ),
          ),
          if (widget.description != null && widget.description.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                widget.description ?? "",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18).copyWith(),
              ),
            ),
        ],
      );
    }
    printInDebugMode(widget.description);
    return PostHeader(
        categoryName: widget.categoryName,
        description: widget.description,
        ownerId: widget.ownerId,
        timestamp: widget.timestamp,
        photoUrl: widget.photoUrl,
        username: widget.username);
  }

  Future<void> _postToFirestore() {
    var reference = Firestore.instance.collection('dejavu_posts');

    return reference.add({
      "likes": {},
      "mediaUrl": widget.mediaUrl,
      "description": widget.description,
      "timestamp": widget.timestamp,
      "isVideo": widget.isVideo,
      "communityId": widget.communityId,
      "communityPostId": widget.communityPostId,
      "author": widget.author,
      "audioUrl": widget.audioUrl,
    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      if (kDebugMode) printInDebugMode('documentId = $docId');
      this.postId = docId;
      return reference.document(docId).updateData({"postId": docId});
    }).catchError((onError) {
      if (kDebugMode) printInDebugMode('error while uploading post info mediaUrl');
      return Future.value(null);
    });
  }

  Future<bool> _goToLogin() async {
    return await Navigator.of(context).pushNamed('user_login');
  }

  void _likePost() async {
    var userId = googleSignIn?.currentUser?.id;
    if (userId == null && !(await _goToLogin())) {
      return;
    }

    if (likes == null) {
      likes = {};
    }
    //temporary state
    bool _liked = (likes[userId] ?? false) == true;
    bool _disliked = (likes[userId] ?? true) == false;

    if (postId == null) {
      await _postToFirestore();
    }

    if (_liked) {
      printInDebugMode('removing like');

      // reference.document(postId).updateData({
      //   'likes.$userId': null
      //   //firestore plugin doesnt support deleting, so it must be nulled / falsed
      // });

      setState(() {
        likeCount = likeCount - 1;
        liked = false;
        disliked = false;
        likes.remove(userId);
      });

      if (widget.persists != null && widget.communityId == null) {
        widget.persists(postId, PostEntity.fromUIPost(this).toMap());
        printInDebugMode("persisting data");
      } else {
        printInDebugMode("not persisting data");
      }

      removeActivityFeedItem();
      await Repository.getResponse(
        httpClient,
        'https://us-central1-dejavu-d75eb.cloudfunctions.net/posts?postId=$postId&userId=$userId&value=true',
      );
    }

    if (!_liked || _disliked) {
      printInDebugMode('liking');

      addActivityFeedItem();

      setState(() {
        likeCount = likeCount + (_disliked ? 2 : 1);
        liked = true;
        disliked = false;
        likes[userId] = true;
      });

      if (widget.persists != null) {
        widget.persists(postId, PostEntity.fromUIPost(this).toMap());
        printInDebugMode("persisting data");
      } else {
        printInDebugMode("not persisting data");
      }
      await Repository.getResponse(
        httpClient,
        'https://us-central1-dejavu-d75eb.cloudfunctions.net/posts?postId=$postId&userId=$userId&value=true',
      );
    }
  }

  int getLikeCount() {
    return likeCount;
  }

  void _dislikePost() async {
    var userId = googleSignIn?.currentUser?.id;
    if (userId == null && !(await _goToLogin())) {
      return;
    }

    //temporary state
    if (likes == null) {
      likes = {};
    }

    bool _liked = (likes[userId] ?? false) == true;
    bool _disliked = (likes[userId] ?? true) == false;

    if (postId == null) {
      await _postToFirestore();
    }

    if (_disliked) {
      printInDebugMode('removing dislike');

      setState(() {
        likeCount = likeCount + 1;
        disliked = false;
        liked = false;
        likes.remove(userId);
      });

      if (widget.persists != null && widget.communityId == null) {
        widget.persists(postId, PostEntity.fromUIPost(this).toMap());
        printInDebugMode("persisting data");
      } else {
        printInDebugMode("not persisting data");
      }
      await Repository.getResponse(
        httpClient,
        'https://us-central1-dejavu-d75eb.cloudfunctions.net/posts?postId=$postId&userId=$userId&value=fale',
      );
    }

    if (!_disliked || _liked) {
      printInDebugMode('disliking');

      if (_liked) {
        removeActivityFeedItem();
      }

      setState(() {
        likeCount = likeCount + (liked ? -2 : -1);
        disliked = true;
        liked = false;
        likes[userId] = false;
      });

      if (widget.persists != null) {
        widget.persists(postId, PostEntity.fromUIPost(this).toMap());
        printInDebugMode("persisting data");
      } else {
        printInDebugMode("not persisting data");
      }
      await Repository.getResponse(
        httpClient,
        'https://us-central1-dejavu-d75eb.cloudfunctions.net/posts?postId=$postId&userId=$userId&value=fale',
      );
    }
  }

  void addActivityFeedItem() {
    Firestore.instance.collection("dejavu_a_feed").document(widget.ownerId).collection("items").document(postId).setData({
      "username": currentUserModel.username,
      "userId": currentUserModel.id,
      "type": "like",
      "userProfileImg": currentUserModel.photoUrl,
      "mediaUrl": widget.mediaUrl,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "postId": postId,
    });
  }

  void removeActivityFeedItem() {
    Firestore.instance.collection("dejavu_a_feed").document(widget.ownerId).collection("items").document(postId).delete();
  }

  void goToComments() async {
    if (postId == null) {
      await _postToFirestore();
    }
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return CommentScreen(
            postId: postId,
            postOwner: widget.ownerId ?? "",
            postMediaUrl: widget.mediaUrl,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    printInDebugMode('${widget.description}, ${widget.communityPostId}, ${widget.communityId}, ${widget.postId}');
    if (!doesMediaExists) {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Card(
          margin: EdgeInsets.all(0),
          elevation: 6,
          color: widget.cardColor ?? Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 5,
                ),
                child: buildPostHeader(ownerId: widget.ownerId),
              ),
              buildLikeableMedia(),
              SizedBox(height: 8),
              PostFooter(
                postEntity: PostEntity.fromUIPost(this),
                comment: goToComments,
                dislike: _dislikePost,
                like: _likePost,
                likes: likes,
                getLikeCount: getLikeCount,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _validateMediaUrl() async {
    if (doesMediaExists) return;
    FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(widget.mediaUrl);
    if (fileInfo != null) {
      doesMediaExists = true;
      Repository.postMediaValidityMap[widget.mediaUrl] = true;
      if (!disposed) setState(() {});
      return;
    }

    try {
      printInDebugMode('mediaUrl = ${widget.mediaUrl}');
      final response = await http.head(widget.mediaUrl);
      printInDebugMode('response code = ${response.statusCode}');
      doesMediaExists = response.statusCode == 200;
    } catch (error) {
      printInDebugMode(error.toString());
      doesMediaExists = false;
    }
    Repository.postMediaValidityMap[widget.mediaUrl] = doesMediaExists;
    if (!disposed) setState(() {});
  }
}

class UIPostFromPostId extends StatelessWidget {
  const UIPostFromPostId({this.id, this.cardColor});

  final String id;
  final Color cardColor;

  Future<PostEntity> getMediaPost() async {
    var document = await Firestore.instance.collection('dejavu_posts').document(id).get();
    return PostEntity.fromDocument(document);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostEntity>(
        future: getMediaPost(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(alignment: FractionalOffset.center, padding: const EdgeInsets.only(top: 10.0), child: CircularProgressIndicator());
          return UIPost.fromEntity(
            key: ValueKey(snapshot.data.postId),
            postEntity: snapshot.data,
            cardColor: cardColor,
          );
        });
  }
}
