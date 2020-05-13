import 'dart:collection';

import 'package:equatable/equatable.dart';

import '../util.dart';
import 'discover_user_entity.dart';
import 'discovery_tag_entity.dart';
import 'post_entity.dart';

enum DiscoveryType {
  POST,
  TAG_BASED,
  USER_BASED,
}
class DiscoveryEntity extends Equatable {
  final List<DiscoveryUserEntity> discoveryUsers;
  final List<PostEntity> discoveryPosts;
  final List<DiscoveryTagEntity> discoveryTags;

  final LinkedHashSet<PostEntity> uniquePosts;

  DiscoveryEntity(
      {this.discoveryUsers,
      this.discoveryPosts,
      this.discoveryTags,
      bool keepDuplicates = false})
      : uniquePosts = LinkedHashSet(),
        super([
          discoveryUsers,
          discoveryPosts,
          discoveryTags,
          keepDuplicates
        ]) {
    //remove duplicates
    if (!keepDuplicates) {
      final removeDuplicates =
          (List<PostEntity> list, Set<PostEntity> unique) {
        List duplicates = [];
        list.forEach((element) {
          if (!unique.add(element)) {
            duplicates.add(element);
          }
        });
        list.removeWhere((element) => duplicates.contains(element));
      };

      discoveryTags.forEach((tag) {
        removeDuplicates(tag.posts, uniquePosts);
      });

      removeDuplicates(discoveryPosts, uniquePosts);

      discoveryUsers.forEach((user) {
        removeDuplicates(user.posts, uniquePosts);
      });
    }
  }

  int get count {
    return uniquePosts.length;
  }

  PostEntity getPostForIndex(int index) {
    return uniquePosts.toList()[index];
  }

  DiscoveryType getDiscoveryTypeForPost(PostEntity post) {
    if (discoveryPosts.contains(post)) {
      return DiscoveryType.POST;
    } else if (getTagPosts.contains(post)) {
      return DiscoveryType.TAG_BASED;
    } else if (discoveryUsers.expand((e) => e.posts).toList().contains(post)) {
      return DiscoveryType.USER_BASED;
    }
    return DiscoveryType.POST;
  }

  List<PostEntity> get getTagPosts {
    return discoveryTags.expand((element) => element.posts).toList();
  }

  factory DiscoveryEntity.empty() {
    return DiscoveryEntity(
        discoveryUsers: [],
        discoveryPosts: [],
        discoveryTags: []);
  }

  factory DiscoveryEntity.fromJson(Map<String, dynamic> data) {
    try {
      final usersData = (data['users'] ?? [])
          .map<DiscoveryUserEntity>(
              (item) => DiscoveryUserEntity.fromJSON(item))
          .toList();

      final postsData = (data['posts'] as List<dynamic> ?? [])
          .map<PostEntity>((item) => PostEntity.fromJSON(item))
          .toList();

      final tagsData = (data['tags'] as Map<String, dynamic> ?? {})
          .map<String, DiscoveryTagEntity>((key, value) =>
              MapEntry(key, DiscoveryTagEntity.fromJson(key, value)))
          .values
          .toList();

      return DiscoveryEntity(
          discoveryUsers: usersData,
          discoveryPosts: postsData,
          discoveryTags: tagsData);
    } catch (error) {
      printInDebugMode('error is ${error.toString()}');
      return DiscoveryEntity.empty();
    }
  }
}