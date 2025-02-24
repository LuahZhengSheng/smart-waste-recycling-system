// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class SignupModel {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   /// Firebase 用户注册并保存到 Firestore
//   Future<User?> createUser(String name, String email, String password) async {
//     try {
//       // 注册用户
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // 获取用户 ID
//       final userId = userCredential.user?.uid;
//
//       // 存储到 Firestore 的 `users` 集合
//       if (userId != null) {
//         await _firestore.collection('users').doc(userId).set({
//           'name': name,                     // 用户名
//           'email': email,                   // 邮箱
//           'password': password,             // 明文密码（建议哈希存储）
//           'join_date': DateTime.now(),      // 加入日期
//         });
//       }
//
//       return userCredential.user; // 返回用户信息
//     } catch (e) {
//       print("Error during user creation: $e");
//       throw e; // 将错误抛出给 Controller 处理
//     }
//   }
// }
