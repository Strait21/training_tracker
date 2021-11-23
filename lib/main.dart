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
// ignore: import_of_legacy_library_into_null_safe
import 'package:location/location.dart';

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
    setSigninLoc();
    setState(() {
      _signInTime = DateFormat.Hms().format(DateTime.now());
      print("User: ${widget.user}, Signed in at: ${_signInTime}");
      _date = DateFormat.yMd().format(DateTime.now());
    });
  }

  void _setSignOut() {
    setSignoutLoc();
    setState(() {
      _signOutTime = DateFormat.Hms().format(DateTime.now());
      print("User: ${widget.user} Signed out at: ${_signOutTime}");
    });
  }

// This submit json should just be nested in the _setSignOutTime method but for now its working and I dont want to fuck with it
  void _submitInfo() {
    if (_signInTime == "" || _signOutTime == '') {
    } else {
      FirebaseFirestore.instance.collection("Users").add({
        "Name": widget.user,
        "Sign in time": _signInTime,
        "Sign out time": _signOutTime,
        "date": _date,
        "sign in LOC": _signInLoc,
        "sign out LOC": _signOutLoc,
      });
    }
  }

  void viewPlayers() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserInformation(title: widget.title, user: widget.user)));
  }

  void setSigninLoc() async {
    Location location = Location();
    LocationData _locationData;

    _locationData = await location.getLocation();
    print(
        "Longitude is: ${_locationData.longitude} Latitude is: ${_locationData.latitude}");
    setState(() {
      _signInLoc = '${_locationData.latitude} , ${_locationData.longitude}';
    });
  }

  void setSignoutLoc() async {
    Location location = Location();
    LocationData _locationData;

    _locationData = await location.getLocation();
    print(
        "Longitude is: ${_locationData.longitude} Latitude is: ${_locationData.latitude}");

    setState(() {
      _signOutLoc = '${_locationData.latitude} , ${_locationData.longitude}';
    });
  }

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                                Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF333333),
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF333333),
        unselectedItemColor: Color(0xFF666666),
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(
                  Icons.home,
                ),
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => PlayerHome(
                  //               title: 'Testing page routing',
                  //               user: widget.user,
                  //             )));
                },
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.list_alt),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "Home"));
                },
              ),
              label: "Database"),
        ],
      ),
    );
  }
}

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                                Login page state

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String userName = '';
  final userController = TextEditingController();
  bool _nameSaved = false;

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
              child: Image.asset('assets/HGlogo.png'),
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
                      primary: Color(0x666666),
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

// 8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                                  User Information list

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key, required this.title, required this.user})
      : super(key: key);
  final String title;
  final String user;
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Users').snapshots();

  void deleteUser(String documentID) {
    FirebaseFirestore.instance.collection("Users").doc(documentID).delete();
  }

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    if (document.data()['date'] == '') return const SizedBox(height: 10.0);
    return (ListTile(
      title: Text(document.data()['Name']),
      subtitle: Text(
          ' ${document.data()['Sign in time']} : ${document.data()['Sign out time']} : ${document.data()['date']}'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => deleteUser(document.id),
      ),
      onTap: () {
        print("Ive tapped a player");
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF333333),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF333333),
        selectedItemColor: Color(0xFF999999),
        unselectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "Database"));
                },
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => UserInformation()));
                },
              ),
              label: "Database"),
        ],
      ),
    );
  }
}
// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                            Routing

Route _createRoute(String title, String user, String page) {
  if (page == "Home") {
    print("moving form Home");
    UserInformation page = UserInformation(title: title, user: user);
    return PageRouteBuilder<SlideTransition>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween =
              Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero);
          var curveTween = CurveTween(curve: Curves.ease);

          return SlideTransition(
            position: animation.drive(curveTween).drive(tween),
            child: child,
          );
        });
  } else {
    PlayerHome page = PlayerHome(title: title, user: user);
    print("Moving from somewhere other than home");
    return PageRouteBuilder<SlideTransition>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween =
              Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero);
          var curveTween = CurveTween(curve: Curves.ease);

          return SlideTransition(
            position: animation.drive(curveTween).drive(tween),
            child: child,
          );
        });
  }
}
