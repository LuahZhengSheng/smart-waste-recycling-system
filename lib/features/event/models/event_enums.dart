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

/// Event status for filtering
enum EventStatusFilter {
  all,
  open,
  full,
  closed,
  ended,
}

/// Extension to get display name for EventStatusFilter
extension EventStatusFilterExtension on EventStatusFilter {
  String get displayName {
    switch (this) {
      case EventStatusFilter.all:
        return 'All Events';
      case EventStatusFilter.open:
        return 'Open for Registration';
      case EventStatusFilter.full:
        return 'Fully Booked';
      case EventStatusFilter.closed:
        return 'Registration Closed';
      case EventStatusFilter.ended:
        return 'Ended';
    }
  }
}

/// Event registration status
enum RegistrationStatus {
  notRegistered,
  registered,
  cancelled,
  waitlisted,
}

/// Extension to get display name for RegistrationStatus
extension RegistrationStatusExtension on RegistrationStatus {
  String get displayName {
    switch (this) {
      case RegistrationStatus.notRegistered:
        return 'Not Registered';
      case RegistrationStatus.registered:
        return 'Registered';
      case RegistrationStatus.cancelled:
        return 'Cancelled';
      case RegistrationStatus.waitlisted:
        return 'Waitlisted';
    }
  }
}

/// Event attendance status
enum AttendanceStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

/// Extension to get display name for AttendanceStatus
extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.upcoming:
        return 'Upcoming';
      case AttendanceStatus.ongoing:
        return 'Ongoing';
      case AttendanceStatus.completed:
        return 'Completed';
      case AttendanceStatus.cancelled:
        return 'Cancelled';
    }
  }
}