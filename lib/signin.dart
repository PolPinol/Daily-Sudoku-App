import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_app/signup.dart';
import 'package:sudoku_app/game.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool error = false;
  String errMsg = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // sign in page
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/icon.png',
              height: 100,
            ),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            const Text(
              'Welcome! ',
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
            ),
            // Text box for password
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
            ),
            // Text error with color red
            if (error) ...[
              Text(errMsg, style: const TextStyle(color: Colors.red)),
            ],
            if (!error) ...[
              const Text('', style: TextStyle(color: Colors.red)),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_isLoading) return;
                  setState(() {
                    _isLoading = true;
                  });
                  if (email != null && password != null) {
                    try {
                      setState(() {
                        error = false;
                      });
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email!, password: password!);
                      if (user.user != null) {
                        log(user.user!.uid);

                        if (!mounted) return;

                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setString('uid', user.user!.uid);
                        });

                        setState(() {
                          _isLoading = false;
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GamePage(
                                    uid: user.user!.uid,
                                  )),
                        );
                      } else {
                        setState(() {
                          _isLoading = false;
                          errMsg = "Error from firebase";
                          error = true;
                        });
                      }
                    } catch (e) {
                      setState(() {
                        var err = e.toString().split("]");
                        setState(() {
                          _isLoading = false;
                          errMsg = err[1];
                          error = true;
                        });
                      });
                    }
                  }
                },
                child: const Text('Log In'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text('Create account'),
            ),
            // Sign-up button
          ],
        ),
      ),
    ));
  }
}
