import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main.dart';
import 'models/post_entity.dart';
import 'util.dart';

class PostFooter extends StatefulWidget {
  final PostEntity postEntity;
  final Map likes;
  final Function like;
  final Function dislike;
  final Function comment;
  final Function getLikeCount;
  const PostFooter({
    Key key,
    this.postEntity,
    this.like,
    this.dislike,
    this.comment,
    this.likes,
    this.getLikeCount,
  }) : super(key: key);

  @override
  _PostFooterState createState() => _PostFooterState(postEntity);
}

class _PostFooterState extends State<PostFooter> {
  PostEntity postEntity;

  _PostFooterState(this.postEntity);

  @override
  void initState() {
    super.initState();

    if (postEntity.communityPostId != null) {
      _getFirebaseData();
    }
  }

  _getFirebaseData() async {
    final query = Firestore.instance.collection('dejavu_posts').where("communityPostId", isEqualTo: postEntity.communityPostId);
    final querySnapshot = await query.getDocuments();
    if (querySnapshot.documents != null && querySnapshot.documents.length > 0) {
      final doc = querySnapshot.documents[0];
      final communityPostId = doc.data['communityPostId'];
      if (communityPostId != null && communityPostId != '') {
        final _postEntity = PostEntity(
          communityId: postEntity.communityId,
          communityPostId: postEntity.communityPostId,
          description: postEntity.description,
          isVideo: postEntity.isVideo,
          mediaUrl: postEntity.mediaUrl,
          likes: doc.data['likes'],
          postId: doc.documentID,
          source: postEntity.source,
          tags: postEntity.tags,
          timestamp: postEntity.timestamp,
        );
        postEntity = _postEntity;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool liked;
    bool disliked;
    if (widget.likes != null) {
      liked = (widget.likes[googleSignIn?.currentUser?.id?.toString() ?? false] == true);
      disliked = (widget.likes[googleSignIn?.currentUser?.id?.toString() ?? true] == false);
    } else {
      liked = false;
      disliked = false;
    }

    printInDebugMode('liked = $liked, disliked = $disliked for post ${widget.postEntity.description}');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ButtonTheme(
        minWidth: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MaterialButton(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: SvgPicture.asset(
                  liked ? 'assets/images/ic_vote_up_active.svg' : 'assets/images/ic_vote_up.svg',
                  width: 16,
                  height: 16,
                ),
                onPressed: widget.like),
            SizedBox(
              width: 15,
              child: Text(
                widget.getLikeCount().toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: liked || disliked ? Color.fromARGB(255, 57, 173, 238) : Theme.of(context).primaryTextTheme.button.color,
                ),
              ),
            ),
            MaterialButton(
                child: SvgPicture.asset(
                  disliked ? 'assets/images/ic_vote_down_active.svg' : 'assets/images/ic_vote_down.svg',
                  width: 16,
                  height: 16,
                ),
                onPressed: widget.dislike),
            MaterialButton(
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/ic_comment.svg',
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    child: Text(
                      widget.postEntity.commentCount?.toString() ?? 0.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button.color,
                      ),
                    ),
                  )
                ],
              ),
              onPressed: widget.comment,
            ),
            // Expanded(
            //   child: Container(),
            // ),
            // FlatButton(
            //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //   onPressed: () {},
            //   child: Text(
            //     'Share',
            //     style: TextStyle(
            //       color: Theme.of(context).primaryTextTheme.button.color,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
