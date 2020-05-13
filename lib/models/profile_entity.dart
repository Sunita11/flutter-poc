import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class ProfileEntity extends Equatable {
  final String profileId;
  final String displayName;
  final String email;
  final Map<String, bool> followers;
  final Map<String, bool> following;
  final String photoUrl;
  final String username;
  final String androidNotificationToken;
  final String bio;

  ProfileEntity(
      {@required this.profileId,
      this.displayName = "",
      this.email,
      this.followers = const {},
      this.following = const {},
      this.photoUrl,
      this.username,
      this.androidNotificationToken, 
      this.bio,})
      : assert(profileId != null),
        super([
          profileId,
          displayName,
          email,
          followers,
          following,
          photoUrl,
          username,
          androidNotificationToken,
          bio,
        ]);

  factory ProfileEntity.fromJson(Map<String, dynamic> jsonData) {
    return ProfileEntity(
      profileId: jsonData['id'],
      displayName: jsonData['displayName'],
      email: jsonData['email'],
      followers: (jsonData['followers'] as Map).map<String, bool>((key, value) => MapEntry(key.toString(), value as bool)),
      following: (jsonData['following'] as Map).map<String, bool>((key, value) => MapEntry(key.toString(), value as bool)),
      photoUrl: jsonData['photoUrl'] ,
      username: jsonData['username'],
      androidNotificationToken: jsonData['androidNotificationToken'],
      bio: jsonData['bio'],
    );
  }

  factory ProfileEntity.empty(String profileId,) {
    return ProfileEntity(profileId: profileId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : profileId,
      'displayName' : displayName,
      'email' : email,
      'followers' : followers,
      'following' : following,
      'photoUrl' : photoUrl,
      'username' : username,
      'androidNotificationToken' : androidNotificationToken,
      'bio' : bio,
    };
  }
}
