import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/popups/admin_loaders.dart';
import '../../../../data/repositories/event/event_repository.dart';
import '../../../../data/repositories/event/event_registration_repository.dart';
import '../../../../data/repositories/event/reminder_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../data/services/event/event_cancellation_service.dart';
import '../../../../features/authentication/models/user_model.dart';
import '../../../../features/event/models/event_model.dart';
import '../../../event/models/event_registration_model.dart';
import '../../screens/event_management/edit_event/edit_event.dart';

class AdminEventDetailController extends GetxController {
  static AdminEventDetailController get instance => Get.find();

  // Dependencies
  final EventRepository _eventRepository = Get.put(EventRepository());
  final EventRegistrationRepository _registrationRepository = Get.put(EventRegistrationRepository());
  final UserRepository _userRepository = Get.put(UserRepository());
  final ReminderRepository _reminderRepository = Get.put(ReminderRepository());
  final EventCancellationService _cancellationService = Get.put(EventCancellationService());

  // Observables
  final Rx<Event> event = Event.empty().obs;
  final RxList<EventRegistrationWithUser> eventRegistrations = <EventRegistrationWithUser>[].obs;
  final RxList<EventRegistrationWithUser> filteredRegistrations = <EventRegistrationWithUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString sortBy = 'newest'.obs;
  final RxString filterBy = 'all'.obs;

  // Statistics
  final RxInt totalRegistrations = 0.obs;
  final RxInt activeRegistrations = 0.obs;
  final RxInt cancelledRegistrations = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(sortBy, (_) => applySortAndFilter());
    ever(filterBy, (_) => applySortAndFilter());
  }

  void loadEventDetails(String eventId) {
    isLoading.value = true;

    // Listen to event stream
    _eventRepository.getEventById(eventId).listen((loadedEvent) {
      event.value = loadedEvent;
      _loadRegistrations(eventId);
    }, onError: (error) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load event: $error',
      );
      print('$error');
      isLoading.value = false;
    });
  }

  void _loadRegistrations(String eventId) {
    // Listen to registrations stream
    _registrationRepository.getEventRegistrations(eventId).listen((registrationDocs) async {
      if (registrationDocs.isEmpty) {
        eventRegistrations.clear();
        _calculateStatistics();
        applySortAndFilter();
        isLoading.value = false;
        return;
      }

      // Get all user IDs
      final userIds = registrationDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['userId'] as String;
      }).toSet();

      // Fetch users data
      final usersData = await _userRepository.getUsersProfileData(userIds);

      // 🆕 按用户分组，每个用户只取最新的注册记录
      final Map<String, EventRegistrationWithUser> latestRegistrationsByUser = {};

      for (final doc in registrationDocs) {
        final registration = _createRegistrationFromDocument(doc);
        final user = usersData[registration.userId] ?? UserModel.empty();

        // 🆕 如果该用户还没有记录，或者当前记录更新，则更新
        if (!latestRegistrationsByUser.containsKey(registration.userId) ||
            registration.createdAt.isAfter(
                latestRegistrationsByUser[registration.userId]!.registration.createdAt)) {
          latestRegistrationsByUser[registration.userId] = EventRegistrationWithUser(
            registration: registration,
            user: user,
          );
        }
      }

      // 🆕 只保留每个用户的最新注册记录
      eventRegistrations.value = latestRegistrationsByUser.values.toList();

      _calculateStatistics();
      applySortAndFilter();
      isLoading.value = false;
    }, onError: (error) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load registrations: $error',
      );
      print(error);
      isLoading.value = false;
    });
  }

  void _calculateStatistics() {
    // 🆕 现在 eventRegistrations 中每个用户只有一条最新记录
    totalRegistrations.value = eventRegistrations.length;

    // 🆕 统计最新状态为 active 的用户数
    activeRegistrations.value = eventRegistrations
        .where((reg) => !reg.registration.isCancelled)
        .length;

    // 🆕 统计最新状态为 cancelled 的用户数
    cancelledRegistrations.value = eventRegistrations
        .where((reg) => reg.registration.isCancelled)
        .length;

    print('📊 Statistics Updated:');
    print('   Total: ${totalRegistrations.value}');
    print('   Active: ${activeRegistrations.value}');
    print('   Cancelled: ${cancelledRegistrations.value}');
  }

  /// 修复方法：从 DocumentSnapshot<Object?> 创建 EventRegistration
  EventRegistration _createRegistrationFromDocument(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return EventRegistration.empty();

    return EventRegistration(
      registrationId: doc.id,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCancelled: data['isCancelled'] ?? false,
    );
  }

  void applySortAndFilter() {
    List<EventRegistrationWithUser> result = List.from(eventRegistrations);

    // Apply filter
    switch (filterBy.value) {
      case 'active':
        result = result.where((reg) => !reg.registration.isCancelled).toList();
        break;
      case 'cancelled':
        result = result.where((reg) => reg.registration.isCancelled).toList();
        break;
      case 'all':
      default:
        break;
    }

    // Apply sort
    switch (sortBy.value) {
      case 'newest':
        result.sort((a, b) => b.registration.createdAt.compareTo(a.registration.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.registration.createdAt.compareTo(b.registration.createdAt));
        break;
      case 'name':
        result.sort((a, b) => a.user.username.toLowerCase().compareTo(b.user.username.toLowerCase()));
        break;
    }

    filteredRegistrations.value = result;
  }

  void setSortBy(String newSortBy) {
    sortBy.value = newSortBy;
  }

  void setFilterBy(String newFilterBy) {
    filterBy.value = newFilterBy;
  }

  String getRegistrationStatusText(EventRegistration registration) {
    return registration.isCancelled ? 'Cancelled' : 'Active';
  }

  Color getRegistrationStatusColor(EventRegistration registration, bool dark) {
    if (registration.isCancelled) {
      return dark ? FColors.adminDarkError : FColors.adminLightError;
    }
    return dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Actions
  void editEvent() {
    Get.to(() => EditEventScreen(event: event.value));
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

  Future<void> deleteEvent() async {
    try {
      final confirmed = await Get.dialog<bool>(
        _ConfirmDeleteEventDialog(event: event.value),
      );

      if (confirmed != true) return;

      final updatedEvent = event.value.copyWith(
        status: 'deleted',
        isPublish: false,
      );
      await _eventRepository.updateEvent(updatedEvent);

      Get.back(); // Go back to event management

      FAdminLoaders.successSnackBar(
        title: 'Event Deleted',
        message: 'Event has been deleted successfully',
      );
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete event: $e',
      );
      print('$e');
    }
  }
}

// Model class
class EventRegistrationWithUser {
  final EventRegistration registration;
  final UserModel user;

  EventRegistrationWithUser({
    required this.registration,
    required this.user,
  });
}

class _ConfirmDeleteEventDialog extends StatelessWidget {
  final Event event;

  const _ConfirmDeleteEventDialog({required this.event});

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