// reminder_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/helpers/helper_functions.dart';

/// Model representing a reminder for event registration
class Reminder {
  final String reminderId;
  final String registrationId;
  final String title;
  final String message;
  final Timestamp remindAt;  // 使用 Timestamp 存储 UTC 时间
  final Timestamp createdAt; // 使用 Timestamp 存储 UTC 时间
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
    remindAt: Timestamp.now(),
    createdAt: Timestamp.now(),
    isSent: false,
  );

  /// Creates Reminder instance from JSON map
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      reminderId: json['reminderId'] ?? '',
      registrationId: json['registrationId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      remindAt: _parseTimestamp(json['remindAt']),
      createdAt: _parseTimestamp(json['createdAt']),
      isSent: json['isSent'] ?? false,
    );
  }

  /// Creates Reminder instance from Firebase Document
  factory Reminder.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      final data = doc.data()!;
      return Reminder(
        reminderId: doc.id,  // 使用文档 ID 作为 reminderId
        registrationId: data['registrationId'] ?? '',
        title: data['title'] ?? '',
        message: data['message'] ?? '',
        remindAt: data['remindAt'] as Timestamp? ?? Timestamp.now(),
        createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
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
      'remindAt': remindAt,
      'createdAt': createdAt,
      'isSent': isSent,
    };
  }

  /// Converts Reminder instance to Firestore map (使用 server timestamp)
  Map<String, dynamic> toFirestore() {
    return {
      'registrationId': registrationId,
      'title': title,
      'message': message,
      'remindAt': remindAt,
      'createdAt': FieldValue.serverTimestamp(), // 使用 server timestamp
      'isSent': isSent,
    };
  }

  /// 解析时间戳的辅助方法
  static Timestamp _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp;
    } else if (timestamp is String) {
      return Timestamp.fromDate(DateTime.parse(timestamp).toUtc());
    } else if (timestamp is int) {
      return Timestamp.fromMillisecondsSinceEpoch(timestamp);
    }
    return Timestamp.now();
  }

  // ==================== Getter Methods ====================

  /// 获取本地时间的 DateTime（用于显示）
  DateTime get remindAtLocal => remindAt.toDate().toLocal();
  DateTime get createdAtLocal => createdAt.toDate().toLocal();

  /// 获取 UTC 时间的 DateTime
  DateTime get remindAtUtc => remindAt.toDate().toUtc();
  DateTime get createdAtUtc => createdAt.toDate().toUtc();

  /// Returns formatted remind date (使用本地时间显示)
  String get formattedRemindAt {
    return FHelperFunctions.getFormattedDate(remindAtLocal, format: 'dd MMM yyyy, HH:mm');
  }

  /// Returns formatted creation date (使用本地时间显示)
  String get formattedCreatedAt {
    return FHelperFunctions.getFormattedDate(createdAtLocal);
  }

  /// Returns reminder status text
  String get statusText {
    return isSent ? 'Sent' : 'Pending';
  }

  /// Checks if reminder should be sent (使用 UTC 时间比较)
  bool get shouldSend {
    final nowUtc = DateTime.now().toUtc();
    return !isSent && nowUtc.isAfter(remindAtUtc);
  }

  /// Checks if reminder is overdue (使用 UTC 时间比较)
  bool get isOverdue {
    final nowUtc = DateTime.now().toUtc();
    return !isSent && nowUtc.isAfter(remindAtUtc);
  }

  /// Returns time until reminder in a readable format (使用本地时间计算)
  String get timeUntilReminder {
    final now = DateTime.now();
    final difference = remindAtLocal.difference(now);

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
    Timestamp? remindAt,
    Timestamp? createdAt,
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