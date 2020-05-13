import 'package:BlogApp/core/analytics.dart';
import 'package:BlogApp/core/repository.dart';
import 'package:BlogApp/feed_manager.dart';
import 'package:BlogApp/models/post_entity.dart';
import 'package:BlogApp/widgets/app_bar_header.dart';
import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui_post.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'dart:convert';

import 'util.dart';

const int CACHE_DURATION_IN_MINUTES = 5;

class FeedPage extends StatefulWidget {
  final String title;
  final String feedKey;
  final String feedValue;
  final bool appendCommunityFeed;

  const FeedPage({Key key, this.title, this.feedKey, this.feedValue, this.appendCommunityFeed = false}) : super(key: key);

  _Feed createState() => _Feed();
}

class _Feed extends State<FeedPage> with SingleTickerProviderStateMixin implements Refresh {
  List<PostEntity> feedData = [];
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;
//  AnimationController _hideAppBarAnimController;
  final _scrollThreshold = 200.0;

  bool hasReachedMaxFirebaseFeed = false;

  bool isFetchingCommunityFeed = false;
  bool isFetchingFirebaseFeed = false;

  int pageNumberFirebaseFeed = 0;

  bool isFetching = false;
  bool isPastDataUsed = false;

  get hasReachedMax => hasReachedMaxFirebaseFeed;

  final httpClient = HttpClient();

  _getDataFromCache() async {
    final sharedPref = await SharedPreferences.getInstance();
    oldFeedTimestamp = sharedPref.getInt('OLD_FEED_TIMESTAMP') ?? -1;
    if (oldFeedTimestamp > 0) {
      printInDebugMode2('cached time found');
      isPastDataUsed = true;
      final cachedUrl = '$urlToFetch&timestamp=$oldFeedTimestamp';
      final Directory cacheDirectory = await getTemporaryDirectory();
      final File cacheFile = File('${cacheDirectory.path}/${cachedUrl.hashCode}.txt');
      bool isCacheExists = await cacheFile.exists();
      if (isCacheExists) {
        printInDebugMode2('cached data exists');
      
        String response = await cacheFile.readAsString();
        dynamic content;
        if (response != null) {
          content = jsonDecode(response);
        }

        if (content != null) {
          printInDebugMode2('showing cached data');
          feedData = await _generateFeed(content);
          setState(() {});
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    printInDebugMode('init state called');
    _getDataFromCache();
    _scrollController = ScrollController();
    _getNotificationCount();
    _getFeed();
    FeedManager().addRefreshListener(this);
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    // _hideAppBarAnimController = AnimationController(
    //   vsync: this,
    //   duration: kThemeAnimationDuration,
    //   value: 1, // initially visible
    // );

    _scrollController.addListener(() {
      switch (_scrollController.position.userScrollDirection) {
        // Scrolling up - forward the animation (value goes to 1)
        case ScrollDirection.forward:
          _hideFabAnimController.forward();
//          _hideAppBarAnimController.forward();
          break;
        // Scrolling down - reverse the animation (value goes to 0)
        case ScrollDirection.reverse:
          _hideFabAnimController.reverse();
//          _hideAppBarAnimController.reverse();
          break;
        // Idle - keep FAB visibility unchanged
        case ScrollDirection.idle:
          break;
      }
    });
  }

  buildFeed() {
    printInDebugMode('buildfeed called');
    if (hasReachedMax && feedData.isEmpty) {
      return Center(
        child: Text(
          'Empty space around here!',
          softWrap: true,
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        if (index < feedData.length) {
          final postData = feedData[index];
          final uiPost = UIPost.fromEntity(
            postEntity: postData,
            key: ValueKey(postData.postId ?? postData.communityPostId),
            persists: persistResult,
          );

          if (index == feedData.length - 5) {
            return PaginationInitiatorItem(key: ValueKey<int>(index), postExecute: _getFeed, child: uiPost);
          }
          return uiPost;
        } else {
          return PaginationInitiatorItem(
            key: ValueKey<int>(index),
            postExecute: _getFeed,
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 33,
                height: 33,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              ),
            ),
          );
        }
      },
      itemCount: hasReachedMax ? feedData.length : feedData.length + 1,
//      controller: _scrollController,
    );
  }

  goToProfilePage() {
    if (currentUserModel != null) {
      Navigator.of(context).pushNamed('profile_page', arguments: googleSignIn?.currentUser?.id ?? null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16, right: 16),
        child: FadeTransition(
          opacity: _hideFabAnimController,
          child: ScaleTransition(
            scale: _hideFabAnimController,
            child: FloatingActionButton(
              heroTag: 'upload_post',
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed('upload_page');
                if (result != null && result == true) {
                  refresh();
                }
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
//                forceElevated: innerBoxIsScrolled,
                title: widget.title != null
                    ? Text(widget.title)
                    : currentUserModel != null
                        ? AppBarHeader(
                            avatarUrl: currentUserModel?.photoUrl,
                            avatarLabel: currentUserModel?.username,
                            onAvatarTap: goToProfilePage,
                          )
                        : AppBarHeader(),
                centerTitle: widget.title != null,
                actions: <Widget>[
                  IconButton(
                    icon: Container(
                      child: FutureBuilder(
                        future: _getNotificationCount(),
                        builder: (ctx, snapshot) {
                          if (snapshot.hasData && snapshot.data > 0) {
                            return Badge(
                              badgeColor: Color.fromARGB(255, 0, 255, 147),
                              badgeContent: Text(
                                snapshot.data.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 48, 57, 69),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              borderRadius: 10,
                              shape: BadgeShape.square,
                              child: Icon(
                                Icons.notifications,
                                color: Theme.of(context).primaryIconTheme.color,
                              ),
                              padding: EdgeInsets.all(4),
                            );
                          } else {
                            return Icon(
                              Icons.notifications,
                              color: Theme.of(context).primaryIconTheme.color,
                            );
                          }
                        },
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences.getInstance()
                          .then((sharedPreferences) => sharedPreferences.remove('NOTIFICATION_COUNT'))
                          .then((value) => Navigator.of(context).pushNamed('notifications_page'));
                    },
                  )
                ],
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: buildFeed(),
          ),
        ),
      ),
    );
  }

  Future<int> _getNotificationCount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int notificationCount = 0;
    if (sharedPreferences.containsKey('NOTIFICATION_COUNT')) {
      notificationCount += sharedPreferences.getInt('NOTIFICATION_COUNT') + 1;
    }
    return Future.value(notificationCount);
  }

  initializePaginationData() {
    printInDebugMode('initializePaginationData');
    hasReachedMaxFirebaseFeed = false;
    isFetchingCommunityFeed = false;
    isFetchingFirebaseFeed = false;
    pageNumberFirebaseFeed = 0;
    feedData.clear();
    isFetching = false;
    feedTimestamp = -1;
  }

  String get _feedType {
    if (widget.feedKey == null || widget.feedKey.isEmpty) {
      return "home";
    }
    return widget.feedKey;
  }

  int get _feedPageNumber => pageNumberFirebaseFeed;

  Future<Null> _refresh() async {
    printInDebugMode('refresh called');
    Analytics().feedRefreshed(_feedType);
    initializePaginationData();
    final cache = await getTemporaryDirectory();
    cache.list().where((event) => event is File).forEach((element) {
      element.delete();
    });
    try {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: Duration(milliseconds: 1), curve: Curves.ease);
      }
    } catch (error) {
      printInDebugMode(error.toString());
    }

    await _getFeed();
  }

  get urlToFetch {
    if (!hasReachedMaxFirebaseFeed || isPastDataUsed) {
      final uid = googleSignIn?.currentUser?.id;
      final buffer = StringBuffer();
      buffer.write('https://us-central1-dejavu-d75eb.cloudfunctions.net/getUserFeed?');
      if (uid != null) {
        buffer.write('uid=');
        buffer.write(uid.toString());
      }
      buffer.write('&');
      buffer.write('offset=');
      buffer.write(pageNumberFirebaseFeed.toString());
      buffer.write('&');
      buffer.write('limit=');
      buffer.write(30.toString());
      if (widget.feedKey != null && widget.feedKey.isNotEmpty) {
        buffer.write('&');
        buffer.write(widget.feedKey);
        buffer.write('=');
      }
      if (widget.feedValue != null && widget.feedValue.isNotEmpty) {
        buffer.write(widget.feedValue);
      }

      return buffer.toString();
    }
    return null;
  }

  int feedTimestamp = -1;
  int oldFeedTimestamp = -1;

  _getFeed() async {
    printInDebugMode2('getFeedCalled');
    if (isFetching || hasReachedMax) return;
    isFetching = true;
    String url = urlToFetch;
    if (url == null) {
      isFetching = false;
      hasReachedMaxFirebaseFeed = true;
    }
    if (widget.feedValue == null || widget.feedValue.isEmpty) {
      if (feedTimestamp == -1) {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        if (sharedPreferences.containsKey('FEED_TIMESTAMP')) {
          feedTimestamp = sharedPreferences.getInt('FEED_TIMESTAMP');
        } else {
          feedTimestamp = 0;
        }
        DateTime now = DateTime.now();
        if (feedTimestamp < (now.millisecondsSinceEpoch - Duration(seconds: 30).inMilliseconds)) {
          sharedPreferences.setInt('OLD_FEED_TIMESTAMP', feedTimestamp);
          sharedPreferences.setInt('FEED_TIMESTAMP', now.millisecondsSinceEpoch);
        }
      }
      url = '$url&timestamp=$feedTimestamp';
    }
    printInDebugMode2('url to fetch = $url');

    Analytics().feedShown(_feedType, _feedPageNumber, widget.feedValue);

    List<PostEntity> listOfPosts = [];
    final Directory cacheDirectory = await getTemporaryDirectory();
    final startTimestamp = DateTime.now();
    final response = await Repository.getResponse(httpClient, url, CACHE_DURATION_IN_MINUTES);
    final endTimestamp = DateTime.now();
    final timetaken = endTimestamp.difference(startTimestamp);
    printInDebugMode('time taken for feed = ${timetaken.inMilliseconds} ms');
    dynamic content;
    if (response != null) {
      content = jsonDecode(response);
    }

    if (isPastDataUsed) {
      isPastDataUsed = false;
      feedData.clear();
    }

    int prevFeedDataSize = feedData.length;

    if (content != null) {
      printInDebugMode('content is not null, generting feed');
      listOfPosts = await _generateFeed(content);

      printInDebugMode('feed generated, listOfPost lenght = ${listOfPosts.length}');
      await Future.forEach<PostEntity>(listOfPosts, (element) async {
        printInDebugMode('element.postId = ${element.postId}');
        if (element.postId != null) {
          final File cachedPost = File('${cacheDirectory.path}/${element.postId.hashCode}.txt');
          if (await cachedPost.exists()) {
//            printInDebugMode('cached post exists for ${element.postId}');
            final cachedPostContent = await cachedPost.readAsString();
            final cachedPostDecoded = json.decode(cachedPostContent);
            final cachedPostEntity = PostEntity.fromJSON(cachedPostDecoded);
//            printInDebugMode('cachedPostEntity = ${cachedPostEntity.toString()} for ${element.postId}');
            feedData.add(cachedPostEntity);
//            printInDebugMode('added cached image post to feed, returning for foreach async for ${element.postId}');
            return;
          }
        }
        if (element.communityPostId != null) {
          final matched = feedData.firstWhere((e) => e.communityPostId == element.communityPostId, orElse: () => PostEntity.empty());
          if (matched.communityPostId == element.communityPostId) {
            return;
          }
        }
//        printInDebugMode('could not find cached item for $element, adding it to feed data');
        feedData.add(element);
      });
    }

    printInDebugMode('before changing values');
    if (listOfPosts.isEmpty) {
      hasReachedMaxFirebaseFeed = true;
    } else {
      pageNumberFirebaseFeed += 30;
    }
    isFetching = false;

    int newFeedDataSize = feedData.length;
    if (newFeedDataSize - prevFeedDataSize < 5) {
      _getFeed();
    }

    setState(() {});
  }

  Future<void> persistResult(String postId, Map data) async {
    printInDebugMode('persist result for $postId with data = $data');
    final Directory cacheDirectory = await getTemporaryDirectory();
    final File cacheFile = File('${cacheDirectory.path}/$postId.txt');
    cacheFile.writeAsString(json.encode(data));
  }

//List<Map<String, dynamic>>
  Future<List<PostEntity>> _generateFeed(dynamic feedData) async {
    printInDebugMode('inside generatefeed');
    List<PostEntity> listOfPosts = [];
    if (!hasReachedMaxFirebaseFeed) {
      printInDebugMode('hasReachedMaxFirebaseFeed = false');
      final List<Map<String, dynamic>> posts = feedData['data'].cast<Map<String, dynamic>>();

      printInDebugMode('posts.lenght = ${posts.length}');
      listOfPosts.addAll(posts.map<PostEntity>(
        (item) {
          final postEntity = PostEntity.fromJSON(item);
          if ((item["postId"] == null || item["postId"] == "")) {
            String id = item['id'] ?? item['communityPostId'];
            String community = item['community'] ?? item['communityId'];
            String title = item['title'] ?? item['description'];
            String imgUrl = item['isVideo'] ? item['videoUrl'] : item['imgUrl'] ?? item['mediaUrl'];
            bool isVideo = item['isVideo'];
            String description = item['description'];
            String author = item['author'];
            String dataSource = item['dataSource'];
            String audioUrl = item['audioUrl'];
            int timestamp = item['createdAt'] != null ? DateTime.parse(item['createdAt']).millisecondsSinceEpoch : item['timestamp'];
            int height = item['height'];
            int width = item['width'];
            String categoryId = (item['game'] as String).toLowerCase().replaceAll(' ', '_');
            String category = item['game'];
            List<String> tags = item['tag'] != null ? (item['tags'] as List).map<String>((e) => e.toString()).toList() ?? [] : [];
            final postDescription = title.length > 0 && description.length > 0 ? '$title\n$description' : '$title$description';
            return PostEntity(
              description: postDescription,
              isVideo: isVideo,
              mediaUrl: imgUrl,
              communityPostId: id,
              communityId: community,
              source: 'community',
              timestamp: timestamp,
              audioUrl: audioUrl,
              author: author,
              dataSource: dataSource,
              tags: tags,
              width: width,
              height: height,
              categoryId: categoryId,
              categoryLabel: category,
            );
          }
          return postEntity;
        },
      ).toList());

      listOfPosts.removeWhere((element) =>
          element.communityPostId != null &&
          element.communityPostId != "" &&
          this.feedData.firstWhere((e) => e.communityPostId == element.communityPostId, orElse: () => PostEntity.empty()).communityPostId ==
              element.communityPostId);
      return listOfPosts;
    }
    return [];
  }

  @override
  void refresh() {
    _refresh();
  }

  @override
  void dispose() {
    FeedManager().removeRefreshListener(this);
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }
}

class PaginationInitiatorItem extends StatefulWidget {
  final Key key;
  final Function postExecute;
  final Widget child;
  PaginationInitiatorItem({this.key, this.postExecute, this.child}) : super(key: key);

  @override
  _PaginationInitiatorItemState createState() => _PaginationInitiatorItemState();
}

class _PaginationInitiatorItemState extends State<PaginationInitiatorItem> {
  bool isAlreadyCalledPostExecute = false;
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('feed_loader'),
      onVisibilityChanged: (VisibilityInfo info) {
        printInDebugMode('visibility = ${info.visibleFraction}');
        if (info.visibleFraction >= 0.01 && !isAlreadyCalledPostExecute) {
          isAlreadyCalledPostExecute = true;
          widget.postExecute.call();
        }
      },
      child: widget.child,
    );
  }
}
