import 'package:flutter/material.dart';
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
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      return FColors.eventConferenceColor;
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
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
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      return FColors.eventConferenceIcon;
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
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
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      iconData = Iconsax.global;
      iconColor = FColors.eventConferenceIcon;
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
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

  /// Get status color based on event state
  static Color getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.upcoming:
        return FColors.upcoming;
      case AttendanceStatus.ongoing:
        return FColors.ongoing;
      case AttendanceStatus.completed:
        return FColors.completed;
      case AttendanceStatus.cancelled:
        return FColors.cancelled;
    }
  }

  /// Get status icon based on event state
  static IconData getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.upcoming:
        return Iconsax.clock;
      case AttendanceStatus.ongoing:
        return Iconsax.play_circle;
      case AttendanceStatus.completed:
        return Iconsax.tick_circle;
      case AttendanceStatus.cancelled:
        return Iconsax.close_circle;
    }
  }

  // ==================== Event Status Utilities ====================

  /// Get event status based on event data and cancellation status
  static AttendanceStatus getEventStatus(Event event, bool isCancelled) {
    if (isCancelled) {
      return AttendanceStatus.cancelled;
    }

    final now = DateTime.now();
    if (event.endDateTime.isBefore(now)) {
      return AttendanceStatus.completed;
    } else if (event.startDateTime.isAfter(now)) {
      return AttendanceStatus.upcoming;
    } else {
      return AttendanceStatus.ongoing;
    }
  }

  // ==================== Date & Time Format Utilities ====================

  /// Format event date for display
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

  /// Format time to 12-hour format
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get month abbreviation
  static String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // ==================== Button Utilities ====================

  /// Get button color based on registration state
  static Color getButtonColor(Event event, bool isRegistered) {
    if (isRegistered) return FColors.success;
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

  // ==================== External Action Utilities ====================

  /// Share event details
  static void shareEvent(Event event) {
    FLoaders.customToast(message: 'Event sharing coming soon!');
  }

  /// Launch email app
  static Future<void> launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
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

  /// Launch phone dialer
  static Future<void> launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
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

  /// Open location in Google Maps with navigation
  static Future<void> openInGoogleMaps(GeoPointModel geoPoint) async {
    final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${geoPoint.latitude},${geoPoint.longitude}&travelmode=driving'
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

  // ==================== Lightbox Utilities ====================

  /// Show poster in lightbox
  static void showPosterLightbox(BuildContext context, Event event, String? posterUrl) {
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
                          value: loadingProgress.expectedTotalBytes != null
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
              padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
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