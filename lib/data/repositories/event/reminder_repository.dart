// reminder_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/event/models/reminder_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';

class ReminderRepository extends GetxController {
  static ReminderRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  CollectionReference get _remindersCollection => _db.collection('reminders');

  /// Create a new reminder (使用 Firestore 自动生成 ID)
  Future<String> createReminder(Reminder reminder) async {
    try {
      // 使用 add() 方法让 Firestore 自动生成文档 ID
      final docRef = await _remindersCollection.add(reminder.toFirestore());

      // 返回自动生成的 reminderId
      return docRef.id;
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

  /// Get reminder by registration ID
  Future<Reminder?> getReminderByRegistration(String registrationId) async {
    try {
      final querySnapshot = await _remindersCollection
          .where('registrationId', isEqualTo: registrationId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Reminder.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  /// Get reminders that are due to be sent (使用 UTC 时间比较)
  Stream<List<Reminder>> getDueRemindersStream() {
    try {
      final now = Timestamp.now(); // 使用当前 UTC 时间

      return _remindersCollection
          .where('isSent', isEqualTo: false)
          .where('remindAt', isLessThanOrEqualTo: now)
          .snapshots()
          .map((snapshot) {
        final reminders = <Reminder>[];
        for (final doc in snapshot.docs) {
          try {
            reminders.add(Reminder.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>));
          } catch (e) {
            // Skip invalid documents
            continue;
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
}