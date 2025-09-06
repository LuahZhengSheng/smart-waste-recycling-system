import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../utils/popups/loaders.dart';
import '../models/address_model.dart';
import '../models/event_model.dart';
import '../models/location_model.dart';

class EventController extends GetxController {
  static EventController get instance => Get.find();

  // Observable variables
  final isLoading = false.obs;
  final isRegistering = false.obs;
  final events = <Event>[].obs;
  final filteredEvents = <Event>[].obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'All'.obs;
  final selectedDate = Rxn<DateTime>();

  // Text controllers
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadEvents();
    ever(searchQuery, (_) => filterEvents());
    ever(selectedStatus, (_) => filterEvents());
    ever(selectedDate, (_) => filterEvents());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load all events
  Future<void> loadEvents() async {
    try {
      isLoading(true);

      // Mock data for demonstration - replace with actual API call
      final mockEvents = [
        Event(
          eventId: '1',
          title: 'Hazardous Waste Management and Pollution 2025',
          description: 'Learn about proper hazardous waste management and pollution control techniques.',
          contactEmail: 'hazardous@example.com',
          contactPhoneNo: '+60123456789',
          location: Location.empty().copyWith(
            address: Address.empty().copyWith(
              area: 'Kuala Lumpur',
              city: 'Kuala Lumpur',
              state: 'Malaysia',
            ),
          ),
          poster: 'assets/images/events/hazardous_waste.jpg',
          startDateTime: DateTime(2025, 4, 28, 17, 30),
          endDateTime: DateTime(2025, 4, 28, 21, 30),
          registrationDeadline: DateTime(2025, 4, 25, 23, 59),
          maxParticipants: 100,
          registeredCount: 35,
          createdAt: DateTime.now(),
          status: 'active',
        ),
        Event(
          eventId: '2',
          title: 'International Rare Earths Conference',
          description: 'Global conference on rare earth elements and sustainable mining practices.',
          contactEmail: 'rare.earth@example.com',
          contactPhoneNo: '+60123456790',
          location: Location.empty().copyWith(
            address: Address.empty().copyWith(
              area: 'Penang',
              city: 'Georgetown',
              state: 'Malaysia',
            ),
          ),
          poster: 'assets/images/events/rare_earth.jpg',
          startDateTime: DateTime(2025, 5, 1, 14, 0),
          endDateTime: DateTime(2025, 5, 1, 18, 0),
          registrationDeadline: DateTime(2025, 4, 28, 23, 59),
          maxParticipants: 150,
          registeredCount: 89,
          createdAt: DateTime.now(),
          status: 'active',
        ),
        Event(
          eventId: '3',
          title: 'Women\'s Leadership Conference 2021',
          description: 'Empowering women in environmental leadership and sustainability.',
          contactEmail: 'womens.leadership@example.com',
          contactPhoneNo: '+60123456791',
          location: Location.empty().copyWith(
            address: Address.empty().copyWith(
              unitNo: '53',
              area: 'Bush St',
              city: 'San Francisco',
              state: 'CA',
            ),
          ),
          poster: 'assets/images/events/womens_leadership.jpg',
          startDateTime: DateTime(2025, 4, 24, 13, 30),
          endDateTime: DateTime(2025, 4, 24, 17, 30),
          registrationDeadline: DateTime(2025, 4, 22, 23, 59),
          maxParticipants: 80,
          registeredCount: 67,
          createdAt: DateTime.now(),
          status: 'active',
        ),
        Event(
          eventId: '4',
          title: 'International Kids Safe Parents Night Out',
          description: 'Educational event for parents on environmental safety for children.',
          contactEmail: 'kids.safe@example.com',
          contactPhoneNo: '+60123456792',
          location: Location.empty().copyWith(
            address: Address.empty().copyWith(
              unitNo: 'Lot 13',
              area: 'Oakland',
              city: 'Oakland',
              state: 'CA',
            ),
          ),
          poster: 'assets/images/events/kids_safe.jpg',
          startDateTime: DateTime(2025, 4, 23, 18, 0),
          endDateTime: DateTime(2025, 4, 23, 21, 0),
          registrationDeadline: DateTime(2025, 4, 21, 23, 59),
          maxParticipants: 60,
          registeredCount: 45,
          createdAt: DateTime.now(),
          status: 'active',
        ),
      ];

      events.assignAll(mockEvents);
      filteredEvents.assignAll(mockEvents);
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load events');
    } finally {
      isLoading(false);
    }
  }

  /// Filter events based on search query, status, and date
  void filterEvents() {
    var filtered = events.toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((event) =>
      event.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          event.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          event.location.address.city.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // Filter by status
    if (selectedStatus.value != 'All') {
      switch (selectedStatus.value) {
        case 'Open':
          filtered = filtered.where((event) => event.isRegistrationOpen).toList();
          break;
        case 'Full':
          filtered = filtered.where((event) => event.isFullyBooked).toList();
          break;
        case 'Closed':
          filtered = filtered.where((event) => event.isRegistrationClosed).toList();
          break;
        case 'Ended':
          filtered = filtered.where((event) => event.hasEnded).toList();
          break;
      }
    }

    // Filter by date
    if (selectedDate.value != null) {
      filtered = filtered.where((event) {
        final eventDate = DateTime(
          event.startDateTime.year,
          event.startDateTime.month,
          event.startDateTime.day,
        );
        final filterDate = DateTime(
          selectedDate.value!.year,
          selectedDate.value!.month,
          selectedDate.value!.day,
        );
        return eventDate.isAtSameMomentAs(filterDate);
      }).toList();
    }

    filteredEvents.assignAll(filtered);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update status filter
  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  /// Update date filter
  void updateDateFilter(DateTime? date) {
    selectedDate.value = date;
  }

  /// Clear all filters
  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedStatus.value = 'All';
    selectedDate.value = null;
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

      // Mock registration process - replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Update event registered count
      final updatedEvent = event.copyWith(registeredCount: event.registeredCount + 1);
      final index = events.indexWhere((e) => e.eventId == event.eventId);
      if (index != -1) {
        events[index] = updatedEvent;
        filterEvents();
      }

      FLoaders.successSnackBar(
        title: 'Registration Successful',
        message: 'You have successfully registered for ${event.title}',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Registration Failed',
        message: 'Failed to register for the event. Please try again.',
      );
    } finally {
      isRegistering(false);
    }
  }

  /// Check if user is registered for event (mock implementation)
  bool isUserRegistered(String eventId) {
    // Mock implementation - replace with actual user registration check
    return false;
  }

  /// Get user's events (mock implementation)
  List<Event> getUserEvents() {
    // Mock implementation - replace with actual user events
    return events.where((event) => isUserRegistered(event.eventId)).toList();
  }
}