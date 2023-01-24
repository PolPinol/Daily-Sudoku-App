import 'package:flutter/material.dart';
import 'package:sudoku_app/signin.dart';
import 'package:sudoku_app/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uid') ?? '';
  runApp(MyApp(uid: uid));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.uid});

  final String uid;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: uid != '' ? GamePage(uid: uid) : const SignInPage(),
    );
  }
}
