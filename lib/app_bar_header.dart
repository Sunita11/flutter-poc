import 'package:flutter/material.dart';

class AppBarHeader extends StatelessWidget {
  final String heading;
  final String subheading;
  const AppBarHeader({
    Key key,
    this.heading = "",
    this.subheading = "DejaVu",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text('Select your language', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  letterSpacing: -0.01,
                  color: Color(0xFFDADFE7),
                ),
                    textAlign: TextAlign.left),
                Text('All the games and their blogs will be shown in your selected language', style:TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF72849D),
                ),
                    maxLines: 2,
                    textAlign: TextAlign.left)
              ]
          )
      );
  }
}