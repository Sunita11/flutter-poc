import 'package:BlogApp/models/post_entity.dart';
import 'package:BlogApp/profile_page.dart';
import 'package:BlogApp/widgets/post_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostSmallTile extends StatelessWidget {
  final PostEntity post;
  final Widget overlay;

  PostSmallTile({@required this.post, this.overlay}) : assert(post != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        expandPostTile(context, post);
      },
      child: Stack(
        key: ValueKey(post.postId),
        children: <Widget>[
          post.isVideo
              ? PostVideoPlayer(
                  mediaUrl: post.mediaUrl,
                  postId: post.postId,
                  width: post.width == null
                      ? double.infinity
                      : post.width.toDouble(),
                  height: post.width == null
                      ? double.infinity
                      : post.height.toDouble(),
                )
              : CachedNetworkImage(
                  imageUrl: post.mediaUrl,
                  width: post.width == null
                      ? double.infinity
                      : post.width.toDouble(),
                  height: post.width == null
                      ? double.infinity
                      : post.height.toDouble(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    // height: 300.0,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
          overlay != null
              ? Align(
                  child: overlay,
                  alignment: Alignment.bottomLeft,
                )
              : Container()
        ],
      ),
    );
  }
}
