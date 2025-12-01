import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/event/event_repository.dart';
import '../../../../data/repositories/event/event_registration_repository.dart';
import '../../../../data/repositories/event/reminder_repository.dart';
import '../../../../data/repositories/personalization/notification_repository.dart';
import '../../../../data/services/event/event_cancellation_service.dart';
import '../../../../data/services/notification/fcm_service.dart';
import '../../../../features/event/models/event_model.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/popups/admin_loaders.dart';
import '../../../event/models/event_enums.dart';
import '../../screens/event_management/event_detail/event_detail.dart';
import '../../screens/event_management/edit_event/edit_event.dart';
import '../../screens/event_management/event_management/event_management.dart';

class EventManagementController extends GetxController {
  static EventManagementController get instance => Get.find();

  // Dependencies
  final EventRepository _eventRepository = Get.put(EventRepository());
  final EventRegistrationRepository _registrationRepository = Get.put(EventRegistrationRepository());
  final ReminderRepository _reminderRepository = Get.put(ReminderRepository());
  final NotificationRepository _notificationRepository = Get.put(NotificationRepository());
  final FCMService _fcmService = FCMService();
  final EventCancellationService _cancellationService = Get.put(EventCancellationService());

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Stream subscription
  StreamSubscription<List<Event>>? _eventsSubscription;

  // Observables
  final RxList<Event> allEvents = <Event>[].obs;
  final RxList<Event> filteredEvents = <Event>[].obs;
  final RxList<Event> paginatedEvents = <Event>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{}.obs;
  final RxBool isLoading = true.obs;

  final Rx<EventPublishFilter> publishFilter = EventPublishFilter.published.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEvents();

    // Listen to search changes
    searchController.addListener(() {
      _applyFiltersAndSearch();
    });
  }

  void _loadEvents() {
    isLoading.value = true;

    _eventsSubscription = _eventRepository.getAllEvents().listen(
          (events) {
        allEvents.value = events.where((e) => e.status != 'deleted').toList();
        isLoading.value = false;
        _applyFiltersAndSearch();
      },
      onError: (error) {
        isLoading.value = false;
        FAdminLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load events: $error',
        );
        print('Error loading events: $error');
      },
    );

    // Listen to filter changes
    ever(publishFilter, (_) => _applyFiltersAndSearch());
  }

  // Search functionality
  void onSearchChanged(String query) {
    _applyFiltersAndSearch();
  }

  // Publish filter
  void changeFilter(EventPublishFilter filter) {
    publishFilter.value = filter;
  }

  void _applyFiltersAndSearch() {
    List<Event> result = List.from(allEvents);

    // Apply publish filter
    if (publishFilter.value == EventPublishFilter.published) {
      result = result.where((event) => event.isPublish).toList();
    } else if (publishFilter.value == EventPublishFilter.unpublished) {
      result = result.where((event) => !event.isPublish).toList();
    }
    // If filter is 'all', don't filter by publish status

    // Apply search
    final searchQuery = searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      result = result.where((event) {
        return event.title.toLowerCase().contains(searchQuery) ||
            event.description.toLowerCase().contains(searchQuery) ||
            event.contactEmail.toLowerCase().contains(searchQuery) ||
            event.eventId.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply filters
    if (activeFilters['status'] != null) {
      result = result.where((event) {
        final computedStatus = event.computedStatus;
        return computedStatus == activeFilters['status'];
      }).toList();
    }

    if (activeFilters['registrationStatus'] != null) {
      result = result.where((event) {
        switch (activeFilters['registrationStatus']) {
          case 'open':
            return event.isRegistrationOpen;
          case 'closed':
            return event.isRegistrationClosed;
          case 'full':
            return event.isFullyBooked;
          default:
            return true;
        }
      }).toList();
    }

    if (activeFilters['dateRange'] != null) {
      final now = DateTime.now();
      result = result.where((event) {
        switch (activeFilters['dateRange']) {
          case 'next7days':
            return event.startDateTime.isBefore(now.add(const Duration(days: 7)));
          case 'next30days':
            return event.startDateTime.isBefore(now.add(const Duration(days: 30)));
          case 'thisMonth':
            return event.startDateTime.month == now.month &&
                event.startDateTime.year == now.year;
          default:
            return true;
        }
      }).toList();
    }

    filteredEvents.value = result;
    currentPage.value = 1;
    _updatePagination();
  }

  // Sorting
  void sortEvents(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredEvents.sort((a, b) {
      int compare = 0;
      switch (columnIndex) {
        case 0: // Event ID
          compare = a.eventId.compareTo(b.eventId);
          break;
        case 1: // Title
          compare = a.title.compareTo(b.title);
          break;
        case 2: // Contact Email
          compare = a.contactEmail.compareTo(b.contactEmail);
          break;
        case 3: // Contact Phone
          compare = a.contactPhoneNo.compareTo(b.contactPhoneNo);
          break;
        case 4: // Address
          compare = a.location.fullAddress.compareTo(b.location.fullAddress);
          break;
        case 5: // Start Date
          compare = a.startDateTime.compareTo(b.startDateTime);
          break;
        case 6: // End Date
          compare = a.endDateTime.compareTo(b.endDateTime);
          break;
        case 7: // Registration Deadline
          compare = a.registrationDeadline.compareTo(b.registrationDeadline);
          break;
        case 8: // Max Participants
          compare = a.maxParticipants.compareTo(b.maxParticipants);
          break;
        case 9: // Registered Count
          compare = a.registeredCount.compareTo(b.registeredCount);
          break;
        case 10: // Created At
          compare = a.createdAt.compareTo(b.createdAt);
          break;
        case 11: // Status
          compare = a.computedStatus.compareTo(b.computedStatus);
          break;
      }
      return ascending ? compare : -compare;
    });

    _updatePagination();
  }

  // Pagination
  void _updatePagination() {
    final start = (currentPage.value - 1) * itemsPerPage.value;
    final end = (start + itemsPerPage.value).clamp(0, filteredEvents.length);
    paginatedEvents.value = filteredEvents.sublist(start, end);
  }

  void changeItemsPerPage(int? value) {
    if (value != null) {
      itemsPerPage.value = value;
      currentPage.value = 1;
      _updatePagination();
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
      _updatePagination();
    }
  }

  void previousPage() {
    if (canGoPreviousPage) {
      currentPage.value--;
      _updatePagination();
    }
  }

  void goToPage(int page) {
    currentPage.value = page;
    _updatePagination();
  }

  bool get canGoNextPage => endIndex < totalEvents;
  bool get canGoPreviousPage => currentPage.value > 1;
  int get totalEvents => filteredEvents.length;
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalEvents);

  // Filters
  void showFilters() {
    Get.dialog(
      EventFilterDialog(
        dark: Get.isDarkMode,
        currentFilters: activeFilters,
        onApplyFilters: (filters) {
          activeFilters.value = filters;
          _applyFiltersAndSearch();
        },
      ),
    );
  }

  bool get hasActiveFilters {
    return activeFilters.values.any((value) => value != null);
  }

  // Event Actions
  void viewEvent(String eventId) {
    Get.to(() => AdminEventDetailScreen(eventId: eventId));
  }

  void editEvent(Event event) {
    Get.to(() => EditEventScreen(event: event));
  }

  Future<void> togglePublishStatus(Event event) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        _ConfirmPublishDialog(
          event: event,
          isPublishing: !event.isPublish,
        ),
      );

      if (confirmed != true) return;

      final updatedEvent = event.copyWith(isPublish: !event.isPublish);
      await _eventRepository.updateEvent(updatedEvent);

      FAdminLoaders.successSnackBar(
        title: 'Success',
        message: event.isPublish ? 'Event unpublished' : 'Event published',
      );
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update event: $e',
      );
      print('Error toggling publish status: $e');
    }
  }

  /// Cancel event using shared service
  Future<void> cancelEvent(Event event) async {
    final success = await _cancellationService.showCancelEventDialogAndExecute(event);

    if (success) {
      // Event was cancelled successfully
      // The list will auto-update due to stream subscription
      print('✅ Event cancelled from EventManagementController');
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        _ConfirmDeleteDialog(event: event),
      );

      if (confirmed != true) return;

      final updatedEvent = event.copyWith(
        status: 'deleted',
        isPublish: false,
      );
      await _eventRepository.updateEvent(updatedEvent);

      FAdminLoaders.successSnackBar(
        title: 'Event Deleted',
        message: 'Event has been deleted successfully',
      );
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete event: $e',
      );
      print('Error deleting event: $e');
    }
  }

  // 事件更新后发送通知
  Future<void> sendEventUpdateNotifications(Event oldEvent, Event updatedEvent) async {
    try {
      // Get all registrations for this event
      final registrations = await _registrationRepository
          .getActiveEventRegistrationsOnce(updatedEvent.eventId);

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

      // Determine what changed
      final changes = _getEventChanges(oldEvent, updatedEvent);

      if (userIds.isNotEmpty && changes.isNotEmpty) {
        final changeDescription = _formatChangeDescription(changes);
        final notificationTitle = '📝 Event Updated: ${updatedEvent.title}';
        final notificationBody = 'The event "${updatedEvent.title}" has been updated. $changeDescription';

        // 为每个用户创建通知记录
        await _createNotificationRecordsForUsers(
          userIds: userIds,
          title: notificationTitle,
          body: notificationBody,
          eventId: updatedEvent.eventId,
          type: 'event_updated',
        );

        // 发送 FCM 推送通知
        await _sendBulkFCMNotification(
          userIds: userIds,
          title: notificationTitle,
          body: notificationBody,
          eventId: updatedEvent.eventId,
          type: 'event_updated',
        );
      }

      print('📢 Sent update notifications to ${userIds.length} users for event ${updatedEvent.eventId}');
    } catch (e) {
      print('❌ Error sending update notifications: $e');
    }
  }

  // 为多个用户创建通知记录
  Future<void> _createNotificationRecordsForUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String eventId,
    required String type,
  }) async {
    try {
      // 使用 NotificationRepository 来创建通知记录
      await _notificationRepository.createBulkNotificationsForUsers(
        userIds: userIds,
        title: title,
        message: body,
        type: type,
        eventId: eventId,
      );
    } catch (e) {
      print('❌ Error creating notification records: $e');
      // 不重新抛出异常，避免影响主要业务逻辑
    }
  }

  // 批量发送 FCM 通知
  Future<void> _sendBulkFCMNotification({
    required List<String> userIds,
    required String title,
    required String body,
    required String eventId,
    required String type,
  }) async {
    try {
      if (userIds.isEmpty) {
        print('No users to notify');
        return;
      }

      print('📤 Preparing to send FCM notification to ${userIds.length} users');
      print('🔔 Type: $type, Event: $eventId');

      // 使用 FCMService 发送批量通知
      await _fcmService.sendBulkNotificationToUsers(
        userIds: userIds,
        title: title,
        body: body,
        eventId: eventId,
        type: type,
      );

      print('✅ FCM notifications sent successfully to ${userIds.length} users');
    } catch (e) {
      print('❌ Error sending bulk FCM notification: $e');
      // 不重新抛出异常，避免影响主要业务逻辑
    }
  }

  // 检测事件变化
  List<String> _getEventChanges(Event oldEvent, Event newEvent) {
    final changes = <String>[];

    if (oldEvent.title != newEvent.title) {
      changes.add('title');
    }
    if (oldEvent.description != newEvent.description) {
      changes.add('description');
    }
    if (oldEvent.startDateTime != newEvent.startDateTime) {
      changes.add('start time');
    }
    if (oldEvent.endDateTime != newEvent.endDateTime) {
      changes.add('end time');
    }
    if (oldEvent.registrationDeadline != newEvent.registrationDeadline) {
      changes.add('registration deadline');
    }
    if (oldEvent.location.fullAddress != newEvent.location.fullAddress) {
      changes.add('location');
    }
    if (oldEvent.maxParticipants != newEvent.maxParticipants) {
      changes.add('capacity');
    }
    if (oldEvent.contactEmail != newEvent.contactEmail) {
      changes.add('contact email');
    }
    if (oldEvent.contactPhoneNo != newEvent.contactPhoneNo) {
      changes.add('contact phone');
    }

    return changes;
  }

  // 格式化变化描述
  String _formatChangeDescription(List<String> changes) {
    if (changes.isEmpty) return '';

    if (changes.length == 1) {
      return 'Change: ${changes.first}.';
    }

    if (changes.length == 2) {
      return 'Changes: ${changes.first} and ${changes.last}.';
    }

    final lastChange = changes.removeLast();
    return 'Changes: ${changes.join(', ')}, and $lastChange.';
  }

  String _formatEventDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _eventsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

// Confirmation Dialogs (保持不变)
class _ConfirmPublishDialog extends StatelessWidget {
  final Event event;
  final bool isPublishing;

  const _ConfirmPublishDialog({
    required this.event,
    required this.isPublishing,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Get.isDarkMode;

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        isPublishing ? 'Publish Event' : 'Unpublish Event',
        style: TextStyle(
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
        ),
      ),
      content: Text(
        isPublishing
            ? 'Are you sure you want to publish "${event.title}"? This will make it visible to users.'
            : 'Are you sure you want to unpublish "${event.title}"? This will hide it from users.',
        style: TextStyle(
          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
          child: Text(
            isPublishing ? 'Publish' : 'Unpublish',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  final Event event;

  const _ConfirmDeleteDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    final dark = Get.isDarkMode;

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Delete Event',
        style: TextStyle(
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
        style: TextStyle(
          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
          ),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}