import 'dart:async';
import 'dart:developer';

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
import 'package:table_calendar/table_calendar.dart';

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
                    title: 'Home',
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
      Navigator.of(context)
          .push<void>(_createRoute(widget.title, userName, "Home"));
    }
  }

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
            Text("Harrible Garner"),

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

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                              Player Home
class PlayerHome extends StatefulWidget {
  const PlayerHome({Key? key, required this.title, required this.user})
      : super(key: key);
  final String title;
  final String user;

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Widget Extras(BuildContext context) {
    return DropdownButton(items: [
      DropdownMenuItem(
        child: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context)
                .push<void>(_createRoute(widget.title, widget.user, "Logout"));
          },
        ),
      ),
      DropdownMenuItem(
          child: IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF333333),
        title: Text('Home'),
        actions: [Extras(context)],
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2019),
        lastDay: DateTime.utc(2024),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.twoWeeks: 'twoWeeks',
          CalendarFormat.week: "Week"
        },
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF333333),
        selectedItemColor: Color(0xFF999999),
        unselectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "LiftLog"));
                },
              ),
              label: "LiftLog"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {},
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "Database"));
                },
              ),
              label: "Database"),
        ],
      ),
    );
  }
}

// 888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//                        LiftLog
class LiftLog extends StatefulWidget {
  const LiftLog({Key? key, required this.title, required this.user})
      : super(key: key);
  final String title;
  final String user;

  @override
  State<LiftLog> createState() => _LiftLogState();
}

class _LiftLogState extends State<LiftLog> {
  DateTime? _signInTime;
  GeoPoint? _signInLoc;
  DateTime? _signOutTime;
  GeoPoint? _signOutLoc;
  bool _signInPushed = false;
  bool _signOutPushed = false;

  @override
  void initState() {
    super.initState();
  }

  void _setSignIn() {
    if (!_signInPushed) {
      setSigninLoc();
      setState(() {
        _signInTime = DateTime.now();
        print("User: ${widget.user}, Signed in at: ${_signInTime}");
      });
    }
    setState(() {
      _signInPushed = !_signInPushed;
    });
  }

  void _setSignOut() {
    if (!_signOutPushed) {
      setSignoutLoc();
      setState(() {
        _signOutTime = DateTime.now();
        print("User: ${widget.user} Signed out at: ${_signOutTime}");
      });
    }
    setState(() {
      // maybe we can have a lose Progress dialog pop up here???
      _signOutPushed = !_signOutPushed;
    });
  }

  void _submitInfo() {
    if (_signInTime == null || _signOutTime == null) {
// Pop up dialog to state which button needs to be pressed

    } else {
      FirebaseFirestore.instance.collection("Users").add({
        "Name": widget.user,
        "Sign in time": _signInTime,
        "Sign out time": _signOutTime,
        "sign in LOC": _signInLoc,
        "sign out LOC": _signOutLoc,
      });
    }
  }

  void setSigninLoc() async {
    Location location = Location();
    LocationData _locationData;

    _locationData = await location.getLocation();
    setState(() {
      _signInLoc = GeoPoint(_locationData.latitude, _locationData.longitude);

      // _signInLoc = '${_locationData.latitude} , ${_locationData.longitude}';
    });
  }

  void setSignoutLoc() async {
    Location location = Location();
    LocationData _locationData;

    _locationData = await location.getLocation();
    print(
        "Longitude is: ${_locationData.longitude} Latitude is: ${_locationData.latitude}");

    setState(() {
      _signOutLoc = GeoPoint(_locationData.latitude, _locationData.longitude);
      // _signOutLoc = '${_locationData.latitude} , ${_locationData.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                          // Need to change the size of the buttons
                        )),
                    //Text(_signInTime),
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
                    // Text(_signOutTime),
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
                icon: Icon(Icons.person),
                onPressed: () {},
              ),
              label: "LiftLog"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "Home"));
                },
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.list_alt),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "Database"));
                },
              ),
              label: "Database"),
        ],
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
  void deleteUser(String documentID) {
    FirebaseFirestore.instance.collection("Users").doc(documentID).delete();
  }

  Widget _buildList(BuildContext context, DocumentSnapshot document) {
    Duration difference = document
        .data()["Sign out time"]
        .toDate()
        .difference(document.data()["Sign in time"].toDate());

    if (document.data()['date'] == '') return const SizedBox(height: 10.0);
    return (ListTile(
      title: Text(document.data()['Name']),
      subtitle: Text(difference.toString()),

      //Text(
      //     ' ${document.data()['Sign in time']} : ${document.data()['Sign out time']}'),
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
        automaticallyImplyLeading: false,
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
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "LiftLog"));
                },
              ),
              label: "LiftLog"),
          BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).push<void>(
                      _createRoute(widget.title, widget.user, "Home"));
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
  if (page == "Database") {
    UserInformation page = UserInformation(title: title, user: user);
    return PageRouteBuilder<SlideTransition>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween =
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero);
          var curveTween = CurveTween(curve: Curves.ease);

          return SlideTransition(
            position: animation.drive(curveTween).drive(tween),
            child: child,
          );
        });
  } else if (page == "LiftLog") {
    LiftLog page = LiftLog(title: title, user: user);
    return PageRouteBuilder<SlideTransition>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween =
              Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);
          var curveTween = CurveTween(curve: Curves.ease);

          return SlideTransition(
            position: animation.drive(curveTween).drive(tween),
            child: child,
          );
        });
  }
  if (page == "Logout") {
    LoginPage page = LoginPage(title: "login");
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
  } else {
    PlayerHome page = PlayerHome(title: title, user: user);
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
