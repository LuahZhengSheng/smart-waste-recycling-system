import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../../event/models/event_model.dart';
import '../../../event/models/event_registration_model.dart';
import '../../../event/models/location_model.dart';

class AdminEventDetailsController extends GetxController {
  // Observables
  final Rx<Event> event = Event.empty().obs;
  final RxList<EventRegistrationWithUser> eventRegistrations = <EventRegistrationWithUser>[].obs;
  final RxList<EventRegistrationWithUser> filteredRegistrations = <EventRegistrationWithUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString sortBy = 'newest'.obs; // newest, oldest, name
  final RxString filterBy = 'all'.obs; // all, active, cancelled
  final RxBool isImageExpanded = false.obs;

  // Statistics
  final RxInt totalRegistrations = 0.obs;
  final RxInt activeRegistrations = 0.obs;
  final RxInt cancelledRegistrations = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to sort and filter changes
    ever(sortBy, (_) => applySortAndFilter());
    ever(filterBy, (_) => applySortAndFilter());
  }

  void loadEventDetails(String eventId) {
    isLoading.value = true;

    // Mock loading event details - replace with actual API call
    Future.delayed(const Duration(milliseconds: 800), () {
      event.value = _getMockEvent(eventId);
      eventRegistrations.value = _getMockRegistrations(eventId);
      _calculateStatistics();
      applySortAndFilter();
      isLoading.value = false;
    });
  }

  Event _getMockEvent(String eventId) {
    final now = DateTime.now();
    return Event(
      eventId: eventId,
      title: 'Beach Cleanup Drive 2024',
      description: 'Join us for a community beach cleanup to protect marine life and preserve our beautiful coastline. This event is perfect for families, students, and environmental enthusiasts who want to make a positive impact on our environment.\n\nWe will provide all necessary equipment including gloves, garbage bags, and collection tools. Light refreshments will be provided to all participants.\n\nMeet at the main beach entrance near the parking area. Please wear comfortable clothes and closed-toe shoes.',
      contactEmail: 'contact@beachcleanup.com',
      contactPhoneNo: '+60123456789',
      location: Location.empty(),
      poster: 'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800&h=600&fit=crop',
      startDateTime: now.add(const Duration(days: 15)),
      endDateTime: now.add(const Duration(days: 15, hours: 4)),
      registrationDeadline: now.add(const Duration(days: 10)),
      maxParticipants: 100,
      registeredCount: 45,
      createdAt: now.subtract(const Duration(days: 30)),
      isPublish: true,
      status: 'active',
    );
  }

  List<EventRegistrationWithUser> _getMockRegistrations(String eventId) {
    final now = DateTime.now();
    return [
      EventRegistrationWithUser(
        registration: EventRegistration(
          registrationId: '1',
          userId: 'user1',
          createdAt: now.subtract(const Duration(days: 5)),
          isCancelled: false,
        ),
        user: UserModel(
          userId: 'user1',
          username: 'John Doe',
          email: 'john.doe@email.com',
          phoneNo: '+60123456789',
          profileImg: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
          loginAttemptCount: 0,
          role: 'user',
          isVerified: true,
          isActive: true,
          joinDate: now.subtract(const Duration(days: 180)),
        ),
      ),
      EventRegistrationWithUser(
        registration: EventRegistration(
          registrationId: '2',
          userId: 'user2',
          createdAt: now.subtract(const Duration(days: 3)),
          isCancelled: false,
        ),
        user: UserModel(
          userId: 'user2',
          username: 'Sarah Chen',
          email: 'sarah.chen@email.com',
          phoneNo: '+60198765432',
          profileImg: 'https://images.unsplash.com/photo-1494790108755-2616b612b000?w=100&h=100&fit=crop&crop=face',
          loginAttemptCount: 0,
          role: 'user',
          isVerified: true,
          isActive: true,
          joinDate: now.subtract(const Duration(days: 120)),
        ),
      ),
      EventRegistrationWithUser(
        registration: EventRegistration(
          registrationId: '3',
          userId: 'user3',
          createdAt: now.subtract(const Duration(days: 8)),
          isCancelled: true,
        ),
        user: UserModel(
          userId: 'user3',
          username: 'Mike Johnson',
          email: 'mike.johnson@email.com',
          phoneNo: '+60187654321',
          profileImg: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
          loginAttemptCount: 0,
          role: 'user',
          isVerified: true,
          isActive: true,
          joinDate: now.subtract(const Duration(days: 200)),
        ),
      ),
      EventRegistrationWithUser(
        registration: EventRegistration(
          registrationId: '4',
          userId: 'user4',
          createdAt: now.subtract(const Duration(days: 1)),
          isCancelled: false,
        ),
        user: UserModel(
          userId: 'user4',
          username: 'Emily Rodriguez',
          email: 'emily.rodriguez@email.com',
          phoneNo: '+60176543210',
          profileImg: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
          loginAttemptCount: 0,
          role: 'user',
          isVerified: true,
          isActive: true,
          joinDate: now.subtract(const Duration(days: 90)),
        ),
      ),
      EventRegistrationWithUser(
        registration: EventRegistration(
          registrationId: '5',
          userId: 'user5',
          createdAt: now.subtract(const Duration(days: 6)),
          isCancelled: false,
        ),
        user: UserModel(
          userId: 'user5',
          username: 'David Kim',
          email: 'david.kim@email.com',
          phoneNo: '+60165432109',
          profileImg: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
          loginAttemptCount: 0,
          role: 'user',
          isVerified: true,
          isActive: true,
          joinDate: now.subtract(const Duration(days: 150)),
        ),
      ),
    ];
  }

  void _calculateStatistics() {
    totalRegistrations.value = eventRegistrations.length;
    activeRegistrations.value = eventRegistrations.where((reg) => !reg.registration.isCancelled).length;
    cancelledRegistrations.value = eventRegistrations.where((reg) => reg.registration.isCancelled).length;
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
      // No filter
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

  void toggleImageExpansion() {
    isImageExpanded.value = !isImageExpanded.value;
  }

  void goBack() {
    Get.back();
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
}

class EventRegistrationWithUser {
  final EventRegistration registration;
  final UserModel user;

  EventRegistrationWithUser({
    required this.registration,
    required this.user,
  });
}