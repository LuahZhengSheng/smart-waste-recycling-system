import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/event/event_registration_repository.dart';
import '../../../data/repositories/event/event_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/popups/loaders.dart';
import '../models/event_enums.dart';
import '../models/event_model.dart';
import '../utils/event_utils.dart';

class MyEventsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static MyEventsController get instance => Get.find();

  // Repositories
  final eventRepository = Get.put(EventRepository());
  final eventRegistrationRepository = Get.put(EventRegistrationRepository());
  final _authRepo = AuthenticationRepository.instance;

  // Tab Controller
  late TabController tabController;

  // Observable variables
  final isLoading = false.obs;
  final registeredEvents = <Event>[].obs;
  final cancelledEventIds = <String, bool>{}.obs;
  final filteredEvents = <Event>[].obs;
  final currentTabIndex = 0.obs;

  // Time filter
  final selectedTimeFilter = TimeFilter.allTime.obs;

  // Event poster URLs cache
  final eventPosterUrls = <String, String?>{}.obs;
  final isLoadingPoster = <String, bool>{}.obs;

  // Stream subscriptions
  StreamSubscription<List<Event>>? _eventsSubscription;
  StreamSubscription<Map<String, bool>>? _cancelledSubscription;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
      _filterEventsByTab();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyEvents();
    });
  }

  @override
  void onClose() {
    _eventsSubscription?.cancel();
    _cancelledSubscription?.cancel();
    tabController.dispose();
    super.onClose();
  }

  /// Load user's registered events from Firestore
  void _loadMyEvents() {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) {
        Future.delayed(Duration.zero, () {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'User not authenticated',
          );
        });
        return;
      }

      Future.delayed(Duration.zero, () {
        FLoaders.showLoading('Loading your events...');
      });

      // Listen to registered events
      _eventsSubscription =
          eventRegistrationRepository.getUserRegisteredEvents(userId).listen(
                (events) {
              registeredEvents.value = events;

              // Load poster URLs for all events
              for (final event in events) {
                if (event.poster.isNotEmpty) {
                  _loadEventPoster(event.eventId, event.poster);
                }
              }

              _filterEventsByTab();

              if (FLoaders.stopLoading != null) {
                Future.delayed(Duration.zero, () {
                  FLoaders.stopLoading();
                });
              }
            },
            onError: (error) {
              Future.delayed(Duration.zero, () {
                FLoaders.stopLoading();
                FLoaders.errorSnackBar(
                  title: 'Error',
                  message: 'Failed to load events: ${error.toString()}',
                );
              });
            },
          );

      // Listen to cancelled registrations
      _cancelledSubscription = eventRegistrationRepository
          .getUserCancelledRegistrations(userId)
          .listen(
            (cancelledMap) {
          cancelledEventIds.value = cancelledMap;
          _filterEventsByTab();
        },
        onError: (error) {
          print('Error loading cancelled registrations: $error');
        },
      );
    } catch (e) {
      Future.delayed(Duration.zero, () {
        FLoaders.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load events: ${e.toString()}',
        );
      });
    }
  }

  /// Load event poster from Firebase Storage
  Future<void> _loadEventPoster(String eventId, String posterFileName) async {
    if (eventPosterUrls.containsKey(eventId)) return;

    try {
      isLoadingPoster[eventId] = true;
      final url = await eventRepository.getEventPosterUrl(posterFileName);
      eventPosterUrls[eventId] = url;
    } catch (e) {
      print('Error loading poster for event $eventId: $e');
      eventPosterUrls[eventId] = null;
    } finally {
      isLoadingPoster[eventId] = false;
    }
  }

  /// Filter events based on current tab and time filter
  void _filterEventsByTab() {
    List<Event> events = List.from(registeredEvents);

    // Apply time filter first
    events = _applyTimeFilter(events);

    // Apply tab filter
    switch (currentTabIndex.value) {
      case 0: // All
        filteredEvents.value = events;
        break;
      case 1: // Upcoming
        filteredEvents.value = events
            .where((event) =>
        !event.hasStarted && !_isEventCancelled(event.eventId))
            .toList();
        break;
      case 2: // Ongoing
        filteredEvents.value = events
            .where((event) =>
        event.hasStarted &&
            !event.hasEnded &&
            !_isEventCancelled(event.eventId))
            .toList();
        break;
      case 3: // Completed
        filteredEvents.value = events
            .where((event) => event.hasEnded && !_isEventCancelled(event.eventId))
            .toList();
        break;
      case 4: // Cancelled
        filteredEvents.value =
            events.where((event) => _isEventCancelled(event.eventId)).toList();
        break;
    }

    // Sort by start date
    filteredEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  /// Apply time filter to events
  List<Event> _applyTimeFilter(List<Event> events) {
    final now = DateTime.now();

    switch (selectedTimeFilter.value) {
      case TimeFilter.allTime:
        return events;

      case TimeFilter.today:
        return events.where((event) {
          final eventDate = event.startDateTime;
          return eventDate.year == now.year &&
              eventDate.month == now.month &&
              eventDate.day == now.day;
        }).toList();

      case TimeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return events.where((event) {
          return event.startDateTime.isAfter(startOfWeek) &&
              event.startDateTime
                  .isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();

      case TimeFilter.thisMonth:
        return events.where((event) {
          return event.startDateTime.year == now.year &&
              event.startDateTime.month == now.month;
        }).toList();

      case TimeFilter.thisYear:
        return events.where((event) {
          return event.startDateTime.year == now.year;
        }).toList();
    }
  }

  /// Set time filter
  void setTimeFilter(TimeFilter filter) {
    selectedTimeFilter.value = filter;
    _filterEventsByTab();
  }

  /// Cancel event registration
  Future<void> cancelRegistration(String eventId) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) {
        Future.delayed(Duration.zero, () {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'User not authenticated',
          );
        });
        return;
      }

      // Show confirmation dialog
      final confirmed = await FLoaders.showConfirmationDialog(
        title: 'Cancel Registration',
        message:
        'Are you sure you want to cancel your registration for this event?',
        confirmText: 'Yes, Cancel',
        cancelText: 'No',
        confirmColor: FColors.error,
      );

      if (confirmed != true) return;

      Future.delayed(Duration.zero, () {
        FLoaders.showLoading('Cancelling registration...');
      });

      await eventRegistrationRepository.cancelRegistration(userId, eventId);

      Future.delayed(Duration.zero, () {
        FLoaders.stopLoading();
        FLoaders.successSnackBar(
          title: 'Success',
          message: 'Registration cancelled successfully',
        );
      });
    } catch (e) {
      Future.delayed(Duration.zero, () {
        FLoaders.stopLoading();
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to cancel registration: ${e.toString()}',
        );
      });
    }
  }

  /// Get tab count for specific tab
  int getTabCount(int tabIndex) {
    List<Event> events = _applyTimeFilter(List.from(registeredEvents));

    switch (tabIndex) {
      case 0: // All
        return events.length;
      case 1: // Upcoming
        return events
            .where((event) =>
        !event.hasStarted && !_isEventCancelled(event.eventId))
            .length;
      case 2: // Ongoing
        return events
            .where((event) =>
        event.hasStarted &&
            !event.hasEnded &&
            !_isEventCancelled(event.eventId))
            .length;
      case 3: // Completed
        return events
            .where((event) => event.hasEnded && !_isEventCancelled(event.eventId))
            .length;
      case 4: // Cancelled
        return events.where((event) => _isEventCancelled(event.eventId)).length;
      default:
        return 0;
    }
  }

  /// Check if event registration is cancelled
  bool _isEventCancelled(String eventId) {
    return cancelledEventIds[eventId] ?? false;
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    _loadMyEvents();
  }
}