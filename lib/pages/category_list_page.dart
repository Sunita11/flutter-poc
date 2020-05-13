import 'dart:convert';
import 'dart:io';

import 'package:BlogApp/core/repository.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CategoryListPage extends StatelessWidget {
  final HttpClient httpClient;
  CategoryListPage({
    Key key,
    this.httpClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What do you like'),
        actions: <Widget>[
          FlatButton(
            child: Text('Skip'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final categoryList = json.decode(snapshot.data);
              return CategoryList(
                items: categoryList,
              );
            } else if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error while fetching details'));
            }
            return Container();
          },
          future: Repository.getResponse(
              httpClient,
              'https://us-central1-dejavu-d75eb.cloudfunctions.net/categories',
              Duration(days: 1).inMinutes),
        ),
      ),
    );
  }
}

class CategoryList extends StatefulWidget {
  final items;

  const CategoryList({Key key, this.items}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final List selectedItems = [];

  void itemClicked(Map item) {
    if (_isItemSelected(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
    setState(() {});
  }

  bool _isItemSelected(Map item) {
    try {
      return selectedItems.firstWhere(
            (element) => element['id'] == item['id'],
          ) !=
          null;
    } on StateError {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: GridView.builder(
            itemBuilder: (ctx, index) {
              return GestureDetector(
                onTap: () => itemClicked(widget.items[index]),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Theme.of(context).dividerColor),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            //clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                widget.items[index]['poster_url'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: Text(
                              widget.items[index]['name'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      if (_isItemSelected(widget.items[index]))
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Icon(
                              Icons.done,
                              size: 48,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.items.length,
          ),
        ),
        Center(
          child: MaterialButton(
            minWidth: 215,
            onPressed: selectedItems.length == 0 ? null : saveToDisk,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            clipBehavior: Clip.antiAlias,
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
            ),
          ),
        ),
      ],
    );
  }

  Future saveToDisk() async {
    final filesDir = await getApplicationDocumentsDirectory();
    final subscribedCategoriesListFile =
        File('${filesDir.path}/subscribed_categories_list.json');
    await subscribedCategoriesListFile.writeAsString(json.encode(selectedItems));
    Navigator.of(context).pop();
  }
}
