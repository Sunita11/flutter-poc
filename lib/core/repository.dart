import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../util.dart';

const int DEFAULT_CACHE_DURATION_IN_MINUTES = 0;

class UserDetailsCallback {
  String ownerId;
  Function callback;
  UserDetailsCallback({
    this.ownerId,
    this.callback,
  });

}
class Repository {

  static List<UserDetailsCallback> userDetailsCallback = new List();

  static Future<String> getResponse(HttpClient httpClient, String url,
      [int cacheTime = 0]) async {
    final Directory cacheDirectory = await getTemporaryDirectory();
    final File cacheFile = File('${cacheDirectory.path}/${url.hashCode}.txt');
    if (cacheTime > 0) {
      bool isCacheExists = await cacheFile.exists();
      if (isCacheExists) {
        printInDebugMode('cache exists for $url');
        try {
          DateTime lastModified = await cacheFile.lastModified();
          if (lastModified.difference(DateTime.now()).inMinutes.abs() <
              cacheTime) {
            printInDebugMode(
                'difference is less than $cacheTime seconds, returning cached result for $url');
            String content = await cacheFile.readAsString();
            return content;
          } else {
            printInDebugMode(
                'difference in time = ${lastModified.difference(DateTime.now()).inMinutes.abs()}');
          }
        } catch (onError) {}
      } else {
        printInDebugMode('cache does not exists for $url');
      }
    }
    try {
      printInDebugMode('content is null, calling $url at ${DateTime.now().millisecondsSinceEpoch}');
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();

        printInDebugMode('at ${DateTime.now().millisecondsSinceEpoch} , response = $json');
        printInDebugMode(
            'writing it to cache file at ${cacheFile.path} for $url');
        cacheFile.writeAsString(json);
        printInDebugMode("Success in http request for feed from $url");
        return json;
      } else {
        printInDebugMode(
            'Error getting a feed: Http status ${response.statusCode} for $url');
      }
    } catch (exception) {
      printInDebugMode(
          'Failed invoking the getFeed function. Exception: $exception for url: $url');
    }
    return null;
  }

  static Map<String, User> postUsersMap = new HashMap();
  static Map<String, bool> postMediaValidityMap = new HashMap();
}
