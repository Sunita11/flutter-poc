import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'core/repository.dart';
import 'main.dart';

class PostForm extends StatelessWidget {
  final mediaFile;
  final TextEditingController descriptionController;
  final TextEditingController selectGameController;
  final Function onGameSelected;
  final bool loading;
  final isVideo;
  final HttpClient httpClient;
  PostForm(
      {this.mediaFile,
      this.descriptionController,
      this.loading,
      this.onGameSelected,
      this.selectGameController,
      this.isVideo = false,
      this.httpClient});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        loading
            ? LinearProgressIndicator()
            : Padding(padding: EdgeInsets.only(top: 0.0)),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(currentUserModel.photoUrl),
            ),
            Container(
              width: 250.0,
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            Container(
              height: 45.0,
              width: 45.0,
              child: AspectRatio(
                aspectRatio: 487 / 451,
                child: PreviewThumbnail(
                  mediaPath: mediaFile,
                  isVideo: isVideo,
                ),
              ),
            ),
          ],
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.games),
          title: Container(
            width: double.infinity,
            child: TypeAheadField(
              
              getImmediateSuggestions: true ,
              suggestionsCallback: (pattern) async {
                if(onGameSelected != null) {
                  onGameSelected(null);
                }
                
                final categories = await Repository.getResponse(httpClient, 'https://us-central1-dejavu-d75eb.cloudfunctions.net/categories', Duration(days: 1).inMinutes);
                final List categoryList =
                    json.decode(categories);
                return categoryList.where(
                  (element) => (element['name'] as String).contains(
                    RegExp(
                      pattern,
                      caseSensitive: false,
                    ),
                  ),
                );
              },
              itemBuilder: (ctx, suggestion) {
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            NetworkImage(suggestion['poster_url'])),
                  ),
                  title: Text(suggestion['name']),
                );
              },
              onSuggestionSelected: (suggestion) {
                selectGameController.text = suggestion['name'];
                if(onGameSelected != null) {
                  onGameSelected(suggestion['id']);
                }
              },
              textFieldConfiguration: TextFieldConfiguration(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: "Which game this post belongs to?",
                  border: InputBorder.none,
                ),
                controller: selectGameController,
              ),
              noItemsFoundBuilder: (context) => ListTile(title: Text('No game found'),),
            ),
          ),
        ),
      ],
    );
  }
}

class PreviewThumbnail extends StatefulWidget {
  final File mediaPath;
  final isVideo;

  const PreviewThumbnail({@required this.mediaPath, this.isVideo = false});

  @override
  _PreviewThumbnailState createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<PreviewThumbnail> {
  File finalMediaFile;

  void loadMedia() async {
    if (finalMediaFile != null) {
      return;
    }
    if (widget.isVideo) {
      String thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: widget.mediaPath.path,
          imageFormat: ImageFormat.JPEG,
          quality: 40,
          thumbnailPath: (await getTemporaryDirectory()).path);
      finalMediaFile = File(thumbnailPath);
    } else {
      finalMediaFile = widget.mediaPath;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  @override
  Widget build(BuildContext context) {
    return finalMediaFile == null
        ? CircularProgressIndicator()
        : Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    alignment: FractionalOffset.topCenter,
                    image: FileImage(finalMediaFile),
                  ),
                ),
              ),
              widget.isVideo
                  ? Positioned(
                      child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black38),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          );
  }
}
