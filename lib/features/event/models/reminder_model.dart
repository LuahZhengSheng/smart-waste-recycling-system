import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/helpers/helper_functions.dart';

/// Model representing a reminder for event registration
class Reminder {
  final String reminderId;
  final String registrationId;
  final String title;
  final String message;
  final DateTime remindAt;
  final DateTime createdAt;
  final bool isSent;

  const Reminder({
    required this.reminderId,
    required this.registrationId,
    required this.title,
    required this.message,
    required this.remindAt,
    required this.createdAt,
    this.isSent = false,
  });

  /// Creates an empty Reminder instance
  static Reminder empty() => Reminder(
    reminderId: '',
    registrationId: '',
    title: '',
    message: '',
    remindAt: DateTime.now(),
    createdAt: DateTime.now(),
    isSent: false,
  );

  /// Creates Reminder instance from JSON map
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      reminderId: json['reminderId'] ?? '',
      registrationId: json['registrationId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      remindAt: DateTime.parse(json['remindAt'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isSent: json['isSent'] ?? false,
    );
  }

  /// Creates Reminder instance from Firebase Documentdoc
  factory Reminder.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      final data = doc.data()!;
      return Reminder(
        reminderId: doc.id,
        registrationId: data['registrationId'] ?? '',
        title: data['title'] ?? '',
        message: data['message'] ?? '',
        remindAt: (data['remindAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isSent: data['isSent'] ?? false,
      );
    }
    return Reminder.empty();
  }

  /// Converts Reminder instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'reminderId': reminderId,
      'registrationId': registrationId,
      'title': title,
      'message': message,
      'remindAt': remindAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isSent': isSent,
    };
  }

  /// Returns formatted remind date
  String get formattedRemindAt {
    return FHelperFunctions.getFormattedDate(remindAt, format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns formatted creation date
  String get formattedCreatedAt {
    return FHelperFunctions.getFormattedDate(createdAt);
  }

  /// Returns reminder status text
  String get statusText {
    return isSent ? 'Sent' : 'Pending';
  }

  /// Checks if reminder should be sent
  bool get shouldSend {
    return !isSent && DateTime.now().isAfter(remindAt);
  }

  /// Checks if reminder is overdue
  bool get isOverdue {
    return !isSent && DateTime.now().isAfter(remindAt);
  }

  /// Returns time until reminder in a readable format
  String get timeUntilReminder {
    final now = DateTime.now();
    final difference = remindAt.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '$days day${days != 1 ? 's' : ''} ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Creates a copy of Reminder with updated fields
  Reminder copyWith({
    String? reminderId,
    String? registrationId,
    String? title,
    String? message,
    DateTime? remindAt,
    DateTime? createdAt,
    bool? isSent,
  }) {
    return Reminder(
      reminderId: reminderId ?? this.reminderId,
      registrationId: registrationId ?? this.registrationId,
      title: title ?? this.title,
      message: message ?? this.message,
      remindAt: remindAt ?? this.remindAt,
      createdAt: createdAt ?? this.createdAt,
      isSent: isSent ?? this.isSent,
    );
  }

  @override
  String toString() {
    return 'Reminder(reminderId: $reminderId, registrationId: $registrationId, title: $title, message: $message, remindAt: $remindAt, createdAt: $createdAt, isSent: $isSent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.reminderId == reminderId &&
        other.registrationId == registrationId &&
        other.title == title &&
        other.message == message &&
        other.remindAt == remindAt &&
        other.createdAt == createdAt &&
        other.isSent == isSent;
  }

  @override
  int get hashCode {
    return reminderId.hashCode ^
    registrationId.hashCode ^
    title.hashCode ^
    message.hashCode ^
    remindAt.hashCode ^
    createdAt.hashCode ^
    isSent.hashCode;
  }
}