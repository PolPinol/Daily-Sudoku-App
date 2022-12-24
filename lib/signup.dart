import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  String? confPassword;
  bool error = false;
  String errMsg = "";

  @override
  Widget build(BuildContext context) {
    // sign in page
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 50.0,
          bottom: 50.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Create an account',
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: TextField(
                decoration: InputDecoration(
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
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
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
            // Text box for rep password
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
                onChanged: (value) {
                  confPassword = value;
                },
              ),
            ),
            if (error) ...[
              Text(errMsg, style: const TextStyle(color: Colors.red)),
            ],
            if (!error) ...[
              Text(' ', style: const TextStyle(color: Colors.red)),
            ],
            // Sign-up button
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to sign-in page
                  if (email == null ||
                      email == null ||
                      password == null ||
                      confPassword == null) {
                    errMsg = "There are empty fields.";
                    setState(() {
                      error = true;
                    });
                  } else if (password != confPassword) {
                    errMsg = "Passwords do not match.";
                    setState(() {
                      error = true;
                    });
                  } else if (email != null && password != null) {
                    try {
                      setState(() {
                        error = false;
                      });
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email!, password: password!);
                      if (newUser != null) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          errMsg = "Error from firebase";
                          error = true;
                        });
                      }
                    } catch (e) {
                      var err = e.toString().split("]");
                      setState(() {
                        errMsg = err[1];
                        error = true;
                      });
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
