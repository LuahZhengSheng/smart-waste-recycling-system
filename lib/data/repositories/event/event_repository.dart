import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String _eventPosterPath = 'event/event_poster';

  /// Get all events as stream
  Stream<List<Event>> getAllEvents() {
    try {
      return _db
          .collection('events')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get events by status (Open, Full, Closed)
  Stream<List<Event>> getEventsByStatus(String status) {
    try {
      return _db
          .collection('events')
          .where('status', isEqualTo: 'active')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snapshot) {
        final events =
        snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();

        // Filter based on status
        switch (status) {
          case 'Open':
            return events.where((event) {
              return event.isRegistrationOpen &&
                  !event.isFullyBooked &&
                  !event.hasEnded;
            }).toList();

          case 'Full':
            return events.where((event) {
              return event.isFullyBooked &&
                  !event.isRegistrationClosed &&
                  !event.hasEnded;
            }).toList();

          case 'Closed':
            return events.where((event) {
              return event.isRegistrationClosed && !event.hasEnded;
            }).toList();

          default:
            return events.where((event) => !event.hasEnded).toList();
        }
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get event by ID as stream
  Stream<Event> getEventById(String eventId) {
    try {
      return _db
          .collection('events')
          .doc(eventId)
          .snapshots()
          .map((snapshot) => Event.fromSnapshot(snapshot));
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Filter events by date range
  Stream<List<Event>> getEventsByDateRange(
      DateTime startDate, DateTime endDate) {
    try {
      return _db
          .collection('events')
          .where('startDateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDateTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Event.fromSnapshot(doc))
          .where((event) => !event.hasEnded)
          .toList());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update event registered count
  Future<void> updateEventRegisteredCount(String eventId, int increment) async {
    try {
      await _db.collection('events').doc(eventId).update({
        'registeredCount': FieldValue.increment(increment),
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get event by ID (future)
  Future<Event> getEventByIdFuture(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      return Event.fromSnapshot(doc);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get event poster URL from Firebase Storage
  Future<String?> getEventPosterUrl(String posterFileName) async {
    try {
      if (posterFileName.isEmpty) {
        return null;
      }

      // Construct the full path
      final path = '$_eventPosterPath/$posterFileName';
      final ref = _storage.ref().child(path);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('Event poster not found: $posterFileName');
        return null;
      }
      throw 'Failed to get event poster URL: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Failed to get event poster URL: $e';
    }
  }

  /// Check if event poster exists
  Future<bool> eventPosterExists(String posterFileName) async {
    try {
      if (posterFileName.isEmpty) return false;

      final path = '$_eventPosterPath/$posterFileName';
      final ref = _storage.ref().child(path);

      // Try to get metadata to check if file exists
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}