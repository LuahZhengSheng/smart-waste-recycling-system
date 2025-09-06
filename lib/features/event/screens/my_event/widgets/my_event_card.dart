import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/my_event_controller.dart';
import '../../../models/event_model.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.xs), // Reduced margin since we're using divider
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        // Removed border and boxShadow for cleaner look
      ),
      child: Column(
        children: [
          // Main card content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              child: Padding(
                padding: const EdgeInsets.all(FSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with status and date
                    Row(
                      children: [
                        // Status badge with enhanced design
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor().withOpacity(0.2),
                                _getStatusColor().withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                            border: Border.all(
                              color: _getStatusColor().withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                size: 10,
                                color: _getStatusColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        // Date badge with gradient
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FColors.primary,
                                FColors.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 10,
                                color: FColors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                FHelperFunctions.getFormattedDate(
                                  event.startDateTime,
                                  format: 'dd MMM',
                                ),
                                style: const TextStyle(
                                  color: FColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: FSizes.md),

                    // Event title with enhanced styling
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isCancelled
                            ? (dark ? FColors.darkGrey : FColors.textSecondary)
                            : (dark ? FColors.white : FColors.textPrimary),
                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                        decorationColor: FColors.error,
                        decorationThickness: 2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: FSizes.xs),

                    // Event description
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: FSizes.md),

                    // Event details in enhanced cards
                    Row(
                      children: [
                        // Time card with gradient background
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(FSizes.sm),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FColors.info.withOpacity(0.08),
                                  FColors.info.withOpacity(0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                              border: Border.all(
                                color: FColors.info.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: FColors.info.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Iconsax.clock,
                                    size: FSizes.iconSm,
                                    color: FColors.info,
                                  ),
                                ),
                                const SizedBox(width: FSizes.xs),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time',
                                        style: TextStyle(
                                          color: FColors.info.withOpacity(0.8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${FHelperFunctions.getFormattedDate(event.startDateTime, format: 'HH:mm')} - ${FHelperFunctions.getFormattedDate(event.endDateTime, format: 'HH:mm')}',
                                        style: TextStyle(
                                          color: dark ? FColors.white : FColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: FSizes.sm),

                        // Participants card with gradient background
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(FSizes.sm),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FColors.accent.withOpacity(0.08),
                                  FColors.accent.withOpacity(0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                              border: Border.all(
                                color: FColors.accent.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: FColors.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Iconsax.people,
                                    size: FSizes.iconSm,
                                    color: FColors.accent,
                                  ),
                                ),
                                const SizedBox(width: FSizes.xs),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Participants',
                                        style: TextStyle(
                                          color: FColors.accent.withOpacity(0.8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${event.registeredCount}/${event.maxParticipants}',
                                        style: TextStyle(
                                          color: dark ? FColors.white : FColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Cancel button section for upcoming events
                    if (showCancelButton && !isCancelled) ...[
                      const SizedBox(height: FSizes.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(() => controller.isLoading.value
                              ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.md,
                              vertical: FSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FColors.error.withOpacity(0.1),
                                  FColors.error.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: FColors.error,
                                  ),
                                ),
                                const SizedBox(width: FSizes.xs),
                                Text(
                                  'Cancelling...',
                                  style: TextStyle(
                                    color: FColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.cancelRegistration(event.eventId),
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: FSizes.md,
                                  vertical: FSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FColors.error.withOpacity(0.1),
                                      FColors.error.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                                  border: Border.all(
                                    color: FColors.error.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.close_circle,
                                      size: FSizes.iconSm,
                                      color: FColors.error,
                                    ),
                                    const SizedBox(width: FSizes.xs),
                                    Text(
                                      'Cancel Registration',
                                      style: TextStyle(
                                        color: FColors.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Bottom border divider
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: (dark ? FColors.darkGrey : FColors.borderPrimary).withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color based on event state
  Color _getStatusColor() {
    if (isCancelled) return FColors.error;
    if (event.hasEnded) return FColors.success;
    if (event.hasStarted && !event.hasEnded) return FColors.warning;
    return FColors.info;
  }

  /// Get status icon based on event state
  IconData _getStatusIcon() {
    if (isCancelled) return Iconsax.close_circle;
    if (event.hasEnded) return Iconsax.tick_circle;
    if (event.hasStarted && !event.hasEnded) return Iconsax.clock;
    return Iconsax.calendar_tick;
  }

  /// Get status text based on event state
  String _getStatusText() {
    if (isCancelled) return 'CANCELLED';
    if (event.hasEnded) return 'COMPLETED';
    if (event.hasStarted && !event.hasEnded) return 'ONGOING';
    return 'UPCOMING';
  }
}