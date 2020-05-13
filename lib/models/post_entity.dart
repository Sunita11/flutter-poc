import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../ui_post.dart';

class PostEntity extends Equatable {
  final String mediaUrl;
  final String username;
  final String description;
  final likes;
  final String postId;
  final String ownerId;
  final int timestamp;
  final bool isVideo;
  final int height;
  final int width;
  final String communityId;
  final String communityPostId;
  final String source;
  final List tags;
  final String categoryId;
  final String categoryLabel;
  final int commentCount;
  final String author;
  final String dataSource;
  final String audioUrl;
  final String photoUrl;
  PostEntity(
      {this.mediaUrl,
      this.username,
      this.description,
      this.likes,
      this.postId,
      this.ownerId,
      this.timestamp,
      this.isVideo,
      this.height,
      this.width,
      this.communityId,
      this.communityPostId,
      this.source = "dejavu",
      this.tags = const [],
      this.categoryId,
      this.categoryLabel,
      this.commentCount,
      this.audioUrl,
      this.dataSource,
      this.author, 
      this.photoUrl,
      })
      : super([
          mediaUrl,
          username,
          description,
          likes,
          postId,
          ownerId,
          timestamp,
          isVideo,
          height,
          width,
          communityId,
          communityPostId,
          source,
          categoryId,
          categoryLabel,
          author,
          dataSource,
          audioUrl,
          photoUrl,
        ]);

  factory PostEntity.fromDocument(
    DocumentSnapshot document,
  ) {
    return PostEntity(
      username: document['username'],
      mediaUrl: document['mediaUrl'],
      likes: document['likes'],
      description: document['description'],
      postId: document.documentID,
      ownerId: document['ownerId'],
      timestamp: document['timestamp'],
      isVideo: document['isVideo'] ?? false,
      height: document['height'] ?? 300,
      width: document['width'] ?? 480,
      source: document['source'],
      tags: document['tags'] ?? const [],
      communityId: document['community'] ?? "",
      communityPostId: document['community_id'] ?? document['communityId'] ?? "",
      categoryId: document['category_id'] ?? "",
      categoryLabel: document['category'] ?? "",
      commentCount: document['commentCount'] ?? 0,
      audioUrl: document['audio_url'] ?? "",
      author: document['author'] ?? "",
      dataSource: document['data_source'] ?? "",
      photoUrl: document['photoUrl'] ?? "",
    );
  }

  factory PostEntity.empty() {
    return PostEntity();
  }
  factory PostEntity.fromJSON(Map data) {
    return PostEntity(
      username: data['username'],
      mediaUrl: data['mediaUrl'],
      likes: data['likes'],
      description: data['description'],
      ownerId: data['ownerId'],
      postId: data['postId'],
      timestamp: data['timestamp'],
      isVideo: data['isVideo'] ?? false,
      height: data['height'] ?? 300,
      width: data['width'] ?? 480,
      source: data['source'],
      tags: data['tags'] ?? const [],
      communityId: data['community'] ?? data['communityId'] ?? "",
      communityPostId: data['id'] ?? data['communityPostId'],
      categoryId: data['category_id'] ?? "",
      categoryLabel: data['category'] ?? "",
      commentCount: data['commentCount'] ?? 0,
      audioUrl: data['audio_url'] ?? "",
      author: data['author'] ?? "",
      dataSource: data['data_source'] ?? "",
      photoUrl: data['photoUrl'] ?? ""
    );
  }

  factory PostEntity.fromUIPost(UIPostState postState) {
    return PostEntity(
      communityId: postState.widget.communityId,
      communityPostId: postState.widget.communityId,
      description: postState.widget.description,
      height: postState.widget.height,
      isVideo: postState.widget.isVideo,
      likes: postState.likes,
      mediaUrl: postState.widget.mediaUrl,
      ownerId: postState.widget.ownerId,
      postId: postState.postId,
      source: postState.widget.source,
      tags: postState.widget.tags,
      timestamp: postState.widget.timestamp,
      username: postState.widget.username,
      width: postState.widget.width,
      categoryId: postState.widget.categoryId,
      categoryLabel: postState.widget.categoryName,
      commentCount: postState.widget.commentCount,
      audioUrl: postState.widget.audioUrl,
      author: postState.widget.author,
      dataSource: postState.widget.dataSource,
      photoUrl: postState.widget.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['username'] = username;
    map['mediaUrl'] = mediaUrl;
    map['likes'] = likes;
    map['description'] = description;
    map['ownerId'] = ownerId;
    map['postId'] = postId;
    map['timestamp'] = timestamp;
    map['isVideo'] = isVideo;
    map['height'] = height;
    map['width'] = width;
    map['source'] = source;
    map['tags'] = tags;
    map['community'] = communityId;
    map['community_id'] = communityPostId;
    map['category_id'] = categoryId;
    map['category'] = categoryLabel;
    map['audio_url'] = audioUrl;
    map['author'] = author;
    map['data_source'] = dataSource;
    map['photo_url'] = photoUrl;
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
