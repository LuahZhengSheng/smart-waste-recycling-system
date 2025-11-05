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
import '../../common_event_widgets/common_event_widgets.dart';

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
            color: dark
                ? FColors.borderDark
                : FColors.borderPrimary.withOpacity(0.2),
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
            // Event Header
            EventHeaderWidget(
              event: event,
              showStatusBadge: true,
              showDateBadge: true,
              isCancelled: isCancelled,
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
                          ? (dark
                          ? FColors.darkGrey
                          : FColors.textSecondary)
                          : (dark ? FColors.darkText : FColors.textPrimary),
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: FColors.error,
                      decorationThickness: 2,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Time
                  EventInfoRow(
                    icon: Iconsax.clock,
                    text:
                    '${EventUtils.formatTime(event.startDateTime)} - ${EventUtils.formatTime(event.endDateTime)}',
                  ),

                  // Location
                  EventInfoRow(
                    icon: Iconsax.location,
                    text: event.location.shortAddress.isNotEmpty
                        ? event.location.shortAddress
                        : 'Event Location',
                  ),

                  const SizedBox(height: 12),

                  // Participants Progress
                  EventProgressWidget(event: event),

                  // Cancel Button
                  if (showCancelButton &&
                      !isCancelled &&
                      status == AttendanceStatus.upcoming) ...[
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
                          disabledBackgroundColor:
                          FColors.error.withOpacity(0.6),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
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