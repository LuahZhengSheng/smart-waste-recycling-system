import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/event/event_registration_repository.dart';
import '../../../data/repositories/event/event_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/event/reminder_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import 'dart:async';

// Event Status Enum
enum EventStatus {
  all,
  open,
  full,
  closed
}

class EventController extends GetxController with GetSingleTickerProviderStateMixin {
  static EventController get instance => Get.find();

  final eventRepository = Get.put(EventRepository());
  final eventRegistrationRepository = Get.put(EventRegistrationRepository());
  final reminderRepository = Get.put(ReminderRepository());
  final authRepository = Get.put(AuthenticationRepository());

  // Observable variables
  final isLoading = false.obs;
  final isRegistering = false.obs;
  final allEvents = <Event>[].obs;
  final filteredEvents = <Event>[].obs;
  final searchQuery = ''.obs;
  final selectedTimeFilter = 'All Time'.obs;

  // Reminder management - 使用 Observable Map 来跟踪提醒状态
  final eventReminders = <String, bool>{}.obs; // eventId -> hasReminder

  // Tab Controller
  late TabController tabController;

  // Text controllers
  final searchController = TextEditingController();

  // Stream subscriptions
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _remindersSubscription;

  // Current user ID
  String get currentUserId => authRepository.authUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();

    // Initialize tab controller with 4 tabs
    tabController = TabController(length: 4, vsync: this);

    // Listen to tab changes
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        filterEvents();
      }
    });

    // Load events and reminders
    loadEvents();
    _loadReminders();

    // Listen to search and filter changes
    ever(searchQuery, (_) => filterEvents());
    ever(selectedTimeFilter, (_) => filterEvents());
  }

  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    _eventsSubscription?.cancel();
    _remindersSubscription?.cancel();
    super.onClose();
  }

  /// Get current tab status as enum
  EventStatus get currentTabStatus {
    switch (tabController.index) {
      case 0:
        return EventStatus.all;
      case 1:
        return EventStatus.open;
      case 2:
        return EventStatus.full;
      case 3:
        return EventStatus.closed;
      default:
        return EventStatus.all;
    }
  }

  /// Get status display name
  String getStatusDisplayName(EventStatus status) {
    switch (status) {
      case EventStatus.all:
        return 'All';
      case EventStatus.open:
        return 'Open';
      case EventStatus.full:
        return 'Full';
      case EventStatus.closed:
        return 'Closed';
    }
  }

  /// Load all events with real-time updates
  void loadEvents() {
    try {
      isLoading(true);

      _eventsSubscription?.cancel();
      _eventsSubscription = eventRepository.getAllEvents().listen(
            (events) {
          allEvents.assignAll(events);
          filterEvents();
          isLoading(false);
        },
        onError: (error) {
          isLoading(false);
          FLoaders.errorSnackBar(
            title: 'Error',
            message: error.toString(),
          );
        },
      );
    } catch (e) {
      isLoading(false);
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load events',
      );
    }
  }

  /// Get single event stream
  Stream<Event> getEventStream(String eventId) {
    return eventRepository.getEventById(eventId);
  }

  /// Filter events based on tab, search query, and time filter
  void filterEvents() {
    var filtered = allEvents.toList();

    // Filter by tab (status)
    final status = currentTabStatus;
    switch (status) {
      case EventStatus.open:
        filtered = filtered.where((event) =>
        event.isRegistrationOpen &&
            !event.isFullyBooked &&
            !event.hasEnded
        ).toList();
        break;
      case EventStatus.full:
        filtered = filtered.where((event) =>
        event.isFullyBooked &&
            !event.isRegistrationClosed &&
            !event.hasEnded
        ).toList();
        break;
      case EventStatus.closed:
        filtered = filtered.where((event) =>
        event.isRegistrationClosed &&
            !event.hasEnded
        ).toList();
        break;
      case EventStatus.all:
      default:
        filtered = filtered.where((event) => !event.hasEnded).toList();
        break;
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((event) =>
      event.title.toLowerCase().contains(query) ||
          event.description.toLowerCase().contains(query) ||
          event.location.address.city.toLowerCase().contains(query) ||
          event.location.address.area.toLowerCase().contains(query)
      ).toList();
    }

    // Filter by time
    if (selectedTimeFilter.value != 'All Time') {
      final now = DateTime.now();
      DateTime startDate;

      switch (selectedTimeFilter.value) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          filtered = filtered.where((event) {
            final eventDate = DateTime(
              event.startDateTime.year,
              event.startDateTime.month,
              event.startDateTime.day,
            );
            return eventDate.isAtSameMomentAs(startDate);
          }).toList();
          break;

        case 'This Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          filtered = filtered.where((event) =>
          event.startDateTime.isAfter(startDate) &&
              event.startDateTime.isBefore(startDate.add(const Duration(days: 7)))
          ).toList();
          break;

        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          final endDate = DateTime(now.year, now.month + 1, 0);
          filtered = filtered.where((event) =>
          event.startDateTime.isAfter(startDate) &&
              event.startDateTime.isBefore(endDate)
          ).toList();
          break;

        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          final endDate = DateTime(now.year, 12, 31);
          filtered = filtered.where((event) =>
          event.startDateTime.isAfter(startDate) &&
              event.startDateTime.isBefore(endDate)
          ).toList();
          break;
      }
    }

    filteredEvents.assignAll(filtered);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update time filter
  void setTimeFilter(String filter) {
    selectedTimeFilter.value = filter;
  }

  /// Clear all filters
  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedTimeFilter.value = 'All Time';
  }

  /// Register for event
  Future<void> registerForEvent(Event event) async {
    try {
      isRegistering(true);

      // Validate registration
      if (!event.isRegistrationOpen) {
        FLoaders.errorSnackBar(
          title: 'Registration Closed',
          message: 'Registration for this event is no longer available.',
        );
        return;
      }

      if (event.isFullyBooked) {
        FLoaders.errorSnackBar(
          title: 'Event Full',
          message: 'This event has reached maximum capacity.',
        );
        return;
      }

      // Register through repository
      await eventRegistrationRepository.registerForEvent(currentUserId, event.eventId);

      FLoaders.successSnackBar(
        title: 'Registration Successful',
        message: 'You have successfully registered for ${event.title}',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Registration Failed',
        message: e.toString(),
      );
    } finally {
      isRegistering(false);
    }
  }

  /// Cancel event registration
  Future<void> cancelRegistration(Event event) async {
    try {
      isRegistering(true);

      // Get registration ID first to delete reminder
      final registrationId = await eventRegistrationRepository.getUserRegistrationId(currentUserId, event.eventId);

      await eventRegistrationRepository.cancelRegistration(currentUserId, event.eventId);

      // Remove reminder if exists
      if (eventReminders[event.eventId] == true) {
        await _deleteReminder(registrationId, event.eventId);
      }

      FLoaders.successSnackBar(
        title: 'Cancellation Successful',
        message: 'Your registration has been cancelled',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Cancellation Failed',
        message: e.toString(),
      );
    } finally {
      isRegistering(false);
    }
  }

  /// Check if user is registered for event
  Stream<bool> isUserRegistered(String eventId) {
    return eventRegistrationRepository.isUserRegistered(currentUserId, eventId);
  }

  /// Get user's registered events
  Stream<List<Event>> getUserEvents() {
    return eventRegistrationRepository.getUserRegisteredEvents(currentUserId);
  }

  // ==================== Reminder Management ====================

  /// Load user's event reminders
  void _loadReminders() {
    try {
      // Get user's registration IDs first
      _remindersSubscription?.cancel();
      // We'll load reminders on-demand when checking specific events
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error loading reminders',
        message: e.toString(),
      );
    }
  }

  /// Check if event has reminder enabled
  Future<bool> hasReminder(String eventId) async {
    try {
      // 如果本地已经有状态，先返回本地状态
      if (eventReminders.containsKey(eventId)) {
        return eventReminders[eventId]!;
      }

      // Get registration ID for this event
      final registrationId = await eventRegistrationRepository.getUserRegistrationId(currentUserId, eventId);
      if (registrationId.isEmpty) {
        eventReminders[eventId] = false;
        return false;
      }

      // Check if reminder exists in Firestore using reminder repository
      final reminderExists = await reminderRepository.checkReminderExists(registrationId);
      eventReminders[eventId] = reminderExists;
      return reminderExists;
    } catch (e) {
      return eventReminders[eventId] ?? false;
    }
  }

  /// Toggle reminder for event
  Future<void> toggleReminder(String eventId, bool value) async {
    try {
      // Get registration ID for this event
      final registrationId = await eventRegistrationRepository.getUserRegistrationId(currentUserId, eventId);
      if (registrationId.isEmpty) {
        throw 'User is not registered for this event';
      }

      if (value) {
        // Create new reminder using reminder repository
        await _createReminder(eventId, registrationId);
      } else {
        // Delete existing reminder using reminder repository
        await _deleteReminder(registrationId, eventId);
      }

      // 立即更新本地状态，确保 UI 实时响应
      eventReminders[eventId] = value;

      FLoaders.successSnackBar(
        title: value ? 'Reminder Set' : 'Reminder Removed',
        message: value
            ? 'You will be notified 1 day before the event starts'
            : 'Reminder has been removed',
        duration: 2,
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update reminder: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Create a new reminder using reminder repository
  Future<void> _createReminder(String eventId, String registrationId) async {
    try {
      // Get event details
      final event = await eventRepository.getEventById(eventId).first;

      // Calculate reminder time (1 day before event start)
      final remindAt = event.startDateTime.subtract(const Duration(days: 1));

      // Create reminder model
      final reminder = Reminder(
        reminderId: _generateReminderId(),
        registrationId: registrationId,
        title: 'Event Reminder: ${event.title}',
        message: 'Your event "${event.title}" starts in 1 day at ${event.location.address.area}',
        remindAt: remindAt,
        createdAt: DateTime.now(),
        isSent: false,
      );

      // Save to Firestore using reminder repository
      await reminderRepository.createReminder(reminder);

    } catch (e) {
      rethrow;
    }
  }

  /// Delete an existing reminder using reminder repository
  Future<void> _deleteReminder(String registrationId, String eventId) async {
    try {
      // Get the reminder to get its ID using reminder repository
      final reminder = await reminderRepository.getReminderByRegistration(registrationId);
      if (reminder != null) {
        await reminderRepository.deleteReminder(reminder.reminderId);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Generate a unique reminder ID
  String _generateReminderId() {
    return 'rem_${DateTime.now().millisecondsSinceEpoch}_${currentUserId.substring(0, 8)}';
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    loadEvents();
  }
}