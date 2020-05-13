import 'package:equatable/equatable.dart';

import 'post_entity.dart';

class DiscoveryTagEntity extends Equatable {
  final String tag;
  final List<PostEntity> posts;

  DiscoveryTagEntity({this.tag, this.posts}) : super([tag, posts]);
  factory DiscoveryTagEntity.fromJson(String tag, List data) {
    return DiscoveryTagEntity(
      tag: tag,
      posts: data.map((entry) => PostEntity.fromJSON(entry)).toList(),
    );
  }
}