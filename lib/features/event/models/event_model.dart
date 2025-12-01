import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'location_model.dart';
import 'event_registration_model.dart';
import 'dart:math' as math;

/// Model representing an event
class Event {
  final String eventId;
  final String title;
  final String description;
  final String contactEmail;
  final String contactPhoneNo;
  final Location location;
  final String poster;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final int registeredCount;
  final DateTime createdAt;
  final bool isPublish;
  final String status;
  final List<EventRegistration> eventRegistrations;

  const Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.contactEmail,
    required this.contactPhoneNo,
    required this.location,
    this.poster = '',
    required this.startDateTime,
    required this.endDateTime,
    required this.registrationDeadline,
    required this.maxParticipants,
    this.registeredCount = 0,
    required this.createdAt,
    this.isPublish = false,
    this.status = 'active',
    this.eventRegistrations = const [],
  });

  /// Creates Event instance from Firebase DocumentSnapshot
  factory Event.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return Event.empty();

    // Parse location as contained object
    Location location = Location.empty();
    if (data.containsKey('location') && data['location'] != null) {
      try {
        location = Location.fromJson(
            Map<String, dynamic>.from(data['location'] ?? {}));
      } catch (e) {
        print('Error parsing location for event ${doc.id}: $e');
        location = Location.empty();
      }
    }

    return Event(
      eventId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhoneNo: data['contactPhoneNo'] ?? '',
      location: location,
      poster: data['poster'] ?? '',
      startDateTime:
      (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDateTime:
      (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registrationDeadline:
      (data['registrationDeadline'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 0,
      registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      eventRegistrations: [],
    );
  }

  /// Converts Event instance to Firestore map (with Timestamps)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'contactEmail': contactEmail,
      'contactPhoneNo': contactPhoneNo,
      'location': location.toJson(),
      'poster': poster,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  /// Creates an empty Event instance
  static Event empty() => Event(
    eventId: '',
    title: '',
    description: '',
    contactEmail: '',
    contactPhoneNo: '',
    location: Location.empty(),
    poster: '',
    startDateTime: DateTime.now(),
    endDateTime: DateTime.now(),
    registrationDeadline: DateTime.now(),
    maxParticipants: 0,
    registeredCount: 0,
    createdAt: DateTime.now(),
    status: 'active',
    eventRegistrations: [],
  );


  /// Creates a copy of Event with updated fields
  Event copyWith({
    String? eventId,
    String? title,
    String? description,
    String? contactEmail,
    String? contactPhoneNo,
    Location? location,
    String? poster,
    DateTime? startDateTime,
    DateTime? endDateTime,
    DateTime? registrationDeadline,
    int? maxParticipants,
    int? registeredCount,
    DateTime? createdAt,
    bool? isPublish,
    String? status,
    List<EventRegistration>? eventRegistrations,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhoneNo: contactPhoneNo ?? this.contactPhoneNo,
      location: location ?? this.location,
      poster: poster ?? this.poster,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredCount: registeredCount ?? this.registeredCount,
      createdAt: createdAt ?? this.createdAt,
      isPublish: isPublish ?? this.isPublish,
      status: status ?? this.status,
      eventRegistrations: eventRegistrations ?? this.eventRegistrations,
    );
  }

  /// Returns formatted start date and time
  String get formattedStartDateTime {
    return FHelperFunctions.getFormattedDate(startDateTime,
        format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns formatted end date and time
  String get formattedEndDateTime {
    return FHelperFunctions.getFormattedDate(endDateTime,
        format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns formatted registration deadline
  String get formattedRegistrationDeadline {
    return FHelperFunctions.getFormattedDate(registrationDeadline,
        format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns event duration in hours
  double get durationInHours {
    return endDateTime.difference(startDateTime).inMinutes / 60.0;
  }

  /// Returns available spots for registration
  int get availableSpots {
    return math.max(0, maxParticipants - registeredCount);
  }

  /// Checks if event registration is open
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return status == 'active' &&
        now.isBefore(registrationDeadline) &&
        availableSpots > 0;
  }

  /// Checks if event is fully booked
  bool get isFullyBooked {
    return registeredCount >= maxParticipants;
  }

  /// Checks if event has started
  bool get hasStarted {
    return DateTime.now().isAfter(startDateTime);
  }

  /// Checks if event has ended
  bool get hasEnded {
    return DateTime.now().isAfter(endDateTime);
  }

  /// Checks if registration deadline has passed
  bool get isRegistrationClosed {
    return DateTime.now().isAfter(registrationDeadline);
  }

  /// Checks if event is cancelled by organizer
  bool get isCancelledByOrganizer {
    return status == 'cancelled' || status == 'deleted';
  }

  /// Returns event status text
  String get statusText {
    if (isCancelledByOrganizer) return 'Cancelled by Organizer';
    if (hasEnded) return 'Ended';
    if (hasStarted) return 'In Progress';
    if (isRegistrationClosed) return 'Registration Closed';
    if (isFullyBooked) return 'Fully Booked';
    if (isRegistrationOpen) return 'Open for Registration';
    return 'Inactive';
  }

  /// Returns time until event starts
  String get timeUntilStart {
    final now = DateTime.now();
    if (hasStarted) return 'Started';

    final difference = startDateTime.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return '$days day${days != 1 ? 's' : ''} later';
    } else if (hours > 0) {
      return '${hours}h later';
    } else {
      return '${difference.inMinutes}m later';
    }
  }

  /// Returns registration progress percentage
  double get registrationProgress {
    if (maxParticipants == 0) return 0.0;
    return (registeredCount / maxParticipants).clamp(0.0, 1.0);
  }

  /// Checks if user is registered for this event
  bool isUserRegistered(String userId) {
    return eventRegistrations.any((registration) =>
    registration.userId == userId && !registration.isCancelled);
  }

  /// Returns user's registration for this event
  EventRegistration? getUserRegistration(String userId) {
    try {
      return eventRegistrations.firstWhere((registration) =>
      registration.userId == userId && !registration.isCancelled);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Event(eventId: $eventId, title: $title, description: $description, contactEmail: $contactEmail, contactPhoneNo: $contactPhoneNo, location: $location, poster: $poster, startDateTime: $startDateTime, endDateTime: $endDateTime, registrationDeadline: $registrationDeadline, maxParticipants: $maxParticipants, registeredCount: $registeredCount, createdAt: $createdAt, status: $status, eventRegistrations: $eventRegistrations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event &&
        other.eventId == eventId &&
        other.title == title &&
        other.description == description &&
        other.contactEmail == contactEmail &&
        other.contactPhoneNo == contactPhoneNo &&
        other.location == location &&
        other.poster == poster &&
        other.startDateTime == startDateTime &&
        other.endDateTime == endDateTime &&
        other.registrationDeadline == registrationDeadline &&
        other.maxParticipants == maxParticipants &&
        other.registeredCount == registeredCount &&
        other.createdAt == createdAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return eventId.hashCode ^
    title.hashCode ^
    description.hashCode ^
    contactEmail.hashCode ^
    contactPhoneNo.hashCode ^
    location.hashCode ^
    poster.hashCode ^
    startDateTime.hashCode ^
    endDateTime.hashCode ^
    registrationDeadline.hashCode ^
    maxParticipants.hashCode ^
    registeredCount.hashCode ^
    createdAt.hashCode ^
    status.hashCode;
  }

  /// Get days remaining until registration deadline
  int get daysUntilDeadline {
    final now = DateTime.now();
    if (now.isAfter(registrationDeadline)) {
      // 已经过期，统一返回 0
      return 0;
    }

    final diff = registrationDeadline.difference(now);
    // 向上取整，比如 0.3 天算 1 天
    final days = (diff.inHours / 24).ceil();
    return days < 0 ? 0 : days;
  }

  /// Get formatted days remaining text
  String get daysUntilDeadlineText {
    if (isRegistrationClosed) return 'Closed';

    final days = daysUntilDeadline;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    return '$days days';
  }


  /// Get computed status based on dates (upcoming/ongoing/completed)
  String get computedStatus {
    if (status == 'cancelled') return 'cancelled';
    if (status == 'deleted') return 'deleted';
    if (hasEnded) return 'completed';
    if (hasStarted) return 'ongoing';
    return 'upcoming';
  }
}