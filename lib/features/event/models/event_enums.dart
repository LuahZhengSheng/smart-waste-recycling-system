import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';

/// Event-related enumerations
/// Time filter options for events
enum TimeFilter {
  allTime,
  today,
  thisWeek,
  thisMonth,
  thisYear,
}

/// Extension to get display name for TimeFilter
extension TimeFilterExtension on TimeFilter {
  String get displayName {
    switch (this) {
      case TimeFilter.allTime:
        return 'All Time';
      case TimeFilter.today:
        return 'Today';
      case TimeFilter.thisWeek:
        return 'This Week';
      case TimeFilter.thisMonth:
        return 'This Month';
      case TimeFilter.thisYear:
        return 'This Year';
    }
  }
}

/// Event publish for filtering
enum EventPublishFilter {
  published,
  unpublished,
}

/// Extension for EventPublishFilter
extension EventPublishFilterExtension on EventPublishFilter {
  String get displayName {
    switch (this) {
      case EventPublishFilter.published:
        return 'Published Events';
      case EventPublishFilter.unpublished:
        return 'Unpublished Events';
    }
  }
}

/// Event status for filtering
enum EventStatusFilter {
  all,
  open,
  full,
  closed,
}

/// Extension to get display name for EventStatusFilter
extension EventStatusFilterExtension on EventStatusFilter {
  String get displayName {
    switch (this) {
      case EventStatusFilter.all:
        return 'All';
      case EventStatusFilter.open:
        return 'Open';
      case EventStatusFilter.full:
        return 'Full';
      case EventStatusFilter.closed:
        return 'Closed';
    }
  }
}

/// Event registration status for Events Screen
enum RegistrationStatus {
  open('Open', FColors.primary, Iconsax.tick_circle),
  full('Full', FColors.warning, Iconsax.danger),
  closed('Closed', FColors.error, Iconsax.close_circle);

  final String displayName;
  final Color color;
  final IconData icon;

  const RegistrationStatus(this.displayName, this.color, this.icon);
}

/// Extension to get display name for RegistrationStatus
// extension RegistrationStatusExtension on RegistrationStatus {
//   String get displayName {
//     switch (this) {
//       case RegistrationStatus.cancelled:
//         return 'Cancelled by Organizer';
//       case RegistrationStatus.notRegistered:
//         return 'Not Registered';
//       case RegistrationStatus.registered:
//         return 'Registered';
//       case RegistrationStatus.waitlisted:
//         return 'Waitlisted';
//     }
//   }
// }

/// Event attendance status for My Events Screen
enum AttendanceStatus {
  upcoming('Upcoming', Color(0xFF3B82F6), Iconsax.calendar), // Blue
  ongoing('Ongoing', FColors.warning, Iconsax.flash_1),
  completed('Completed', Color(0xFF06B6D4), Iconsax.tick_square), // Cyan
  cancelledByYou('Cancelled by You', FColors.error, Iconsax.close_square),
  cancelledByOrganizer('Cancelled by Organizer', FColors.error, Iconsax.close_circle);

  final String displayName;
  final Color color;
  final IconData icon;

  const AttendanceStatus(this.displayName, this.color, this.icon);
}

/// Extension to get display name for AttendanceStatus
// extension AttendanceStatusExtension on AttendanceStatus {
//   String get displayName {
//     switch (this) {
//       case AttendanceStatus.cancelled:
//         return 'Cancelled by Organizer';
//       case AttendanceStatus.upcoming:
//         return 'Upcoming';
//       case AttendanceStatus.ongoing:
//         return 'Ongoing';
//       case AttendanceStatus.completed:
//         return 'Completed';
//     }
//   }
// }

/// Event notification type
enum EventNotificationType {
  reminder,
  update,
  cancellation,
}

/// Extension for EventNotificationType
extension EventNotificationTypeExtension on EventNotificationType {
  String get displayName {
    switch (this) {
      case EventNotificationType.reminder:
        return 'Event Reminder';
      case EventNotificationType.update:
        return 'Event Update';
      case EventNotificationType.cancellation:
        return 'Event Cancellation';
    }
  }

  String get fcmType {
    switch (this) {
      case EventNotificationType.reminder:
        return 'event_reminder';
      case EventNotificationType.update:
        return 'event_update';
      case EventNotificationType.cancellation:
        return 'event_cancellation';
    }
  }
}