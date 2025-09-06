import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an event registration
class EventRegistration {
  final String registrationId;
  final String userId;
  final DateTime createdAt;
  final bool isCancelled;

  const EventRegistration({
    required this.registrationId,
    required this.userId,
    required this.createdAt,
    this.isCancelled = false,
  });

  /// Creates an empty EventRegistration instance
  static EventRegistration empty() => EventRegistration(
    registrationId: '',
    userId: '',
    createdAt: DateTime.now(),
    isCancelled: false,
  );

  /// Creates EventRegistration instance from JSON map
  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      registrationId: json['registrationId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isCancelled: json['isCancelled'] ?? false,
    );
  }

  /// Creates EventRegistration instance from Firebase DocumentSnapshot
  factory EventRegistration.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return EventRegistration.empty();

    return EventRegistration(
      registrationId: snapshot.id,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCancelled: data['isCancelled'] ?? false,
    );
  }

  /// Converts EventRegistration instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'registrationId': registrationId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isCancelled': isCancelled,
    };
  }

  /// Converts EventRegistration instance to Firestore map (with Timestamp)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCancelled': isCancelled,
    };
  }

  /// Returns formatted creation date
  String get formattedCreatedAt {
    // You'll need to implement or import your date formatting function
    // For now, using basic formatting
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Returns registration status text
  String get statusText {
    return isCancelled ? 'Cancelled' : 'Active';
  }

  /// Checks if registration is active
  bool get isActive => !isCancelled;

  /// Creates a copy of EventRegistration with updated fields
  EventRegistration copyWith({
    String? registrationId,
    String? userId,
    DateTime? createdAt,
    bool? isCancelled,
  }) {
    return EventRegistration(
      registrationId: registrationId ?? this.registrationId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }

  @override
  String toString() {
    return 'EventRegistration(registrationId: $registrationId, userId: $userId, createdAt: $createdAt, isCancelled: $isCancelled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventRegistration &&
        other.registrationId == registrationId &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.isCancelled == isCancelled;
  }

  @override
  int get hashCode {
    return registrationId.hashCode ^
    userId.hashCode ^
    createdAt.hashCode ^
    isCancelled.hashCode;
  }
}