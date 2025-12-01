import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/popups/loaders.dart';
import '../models/event_model.dart';
import '../models/event_enums.dart';
import '../models/geopoint_model.dart';

class EventUtils {
  EventUtils._();

  // ==================== Color & Icon Utilities ====================

  /// Get event color based on title keywords
  static Color getEventColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      return FColors.eventWasteColor;
    } else if (lowerTitle.contains('conference') ||
        lowerTitle.contains('international')) {
      return FColors.eventConferenceColor;
    } else if (lowerTitle.contains('leadership') ||
        lowerTitle.contains('women')) {
      return FColors.eventLeadershipColor;
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      return FColors.eventKidsColor;
    } else {
      return FColors.primaryBackground;
    }
  }

  /// Get event icon color based on title keywords
  static Color getEventIconColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      return FColors.eventWasteIcon;
    } else if (lowerTitle.contains('conference') ||
        lowerTitle.contains('international')) {
      return FColors.eventConferenceIcon;
    } else if (lowerTitle.contains('leadership') ||
        lowerTitle.contains('women')) {
      return FColors.eventLeadershipIcon;
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      return FColors.eventKidsIcon;
    } else {
      return FColors.primary;
    }
  }

  /// Build event icon based on title keywords
  static Widget buildEventIcon(String title, {double size = 48}) {
    final lowerTitle = title.toLowerCase();
    IconData iconData;
    Color iconColor;

    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      iconData = Iconsax.trash;
      iconColor = FColors.eventWasteIcon;
    } else if (lowerTitle.contains('conference') ||
        lowerTitle.contains('international')) {
      iconData = Iconsax.global;
      iconColor = FColors.eventConferenceIcon;
    } else if (lowerTitle.contains('leadership') ||
        lowerTitle.contains('women')) {
      iconData = Iconsax.crown;
      iconColor = FColors.eventLeadershipIcon;
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      iconData = Iconsax.people;
      iconColor = FColors.eventKidsIcon;
    } else {
      iconData = Iconsax.calendar;
      iconColor = FColors.primary;
    }

    return Icon(iconData, size: size, color: iconColor);
  }

  /// 🆕 Get attendance status color
  static Color getAttendanceStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.upcoming:
        return FColors.upcoming;
      case AttendanceStatus.ongoing:
        return FColors.ongoing;
      case AttendanceStatus.completed:
        return FColors.completed;
      case AttendanceStatus.cancelledByYou:
      case AttendanceStatus.cancelledByOrganizer:
        return FColors.cancelled;
    }
  }

  /// 🆕 Get attendance status icon
  static IconData getAttendanceStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.upcoming:
        return Iconsax.clock;
      case AttendanceStatus.ongoing:
        return Iconsax.play_circle5;
      case AttendanceStatus.completed:
        return Iconsax.tick_circle5;
      case AttendanceStatus.cancelledByYou:
      case AttendanceStatus.cancelledByOrganizer:
        return Iconsax.close_circle5;
    }
  }

  /// Get status color based on event state (deprecated - use getAttendanceStatusColor)
  @Deprecated('Use getAttendanceStatusColor instead')
  static Color getStatusColor(AttendanceStatus status) {
    return getAttendanceStatusColor(status);
  }

  /// Get status icon based on event state (deprecated - use getAttendanceStatusIcon)
  @Deprecated('Use getAttendanceStatusIcon instead')
  static IconData getStatusIcon(AttendanceStatus status) {
    return getAttendanceStatusIcon(status);
  }

  // ==================== Event Status Utilities ====================

  /// Get event status based on event data and cancellation status
  static AttendanceStatus getEventStatus(Event event, bool isCancelled) {
    if (event.isCancelledByOrganizer) {
      return AttendanceStatus.cancelledByOrganizer;
    }
    if (isCancelled) {
      return AttendanceStatus.cancelledByYou;
    }
    if (event.hasEnded) {
      return AttendanceStatus.completed;
    }
    if (event.hasStarted) {
      return AttendanceStatus.ongoing;
    }
    return AttendanceStatus.upcoming;
  }

  // ==================== 🆕 Date & Time Format Utilities ====================

  /// 🆕 Format full date (e.g., "December 1, 2025")
  static String formatDate(DateTime dateTime) {
    final month = _getMonthName(dateTime.month);
    return '$month ${dateTime.day}, ${dateTime.year}';
  }

  /// 🆕 Format date with day of week (e.g., "Mon, Dec 1")
  static String formatDateWithDay(DateTime dateTime) {
    final day = _getDayAbbreviation(dateTime.weekday);
    final month = _getMonthAbbreviation(dateTime.month);
    return '$day, $month ${dateTime.day}';
  }

  /// Format event date for display (Today, Tomorrow, etc.)
  static String formatEventDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final month = _getMonthAbbreviation(dateTime.month);
      return '$month ${dateTime.day}';
    }
  }

  /// Format time to 12-hour format (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// 🆕 Format date range (e.g., "Dec 1 - Dec 5, 2025")
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      // Same day
      return formatDate(start);
    } else if (start.year == end.year && start.month == end.month) {
      // Same month
      final month = _getMonthName(start.month);
      return '$month ${start.day} - ${end.day}, ${start.year}';
    } else if (start.year == end.year) {
      // Same year
      final startMonth = _getMonthAbbreviation(start.month);
      final endMonth = _getMonthAbbreviation(end.month);
      return '$startMonth ${start.day} - $endMonth ${end.day}, ${start.year}';
    } else {
      // Different years
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }

  /// 🆕 Format time range (e.g., "2:00 PM - 5:00 PM")
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// 🆕 Get time remaining until event (e.g., "2 days", "3 hours")
  static String getTimeRemaining(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.isNegative) {
      return 'Event has passed';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Starting soon';
    }
  }

  /// 🆕 Get full month name
  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  /// Get month abbreviation
  static String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  /// 🆕 Get day abbreviation
  static String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // ==================== Button Utilities ====================

  /// Get button color based on registration state
  static Color getButtonColor(Event event, bool isRegistered) {
    if (isRegistered) return FColors.success;
    if (event.hasEnded) return FColors.darkGrey;
    if (event.isRegistrationClosed) return FColors.darkGrey;
    if (event.isFullyBooked) return FColors.error;
    return FColors.primary;
  }

  /// Get button icon based on event and registration state
  static IconData getButtonIcon(Event event, bool isRegistered) {
    if (isRegistered) return Iconsax.tick_circle5;
    if (event.hasEnded) return Iconsax.close_circle;
    if (event.isRegistrationClosed) return Iconsax.lock;
    if (event.isFullyBooked) return Iconsax.user_remove;
    return Iconsax.user_add;
  }

  /// Get button text based on event and registration state
  static String getButtonText(Event event, bool isRegistered) {
    if (isRegistered) return 'Registered';
    if (event.hasEnded) return 'Event Ended';
    if (event.isRegistrationClosed) return 'Registration Closed';
    if (event.isFullyBooked) return 'Event Full';
    return 'Register Now';
  }

  /// Check if user can register for event
  static bool canRegister(Event event, bool isRegistered) {
    return !isRegistered && event.isRegistrationOpen && !event.isFullyBooked;
  }

  // ==================== Time Filter Utilities ====================

  /// Get time filter icon
  static IconData getTimeFilterIcon(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.allTime:
        return Iconsax.calendar;
      case TimeFilter.today:
        return Iconsax.calendar_1;
      case TimeFilter.thisWeek:
        return Iconsax.calendar_2;
      case TimeFilter.thisMonth:
        return Iconsax.calendar_tick;
      case TimeFilter.thisYear:
        return Iconsax.calendar_circle;
    }
  }

  // ==================== 🆕 Copy & Share Utilities ====================

  /// 🆕 Copy text to clipboard with feedback
  static void copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    FLoaders.successSnackBar(
      title: 'Copied',
      message: '$label copied to clipboard',
    );
  }

  /// 🆕 Share event details
  static Future<void> shareEvent(Event event) async {
    final text = '''
Check out this event!

${event.title}

📅 ${formatDate(event.startDateTime)}
🕐 ${formatTimeRange(event.startDateTime, event.endDateTime)}
📍 ${event.location.venueName}

${event.description}
''';

    try {
      // TODO: Implement share functionality
      await Clipboard.setData(ClipboardData(text: text));
      FLoaders.successSnackBar(
        title: 'Copied',
        message: 'Event details copied to clipboard',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to share event',
      );
    }
  }

  // ==================== 🆕 Contact Utilities ====================

  /// 🆕 Launch email app with error handling
  static Future<void> launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open email app',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open email: ${e.toString()}',
      );
    }
  }

  /// 🆕 Launch phone dialer with error handling
  static Future<void> launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open phone dialer',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open dialer: ${e.toString()}',
      );
    }
  }

  // ==================== 🆕 Map Utilities ====================

  /// 🆕 Open location in Google Maps with confirmation
  static Future<void> openInGoogleMaps({
    required double latitude,
    required double longitude,
    required String venueName,
    required String address,
  }) async {
    // Show confirmation dialog
    final confirmed = await FLoaders.showMapConfirmationDialog(
      venueName: venueName,
      address: address,
    );

    if (confirmed != true) return;

    // Open map
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open Google Maps',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open maps: ${e.toString()}',
      );
    }
  }

  /// 🆕 Open location with navigation in Google Maps
  static Future<void> openInGoogleMapsWithNavigation({
    required double latitude,
    required double longitude,
    required String venueName,
    required String address,
  }) async {
    // Show confirmation dialog
    final confirmed = await FLoaders.showMapConfirmationDialog(
      venueName: venueName,
      address: address,
    );

    if (confirmed != true) return;

    // Open map with navigation
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open Google Maps',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open maps: ${e.toString()}',
      );
    }
  }

  /// @deprecated Use openInGoogleMaps instead
  @Deprecated('Use openInGoogleMaps with named parameters instead')
  static Future<void> openInGoogleMapsOld(GeoPointModel geoPoint) async {
    await openInGoogleMaps(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      venueName: '',
      address: '',
    );
  }

  // ==================== 🆕 Validation Utilities ====================

  /// 🆕 Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 🆕 Check if phone is valid
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone);
  }

  /// 🆕 Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    // Format based on length
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    } else {
      return phone; // Return original if format is unknown
    }
  }

  // ==================== Lightbox Utilities ====================

  /// Show poster in lightbox
  static void showPosterLightbox(
      BuildContext context, Event event, String? posterUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Stack(
          children: [
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: getEventColor(event.title),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: getEventColor(event.title).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: posterUrl != null && posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: FColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultPoster(event);
                          },
                        )
                      : _buildDefaultPoster(event),
                ),
              ),
            ),
            Positioned(
              top: FSizes.defaultSpace,
              right: FSizes.defaultSpace,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.close_circle,
                    color: FColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build default poster when image is not available
  static Widget _buildDefaultPoster(Event event) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getEventColor(event.title),
            getEventColor(event.title).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: buildEventIcon(event.title, size: 80),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
              child: Text(
                event.title,
                style: const TextStyle(
                  color: FColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
