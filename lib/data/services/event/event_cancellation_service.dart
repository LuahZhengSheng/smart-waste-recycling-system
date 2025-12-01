import 'package:get/get.dart';
import '../../../utils/popups/admin_loaders.dart';
import '../../repositories/event/event_repository.dart';
import '../../repositories/event/event_registration_repository.dart';
import '../../repositories/event/reminder_repository.dart';
import '../../repositories/personalization/notification_repository.dart';
import '../notification/fcm_service.dart';
import '../../../features/event/models/event_model.dart';

class EventCancellationService {
  static EventCancellationService get instance => Get.find();

  // Dependencies
  final EventRepository _eventRepository = Get.find();
  final EventRegistrationRepository _registrationRepository = Get.find();
  final ReminderRepository _reminderRepository = Get.find();
  final NotificationRepository _notificationRepository = Get.find();
  final FCMService _fcmService = FCMService();

  /// Cancel event with proper sequence
  ///
  /// Returns true if cancellation was successful, false otherwise
  Future<bool> cancelEvent(Event event) async {
    try {
      print('🚫 Starting event cancellation process...');
      print('   Event ID: ${event.eventId}');
      print('   Event Title: ${event.title}');

      // 1. Update event status
      final updatedEvent = event.copyWith(
        status: 'cancelled',
        isPublish: false,
      );
      await _eventRepository.updateEvent(updatedEvent);

      // 2. Send cancellation notifications to all registered users
      await _sendEventCancellationNotifications(event);

      // 3. Delete all reminders for this event
      await _deleteEventReminders(event.eventId);

      // 4. Cancel all registrations for this event
      // await _registrationRepository.cancelAllEventRegistrations(event.eventId);

      print('✅ Event cancellation completed successfully');
      return true;
    } catch (e) {
      print('❌ Event cancellation failed: $e');
      rethrow;
    }
  }

  /// Delete all reminders for an event (only active registrations)
  Future<void> _deleteEventReminders(String eventId) async {
    try {
      int deletedCount = 0;

      // 1️⃣ 获取所有 isCancelled == false 的 registrations
      final registrationsSnapshot = await _registrationRepository
          .getActiveEventRegistrationsOnce(eventId);

      // 2️⃣ 对每个 registration，删除所有它的 reminders
      for (final regDoc in registrationsSnapshot) {
        try {
          await _reminderRepository.deleteAllRemindersByRegistration(regDoc.id);
          deletedCount++; // 每个 registration 算一次（你也可以统计总 reminder 数量）
          print('   ✅ Deleted all reminders for registration: ${regDoc.id}');
        } catch (e) {
          print('   ⚠️ Failed to delete reminders for registration ${regDoc.id}: $e');
        }
      }

      print('   📊 Total registrations with reminders deleted: $deletedCount');
    } catch (e) {
      print('   ❌ Error deleting event reminders: $e');
      throw 'Failed to delete event reminders: $e';
    }
  }

  /// Send cancellation notifications to all registered users (only active, one per user)
  Future<void> _sendEventCancellationNotifications(Event event) async {
    try {
      // 1️⃣ 获取所有“未取消”的 registrations（一次性）
      final registrations = await _registrationRepository
          .getActiveEventRegistrationsOnce(event.eventId);

      if (registrations.isEmpty) {
        print('   ℹ️ No active registrations to notify');
        return;
      }

      // 2️⃣ 收集 userId（用 Set 去重：同一个用户只会出现一次）
      final userIdSet = <String>{};

      for (final regDoc in registrations) {
        final data = regDoc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        if (userId != null && userId.isNotEmpty) {
          userIdSet.add(userId);
        }
      }

      final userIds = userIdSet.toList();

      if (userIds.isEmpty) {
        print('   ℹ️ No users to notify after filtering');
        return;
      }

      print('   📢 Sending notifications to ${userIds.length} unique active users');

      final notificationTitle = '🚫 Event Cancelled: ${event.title}';
      final notificationBody =
          'The event "${event.title}" scheduled for ${_formatEventDate(event.startDateTime)} '
          'has been cancelled. We apologize for any inconvenience.';

      // 3️⃣ 创建 in-app notification 记录（每个用户 1 条）
      await _createNotificationRecordsForUsers(
        userIds: userIds,
        title: notificationTitle,
        body: notificationBody,
        eventId: event.eventId,
        type: 'event_cancelled',
      );

      // 4️⃣ 发送 FCM 推送（每个用户 1 条）
      await _sendBulkFCMNotification(
        userIds: userIds,
        title: notificationTitle,
        body: notificationBody,
        eventId: event.eventId,
        type: 'event_cancelled',
      );

      print('   ✅ Cancellation notifications sent to ${userIds.length} users');
    } catch (e) {
      print('   ⚠️ Error sending cancellation notifications: $e');
      // 不抛异常：通知失败不影响主业务
    }
  }

  /// Create notification records for multiple users
  Future<void> _createNotificationRecordsForUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String eventId,
    required String type,
  }) async {
    try {
      await _notificationRepository.createBulkNotificationsForUsers(
        userIds: userIds,
        title: title,
        message: body,
        type: type,
        eventId: eventId,
      );
      print('   ✅ Created in-app notification records for ${userIds.length} users');
    } catch (e) {
      print('   ⚠️ Error creating notification records: $e');
      // Don't throw - continue with FCM notifications
    }
  }

  /// Send bulk FCM push notifications
  Future<void> _sendBulkFCMNotification({
    required List<String> userIds,
    required String title,
    required String body,
    required String eventId,
    required String type,
  }) async {
    try {
      if (userIds.isEmpty) {
        print('   ℹ️ No users to send FCM notifications to');
        return;
      }

      print('   📤 Sending FCM notifications to ${userIds.length} users');

      await _fcmService.sendBulkNotificationToUsers(
        userIds: userIds,
        title: title,
        body: body,
        eventId: eventId,
        type: type,
      );

      print('   ✅ FCM push notifications sent successfully');
    } catch (e) {
      print('   ⚠️ Error sending FCM notifications: $e');
      // Don't throw - notifications are not critical
    }
  }

  /// Format event date for display
  String _formatEventDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Show cancel event confirmation dialog and execute cancellation if confirmed
  ///
  /// Returns true if event was cancelled, false if user cancelled the dialog
  Future<bool> showCancelEventDialogAndExecute(Event event) async {
    try {
      // Show confirmation dialog
      final confirmed = await FAdminLoaders.cancelEventDialog(
        eventTitle: event.title,
      );

      if (!confirmed) {
        print('ℹ️ Event cancellation cancelled by user');
        return false;
      }

      // Show loading
      FAdminLoaders.loadingDialogWithMessage('Cancelling event');

      // Execute cancellation
      final success = await cancelEvent(event);

      // Close loading dialog
      FAdminLoaders.closeLoadingDialog();

      if (success) {
        // Show success message
        FAdminLoaders.successSnackBar(
          title: 'Event Cancelled',
          message: 'Event has been cancelled successfully. All users have been notified.',
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Close loading dialog if open
      FAdminLoaders.closeLoadingDialog();

      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to cancel event: $e',
      );
      print('❌ Event cancellation error: $e');
      return false;
    }
  }
}
