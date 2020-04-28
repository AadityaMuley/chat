import 'package:chat/authenticator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(Authenticator(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => FirstScreen(),
        '/login': (context) => LoginScreen(),
//        '/loading': (context) => LoadingScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var auth = Authenticator.of(context);
    return auth.isLoggedIn ? HomePage() : LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  var textControllers = {
    "email": TextEditingController(),
    "password": TextEditingController(),
    "name": TextEditingController()
  };
  var email;
  var name;
  var password;
  var autoValidate = false;
  var isNewUser = false;

  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charaters';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 8)
      return 'Password must be more than 8 charaters';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: formKey,
            autovalidate: autoValidate,
            child: Container(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                    Text(
                      "CHAT APP",
                      style: TextStyle(fontSize: 50),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    TextFormField(
                      controller: textControllers["email"],
//                      autofocus: true,
                      validator: validateEmail,
                      onSaved: (val) {
                        this.email = val;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.blueGrey),
                          icon: Icon(
                            Icons.mail,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    TextFormField(
                      controller: textControllers["password"],
                      validator: validatePassword,
                      onSaved: (val) {
                        this.password = val;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.blueGrey),
                          icon: Icon(
                            Icons.security,
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    isNewUser
                        ? TextFormField(
                            controller: textControllers["name"],
                            validator: validateName,
                            onSaved: (val) {
                              this.name = val;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.5),
                                hintText: 'Name',
                                hintStyle: TextStyle(color: Colors.blueGrey),
                                icon: Icon(
                                  Icons.person,
                                )),
                          )
                        : Container(),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("${isNewUser ? 'Sign Up' : 'Login'}"),
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              try {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_context) {
                                  return LoadingScreen(
                                    email: email,
                                    password: password,
                                    name: isNewUser ? name : null,
//                                    context1: context,
                                  );
                                }));
                              } catch (e) {
                                print(e);
                              }
                            } else {
                              setState(() {
                                autoValidate = true;
                              });
                            }
                          },
                        ),
                        RaisedButton(
                          child: Text(
                              "${isNewUser ? 'Already Registered?' : 'New User?'}"),
                          onPressed: () {
                            setState(() {
                              isNewUser = !isNewUser;
                            });
                          },
                        )
                      ],
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                  ],
                ))));
  }
}

class LoadingScreen extends StatelessWidget {
  LoadingScreen({
    Key key,
    @required this.email,
    @required this.password,
    this.name,
//    @required this.context1,
  }) : super(key: key);
  final email;
  final password;
  final name;
  login(auth) async {
    if (!auth.isLoggedIn) {
      if (name != null) {
        return await auth.signUp(email, password, name);
      } else {
        return await auth.login(email, password);
      }
    } else {
      return auth.user;
    }
  }

//  final context1;
  @override
  Widget build(context) {
    var auth = Authenticator.of(context);
    return FutureBuilder(
        future: login(auth),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var chatKey = GlobalKey<FormState>();
  var chat = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var auth = Authenticator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Chat App: ${auth.user == null ? 'null' : auth.user.displayName}"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await auth.logout();
              await Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: !auth.isLoggedIn
          ? Center(
              child: RaisedButton(
              child: Text("Login"),
              onPressed: () async {
                await Navigator.of(context).pushReplacementNamed('/login');
              },
            ))
          : Container(
//          height: MediaQuery.of(context).size.height,
              child: Column(
              children: <Widget>[
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
//                    .collection("users/${auth.user.email}/chats")
                      .collection("chats")
                      .snapshots(),
                  builder: (_context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      if (snapshot.data.documents.length == 0) {
                        return Center(
                          child: Text("No chats"),
                        );
                      } else {
                        return ListView.separated(
                            itemBuilder: (_context, index) {
                              return ListTile(
                                title: Text(snapshot
                                    .data.documents[index].data['message']),
                                subtitle: Text(
                                    "${snapshot.data.documents[index].data['from']}"),
                              );
                            },
                            separatorBuilder: (_context, index) => Divider(),
                            itemCount: snapshot.data.documents.length);
                      }
                    }
                  },
                )),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Form(
                            key: chatKey,
                            child: TextField(
                              controller: chat,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your message here',
                              ),
                            )
//    child: TextFormField(
//    controller: chat,
//    ),
                            )),
                    IconButton(
//                        color: Colors.white,
                      onPressed: () async {
                        if (chat.text.trim().length != 0) {
                          await Firestore.instance
//                            .collection("users/${auth.user.email}/chats")
                              .collection("chats")
                              .add({
                            'message': chat.text,
                            'from': auth.user.displayName ?? 'null'
                          });
                        }
                      },
                      icon: Icon(Icons.send),
                    )
                  ],
                ),
              ],
            )),
    );
  }
}
