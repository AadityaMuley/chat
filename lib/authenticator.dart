import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

//final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

//Future<FirebaseUser> _handleSignIn() async {
//  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//  final AuthCredential credential = GoogleAuthProvider.getCredential(
//    accessToken: googleAuth.accessToken,
//    idToken: googleAuth.idToken,
//  );
//
//  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
//  print("signed in " + user.displayName);
//  return user;
//}

class InheritedAuthenticator extends InheritedWidget {
  final AuthenticatorState state;

  InheritedAuthenticator({
    Key key,
    @required this.state,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedAuthenticator old) => true;
}

class Authenticator extends StatefulWidget {
  Authenticator({Key key, @required this.child}) : super(key: key);
  final Widget child;
  static AuthenticatorState of(BuildContext context) {
    return (context
            .dependOnInheritedWidgetOfExactType<InheritedAuthenticator>())
        .state;
  }

  @override
  AuthenticatorState createState() => AuthenticatorState();
}

class AuthenticatorState extends State<Authenticator> {
  bool isLoggedIn;
  FirebaseUser user;

  @override
  void initState() {
    isLoggedIn = false;
    _auth.currentUser().then((_user) async {
      if (_user != null) {
        user = _user;
        setState(() {
          isLoggedIn = true;
        });
//        firebaseCloudMessagingListeners();
      } else {
        setState(() {
          isLoggedIn = false;
        });
//        firebaseCloudMessagingListeners();
      }
    });
    super.initState();
  }

  login(email, password) async {
    try {
      var _user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      print(_user);
      setState(() {
        user = _user;
        isLoggedIn = true;
      });
    } catch (e) {
      print(e);
      throw e;
    }
    return user;
  }

  logout() async {
    try {
      await _auth.signOut();
      setState(() {
        user = null;
        isLoggedIn = false;
      });
      print(user);
    } catch (e) {
      print(e);
      throw e;
    }
    return user;
  }

  signUp(email, password, name) async {
    try {
      var _user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      UserUpdateInfo info = UserUpdateInfo();
      info.displayName = name;
      _user.updateProfile(info);
      await _user.reload();
      setState(() {
        user = _user;
        isLoggedIn = true;
      });
    } catch (e) {
      print(e);
      throw e;
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedAuthenticator(
      state: this,
      child: widget.child,
    );
  }
}
