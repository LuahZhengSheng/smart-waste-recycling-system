import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all events as stream
  Stream<List<Event>> getAllEvents() {
    try {
      return _db
          .collection('events')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Event.fromSnapshot(doc))
          .toList());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get events by status (Open, Full, Closed)
  Stream<List<Event>> getEventsByStatus(String status) {
    try {
      final now = DateTime.now();

      return _db
          .collection('events')
          .where('status', isEqualTo: 'active')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .map((snapshot) {
        final events = snapshot.docs
            .map((doc) => Event.fromSnapshot(doc))
            .toList();

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
              return event.isRegistrationClosed &&
                  !event.hasEnded;
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
  Stream<List<Event>> getEventsByDateRange(DateTime startDate, DateTime endDate) {
    try {
      return _db
          .collection('events')
          .where('startDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
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
}