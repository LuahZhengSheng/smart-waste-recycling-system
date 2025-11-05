// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../../data/services/notification/fcm_service.dart';
//
// class NotificationTestScreen extends StatelessWidget {
//   final FCMService fcmService = FCMService();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   NotificationTestScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('推送通知测试'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // 调试信息
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       '调试信息',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     FutureBuilder<String?>(
//                       future: fcmService.getCurrentToken(),
//                       builder: (context, snapshot) {
//                         return Text('FCM Token: ${snapshot.data ?? "Loading..."}');
//                       },
//                     ),
//                     const SizedBox(height: 5),
//                     Text('User ID: ${_auth.currentUser?.uid ?? "Not logged in"}'),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // 测试按钮
//             ElevatedButton(
//               onPressed: _testLocalNotification,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 '测试本地通知',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: _testForegroundNotification,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 '测试前台通知',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: _createTestReminder,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 '创建测试提醒',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: _sendTestPushNotification,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 '发送测试推送通知',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             ElevatedButton(
//               onPressed: fcmService.printDebugInfo,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 '打印调试信息',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // 查看现有提醒
//             const Text(
//               '现有提醒:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('reminders')
//                     .where('userId', isEqualTo: _auth.currentUser?.uid)
//                     .orderBy('remindAt', descending: false)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   }
//
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   final reminders = snapshot.data!.docs;
//
//                   if (reminders.isEmpty) {
//                     return const Center(child: Text('没有提醒'));
//                   }
//
//                   return ListView.builder(
//                     itemCount: reminders.length,
//                     itemBuilder: (context, index) {
//                       final reminder = reminders[index];
//                       final data = reminder.data() as Map<String, dynamic>;
//
//                       return Card(
//                         child: ListTile(
//                           title: Text(data['title'] ?? 'No Title'),
//                           subtitle: Text(data['message'] ?? 'No Message'),
//                           trailing: Text(data['isSent'] == true ? '已发送' : '待发送'),
//                           onTap: () {
//                             _sendSpecificReminder(reminder.id);
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // 测试本地通知
//   void _testLocalNotification() async {
//     try {
//       final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//       const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//         'event_reminders',
//         'Event Reminders',
//         channelDescription: 'Notifications for event reminders',
//         importance: Importance.high,
//         playSound: true,
//       );
//
//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
//
//       const NotificationDetails details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );
//
//       await flutterLocalNotificationsPlugin.show(
//         999,
//         '测试本地通知',
//         '这是一个本地通知测试',
//         details,
//         payload: jsonEncode({
//           'type': 'event_reminder',
//           'eventId': 'test_event_123',
//           'userId': _auth.currentUser?.uid,
//         }),
//       );
//
//       Get.snackbar('成功', '本地通知已发送');
//     } catch (e) {
//       Get.snackbar('错误', '发送本地通知失败: $e');
//     }
//   }
//
//   // 测试前台通知
//   void _testForegroundNotification() async {
//     try {
//       // 模拟一个远程消息
//       final remoteMessage = RemoteMessage(
//         data: {
//           'type': 'event_reminder',
//           'eventId': 'test_event_456',
//           'reminderId': 'test_reminder_456',
//           'registrationId': 'test_registration_456',
//           'userId': _auth.currentUser?.uid,
//           'title': '测试前台通知',
//           'message': '这是一个前台通知测试',
//         },
//         notification: RemoteNotification(
//           title: '测试前台通知',
//           body: '这是一个前台通知测试',
//         ),
//       );
//
//       // 直接调用 FCM Service 的处理方法
//       FCMService().showLocalNotification(remoteMessage);
//
//       Get.snackbar('成功', '前台通知测试已发送');
//     } catch (e) {
//       Get.snackbar('错误', '前台通知测试失败: $e');
//     }
//   }
//
//   // 创建测试提醒
//   void _createTestReminder() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         Get.snackbar('错误', '用户未登录');
//         return;
//       }
//
//       // 首先创建一个测试事件注册
//       final registrationDoc = await _firestore.collection('eventRegistrations').add({
//         'userId': userId,
//         'eventId': 'test_event_${DateTime.now().millisecondsSinceEpoch}',
//         'createdAt': FieldValue.serverTimestamp(),
//         'status': 'registered',
//       });
//
//       // 创建测试提醒（5分钟后）
//       final remindAt = DateTime.now().add(const Duration(minutes: 5));
//
//       await _firestore.collection('reminders').add({
//         'registrationId': registrationDoc.id,
//         'userId': userId,
//         'title': '测试事件提醒',
//         'message': '这是一个测试事件提醒，请检查通知功能是否正常。',
//         'remindAt': remindAt,
//         'createdAt': FieldValue.serverTimestamp(),
//         'isSent': false,
//       });
//
//       Get.snackbar('成功', '测试提醒已创建，将在5分钟后发送');
//     } catch (e) {
//       Get.snackbar('错误', '创建测试提醒失败: $e');
//     }
//   }
//
//   // 发送测试推送通知
//   void _sendTestPushNotification() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         Get.snackbar('错误', '用户未登录');
//         return;
//       }
//
//       // 获取用户的 FCM token
//       final userDoc = await _firestore.collection('users').doc(userId).get();
//       final userData = userDoc.data();
//       final fcmTokens = userData?['fcmTokens'] as List<dynamic>? ?? [];
//
//       if (fcmTokens.isEmpty) {
//         Get.snackbar('错误', '用户没有 FCM token');
//         return;
//       }
//
//       // 使用 Firebase Console 或 Postman 发送测试通知
//       // 这里只是显示信息
//       Get.defaultDialog(
//         title: '发送测试推送通知',
//         content: Column(
//           children: [
//             const Text('请使用以下方法之一发送测试通知:'),
//             const SizedBox(height: 10),
//             const Text('1. Firebase Console → Cloud Messaging'),
//             const Text('2. Postman 调用 FCM API'),
//             const Text('3. 使用 Cloud Functions 测试函数'),
//             const SizedBox(height: 10),
//             Text('User ID: $userId'),
//             Text('FCM Tokens: ${fcmTokens.length}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('确定'),
//           ),
//         ],
//       );
//
//     } catch (e) {
//       Get.snackbar('错误', '发送测试推送通知失败: $e');
//     }
//   }
//
//   // 发送特定提醒
//   void _sendSpecificReminder(String reminderId) async {
//     try {
//       // 这里可以调用 Cloud Function 来手动发送提醒
//       Get.snackbar('信息', '点击了提醒 $reminderId');
//     } catch (e) {
//       Get.snackbar('错误', '发送提醒失败: $e');
//     }
//   }
// }