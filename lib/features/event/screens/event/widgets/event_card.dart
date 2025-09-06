import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/event_model.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/formatters/formatter.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: Border.all(
            color: dark ? FColors.darkGrey : FColors.borderPrimary,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                color: _getEventColor(event.title),
              ),
              child: _buildEventIcon(event.title),
            ),

            const SizedBox(width: FSizes.md),

            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: FColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    ),
                    child: Text(
                      _formatEventDateTime(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: FColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: FSizes.xs),

                  // Event Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dark ? FColors.white : FColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: FSizes.xs / 2),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: FSizes.iconSm,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location.shortAddress,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: FSizes.xs),

                  // Status and Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Participants Count
                      Row(
                        children: [
                          Icon(
                            Iconsax.people,
                            size: FSizes.iconSm,
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.registeredCount}/${event.maxParticipants}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format event date and time
  String _formatEventDateTime() {
    final now = DateTime.now();
    final eventDate = event.startDateTime;

    // Check if it's today, tomorrow, or this week
    if (eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day) {
      return 'Today • ${FFormatter.formatDate(eventDate)} • ${_formatTime(eventDate)}';
    } else if (eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day + 1) {
      return 'Tomorrow • ${_formatTime(eventDate)}';
    } else {
      final dayName = _getDayName(eventDate.weekday);
      return '$dayName, ${_getMonthAbbr(eventDate.month)} ${eventDate.day} • ${_formatTime(eventDate)}';
    }
  }

  /// Format time to 12-hour format
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get month abbreviation
  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  /// Get event color based on title keywords
  Color _getEventColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      return const Color(0xFFFFE5E5); // Light red/pink
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      return const Color(0xFFE5E5FF); // Light purple/blue
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
      return const Color(0xFFE5F5FF); // Light purple
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      return const Color(0xFFE5F0FF); // Light blue
    } else {
      return FColors.primaryBackground;
    }
  }

  /// Build event icon based on title keywords
  Widget _buildEventIcon(String title) {
    final lowerTitle = title.toLowerCase();
    IconData iconData;
    Color iconColor;

    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      iconData = Iconsax.trash;
      iconColor = const Color(0xFFFF6B6B);
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      iconData = Iconsax.global;
      iconColor = const Color(0xFF6B6BFF);
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
      iconData = Iconsax.crown;
      iconColor = const Color(0xFF9B6BFF);
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      iconData = Iconsax.people;
      iconColor = const Color(0xFF6B9BFF);
    } else {
      iconData = Iconsax.calendar;
      iconColor = FColors.primary;
    }

    return Icon(
      iconData,
      size: FSizes.iconLg,
      color: iconColor,
    );
  }

  /// Get status color
  Color _getStatusColor() {
    if (event.hasEnded) return FColors.darkGrey;
    if (event.isRegistrationClosed) return FColors.warning;
    if (event.isFullyBooked) return FColors.error;
    if (event.isRegistrationOpen) return FColors.success;
    return FColors.darkGrey;
  }

  /// Get status text
  String _getStatusText() {
    if (event.hasEnded) return 'Ended';
    if (event.isRegistrationClosed) return 'Closed';
    if (event.isFullyBooked) return 'Full';
    if (event.isRegistrationOpen) return 'Open';
    return 'Inactive';
  }
}