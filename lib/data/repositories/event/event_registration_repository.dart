import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import 'event_repository.dart';
import 'reminder_repository.dart';

class EventRegistrationRepository extends GetxController {
  static EventRegistrationRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EventRepository _eventRepository = Get.put(EventRepository());
  final ReminderRepository _reminderRepository = Get.put(ReminderRepository());

  /// Collection reference
  CollectionReference get _registrationsCollection =>
      _db.collection('eventRegistrations');

  /// Get registration by registration ID
  Future<Map<String, dynamic>?> getRegistrationById(
      String registrationId) async {
    try {
      final doc = await _registrationsCollection.doc(registrationId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return {
            'registrationId': doc.id,
            'userId': data['userId'] ?? '',
            'eventId': data['eventId'] ?? '',
            'createdAt':
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            'isCancelled': data['isCancelled'] ?? false,
          };
        }
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get registration by registration ID with DocumentSnapshot
  Future<DocumentSnapshot<Map<String, dynamic>>?> getRegistrationSnapshotById(
      String registrationId) async {
    try {
      final doc = await _registrationsCollection.doc(registrationId).get();
      return doc.exists ? doc as DocumentSnapshot<Map<String, dynamic>> : null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get user's registered events with real-time updates
  Stream<List<Event>> getUserRegisteredEvents(String userId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((registrations) async {

        if (registrations.docs.isEmpty) {
          print('❌ 用户没有任何注册记录');
          return [];
        }

        // 使用 Map 来确保每个事件只保留最新的注册记录
        final latestRegistrations = <String, QueryDocumentSnapshot>{};

        for (final doc in registrations.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
            print('⚠️ 跳过空数据的注册文档: ${doc.id}');
            continue;
          }

          final eventId = data['eventId'] as String?;
          final isCancelled = data['isCancelled'] as bool? ?? false;

          // 只处理未取消的注册，并且只保留每个事件的最新记录
          if (eventId != null) {
            if (!latestRegistrations.containsKey(eventId)) {
              latestRegistrations[eventId] = doc;
              print('✅ 添加活动 $eventId 的最新注册记录');
            } else {
              print('⏩ 跳过活动 $eventId 的旧注册记录');
            }
          }
        }

        final eventIds = latestRegistrations.keys.toList();
        print('🎯 最终有效的活动ID列表: $eventIds (${eventIds.length} 个)');

        if (eventIds.isEmpty) {
          print('❌ 没有找到有效的活动ID');
          return [];
        }

        // 【调用 EventRepository.getEventsByIds()】
        final allEvents = await _eventRepository.getEventsByIds(eventIds);

        print('📦 成功获取 ${allEvents.length} 个活动');
        for (final event in allEvents) {
          print('   - ${event.eventId}: ${event.title}');
        }

        return allEvents;
      });
    } on FirebaseException catch (e) {
      print('🔥 Firebase错误: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('💥 未知错误: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get user's active (not cancelled) eventIds with real-time updates
  Stream<List<String>> getUserActiveEventIds(String userId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((registrations) {
        if (registrations.docs.isEmpty) return <String>[];

        final latestRegistrations = <String, QueryDocumentSnapshot>{};

        for (final doc in registrations.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final eventId = data['eventId'] as String?;
          final isCancelled = data['isCancelled'] as bool? ?? false;

          // 只考虑未取消的最新一条
          if (eventId != null) {
            if (!latestRegistrations.containsKey(eventId)) {
              latestRegistrations[eventId] = doc;
            }
          }
        }

        return latestRegistrations.keys.toList();
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if user's registration is cancelled
  /// 🆕 返回所有被取消的注册（包括同一个事件的多次取消）
  Stream<Map<String, bool>> getUserCancelledRegistrations(String userId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final cancelledMap = <String, bool>{};
        final processedEvents = <String>{};

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final eventId = data['eventId'] as String?;
          final isCancelled = data['isCancelled'] as bool? ?? false;

          // 🆕 只保留每个事件的最新记录，记录其取消状态
          if (eventId != null && !processedEvents.contains(eventId)) {
            cancelledMap[eventId] = isCancelled;
            processedEvents.add(eventId);

            if (isCancelled) {
              print('✅ 活动 $eventId 的最新状态：已取消');
            }
          }
        }

        print('📋 用户已取消的活动 (${cancelledMap.entries.where((e) => e.value).length} 个): ${cancelledMap.entries.where((e) => e.value).map((e) => e.key).toList()}');
        return cancelledMap;
      });
    } on FirebaseException catch (e) {
      print('🔥 Firebase错误: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('💥 错误: $e');
      throw 'Something went wrong. Please try again';
    }
  }

  /// Register user for event
  Future<String> registerForEvent(String userId, String eventId) async {
    try {
      // Check if already registered
      final existingRegistration = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw 'You are already registered for this event';
      }

      // Validate event
      await _eventRepository.validateEventForRegistration(eventId);

      // Get event details for reminder creation
      final event = await _eventRepository.getEventByIdFuture(eventId);

      // Create registration
      final docRef = await _registrationsCollection.add({
        'userId': userId,
        'eventId': eventId,
        'createdAt': Timestamp.now(),
        'isCancelled': false,
      });

      final registrationId = docRef.id;
      print('✅ Created registration: $registrationId');

      // 🆕 Create 3 default reminders automatically
      try {
        
        await _reminderRepository.createDefaultReminders(
          registrationId: registrationId,
          eventTitle: event.title,
          eventStartDateTime: event.startDateTime,
        );
        print('✅ Created default reminders for registration $registrationId');
      } catch (e) {
        print('⚠️ Failed to create reminders (non-critical): $e');
        // Don't throw - reminders are optional
      }

      // Update registered count
      await _eventRepository.updateEventRegisteredCount(eventId, 1);

      return registrationId;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (e is String) rethrow;
      throw 'Something went wrong. Please try again';
    }
  }

  /// Cancel event registration
  Future<void> cancelRegistration(String userId, String eventId) async {
    try {
      // Find registration - 只查找最新的未取消注册
      final registrations = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (registrations.docs.isEmpty) {
        throw 'Registration not found';
      }

      // Cancel registration
      final registrationId = registrations.docs.first.id;
      await _registrationsCollection.doc(registrationId).update({
        'isCancelled': true,
      });

      // 【调用 EventRepository.updateEventRegisteredCount()】
      await _eventRepository.updateEventRegisteredCount(eventId, -1);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      if (e is String) rethrow;
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if user is registered for event
  Stream<bool> isUserRegistered(String userId, String eventId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get registration ID for a user and event
  Future<String?> getRegistrationId(String userId, String eventId) async {
    try {
      final registrations = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (registrations.docs.isNotEmpty) {
        return registrations.docs.first.id;
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get user registration ID (alias for getRegistrationId for compatibility)
  Future<String> getUserRegistrationId(String userId, String eventId) async {
    try {
      final registrationId = await getRegistrationId(userId, eventId);
      return registrationId ?? '';
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get all registrations for an event (including cancelled)
  Stream<List<DocumentSnapshot>> getEventRegistrations(String eventId) {
    try {
      return _registrationsCollection
          .where('eventId', isEqualTo: eventId)
      // 🆕 移除 isCancelled 过滤，获取所有记录
      // .where('isCancelled', isEqualTo: false) // ❌ 删除这行
          .orderBy('createdAt', descending: true) // ✅ 按时间降序
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get all active (not cancelled) registrations for an event (one-shot)
  Future<List<DocumentSnapshot>> getActiveEventRegistrationsOnce(
      String eventId) async {
    try {
      final snapshot = await _registrationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)   // 只要未取消的
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }


  /// Cancel all registrations for an event (admin use)
  Future<void> cancelAllEventRegistrations(String eventId) async {
    try {
      print('🚫 Cancelling all registrations for event: $eventId');

      final registrations = await _registrationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .get();

      if (registrations.docs.isEmpty) {
        print('   ℹ️ No active registrations to cancel');
        return;
      }

      final batch = _db.batch();
      for (final doc in registrations.docs) {
        batch.update(doc.reference, {'isCancelled': true});
      }
      await batch.commit();

      print('   ✅ Cancelled ${registrations.docs.length} registrations for event $eventId');
    } on FirebaseException catch (e) {
      print('   ❌ Firebase error: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } catch (e) {
      print('   ❌ Error: $e');
      throw 'Failed to cancel registrations: $e';
    }
  }
}
