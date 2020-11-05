import 'package:flutter/material.dart';
// import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oauth1/oauth1.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:twitter_login/twitter_login.dart' as T;
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}


class _LoginState extends State<Login> {

FirebaseAuth _auth = FirebaseAuth.instance;
Authorization _oauth;
final twitterPlatform = Platform(
    'https://api.twitter.com/oauth/request_token', // temporary credentials request
    'https://api.twitter.com/oauth/authorize', // resource owner authorization
    'https://api.twitter.com/oauth/access_token', // token credentials request
    SignatureMethods.hmacSha1, // signature method
  );
final ClientCredentials clientCredentials= ClientCredentials('O9AvyC4qDvCCdxn1LaypRVF8E', '4qAEinQ6L3Wba25sZVllSEtb8vx6i1zuwIHnD3vT4MyDBgd0CI');
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  final oauthCallbackHandler = 'https://dummy-test-10de7.firebaseapp.com/__/auth/handler';


 @override
  void initState() {
    // Initialize Twitter OAuth
    _oauth = Authorization(clientCredentials, twitterPlatform);

    flutterWebviewPlugin.onUrlChanged.listen((url) {
      // Look for Step 2 callback so that we can move to Step 3.
      if (url.startsWith(oauthCallbackHandler)) {
        print('url: $url');
        final queryParameters = Uri.parse(url).queryParameters;
        final oauthToken = queryParameters['oauth_token'];
        final oauthVerifier = queryParameters['oauth_verifier'];
        if (null != oauthToken && null != oauthVerifier) {
          _twitterLogInFinish(oauthToken, oauthVerifier);
        }
      }
    });

    flutterWebviewPlugin.close();

    
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

    Future<void> _twitterLogInStart() async {
      print('_twitterLogInStart $_oauth');
    assert(null != _oauth);
    // Step 1 - Request Token
    final requestTokenResponse =
        await _oauth.requestTemporaryCredentials(oauthCallbackHandler);
    // Step 2 - Redirect to Authorization Page
    final authorizationPage = _oauth.getResourceOwnerAuthorizationURI(
        requestTokenResponse.credentials.token);
        print('authorizationPage: $authorizationPage');
    flutterWebviewPlugin.launch(authorizationPage);
  }

    Future<void> _twitterLogInFinish(
      String oauthToken, String oauthVerifier) async {
    // Step 3 - Request Access Token
      print('_twitterLogInFinish');
    final tokenCredentialsResponse = await _oauth.requestTokenCredentials(
        Credentials(oauthToken, ''), oauthVerifier);

    final result = TwitterAuthProvider.getCredential(
      authToken: tokenCredentialsResponse.credentials.token,
      authTokenSecret: tokenCredentialsResponse.credentials.tokenSecret,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(result)).user;
        print('users: $user');

    final FirebaseUser currentUser = await _auth.currentUser();
      if (user != null) {
        var _message = 'Successfully signed in with Twitter. ' + user.uid;

        print(_message);
        // flutterWebviewPlugin.dispose();
        
      } else {
        var _message = 'Failed to sign in with Twitter. ';
         print(_message);
      }
    flutterWebviewPlugin.close();
    print('auth result: $result');

     Navigator.of(context).pushNamed('home');
  }

  /* _signInTwitterNormal(context) async {
    var twitterLogin = new TwitterLogin(
      consumerKey: 'O9AvyC4qDvCCdxn1LaypRVF8E',
      consumerSecret: '4qAEinQ6L3Wba25sZVllSEtb8vx6i1zuwIHnD3vT4MyDBgd0CI',
    );

    final TwitterLoginResult result = await twitterLogin.authorize();
    print('TwitterLoginResult $result');
      switch (result.status) {
        case TwitterLoginStatus.loggedIn:
          print('login successfull');
              final result2 = TwitterAuthProvider.getCredential(
              authToken: result.session.token,
              authTokenSecret: result.session.secret,
            );

            final FirebaseUser user =
                (await _auth.signInWithCredential(result2)).user;
                print('users: $user');
          // Navigator.of(context).pushNamed('home');
          // _sendTokenAndSecretToServer(session.token, session.secret);
          break;
        case TwitterLoginStatus.cancelledByUser:
          print('login cancelled');
          // _showCancelMessage();
          break;
        case TwitterLoginStatus.error:
          var msg = result.errorMessage;
          print('error occurred: $msg');
          // _showErrorMessage(result.error);
          break;
      }
  } */

  /* _signInNewLogin() async {
      final twitterLogin = T.TwitterLogin(
      // Consumer API keys
      apiKey: 'O9AvyC4qDvCCdxn1LaypRVF8E',
      apiSecretKey: '4qAEinQ6L3Wba25sZVllSEtb8vx6i1zuwIHnD3vT4MyDBgd0CI',
      // Callback URL for Twitter App
      // Android is a deeplink
      // iOS is a URLScheme
      redirectURI: 'https://dummy-test-10de7.firebaseapp.com/__/auth/handler',
      );
      final authResult1 = await twitterLogin.login();
      switch (authResult1.status) {
      case T.TwitterLoginStatus.loggedIn:
          // success
          print('success');
          break;
      case T.TwitterLoginStatus.cancelledByUser:
          // cancel
           print('cancel');
          break;
      case T.TwitterLoginStatus.error:
          // error
          break;
      }
  } */

  // Example code of how to sign in with Twitter.
  void _signInWithTwitter() async {
    final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: 'O9AvyC4qDvCCdxn1LaypRVF8E',
        authTokenSecret: '4qAEinQ6L3Wba25sZVllSEtb8vx6i1zuwIHnD3vT4MyDBgd0CI');
        print(credential);
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
      if (user != null) {
        var _message = 'Successfully signed in with Twitter. ' + user.uid;
        print(_message);
      } else {
        var _message = 'Failed to sign in with Twitter. ';
         print(_message);
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text('Login page header', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    letterSpacing: -0.01,
                    color: Color(0xFFDADFE7),
                  ),
                      textAlign: TextAlign.left),
                ]
            )
        ),
        ),
        body: Center(
          child: Container(
          height: 50.0,
          child: RaisedButton(
            onPressed: () {
              // _signInNewLogin();
              // _signInTwitterNormal(context);
              // _signInWithTwitter();
              // _twitterLogInStart();
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
            padding: EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0)
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                alignment: Alignment.center,
                child: Text(
                  "Login twitter",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        ),
        )
    );
  }
}