import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/app_bloc.dart';

/*
class LocaleList extends StatefulWidget {
  LocaleList({
    Key key,
  }) : super(key: key);


  @override
  _LocaleListState createState() => _LocaleListState();
}

class _LocaleListState extends State<LocaleList> {
  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['English', '台灣', 'Tiếng Việt', 'Türkçe', 'ไทย','Русский', 'Português', 'polski', 'Melayu', '한국어'];
    final List<String>  mapEntries = <String>['en', 'ja', 'vi', 'tr', 'th', 'ru', 'pt-br', 'po', 'ma', 'ko'];
    final List<int> colorCodes = <int>[600, 500, 100, 600, 500, 100, 600, 500, 100, 600, 500, 100, 600, 500, 100];

    int activeIndex=0;
    Color activeColor = const Color(0xFF00CC76);
    Color activeBorderColor= const Color(0xFF00FF7F);

    void _onSelected(int i) {
      print(i);
      setState(() {
        activeIndex = i;
      });
    }
    return
      ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
//            print(activeIndex);
            return GestureDetector(
              child: Container(
                height: 50,
                child: Center(child: Text('${entries[index]}', style: TextStyle(color:  activeIndex != null && activeIndex == index ? activeColor : Color(0xFF72849D)))),
                decoration: new BoxDecoration(
                    border: new BorderDirectional(
                        bottom: new BorderSide(
                            color: activeIndex != null && activeIndex == index ? activeBorderColor :  Color(0xFF1a1f26),
                            width: 1.0,
                            style: BorderStyle.solid
                        )
                    )
                ),
              ),
              onTap: () {
                _onSelected(index);
              },
            );

          }
      );
  }
}

*/


class LocaleList extends StatefulWidget {
  LocaleList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocaleListState createState() => _LocaleListState();
}

class _LocaleListState extends State<LocaleList> {
  int _counter = -1;

  void _onSelected(int i) {
    print(i);
    setState(() {
      _counter = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['English', '台灣', 'Tiếng Việt', 'Türkçe', 'ไทย','Русский', 'Português', 'polski', 'Melayu', '한국어'];
    final List<String>  mapEntries = <String>['en', 'ja', 'vi', 'tr', 'th', 'ru', 'pt-br', 'po', 'ma', 'ko'];
    final List<int> colorCodes = <int>[600, 500, 100, 600, 500, 100, 600, 500, 100, 600, 500, 100, 600, 500, 100];
//    print(locale);
    Color activeColor = const Color(0xFF00CC76);
    Color activeBorderColor= const Color(0xFF00FF7F);

    final AppBloc _appBloc = BlocProvider.of<AppBloc>(context);

    return BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Container(
                        height: 50,
                        child: Center(child: Text('${entries[index]}', style: TextStyle(color:  _counter != null && _counter == index ? activeColor : Color(0xFF72849D)))),
                        decoration: new BoxDecoration(
                            border: new BorderDirectional(
                                bottom: new BorderSide(
                                    color: _counter != null && _counter == index ? activeBorderColor :  Color(0xFF1a1f26),
                                    width: 1.0,
                                    style: BorderStyle.solid
                                )
                            )
                        ),
                      ),
                      onTap: () {
                        _onSelected(index);
                        _appBloc.add(LocaleChanged(locale: mapEntries[_counter]));
                      },
                    );

                  }
              );
            }
    );
  }
}