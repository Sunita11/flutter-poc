import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Analytics {
  static final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics();
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Analytics _singleton = Analytics._internal();

  factory Analytics() {
    return _singleton;
  }

  Analytics._internal();

  FirebaseAnalytics get analytics => _firebaseAnalytics;

  void _logEvent(String name, Map<String, dynamic> parameters) async {
    final userId = (await _firebaseAuth.currentUser())?.uid ?? "";
    _firebaseAnalytics.logEvent(
        name: name,
        parameters: (parameters ?? {})..putIfAbsent('user_id', () => userId));
  }

  void feedShown(String type, int pageNumber, String label) {
    var params = {
      'page_number': pageNumber,
      'type': type,
    };
    if(label != null && label.isNotEmpty) {
      params['label'] = label;
    }
    _logEvent('feed_shown', params);
  }

  void feedRefreshed(String type) {
    _logEvent('feed_refreshed', {
      'type': type,
    });
  }

  void drawerShown() {
    _logEvent('user_action', {'action_name': 'drawer_shown'});
  }

  void drawerClosed() {
    _logEvent('user_action ', {'action_name': 'drawer_closed'});
  }

  void categorySubscribed(String name, [String source = 'drawer']) {
    _logEvent(
        'subscription', {'name ': name, 'type': 'category', 'source': source});
  }

  void categoryUnsubscribed(String name, [String source = 'drawer']) {
    _logEvent('unsubscription',
        {'name ': name, 'type': 'category', 'source': source});
  }
}
