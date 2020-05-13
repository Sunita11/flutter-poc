import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'core/repository.dart';
import 'profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostHeader extends StatelessWidget {
  final String ownerId;
  final String categoryName;
  final int timestamp;
  final String description;
  final String photoUrl;
  final String username;

  const PostHeader({Key key, this.ownerId, this.categoryName, this.timestamp, this.description, this.photoUrl, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
            children: [
              photoUrl != null
                  ? CircleAvatar(
                      radius: 12,
                      backgroundImage: CachedNetworkImageProvider(photoUrl),
                      backgroundColor: Theme.of(context).accentColor,
                    )
                  : SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    ),
              SizedBox(width: 10),
              GestureDetector(
                child: Text(username ?? "", style: Theme.of(context).primaryTextTheme.body1.copyWith(fontSize: 14)),
                onTap: () {
                  openProfile(context, ownerId);
                },
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                categoryName,
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 204, 118),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(width: 16),
              Text(
                timeago.format(DateTime.fromMillisecondsSinceEpoch(timestamp)),
                style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: (description != null && description.trim().isNotEmpty)
              ? Text(
                  description ?? "",
                  style: Theme.of(context).textTheme.body1.copyWith(fontSize: 20),
                )
              : Container(),
        )
      ],
    );
  }

  
}
