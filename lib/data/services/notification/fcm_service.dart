import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/event/models/event_model.dart';
import '../../../features/event/screens/event_detail/event_detail.dart';
import '../../repositories/event/event_repository.dart';

class FCMService {
  // 单例模式确保全局唯一实例
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin _localNotifications;

  static const String _lastUserIdKey = 'last_known_user_id';

  // 初始化 FCM
  Future<void> initialize() async {
    try {
      // 初始化本地通知
      await _initializeLocalNotifications();

      // 请求通知权限
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      print('Notification permission granted: ${settings.authorizationStatus}');

      // 获取并保存 FCM token
      await _getAndSaveFCMToken();

      // 设置消息处理回调
      _setupMessageHandlers();

      // 监听登录/登出状态
      _setupAuthStateListener();

      print('FCM Service initialized successfully for Event Reminders');
    } catch (e) {
      print('Error initializing FCM Service: $e');
    }
  }

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android 通知配置
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 通知配置
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response);
      },
    );

    // 创建事件提醒通知渠道 (Android)
    await _createNotificationChannels();
  }

  // 创建通知渠道
  Future<void> _createNotificationChannels() async {
    // 事件提醒渠道
    const AndroidNotificationChannel eventRemindersChannel =
    AndroidNotificationChannel(
      'event_reminders', // channelId
      'Event Reminders', // channelName
      description: 'Notifications for upcoming event reminders',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventRemindersChannel);
  }

  // 处理通知点击响应
  void _handleNotificationResponse(NotificationResponse response) {
    Map<String, dynamic>? payloadMap;
    if (response.payload != null) {
      try {
        payloadMap = _parsePayloadString(response.payload!);
      } catch (e) {
        print('Failed to parse notification payload: $e');
      }
    }
    _handleNotificationClick(payloadMap);
  }

  // 解析 payload 字符串
  Map<String, dynamic>? _parsePayloadString(String payload) {
    try {
      if (payload.startsWith('{') && payload.endsWith('}')) {
        return json.decode(payload) as Map<String, dynamic>;
      } else {
        // 处理查询字符串格式
        final Map<String, dynamic> result = {};
        final pairs = payload.split('&');
        for (final pair in pairs) {
          final keyValue = pair.split('=');
          if (keyValue.length == 2) {
            result[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
          }
        }
        return result;
      }
    } catch (e) {
      print('Error parsing payload: $e');
      return null;
    }
  }

  // 获取并保存 FCM token
  Future<void> _getAndSaveFCMToken() async {
    try {
      String? token = await _messaging.getToken();

      if (token != null) {
        await _saveTokenToFirestore(token);
        print('FCM Token obtained: $token');
      } else {
        print('Failed to get FCM token');
      }

      // 监听 token 刷新
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
        print('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // 保存 token 到 Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      String? userId = _getCurrentUserId();

      if (userId != null) {
        await _firestore.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('FCM token saved successfully for user $userId');

        // 保存用户ID到本地存储
        await _saveUserId(userId);
      } else {
        print('No user logged in, token not saved to Firestore');
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  // 获取当前用户ID
  String? _getCurrentUserId() {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // 设置消息处理回调
  void _setupMessageHandlers() {
    // 处理前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      showLocalNotification(message);
    });

    // 处理后台消息点击
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    });

    // 处理终止状态消息点击
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        _handleNotificationClick(message.data);
      }
    });
  }

  // 设置认证状态监听
  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // 用户登录，重新获取并保存 token
        print('User logged in, refreshing FCM token for user: ${user.uid}');
        await _saveUserId(user.uid);
        await _getAndSaveFCMToken();
      } else {
        // 用户登出
        print('User logged out, clearing local user data');
        await _clearTokensOnLogout();
      }
    });
  }

  // 保存用户ID到本地存储
  Future<void> _saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUserIdKey, userId);
      print('User ID saved to local storage: $userId');
    } catch (e) {
      print('Error saving user ID: $e');
    }
  }

  // 从本地存储获取最后一次已知的用户ID
  Future<String?> _getLastKnownUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUserIdKey);
    } catch (e) {
      print('Error getting last user ID: $e');
      return null;
    }
  }

  // 清理本地存储的用户ID
  Future<void> _clearSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUserIdKey);
      print('User ID cleared from local storage');
    } catch (e) {
      print('Error clearing user ID: $e');
    }
  }

  // 登出时清理token
  Future<void> _clearTokensOnLogout() async {
    try {
      final lastKnownUserId = await _getLastKnownUserId();

      if (lastKnownUserId != null) {
        // 清理 Firestore 中的 token
        await _firestore.collection('users').doc(lastKnownUserId).update({
          'fcmTokens': FieldValue.delete(),
          'lastLogout': FieldValue.serverTimestamp(),
        });
        print('FCM tokens cleared for user $lastKnownUserId on logout');

        // 清理本地存储的用户ID
        await _clearSavedUserId();
      } else {
        print('No known user ID to clear tokens');
      }
    } catch (e) {
      print('Error clearing tokens on logout: $e');
    }
  }

  // 显示本地通知
  Future<void> showLocalNotification(RemoteMessage message) async {
    final String? type = message.data['type'];

    // 根据通知类型选择不同的渠道和配置
    String channelId = 'event_reminders';
    String channelName = 'Event Reminders';
    String? sound;

    if (type == 'event_reminder') {
      channelId = 'event_reminders';
      channelName = 'Event Reminders';
    } else if (type == 'payment_reminder') {
      channelId = 'payment_reminders';
      channelName = 'Payment Reminders';
    }

    // Android 通知配置
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications for $channelName',
      importance: Importance.high,
      playSound: true,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      styleInformation: const BigTextStyleInformation(''),
    );

    // iOS 通知配置
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        message.hashCode, // 使用消息哈希作为通知ID
        message.notification?.title ?? 'Event Reminder',
        message.notification?.body ?? 'You have an upcoming event!',
        details,
        payload: jsonEncode(message.data),
      );
      print('Local notification shown successfully');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // 处理通知点击
  void _handleNotificationClick(Map<String, dynamic>? data) {
    if (data != null) {
      final type = data['type'];
      final eventId = data['eventId'];
      final reminderId = data['reminderId'];
      final registrationId = data['registrationId'];
      final userId = data['userId'];

      print('Notification clicked - Type: $type, Event ID: $eventId, User ID: $userId');

      // 验证通知属于当前用户
      final currentUserId = _getCurrentUserId();
      if (userId != null && currentUserId != null && userId != currentUserId) {
        print('Notification does not belong to current user. Expected: $currentUserId, Got: $userId');
        return;
      }

      // 根据通知类型导航到相应页面
      if (type == 'event_reminder' && eventId != null) {
        _navigateToEventDetails(eventId);
      } else if (type == 'payment_reminder' && data['invoiceId'] != null) {
        // 如果有支付提醒，可以在这里处理
        _navigateToPaymentDetails(data['invoiceId']);
      } else {
        print('Unknown notification type or missing data: $type');
      }
    } else {
      print('Notification clicked but no data provided');
    }
  }

  // 导航到事件详情页面
  void _navigateToEventDetails(String eventId) {
    try {
      // 使用 GetX 导航到事件详情页面，使用 EventRepository 获取 Event 对象
      Get.to(() => EventDetailScreenWrapper(eventId: eventId));
      print('Navigated to event details for event: $eventId');
    } catch (e) {
      print('Error navigating to event details: $e');
    }
  }

  // 导航到支付详情页面（如果需要）
  void _navigateToPaymentDetails(String invoiceId) {
    // 这里可以添加支付详情页面的导航逻辑
    print('Would navigate to payment details for invoice: $invoiceId');
    // Get.to(() => PaymentDetailScreen(invoiceId: invoiceId));
  }

  // ==================== 公共方法 ====================

  // 获取当前 FCM token（用于调试）
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting current token: $e');
      return null;
    }
  }

  // 手动保存 token（如果需要）
  Future<void> manuallySaveToken() async {
    await _getAndSaveFCMToken();
  }

  // 检查通知权限状态
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  // 订阅主题（如果需要）
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // 取消订阅主题
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // 清理所有注册的 tokens（用户登出时调用）
  Future<void> clearTokens() async {
    try {
      String? userId = _getCurrentUserId();
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.delete(),
          'lastTokenClear': FieldValue.serverTimestamp(),
        });
        print('FCM tokens cleared for user $userId');
      }
    } catch (e) {
      print('Error clearing FCM tokens: $e');
    }
  }

  // 获取 APNs token（iOS 专用）
  Future<String?> getAPNsToken() async {
    try {
      return await _messaging.getAPNSToken();
    } catch (e) {
      print('Error getting APNs token: $e');
      return null;
    }
  }

  // 检查是否已初始化
  bool get isInitialized => _localNotifications != null;

  // 打印调试信息
  Future<void> printDebugInfo() async {
    final token = await getCurrentToken();
    final settings = await getNotificationSettings();

    print('=== FCM Service Debug Info ===');
    print('FCM Token: $token');
    print('Notification Settings: $settings');
    print('Current User ID: ${_getCurrentUserId()}');
    print('Last Known User ID: ${await _getLastKnownUserId()}');
    print('Is Initialized: $isInitialized');
    print('==============================');
  }
}

// ==================== Event Detail Screen Wrapper ====================

/// Wrapper widget that fetches the Event object and passes it to EventDetailsScreen
class EventDetailScreenWrapper extends StatelessWidget {
  final String eventId;
  final EventRepository eventRepository = Get.find<EventRepository>();

  EventDetailScreenWrapper({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: eventRepository.getEventById(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading event: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Event not found')),
          );
        }

        final event = snapshot.data!;
        return EventDetailsScreen(event: event);
      },
    );
  }
}
