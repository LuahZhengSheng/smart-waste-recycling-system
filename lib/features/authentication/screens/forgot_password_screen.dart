import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  reset() async {
    // await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.text,
      );
    } catch (e) {
      print("Error during sign in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot'),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),
            ElevatedButton(
              onPressed: (() => reset()),
              child: Text('Send link'),
            ),
          ],
        ),
      ),
    );
  }
}
