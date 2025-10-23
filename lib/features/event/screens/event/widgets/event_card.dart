import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/event_model.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';

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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: dark ? FColors.darkGrey.withOpacity(0.3) : FColors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header with Image/Icon
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getEventColor(event.title),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getEventColor(event.title),
                    _getEventColor(event.title).withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Event Icon
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Opacity(
                      opacity: 0.4,
                      child: _buildEventIcon(event.title, size: 64),
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 12,
                            color: FColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(),
                            style: const TextStyle(
                              color: FColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Date Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.calendar_1,
                            size: 12,
                            color: _getEventIconColor(event.title),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatEventDate(),
                            style: TextStyle(
                              color: _getEventIconColor(event.title),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? FColors.white : FColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.clock,
                          size: 14,
                          color: FColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_formatTime(event.startDateTime)} - ${_formatTime(event.endDateTime)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.location,
                          size: 14,
                          color: FColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location.shortAddress.isNotEmpty
                              ? event.location.shortAddress
                              : 'Event Location',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Participants Progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.people,
                                      size: 14,
                                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Participants',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${event.registeredCount}/${event.maxParticipants}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: dark ? FColors.white : FColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: event.registrationProgress,
                              backgroundColor: dark
                                  ? FColors.darkGrey.withOpacity(0.3)
                                  : FColors.grey.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                event.isFullyBooked ? FColors.error : FColors.primary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ),
                          ],
                        ),
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

  String _formatEventDate() {
    final now = DateTime.now();
    final eventDate = event.startDateTime;

    if (eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day) {
      return 'Today';
    } else if (eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      return '${_getMonthAbbr(eventDate.month)} ${eventDate.day}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Color _getEventColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      return const Color(0xFFFFE5E5);
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      return const Color(0xFFE5E5FF);
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
      return const Color(0xFFE5F5FF);
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      return const Color(0xFFE5F0FF);
    } else {
      return FColors.primaryBackground;
    }
  }

  Color _getEventIconColor(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('waste') || lowerTitle.contains('pollution')) {
      return const Color(0xFFFF6B6B);
    } else if (lowerTitle.contains('conference') || lowerTitle.contains('international')) {
      return const Color(0xFF6B6BFF);
    } else if (lowerTitle.contains('leadership') || lowerTitle.contains('women')) {
      return const Color(0xFF9B6BFF);
    } else if (lowerTitle.contains('kids') || lowerTitle.contains('parents')) {
      return const Color(0xFF6B9BFF);
    } else {
      return FColors.primary;
    }
  }

  Widget _buildEventIcon(String title, {double size = 48}) {
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
      size: size,
      color: iconColor,
    );
  }

  Color _getStatusColor() {
    if (event.hasEnded) return FColors.darkGrey;
    if (event.isRegistrationClosed) return FColors.warning;
    if (event.isFullyBooked) return FColors.error;
    if (event.isRegistrationOpen) return FColors.success;
    return FColors.darkGrey;
  }

  IconData _getStatusIcon() {
    if (event.hasEnded) return Iconsax.close_circle;
    if (event.isRegistrationClosed) return Iconsax.lock;
    if (event.isFullyBooked) return Iconsax.user_remove;
    if (event.isRegistrationOpen) return Iconsax.tick_circle;
    return Iconsax.info_circle;
  }

  String _getStatusText() {
    if (event.hasEnded) return 'Ended';
    if (event.isRegistrationClosed) return 'Closed';
    if (event.isFullyBooked) return 'Full';
    if (event.isRegistrationOpen) return 'Open';
    return 'Inactive';
  }
}