import 'package:equatable/equatable.dart';

import 'post_entity.dart';


class DiscoveryUserEntity extends Equatable {
  final String userId;
  final String avatarUrl;
  final bool isFollowing;
  final String displayName;
  final List<PostEntity> posts;

  DiscoveryUserEntity(
      {this.userId,
      this.avatarUrl,
      this.isFollowing,
      this.displayName,
      this.posts})
      : super([userId, avatarUrl, isFollowing, displayName, posts]);

  factory DiscoveryUserEntity.fromJSON(Map data) {
    return DiscoveryUserEntity(
      userId: data['user_id'],
      avatarUrl: data['avatar_url'],
      isFollowing: data['is_following'],
      displayName: data['display_name'],
      posts: (data['posts'] as List<dynamic>)
          .map((entry) => PostEntity.fromJSON(entry))
          .toList(),
    );
  }
}