import 'package:firebase_auth/firebase_auth.dart';
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
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin _localNotifications;

  static const String _lastUserIdKey = 'last_known_user_id';
  static const String _scheduledRemindersKey = 'scheduled_reminders';

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      await _initializeLocalNotifications();

      // Request notification permission
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

      // Get and save FCM token
      await _getAndSaveFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Setup auth state listener
      _setupAuthStateListener();

      print('FCM Service initialized successfully for Event Reminders');
    } catch (e) {
      print('Error initializing FCM Service: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response);
      },
    );

    await _createNotificationChannels();
  }

  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel eventRemindersChannel =
    AndroidNotificationChannel(
      'event_reminders',
      'Event Reminders',
      description: 'Notifications for upcoming event reminders',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventRemindersChannel);
  }

  /// Handle notification response
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

  /// Parse payload string
  Map<String, dynamic>? _parsePayloadString(String payload) {
    try {
      if (payload.startsWith('{') && payload.endsWith('}')) {
        return json.decode(payload) as Map<String, dynamic>;
      } else {
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

  /// Get and save FCM token
  Future<void> _getAndSaveFCMToken() async {
    try {
      String? token = await _messaging.getToken();

      if (token != null) {
        await _saveTokenToFirestore(token);
        print('FCM Token obtained: $token');
      } else {
        print('Failed to get FCM token');
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToFirestore(newToken);
        print('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Save token to Firestore
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
        await _saveUserId(userId);
      } else {
        print('No user logged in, token not saved to Firestore');
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  /// Get current user ID
  String? _getCurrentUserId() {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state: ${message.notification?.title}');
        _handleNotificationClick(message.data);
      }
    });
  }

  /// Setup auth state listener
  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        print('User logged in, refreshing FCM token for user: ${user.uid}');
        await _saveUserId(user.uid);
        await _getAndSaveFCMToken();
      } else {
        print('User logged out, clearing local user data');
        await _clearTokensOnLogout();
      }
    });
  }

  /// Save user ID to local storage
  Future<void> _saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUserIdKey, userId);
      print('User ID saved to local storage: $userId');
    } catch (e) {
      print('Error saving user ID: $e');
    }
  }

  /// Get last known user ID
  Future<String?> _getLastKnownUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUserIdKey);
    } catch (e) {
      print('Error getting last user ID: $e');
      return null;
    }
  }

  /// Clear saved user ID
  Future<void> _clearSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUserIdKey);
      print('User ID cleared from local storage');
    } catch (e) {
      print('Error clearing user ID: $e');
    }
  }

  /// Clear tokens on logout
  Future<void> _clearTokensOnLogout() async {
    try {
      final lastKnownUserId = await _getLastKnownUserId();

      if (lastKnownUserId != null) {
        await _firestore.collection('users').doc(lastKnownUserId).update({
          'fcmTokens': FieldValue.delete(),
          'lastLogout': FieldValue.serverTimestamp(),
        });
        print('FCM tokens cleared for user $lastKnownUserId on logout');

        await _clearSavedUserId();
      } else {
        print('No known user ID to clear tokens');
      }
    } catch (e) {
      print('Error clearing tokens on logout: $e');
    }
  }

  /// Show local notification
  Future<void> showLocalNotification(RemoteMessage message) async {
    final String? type = message.data['type'];

    String channelId = 'event_reminders';
    String channelName = 'Event Reminders';

    if (type == 'event_reminder') {
      channelId = 'event_reminders';
      channelName = 'Event Reminders';
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications for $channelName',
      importance: Importance.high,
      playSound: true,
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
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
        message.hashCode,
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

  /// Handle notification click
  void _handleNotificationClick(Map<String, dynamic>? data) {
    if (data != null) {
      final type = data['type'];
      final eventId = data['eventId'];
      final userId = data['userId'];

      print('Notification clicked - Type: $type, Event ID: $eventId, User ID: $userId');

      final currentUserId = _getCurrentUserId();
      if (userId != null && currentUserId != null && userId != currentUserId) {
        print(
            'Notification does not belong to current user. Expected: $currentUserId, Got: $userId');
        return;
      }

      if (type == 'event_reminder' && eventId != null) {
        _navigateToEventDetails(eventId);
      } else {
        print('Unknown notification type or missing data: $type');
      }
    } else {
      print('Notification clicked but no data provided');
    }
  }

  /// Navigate to event details
  void _navigateToEventDetails(String eventId) {
    try {
      Get.to(() => _EventDetailScreenWrapper(eventId: eventId));
      print('Navigated to event details for event: $eventId');
    } catch (e) {
      print('Error navigating to event details: $e');
    }
  }

  // ==================== Public Methods ====================

  /// Schedule event reminder (called when user enables reminder)
  Future<void> scheduleEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required String eventLocation,
    required DateTime remindAt,
    required String reminderId,
    required String registrationId,
  }) async {
    try {
      // Save scheduled reminder info to Firestore for Cloud Function to process
      await _firestore.collection('scheduledReminders').doc(reminderId).set({
        'userId': userId,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'eventLocation': eventLocation,
        'remindAt': Timestamp.fromDate(remindAt),
        'reminderId': reminderId,
        'registrationId': registrationId,
        'type': 'event_reminder',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Event reminder scheduled: $reminderId for event: $eventTitle at $remindAt');
    } catch (e) {
      print('Error scheduling event reminder: $e');
      throw 'Failed to schedule event reminder';
    }
  }

  /// Cancel event reminder
  Future<void> cancelEventReminder(String reminderId) async {
    try {
      await _firestore.collection('scheduledReminders').doc(reminderId).delete();
      print('Event reminder cancelled: $reminderId');
    } catch (e) {
      print('Error cancelling event reminder: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting current token: $e');
      return null;
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Clear all tokens
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
}

/// Wrapper widget for event details screen
class _EventDetailScreenWrapper extends StatelessWidget {
  final String eventId;

  const _EventDetailScreenWrapper({required this.eventId});

  @override
  Widget build(BuildContext context) {
    final eventRepository = Get.find<EventRepository>();

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