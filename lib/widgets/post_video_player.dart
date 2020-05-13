import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:video_player/video_player.dart';

import '../util.dart';

class PostVideoPlayer extends StatefulWidget {
  final String mediaUrl;
  final String postId;
  final double height;
  final double width;
  PostVideoPlayer({this.postId, @required this.mediaUrl, this.height, this.width}) : assert(mediaUrl != null);

  @override
  _PostVideoPlayerState createState() => _PostVideoPlayerState();
}

enum PlayerState {
  playing,
  paused,
  stopped,
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  VideoPlayerController _controller;
  PlayerState _playerState = PlayerState.stopped;
  bool isDisposed = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.mediaUrl)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.initialized
          ? Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                ),
                Container(
                  width: double.infinity,
                  // height:
                  //     widget.height == null ? null : widget.height.toDouble(),
                  child: VisibilityDetector(
                    key: ValueKey(widget.postId),
                    onVisibilityChanged: (VisibilityInfo info) {
                      if (kDebugMode) {
                        printInDebugMode("visibility = ${info.visibleFraction}");
                      }
                      if (isDisposed) return;
                      if (info.visibleFraction >= 1) {
                        if (_playerState != PlayerState.playing) {
                          _controller.play();
                          _playerState = PlayerState.playing;
                        }
                      } else {
                        if (_playerState == PlayerState.playing) {
                          _controller.pause();
                          _playerState = PlayerState.paused;
                        }
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio > 0 ? _controller.value.aspectRatio : 2,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                // Align(
                //   alignment: FractionalOffset.bottomRight,
                //   child: Container(
                //     width: 30,
                //     height: 30,
                //     margin: EdgeInsets.all(5.0),
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.black54,
                //     ),
                //     child: Center(

                //       child: IconButton(
                //         padding: EdgeInsets.all(0),
                //         icon: Icon(Icons.volume_off),
                //         color: Colors.white,
                //         iconSize: 15,
                //         onPressed: () {
                //           _controller.setVolume(1);
                //         },
                //       ),
                //     ),
                //   ),
                // ),
              ],
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
    _controller.dispose();
  }
}
