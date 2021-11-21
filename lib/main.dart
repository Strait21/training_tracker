import 'dart:async';
//import 'dart:html';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(title: 'Logging in'),
    );
  }
}

class AnimatedLogo extends AnimatedWidget {
  const AnimatedLogo({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  // Make the Tweens static because they don't change.
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  static final _sizeTween = Tween<double>(begin: 0, end: 300);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: _sizeTween.evaluate(animation),
          width: _sizeTween.evaluate(animation),
          child: Image.asset('assets/BlackWellsCollegeW.jpg'),
        ),
      ),
    );
  }
}

// class LoadingSplash extends StatefulWidget {
//   //const PlayerList({Key? key, required this.title, required this.user}) : super(key: key);
//   //final String title;
//   //final String user;

//   @override
//   State<LoadingSplash> createState() => _LoadingSplash();
// }

// class _LoadingSplash extends State<LoadingSplash> {

//    @override
//   void initState() {
//     super.initState();
//     Firebase.initializeApp();
//   }

// // 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
// //                                Build
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference users = FirebaseFirestore.instance.collection('Users');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       // body: StreamBuilder(
//       //     stream: FirebaseFirestore.instance.collection("Users").snapshots(),
//       //     builder:(context, snapshot) {
//       //       if (!snapshot.hasData) return const Text('Loading...');
//       //       return ListView.builder(
//       //         itemExtent: 88.0,
//       //         itemBuilder: (context, index) =>
//       //           );
//       //     } ,
//       // ),
//     );
//   }
// }

// // class User {
//    String name;
//    String signIn;
//    String signOut;

//    User(String name, String signIn, String signOut{
//       this.name = name;
//       this.signIn = signIn;
//       this.signOut = signOut;
//    }

//   // factory User.fromJson(Map<String, String> json) {
//   //   return User(
//   //     name: json['name'] as String,
//   //     signIn: json['sign in'] as String,
//   //     signOut: json['sign out'] as String,
//   //   );
//   // }
// }

class PlayerHome extends StatefulWidget {
  const PlayerHome({Key? key, required this.title, required this.user})
      : super(key: key);
  final String title;
  final String user;

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  String _signInTime = "";
  String _signInLoc = "";
  String _signOutTime = "";
  String _signOutLoc = "";
  String _date = '';

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp();
  }

  void _setSignIn() {
    setState(() {
      _signInTime = DateFormat.Hms().format(DateTime.now());
      print("User: ${widget.user}, Signed in at: ${_signInTime}");
      _date = DateFormat.yMd().format(DateTime.now());
    });
  }

  void _setSignOut() {
    setState(() {
      _signOutTime = DateFormat.Hms().format(DateTime.now());
      print("User: ${widget.user} Signed out at: ${_signOutTime}");
    });
  }

// This submit json should just be nested in the _setSignOutTime method but for now its working and I dont want to fuck with it
  void _submitInfo() {
    FirebaseFirestore.instance.collection("Users").add({
      "Name": widget.user,
      "Sign in time": _signInTime,
      "Sign out time": _signOutTime,
      "date": _date
    });
  }

  void viewPlayers() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UserInformation()));
  }

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                                Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: _setSignIn,
                          child: const Text("Sign in"),
                          // Need to change the size of the buttons and add the sending of the data to firebase for both of them
                        )),
                    Text(_signInTime),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: _setSignOut,
                          child: const Text("Sign out"),
                        )),
                    Text(_signOutTime),
                  ],
                ),
              ],
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                  child: Text("submit info"),
                  onPressed: _submitInfo,
                )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                  child: Text("View Player list"),
                  onPressed: viewPlayers,
                )),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
class _LoginPageState extends State<LoginPage> {
//                        Variables
  String userName = '';
  final userController = TextEditingController();
  bool _nameSaved = false;
// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                         Functions

  _saveName(string) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('key', string);
    print("saving name as: ${prefs.getString("key")}");
    //return true;
  }

  _removeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    print("Removing name: ${prefs.getString('key')}");
    return true;
  }

  _getSavedName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('key') != null) {
      userName = prefs.getString("key")!;
      setState(() {});
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayerHome(
                    title: 'Testing page routing',
                    user: '${prefs.getString('key')}',
                  )));
      print(prefs.getString("key"));
    }
  }

  @override
  void initState() {
    super.initState();
    _getSavedName();
    // Start listening to changes.
    userController.addListener(_setUserName);
    //passController.addListener(_printLatestValue);
  }

  void _setUserName() {
    userName = userController.text;
    //print('Username is: ${userName}');
  }

  void submitAuth() {
    if (userName != "") {
      if (_nameSaved) {
        _saveName(userName);
      } else {
        _removeName();
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayerHome(
                    title: 'Testing page routing',
                    user: '${userController.text}',
                  )));
    }
  }

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                              Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xD1D1D1FF), Color(0xFFFFFFFF)],
              begin: FractionalOffset(0.0, 1.0),
              end: FractionalOffset(0.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: ListView(
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 50.0, top: 50.0),
              child: Image.asset('assets/BlackWellsCollegeW.jpg'),
            ),

            // ignore: prefer_const_constructors
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: userController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _nameSaved,
                  onChanged: (bool? value) {
                    setState(() {
                      _nameSaved = !_nameSaved;
                    });
                  },
                ),
                const Text("Remember your name?")
              ],
            ),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: submitAuth,
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shadowColor: Colors.black,
                      minimumSize: Size(100.0, 30.0),
                    ),
                  )),
            ]),
          ],
        ),
      ),
    );
  }
}

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    if (document.data()['date'] == '') return const SizedBox(height: 10.0);
    return ListTile(
      title: Row(
        children: [
          Column(
            children: [
              Text(document.data()['Name']),
              Text(
                  ' ${document.data()['Sign in time']} : ${document.data()['Sign out time']} : ${document.data()['date']}'),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc(document.id)
                            .delete();
                      },
                      child: Text("Delete"))
                ],
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PlayerList'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");
          return ListView.builder(
            itemCount: snapshot.data!.size,
            itemBuilder: (context, index) =>
                _buildList(context, snapshot.data!.docs[index]),
          );
        },
      ),
    );
  }
}


// class PlayerList extends StatefulWidget {
//   const PlayerList({Key? key, required this.title, required this.user})
//       : super(key: key);
//   final String title;
//   final String user;

//   @override
//   State<PlayerList> createState() => _PlayerList();
// }

// class _PlayerList extends State<PlayerList> {
//   @override
//   void initState() {
//     super.initState();
//     Firebase.initializeApp();
//   }

// // 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
// //                                Build
//   @override
//   Widget build(BuildContext context) {
//     CollectionReference users = FirebaseFirestore.instance.collection('Users');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: StreamBuilder(
//           stream: FirebaseFirestore.instance.collection('Users').snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) return const Text('Loading...');
//             return ListView(
//               children: snapshot.data!.docs.map((DocumentSnapshot document) {
//                 Map<String, dynamic> data =
//                     document.data()! as Map<String, dynamic>;
//                 return ListTile(
//                   title: Text(data['name']),
//                   subtitle: Text(data['date']),
//                 );
//               }).toList(),
//             );
//           }),
//     );
//   }
// }
