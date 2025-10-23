import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/my_event_controller.dart';
import '../../../models/event_enums.dart';
import '../../../models/event_model.dart';
import '../../../utils/event_utils.dart';

class MyEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool showCancelButton;
  final bool isCancelled;

  const MyEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.showCancelButton = false,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    final controller = MyEventsController.instance;
    final status = EventUtils.getEventStatus(event, isCancelled);

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
                color: EventUtils.getEventColor(event.title),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    EventUtils.getEventColor(event.title),
                    EventUtils.getEventColor(event.title).withOpacity(0.7),
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
                      child: EventUtils.buildEventIcon(event.title, size: 64),
                    ),
                  ),

                  // Status Badge (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: EventUtils.getStatusColor(status).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: EventUtils.getStatusColor(status).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            EventUtils.getStatusIcon(status),
                            size: 12,
                            color: FColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status.displayName,
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

                  // Date Badge (Top Right)
                  Positioned(
                    top: 12,
                    right: 12,
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
                            color: EventUtils.getEventIconColor(event.title),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            EventUtils.formatEventDate(event.startDateTime),
                            style: TextStyle(
                              color: EventUtils.getEventIconColor(event.title),
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
                      color: isCancelled
                          ? (dark ? FColors.darkGrey : FColors.textSecondary)
                          : (dark ? FColors.white : FColors.textPrimary),
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                      decorationColor: FColors.error,
                      decorationThickness: 2,
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
                          '${EventUtils.formatTime(event.startDateTime)} - ${EventUtils.formatTime(event.endDateTime)}',
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

                  // Cancel Button - Show for upcoming events in All and Upcoming tabs
                  if (showCancelButton && !isCancelled && status == AttendanceStatus.upcoming) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.cancelRegistration(event.eventId),
                        icon: controller.isLoading.value
                            ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: FColors.white,
                          ),
                        )
                            : Icon(
                          Iconsax.close_circle,
                          size: FSizes.iconSm,
                        ),
                        label: Text(
                          controller.isLoading.value
                              ? 'Cancelling...'
                              : 'Cancel Registration',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FColors.error,
                          foregroundColor: FColors.white,
                          disabledBackgroundColor: FColors.error.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}