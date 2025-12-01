import 'package:get/get.dart';
import '../../repositories/event/reminder_repository.dart';

class ReminderService {
  static ReminderService get instance => Get.find();

  final ReminderRepository _reminderRepo = Get.find();

  /// Toggle reminders for a registration
  /// Returns true if reminders are now enabled, false if disabled
  Future<bool> toggleReminders({
    required String registrationId,
    required String eventTitle,
    required DateTime eventStartDateTime,
  }) async {
    try {
      // Check if reminders exist
      final hasReminders = await _reminderRepo.hasReminders(registrationId);

      if (hasReminders) {
        // Delete all reminders
        print('🔕 Disabling reminders for registration: $registrationId');
        await _reminderRepo.deleteAllRemindersByRegistration(registrationId);
        print('✅ Reminders disabled');
        return false;
      } else {
        // Create 3 default reminders
        print('🔔 Enabling reminders for registration: $registrationId');
        await _reminderRepo.createDefaultReminders(
          registrationId: registrationId,
          eventTitle: eventTitle,
          eventStartDateTime: eventStartDateTime,
        );
        print('✅ Reminders enabled');
        return true;
      }
    } catch (e) {
      print('❌ Error toggling reminders: $e');
      rethrow;
    }
  }

  /// Enable reminders (create 3 default reminders)
  Future<void> enableReminders({
    required String registrationId,
    required String eventTitle,
    required DateTime eventStartDateTime,
  }) async {
    try {
      print('🔔 Enabling reminders for registration: $registrationId');
      await _reminderRepo.createDefaultReminders(
        registrationId: registrationId,
        eventTitle: eventTitle,
        eventStartDateTime: eventStartDateTime,
      );
      print('✅ Reminders enabled');
    } catch (e) {
      print('❌ Error enabling reminders: $e');
      rethrow;
    }
  }

  /// Disable reminders (delete all reminders)
  Future<void> disableReminders(String registrationId) async {
    try {
      print('🔕 Disabling reminders for registration: $registrationId');
      await _reminderRepo.deleteAllRemindersByRegistration(registrationId);
      print('✅ Reminders disabled');
    } catch (e) {
      print('❌ Error disabling reminders: $e');
      rethrow;
    }
  }

  /// Check if reminders are enabled
  Future<bool> areRemindersEnabled(String registrationId) async {
    return await _reminderRepo.hasReminders(registrationId);
  }

  /// Stream to monitor reminder status
  Stream<bool> reminderStatusStream(String registrationId) {
    return _reminderRepo.areRemindersEnabled(registrationId);
  }
}
