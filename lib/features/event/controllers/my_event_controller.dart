import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';
import '../models/event_model.dart';
import '../models/location_model.dart';

class MyEventsController extends GetxController with GetSingleTickerProviderStateMixin {
  static MyEventsController get instance => Get.find();

  // Tab Controller
  late TabController tabController;

  // Observable variables
  final isLoading = false.obs;
  final selectedDateRange = Rx<DateTimeRange?>(null);
  final registeredEvents = <Event>[].obs;
  final filteredEvents = <Event>[].obs;
  final currentTabIndex = 0.obs;

  // Date filter controller
  final TextEditingController dateRangeController = TextEditingController();

  final dateFilterType = 'All Time'.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
      _filterEventsByTab();
    });
    loadMyEvents();
  }

  @override
  void onClose() {
    tabController.dispose();
    dateRangeController.dispose();
    super.onClose();
  }

  /// Load user's registered events
  Future<void> loadMyEvents() async {
    try {
      isLoading.value = true;

      // TODO: Replace with actual API call to fetch user's registered events
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock data - replace with actual data from your backend
      registeredEvents.value = _getMockRegisteredEvents();

      _filterEventsByTab();
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load events: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter events based on current tab and date range
  void _filterEventsByTab() {
    List<Event> events = List.from(registeredEvents);

    // Apply date filter first
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      events = events.where((event) {
        final eventDate = DateTime(
          event.startDateTime.year,
          event.startDateTime.month,
          event.startDateTime.day,
        );
        final startDate = DateTime(range.start.year, range.start.month, range.start.day);
        final endDate = DateTime(range.end.year, range.end.month, range.end.day);

        return eventDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply tab filter
    switch (currentTabIndex.value) {
      case 0: // All
        filteredEvents.value = events;
        break;
      case 1: // Upcoming
        filteredEvents.value = events.where((event) =>
        !event.hasStarted && !_isEventCancelled(event.eventId)).toList();
        break;
      case 2: // Ongoing
        filteredEvents.value = events.where((event) =>
        event.hasStarted && !event.hasEnded && !_isEventCancelled(event.eventId)).toList();
        break;
      case 3: // Completed
        filteredEvents.value = events.where((event) =>
        event.hasEnded && !_isEventCancelled(event.eventId)).toList();
        break;
      case 4: // Cancelled
        filteredEvents.value = events.where((event) =>
            _isEventCancelled(event.eventId)).toList();
        break;
    }

    // Sort by start date
    filteredEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  String get dateRangeText {
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
    }
    return '';
  }

  /// Update date range filter
  void updateDateFilter(String filterType, {DateTime? start, DateTime? end}) {
    dateFilterType.value = filterType;

    switch (filterType) {
      case 'All Time':
        selectedDateRange.value = null;
        startDate.value = null;
        endDate.value = null;
        dateRangeController.clear();
        break;
      case 'This Week':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        selectedDateRange.value = DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
        );
        break;
      case 'This Month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        selectedDateRange.value = DateTimeRange(
          start: startOfMonth,
          end: endOfMonth,
        );
        break;
      case 'Custom':
        if (start != null && end != null) {
          selectedDateRange.value = DateTimeRange(start: start, end: end);
          startDate.value = start;
          endDate.value = end;
          dateRangeController.text = '${_formatDate(start)} - ${_formatDate(end)}';
        }
        break;
    }

    _filterEventsByTab();
  }

  /// Clear all filters
  void clearAllFilters() {
    dateFilterType.value = 'All Time';
    selectedDateRange.value = null;
    startDate.value = null;
    endDate.value = null;
    dateRangeController.clear();
    _filterEventsByTab();
  }

  /// Cancel event registration
  Future<void> cancelRegistration(String eventId) async {
    try {
      isLoading.value = true;

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Registration'),
          content: const Text('Are you sure you want to cancel your registration for this event?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // TODO: Replace with actual API call to cancel registration
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock cancellation - add to cancelled list
      _mockCancelledRegistrations.add(eventId);

      _filterEventsByTab();
      FLoaders.successSnackBar(title: 'Success', message: 'Registration cancelled successfully');

    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to cancel registration: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get tab count for specific tab
  int getTabCount(int tabIndex) {
    List<Event> events = List.from(registeredEvents);

    // Apply date filter
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      events = events.where((event) {
        final eventDate = DateTime(
          event.startDateTime.year,
          event.startDateTime.month,
          event.startDateTime.day,
        );
        final startDate = DateTime(range.start.year, range.start.month, range.start.day);
        final endDate = DateTime(range.end.year, range.end.month, range.end.day);

        return eventDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    switch (tabIndex) {
      case 0: // All
        return events.length;
      case 1: // Upcoming
        return events.where((event) =>
        !event.hasStarted && !_isEventCancelled(event.eventId)).length;
      case 2: // Ongoing
        return events.where((event) =>
        event.hasStarted && !event.hasEnded && !_isEventCancelled(event.eventId)).length;
      case 3: // Completed
        return events.where((event) =>
        event.hasEnded && !_isEventCancelled(event.eventId)).length;
      case 4: // Cancelled
        return events.where((event) =>
            _isEventCancelled(event.eventId)).length;
      default:
        return 0;
    }
  }

  /// Check if event registration is cancelled
  bool _isEventCancelled(String eventId) {
    return _mockCancelledRegistrations.contains(eventId);
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return FHelperFunctions.getFormattedDate(date, format: 'dd MMM');
  }

  // Mock data and cancelled registrations list (replace with actual data)
  static final List<String> _mockCancelledRegistrations = [];

  List<Event> _getMockRegisteredEvents() {
    final now = DateTime.now();
    return [
      Event(
        eventId: '1',
        title: 'Beach Cleanup Drive',
        description: 'Join us for a community beach cleanup to protect marine life and keep our beaches clean.',
        contactEmail: 'cleanup@example.com',
        contactPhoneNo: '+1234567890',
        location: Location.empty(),
        poster: '',
        startDateTime: now.add(const Duration(days: 5)),
        endDateTime: now.add(const Duration(days: 5, hours: 3)),
        registrationDeadline: now.add(const Duration(days: 3)),
        maxParticipants: 50,
        registeredCount: 25,
        createdAt: now.subtract(const Duration(days: 10)),
        status: 'active',
      ),
      Event(
        eventId: '2',
        title: 'Recycling Workshop',
        description: 'Learn about proper recycling techniques and sustainable waste management.',
        contactEmail: 'recycle@example.com',
        contactPhoneNo: '+1234567890',
        location: Location.empty(),
        poster: '',
        startDateTime: now.subtract(const Duration(hours: 2)),
        endDateTime: now.add(const Duration(hours: 1)),
        registrationDeadline: now.subtract(const Duration(days: 1)),
        maxParticipants: 30,
        registeredCount: 20,
        createdAt: now.subtract(const Duration(days: 5)),
        status: 'active',
      ),
      Event(
        eventId: '3',
        title: 'Tree Planting Initiative',
        description: 'Help us plant trees and create a greener environment for future generations.',
        contactEmail: 'trees@example.com',
        contactPhoneNo: '+1234567890',
        location: Location.empty(),
        poster: '',
        startDateTime: now.subtract(const Duration(days: 2)),
        endDateTime: now.subtract(const Duration(days: 2, hours: -4)),
        registrationDeadline: now.subtract(const Duration(days: 5)),
        maxParticipants: 100,
        registeredCount: 80,
        createdAt: now.subtract(const Duration(days: 15)),
        status: 'active',
      ),
      Event(
        eventId: '4',
        title: 'Eco Fair 2024',
        description: 'Discover eco-friendly products and sustainable living tips at our annual eco fair.',
        contactEmail: 'ecofair@example.com',
        contactPhoneNo: '+1234567890',
        location: Location.empty(),
        poster: '',
        startDateTime: now.add(const Duration(days: 15)),
        endDateTime: now.add(const Duration(days: 15, hours: 6)),
        registrationDeadline: now.add(const Duration(days: 10)),
        maxParticipants: 200,
        registeredCount: 150,
        createdAt: now.subtract(const Duration(days: 20)),
        status: 'active',
      ),
    ];
  }
}