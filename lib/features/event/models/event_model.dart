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
    this.status = 'active',
    this.eventRegistrations = const [],
  });

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

  /// Creates Event instance from JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhoneNo: json['contactPhoneNo'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      poster: json['poster'] ?? '',
      startDateTime: DateTime.parse(json['startDateTime'] ?? DateTime.now().toIso8601String()),
      endDateTime: DateTime.parse(json['endDateTime'] ?? DateTime.now().toIso8601String()),
      registrationDeadline: DateTime.parse(json['registrationDeadline'] ?? DateTime.now().toIso8601String()),
      maxParticipants: json['maxParticipants']?.toInt() ?? 0,
      registeredCount: json['registeredCount']?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      eventRegistrations: (json['eventRegistrations'] as List<dynamic>?)
          ?.map((reg) => EventRegistration.fromJson(reg))
          .toList() ?? [],
    );
  }

  /// Creates Event instance from Firebase DocumentSnapshot
  factory Event.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return Event.empty();

    return Event(
      eventId: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhoneNo: data['contactPhoneNo'] ?? '',
      location: Location.fromJson(Map<String, dynamic>.from(data['location'] ?? {})),
      poster: data['poster'] ?? '',
      startDateTime: (data['startDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDateTime: (data['endDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      registrationDeadline: (data['registrationDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 0,
      registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      eventRegistrations: [], // Registrations are typically loaded separately
    );
  }

  /// Converts Event instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'contactEmail': contactEmail,
      'contactPhoneNo': contactPhoneNo,
      'location': location.toJson(),
      'poster': poster,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'eventRegistrations': eventRegistrations.map((reg) => reg.toJson()).toList(),
    };
  }

  /// Converts Event instance to Firestore map (with Timestamps)
  Map<String, dynamic> toFirestore() {
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

  /// Returns formatted start date and time
  String get formattedStartDateTime {
    return FHelperFunctions.getFormattedDate(startDateTime, format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns formatted end date and time
  String get formattedEndDateTime {
    return FHelperFunctions.getFormattedDate(endDateTime, format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns formatted registration deadline
  String get formattedRegistrationDeadline {
    return FHelperFunctions.getFormattedDate(registrationDeadline, format: 'dd MMM yyyy, HH:mm');
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

  /// Returns event status text
  String get statusText {
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
      return '$days day${days != 1 ? 's' : ''} ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
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
      status: status ?? this.status,
      eventRegistrations: eventRegistrations ?? this.eventRegistrations,
    );
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
}