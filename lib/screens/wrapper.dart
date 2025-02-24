// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fyp/screens/authentication/login_screen.dart';
// import 'package:fyp/screens/authentication/verify_email.dart';
//
// import 'home/home.dart';
//
// class Wrapper extends StatelessWidget {
//   const Wrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     // Return either Home or Authenticate Widget
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             print(snapshot.data);
//             if (snapshot.data!.emailVerified) {
//               return Home();
//             } else {
//               return Verify();
//             }
//           } else {
//             return Login();
//           }
//         }
//       ),
//     );
//   }
// }
