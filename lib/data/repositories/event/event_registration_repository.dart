import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import 'event_repository.dart';

class EventRegistrationRepository extends GetxController {
  static EventRegistrationRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EventRepository eventRepository = EventRepository.instance;

  /// Collection reference
  CollectionReference get _registrationsCollection => _db.collection('eventRegistrations');

  /// Get user's registered events with real-time updates
  Stream<List<Event>> getUserRegisteredEvents(String userId) {
    try {
      return _registrationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((registrations) async {
        if (registrations.docs.isEmpty) return [];

        // 使用 Map 来确保每个事件只保留最新的注册记录
        final latestRegistrations = <String, QueryDocumentSnapshot>{};

        for (final doc in registrations.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final eventId = data['eventId'] as String?;
          final isCancelled = data['isCancelled'] as bool? ?? false;

          // 只处理未取消的注册，并且只保留每个事件的最新记录
          if (eventId != null && !isCancelled) {
            if (!latestRegistrations.containsKey(eventId)) {
              latestRegistrations[eventId] = doc;
            }
          }
        }

        final eventIds = latestRegistrations.keys.toList();
        if (eventIds.isEmpty) return [];

        // Split into chunks of 10 (Firestore 'in' query limit)
        final chunks = <List<String>>[];
        for (var i = 0; i < eventIds.length; i += 10) {
          chunks.add(
            eventIds.sublist(
              i,
              i + 10 > eventIds.length ? eventIds.length : i + 10,
            ),
          );
        }

        // Fetch events for all chunks
        final allEvents = <Event>[];
        for (final chunk in chunks) {
          final eventsQuery = await _db
              .collection('events')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          allEvents.addAll(
            eventsQuery.docs.map((doc) => Event.fromSnapshot(doc)),
          );
        }

        return allEvents;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Check if user's registration is cancelled
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

          // 只处理每个事件的最新记录
          if (eventId != null && !processedEvents.contains(eventId)) {
            cancelledMap[eventId] = isCancelled;
            processedEvents.add(eventId);
          }
        }
        return cancelledMap;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Register user for event
  Future<void> registerForEvent(String userId, String eventId) async {
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

      // Get event to check capacity
      final event = await eventRepository.getEventByIdFuture(eventId);

      if (event.isFullyBooked) {
        throw 'Event is fully booked';
      }

      if (!event.isRegistrationOpen) {
        throw 'Registration is closed for this event';
      }

      // Create registration
      await _registrationsCollection.add({
        'userId': userId,
        'eventId': eventId,
        'createdAt': Timestamp.now(),
        'isCancelled': false,
      });

      // Update event registered count
      await eventRepository.updateEventRegisteredCount(eventId, 1);
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

      // Update event registered count
      await eventRepository.updateEventRegisteredCount(eventId, -1);
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

  /// Get all registrations for an event
  Stream<List<DocumentSnapshot>> getEventRegistrations(String eventId) {
    try {
      return _registrationsCollection
          .where('eventId', isEqualTo: eventId)
          .where('isCancelled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}