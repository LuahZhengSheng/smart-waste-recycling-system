import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

import '../../../features/event/models/reminder_model.dart';

class ReminderRepository extends GetxController {
  static ReminderRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference get _remindersCollection => _db.collection('reminders');

  /// Create a new reminder
  Future<void> createReminder(Reminder reminder) async {
    try {
      await _remindersCollection.doc(reminder.reminderId).set(reminder.toJson());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Delete reminder by ID
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _remindersCollection.doc(reminderId).delete();
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get reminder by ID
  Future<Reminder?> getReminderById(String reminderId) async {
    try {
      final doc = await _remindersCollection.doc(reminderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Reminder.fromJson(data);
        }
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get reminder by registration ID
  Future<Reminder?> getReminderByRegistration(String registrationId) async {
    try {
      final querySnapshot = await _remindersCollection
          .where('registrationId', isEqualTo: registrationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Reminder.fromJson(data);
        }
      }
      return null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Stream to get all reminders for a user by registration IDs
  Stream<List<Reminder>> getUserRemindersStream(List<String> registrationIds) {
    try {
      if (registrationIds.isEmpty) {
        return Stream.value([]);
      }

      return _remindersCollection
          .where('registrationId', whereIn: registrationIds)
          .snapshots()
          .map((snapshot) {
        final reminders = <Reminder>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            try {
              reminders.add(Reminder.fromJson(data));
            } catch (e) {
              // Skip invalid documents
              continue;
            }
          }
        }
        return reminders;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Stream to get single reminder by registration ID
  Stream<Reminder?> getReminderByRegistrationStream(String registrationId) {
    try {
      return _remindersCollection
          .where('registrationId', isEqualTo: registrationId)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            return Reminder.fromJson(data);
          }
        }
        return null;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update reminder sent status
  Future<void> updateReminderSentStatus(String reminderId, bool isSent) async {
    try {
      await _remindersCollection.doc(reminderId).update({
        'isSent': isSent,
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get reminders that are due to be sent
  Stream<List<Reminder>> getDueRemindersStream() {
    try {
      return _remindersCollection
          .where('isSent', isEqualTo: false)
          .where('remindAt', isLessThanOrEqualTo: DateTime.now())
          .snapshots()
          .map((snapshot) {
        final reminders = <Reminder>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            try {
              reminders.add(Reminder.fromJson(data));
            } catch (e) {
              // Skip invalid documents
              continue;
            }
          }
        }
        return reminders;
      });
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Check if reminder exists for registration
  Future<bool> checkReminderExists(String registrationId) async {
    try {
      final reminder = await getReminderByRegistration(registrationId);
      return reminder != null;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get all reminders with pagination
  Future<List<Reminder>> getRemindersPaginated({
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _remindersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      final reminders = <Reminder>[];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          try {
            reminders.add(Reminder.fromJson(data));
          } catch (e) {
            // Skip invalid documents
            continue;
          }
        }
      }
      return reminders;
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}