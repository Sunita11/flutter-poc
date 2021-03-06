import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'app_bar_header.dart';
import 'locale_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/app_bloc.dart';


class WrapperPage extends StatefulWidget {
  final String title;

  const WrapperPage({Key key, this.title}) : super(key: key);

  _WrapperFeed createState() => _WrapperFeed();
}

class _WrapperFeed extends State<WrapperPage> with SingleTickerProviderStateMixin {
  AnimationController _hideFabAnimController;
  ScrollController _scrollController;
  PageController _pageController;
  final _scrollThreshold = 200.0;

  @override
  void initState () {
    super.initState();
    _scrollController = ScrollController();
    // _getDataFromCache();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final localeStr = (state as AppState)
            .locale;
        return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: (){
                // add on pressed code
              },
              label: Text('Next $localeStr'),
              backgroundColor: Colors.green,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            appBar: AppBar(
              title: AppBarHeader(),
            ),
            body: LocaleList()
        );
      }
    );
  }
}