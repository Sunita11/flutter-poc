import 'package:BlogApp/util.dart';
import 'package:flutter/material.dart';

class AppBarHeader extends StatelessWidget {
  final String avatarUrl;
  final String avatarLabel;
  final Function onAvatarTap;
  const AppBarHeader({
    Key key,
    this.avatarUrl = "",
    this.avatarLabel = "BlogApp Sunita",
    this.onAvatarTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    printInDebugMode('$avatarLabel is avatarLabel');
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCircularAvatar(context),
        SizedBox(width: 10),
        _buildAvatarLabel(context),
      ],
    );
  }

  _buildCircularAvatar(BuildContext context) {
    bool isWebUrl = avatarUrl != null && avatarUrl.length > 0 && Uri.parse(avatarUrl).isAbsolute;
    final backgroundImage = isWebUrl ? NetworkImage(avatarUrl) : null;
    final backgroundColor = isWebUrl ? null : Theme.of(context).scaffoldBackgroundColor;
    final child = isWebUrl
        ? null
        : avatarUrl != null && avatarUrl.length > 0
            ? Text(avatarUrl.substring(0, 1))
            : Image.asset(
                'assets/images/ic_launcher.png',
                width: 32,
                height: 32,
              );

    return GestureDetector(
        child: CircleAvatar(backgroundImage: backgroundImage, backgroundColor: backgroundColor, radius: 16, child: child),
        onTap: () {
          printInDebugMode('circle avatar tapped');
          if (onAvatarTap != null) {
            onAvatarTap();
          }
        });
  }

  _buildAvatarLabel(BuildContext context) {
    return GestureDetector(
        child: Text(
      avatarLabel,
    ),
    onTap: () {
          if (onAvatarTap != null) {
            onAvatarTap();
          }
        },
    );
  }
}
