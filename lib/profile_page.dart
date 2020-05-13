import 'package:BlogApp/app_exception.dart';
import 'package:BlogApp/core/navigation_service.dart';
import 'package:BlogApp/core/repository.dart';
import 'package:BlogApp/models/post_entity.dart';
import 'package:BlogApp/widgets/post_small_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'models/user.dart';
import 'pages/user_login.dart';
import 'ui_post.dart';
import 'edit_profile_page.dart';
import 'models/profile_entity.dart';
import 'util.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Login'),
          ),
          body: UserLogin(
            continuation: _setStateInternal(),
          ));
    } else {
      return UserProfile(
        userId: widget.userId,
      );
    }
  }

  _setStateInternal() {
    setState(() {});
  }
}

class UserProfile extends StatelessWidget {
  final String userId;

  const UserProfile({Key key, this.userId})
      : assert(userId != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          printInDebugMode(snapshot.error);
          return Center(
            child: Text(
              'Error while fetching profile',
              textAlign: TextAlign.center,
            ),
          );
        } else if (snapshot.hasData) {
          return _InternalProfilePage(
            profileEntity: snapshot.data[0],
            posts: snapshot.data[1],
          );
        } else {
          return Center(
            child: Text(
              'Internal error. Please restart the app',
              textAlign: TextAlign.center,
            ),
          );
        }
      },
      initialData: [
        ProfileEntity.empty(userId),
        const [],
      ],
      future: Future.wait(
        [
          Firestore.instance
              .collection('dejavu_users')
              .document(userId)
              .get()
              .then(
                (snapshot) => ProfileEntity.fromJson(Map<String, dynamic>.from(snapshot.data),),
              )
              .then(
            (value) {
              printInDebugMode('success in user details');
              return Future.value(value);
            },
          ),
          Firestore.instance
              .collection('dejavu_posts')
              .where('ownerId', isEqualTo: userId)
              .orderBy("timestamp", descending: true)
              .getDocuments()
              .then(
                (snapshot) => snapshot.documents.map<PostEntity>((doc) => PostEntity.fromDocument(doc)).toList(),
              )
              .then(
            (value) {
              printInDebugMode('success in post list');
              return Future.value(value);
            },
          ),
        ],
      ),
    );
  }
}

class _InternalProfilePage extends StatefulWidget {
  final ProfileEntity profileEntity;
  final List<PostEntity> posts;

  const _InternalProfilePage({@required this.profileEntity, this.posts}) : assert(profileEntity != null);

  @override
  State<StatefulWidget> createState() => _InternalProfilePageState();
}

class _InternalProfilePageState extends State<_InternalProfilePage> with AutomaticKeepAliveClientMixin<_InternalProfilePage> {
  String view = "grid"; // default view
  String profileId;
  bool isFollowing = false;
  bool isLoggedInUser = false;

  _InternalProfilePageState();

  @override
  void initState() {
    super.initState();
    final loginUserId = googleSignIn?.currentUser?.id;
    profileId = widget.profileEntity.profileId;
    isLoggedInUser = profileId == loginUserId;
    if (loginUserId != null) {
      isFollowing = !isLoggedInUser &&
          widget.profileEntity.followers != null &&
          widget.profileEntity.followers[loginUserId] != null &&
          widget.profileEntity.followers[loginUserId];
    } else {
      isFollowing = false;
    }

    Repository.postUsersMap[widget.profileEntity.profileId] = User(
        displayName: widget.profileEntity.displayName,
        id: widget.profileEntity.profileId,
        photoUrl: widget.profileEntity.photoUrl,
        username: widget.profileEntity.username);
  }

  @override
  bool get wantKeepAlive => widget.profileEntity.profileId == googleSignIn?.currentUser?.id;

  editProfile() {
    EditProfilePage editPage = EditProfilePage();

    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return Center(
            child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                  ),
                  title: Text(
                    'Edit Profile',
                  ),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                        ),
                        onPressed: () {
                          editPage.applyChanges();
                          Navigator.maybePop(context);
                        })
                  ],
                ),
                body: ListView(
                  children: <Widget>[
                    Container(
                      child: editPage,
                    ),
                  ],
                )),
          );
        },
      ),
    );
  }

  followUser() {
    printInDebugMode('following user');
    final currentUserId = googleSignIn?.currentUser?.id;
    if (currentUserModel == null) {
      Navigator.of(context).pushNamed('login');
      return;
    }
    setState(() {
      isFollowing = true;
    });

    Firestore.instance.document("dejavu_users/$profileId").updateData({
      'followers.$currentUserId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("dejavu_users/$currentUserId").updateData({
      'following.$profileId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    //updates activity feed
    Firestore.instance.collection("dejavu_a_feed").document(profileId).collection("items").document(currentUserId).setData({
      "ownerId": profileId,
      "username": currentUserModel.username,
      "userId": currentUserId,
      "type": "follow",
      "userProfileImg": currentUserModel.photoUrl,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  unfollowUser() {
    printInDebugMode('unfollowing user');
    final currentUserId = googleSignIn?.currentUser?.id;
    if (currentUserModel == null) {
      Navigator.of(context).pushNamed('login');
      return;
    }

    setState(() {
      isFollowing = false;
    });

    Firestore.instance.document("dejavu_users/$profileId").updateData({
      'followers.$currentUserId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("dejavu_users/$currentUserId").updateData({
      'following.$profileId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.collection("dejavu_a_feed").document(profileId).collection("items").document(currentUserId).delete();
  }

  Widget _buildStatColumn(String label, int number, Function onTap) {
    return GestureDetector(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            number.toString(),
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            child: Text(
              label,
              style: TextStyle(color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildProfileFollowButton(ProfileEntity profileEntity) {
    final buttonLabel = isLoggedInUser ? "Edit Profile" : isFollowing ? 'Unfollow' : 'Follow';
    final backgroundColor = isLoggedInUser || isFollowing ? Colors.black : Colors.blue;
    final textColor = isLoggedInUser || isFollowing ? Colors.white : Colors.white;
    final borderColor = isLoggedInUser || isFollowing ? Colors.black : Colors.blue;
    final onPress = isLoggedInUser ? editProfile : isFollowing ? unfollowUser : followUser;
    return _buildFollowButton(
      text: buttonLabel,
      backgroundcolor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      function: onPress,
    );
  }

  Widget _buildFollowButton({String text, Color backgroundcolor, Color textColor, Color borderColor, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundcolor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          width: 250.0,
          height: 27.0,
        ),
      ),
    );
  }

  Widget _buildMediaViewOptionsButtonBar() {
    Color isActiveButtonColor(String viewName) {
      if (view == viewName) {
        return Colors.blueAccent;
      } else {
        return Colors.grey;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on, color: isActiveButtonColor("grid")),
          onPressed: () {
            changeView("grid");
          },
        ),
        IconButton(
          icon: Icon(Icons.list, color: isActiveButtonColor("feed")),
          onPressed: () {
            changeView("feed");
          },
        ),
      ],
    );
  }

  Widget _buildUserPosts(List<PostEntity> posts) {
    final builderDelegate = SliverChildBuilderDelegate((ctx, index) {
      return PostTile(posts[index]);
    }, childCount: posts.length);

    if (view == "grid") {
      // build the grid
      return SliverGrid(
        delegate: builderDelegate,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
        ),
      );
    } else if (view == "feed") {
      return SliverList(delegate: builderDelegate);
    } else {
      throw AppException(reason: 'Profile post view type not supported');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.profileEntity.username,
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) {
                return _buildProfileHeader(widget.profileEntity, widget.posts);
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, __) => Divider(), childCount: 1),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) {
                return _buildMediaViewOptionsButtonBar();
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, __) => Divider(), childCount: 1),
          ),
          widget.posts.length == 0
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (_, __) => Container(
                            height: 60,
                            child: Center(
                              child: Text('No memes found'),
                            ),
                          ),
                      childCount: 1))
              : _buildUserPosts(widget.posts),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileEntity profileEntity, List<PostEntity> postsList) {
    final postCounts = postsList.length;
    final followersCount = profileEntity.followers.values.where((element) => element == true).length;
    final followingCount = profileEntity.following.values.where((element) => element == true).length;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(profileEntity.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildStatColumn("posts", postCounts, null),
                            _buildStatColumn("followers", followersCount, null),
                            _buildStatColumn("following", followingCount, null),
                          ],
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[_buildProfileFollowButton(profileEntity)]),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    profileEntity.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 1.0),
                child: Text(profileEntity.bio),
              ),
            ],
          ),
        ),
      ],
    );
  }

  changeView(String viewName) {
    setState(() {
      view = viewName;
    });
  }
}

class PostTile extends StatelessWidget {
  final PostEntity postEntity;

  PostTile(this.postEntity);

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => expandPostTile(context, postEntity),
      child: PostSmallTile(
        post: postEntity,
        overlay: null,
      ),
    );
  }
}

expandPostTile(BuildContext context, PostEntity postEntity) {
  locator<NavigationService>().push(
    MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return Center(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Post',
              ),
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  child: UIPost.fromEntity(
                    key: ValueKey(postEntity.postId),
                    postEntity: postEntity,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void openProfile(BuildContext context, String userId) {
  printInDebugMode('called openProfile');
  Navigator.of(context).push(
    MaterialPageRoute<bool>(
      builder: (BuildContext context) {
        return ProfilePage(userId: userId);
      },
    ),
  );
}
