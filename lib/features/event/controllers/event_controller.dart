import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/event/event_registration_repository.dart';
import '../../../data/repositories/event/event_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/event/reminder_repository.dart';
import '../../../data/services/notification/fcm_service.dart';
import '../../../utils/popups/loaders.dart';
import '../models/event_model.dart';
import '../models/event_enums.dart';
import '../models/reminder_model.dart';
import 'dart:async';

class EventController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static EventController get instance {
    if (Get.isRegistered<EventController>()) {
      return Get.find<EventController>();
    } else {
      return Get.put(EventController(), permanent: true);
    }
  }

  final eventRepository = Get.put(EventRepository());
  final eventRegistrationRepository = Get.put(EventRegistrationRepository());
  final reminderRepository = Get.put(ReminderRepository());
  final authRepository = Get.put(AuthenticationRepository());
  final fcmService = FCMService();

  // Observable variables
  final isLoading = false.obs;
  final isRegistering = false.obs;
  final allEvents = <Event>[].obs;
  final filteredEvents = <Event>[].obs;
  final searchQuery = ''.obs;
  final selectedTimeFilter = 'All Time'.obs;

  // Event poster URLs cache
  final eventPosterUrls = <String, String?>{}.obs;
  final isLoadingPoster = <String, bool>{}.obs;

  // Reminder management
  final eventReminders = <String, bool>{}.obs;

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
  EventStatusFilter get currentTabStatus {
    switch (tabController.index) {
      case 0:
        return EventStatusFilter.all;
      case 1:
        return EventStatusFilter.open;
      case 2:
        return EventStatusFilter.full;
      case 3:
        return EventStatusFilter.closed;
      default:
        return EventStatusFilter.all;
    }
  }

  /// Load all events with real-time updates
  void loadEvents() {
    try {
      isLoading(true);

      _eventsSubscription?.cancel();
      _eventsSubscription = eventRepository.getAllPublishedEvents().listen(
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
      case EventStatusFilter.open:
        filtered = filtered
            .where((event) =>
                event.isRegistrationOpen &&
                !event.isFullyBooked &&
                !event.hasEnded)
            .toList();
        break;
      case EventStatusFilter.full:
        filtered = filtered
            .where((event) =>
                event.isFullyBooked &&
                !event.isRegistrationClosed &&
                !event.hasEnded)
            .toList();
        break;
      case EventStatusFilter.closed:
        filtered = filtered
            .where((event) => (event.isRegistrationClosed) || event.isCancelledByOrganizer)
            .toList();
        break;
      case EventStatusFilter.all:
      default:
        // filtered = filtered.where((event) => !event.hasEnded).toList();
        filtered = filtered.toList();
        break;
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where((event) =>
              event.title.toLowerCase().contains(query) ||
              event.description.toLowerCase().contains(query) ||
              event.location.address.city.toLowerCase().contains(query) ||
              event.location.address.area.toLowerCase().contains(query))
          .toList();
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
          filtered = filtered
              .where((event) =>
                  event.startDateTime.isAfter(startDate) &&
                  event.startDateTime
                      .isBefore(startDate.add(const Duration(days: 7))))
              .toList();
          break;

        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          final endDate = DateTime(now.year, now.month + 1, 0);
          filtered = filtered
              .where((event) =>
                  event.startDateTime.isAfter(startDate) &&
                  event.startDateTime.isBefore(endDate))
              .toList();
          break;

        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          final endDate = DateTime(now.year, 12, 31);
          filtered = filtered
              .where((event) =>
                  event.startDateTime.isAfter(startDate) &&
                  event.startDateTime.isBefore(endDate))
              .toList();
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
      await eventRegistrationRepository.registerForEvent(
          currentUserId, event.eventId);

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

      // 1️⃣ 先拿到该用户在这个 event 的 registrationId（最新那条）
      final registrationId = await eventRegistrationRepository
          .getUserRegistrationId(currentUserId, event.eventId);

      // 2️⃣ 如果有 registrationId，先删掉所有对应的 reminders
      if (registrationId.isNotEmpty) {
        await reminderRepository.deleteAllRemindersByRegistration(registrationId);
        print('✅ Deleted all reminders for registration: $registrationId');
      }

      // 3️⃣ 再标记 registration 为 isCancelled = true，并更新 event 的 registeredCount
      await eventRegistrationRepository.cancelRegistration(
        currentUserId,
        event.eventId,
      );

      FLoaders.successSnackBar(
        title: 'Cancellation Successful',
        message: 'Your registration has been cancelled.',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to cancel registration: ${e.toString()}',
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
  // Stream<List<Event>> getUserEvents() {
  //   return eventRegistrationRepository.getUserRegisteredEvents(currentUserId);
  // }

  // ==================== Reminder Management ====================

  /// Get registration ID for current user and event
  Future<String?> getRegistrationId(String eventId) async {
    try {
      final userId = authRepository.authUser?.uid;
      if (userId == null || userId.isEmpty) {
        print('❌ User not authenticated');
        return null;
      }

      final registrationId = await eventRegistrationRepository.getRegistrationId(
        userId,
        eventId,
      );

      return registrationId;
    } catch (e) {
      print('❌ Error getting registration ID: $e');
      return null;
    }
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    loadEvents();
  }

  /// Ensure controller is initialized (for push notification handling)
  static void ensureInitialized() {
    instance;
  }
}
