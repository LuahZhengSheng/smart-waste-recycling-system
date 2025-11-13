import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../../features/event/models/event_model.dart';
import '../../../features/event/models/location_model.dart';
import '../../../features/event/models/address_model.dart';
import '../../../features/event/models/geopoint_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String _eventPosterPath = 'event/event_poster';

  /// Get all events as stream with contained location objects
  Stream<List<Event>> getAllEvents() {
    try {
      return _db
          .collection('events')
          .orderBy('startDateTime', descending: false)
          .snapshots()
          .asyncMap((snapshot) async {
        // Process each event document
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        return events;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Build Event object with contained Location objects
  Future<Event> _buildEventWithLocation(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    print('data: ${data}');
    if (data == null) return Event.empty();

    try {
      Location location = Location.empty();

      // Check if location data exists as contained object
      if (data.containsKey('location') && data['location'] != null) {
        final locationData = data['location'] as Map<String, dynamic>;

        Address address = Address.empty();
        GeoPointModel geoPoint = GeoPointModel.empty();

        // Build Address from contained object
        if (locationData.containsKey('address') && locationData['address'] != null) {
          final addressData = locationData['address'] as Map<String, dynamic>;
          address = Address.fromJson(addressData);
          print('test address: ${address.fullAddress}');
        }

        // Build GeoPoint from contained object
        if (locationData.containsKey('geoPoint') && locationData['geoPoint'] != null) {
          final geoPointData = locationData['geoPoint'] as Map<String, dynamic>;
          geoPoint = GeoPointModel.fromJson(geoPointData);
        }

        location = Location(address: address, geoPoint: geoPoint);
        print('location address: ${location.fullAddress}');
      }

      // Build Event with location data
      return Event(
        eventId: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhoneNo: data['contactPhoneNo'] ?? '',
        location: location,
        poster: data['poster'] ?? '',
        startDateTime:
        (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDateTime:
        (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        registrationDeadline:
        (data['registrationDeadline'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 0,
        registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
        createdAt:
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: data['status'] ?? 'active',
        eventRegistrations: [],
      );
    } catch (e) {
      print('Error building event ${doc.id} with location: $e');
      // Return event with empty location if loading fails
      return Event(
        eventId: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        contactPhoneNo: data['contactPhoneNo'] ?? '',
        location: Location.empty(),
        poster: data['poster'] ?? '',
        startDateTime:
        (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDateTime:
        (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        registrationDeadline:
        (data['registrationDeadline'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 0,
        registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
        createdAt:
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: data['status'] ?? 'active',
        eventRegistrations: [],
      );
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
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );

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
          .asyncMap((snapshot) async {
        return await _buildEventWithLocation(snapshot);
      });
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
          .asyncMap((snapshot) async {
        final events = await Future.wait(
          snapshot.docs.map((doc) async {
            return await _buildEventWithLocation(doc);
          }),
        );
        return events.where((event) => !event.hasEnded).toList();
      });
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
      return await _buildEventWithLocation(doc);
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

  /// Helper method to get location for a specific event (if needed separately)
  Future<Location> getEventLocation(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      final data = doc.data();

      if (data == null || !data.containsKey('location')) {
        return Location.empty();
      }

      final locationData = data['location'] as Map<String, dynamic>;

      Address address = Address.empty();
      GeoPointModel geoPoint = GeoPointModel.empty();

      // Build Address from contained object
      if (locationData.containsKey('address') && locationData['address'] != null) {
        final addressData = locationData['address'] as Map<String, dynamic>;
        address = Address.fromJson(addressData);
      }

      // Build GeoPoint from contained object
      if (locationData.containsKey('geoPoint') && locationData['geoPoint'] != null) {
        final geoPointData = locationData['geoPoint'] as Map<String, dynamic>;
        geoPoint = GeoPointModel.fromJson(geoPointData);
      }

      return Location(address: address, geoPoint: geoPoint);
    } catch (e) {
      print('Error getting event location: $e');
      return Location.empty();
    }
  }
}