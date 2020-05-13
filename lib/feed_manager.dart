class FeedManager {
  static final FeedManager _singleton = FeedManager._internal();

  factory FeedManager() {
    return _singleton;
  }

  FeedManager._internal();

  static final List<Refresh> refreshListeners = [];
  void addRefreshListener(Refresh widget) {
    refreshListeners.add(widget);
  }

  void removeRefreshListener(Refresh widget) {
    refreshListeners.remove(widget);
  }

  List<Refresh> get listeners {
    return []..addAll(refreshListeners);
  }
}

abstract class Refresh {
  void refresh();
}