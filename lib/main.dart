import 'dart:async';
import 'dart:developer';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:location/location.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: const LoginPage(title: 'Log in'),
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
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';
  String successMessage = '';

  Future<FirebaseUser?> signIn(String email, String password) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      return user;
    } on PlatformException catch (_, e) {
      handleError(_);
      return null;
    }
  }
  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_USER_NOT_FOUND':
        setState(() {
          errorMessage = 'User Not Found!!!';
        });
        break;
      case 'ERROR_WRONG_PASSWORD':
        setState(() {
          errorMessage = 'Wrong Password!!!';
        });
        break;
    }
  }

  void submitAuth(String _email,String _password) {
    signIn(_email, _password).then((user) {
                                if (user != null) {
                                  print('Logged in successfully.');
                                  setState(() {
                                    successMessage =
                                        'Logged in successfully.\nYou can now navigate to Home Page.';
                                  });
                                } else {
                                  print('Error while Login.');
                                }
  });
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

            // ignore: prefer_const_constructors
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
            ),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () => submitAuth(_emailController.text, _passwordController.text),
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
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  String dropdownValue = 'One';

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF333333),
        title: Text(''),
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
              Tween<Offset>(begin: const Offset(0.0, 0.0), end: Offset.zero);
          var curveTween = CurveTween(curve: Curves.ease);
          return SlideTransition(
            position: animation.drive(curveTween).drive(tween),
            child: child,
          );
        });
  }
}
