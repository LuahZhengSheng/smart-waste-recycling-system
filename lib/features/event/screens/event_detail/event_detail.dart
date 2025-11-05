import 'package:flutter/material.dart';
import 'package:fyp/features/event/models/event_enums.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../../utils/formatters/formatter.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import '../../utils/event_utils.dart';
import '../common_event_widgets/common_event_widgets.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: Text("Details"),
        backgroundColor: dark ? FColors.dark : FColors.white,
      ),
      body: StreamBuilder<Event>(
        stream: controller.getEventStream(event.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: FColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final currentEvent = snapshot.data ?? event;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Poster with Lightbox
                _EventPosterSection(event: currentEvent),

                // Event Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: FSizes.defaultSpace),

                      // Event Title & Status
                      _EventTitleSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Quick Info Cards
                      _QuickInfoSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Date & Time Details
                      SectionTitleWidget(title: 'Schedule', icon: Iconsax.calendar),
                      const SizedBox(height: FSizes.md),
                      _DateTimeSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Location Details
                      SectionTitleWidget(title: 'Location', icon: Iconsax.location),
                      const SizedBox(height: FSizes.md),
                      _LocationSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Contact Details
                      SectionTitleWidget(title: 'Contact Information', icon: Iconsax.call),
                      const SizedBox(height: FSizes.md),
                      _ContactSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Description
                      SectionTitleWidget(title: 'About Event', icon: Iconsax.document_text),
                      const SizedBox(height: FSizes.md),
                      _DescriptionSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Registration Section
                      _RegistrationSection(event: currentEvent),

                      const SizedBox(height: FSizes.spaceBtwSections),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== Event Poster Section ====================
class _EventPosterSection extends StatelessWidget {
  const _EventPosterSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();

    return Obx(() {
      final posterUrl = controller.eventPosterUrls[event.eventId];
      final isLoading = controller.isLoadingPoster[event.eventId] ?? false;

      return GestureDetector(
        onTap: () => EventUtils.showPosterLightbox(context, event, posterUrl),
        child: Container(
          height: 240,
          width: double.infinity,
          margin: const EdgeInsets.all(FSizes.defaultSpace),
          decoration: BoxDecoration(
            color: EventUtils.getEventColor(event.title),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: EventUtils.getEventColor(event.title).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Poster Image or Default
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(color: FColors.primary),
                  )
                else if (posterUrl != null && posterUrl.isNotEmpty)
                  Image.network(
                    posterUrl,
                    width: double.infinity,
                    height: double.infinity,
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
                      return _buildDefaultPoster();
                    },
                  )
                else
                  _buildDefaultPoster(),

                // Status badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: EventUtils.getStatusColor(
                        EventUtils.getEventStatus(event, false),
                      ).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: EventUtils.getStatusColor(
                            EventUtils.getEventStatus(event, false),
                          ).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          EventUtils.getStatusIcon(
                            EventUtils.getEventStatus(event, false),
                          ),
                          color: FColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          EventUtils.getEventStatus(event, false).displayName,
                          style: const TextStyle(
                            color: FColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tap hint
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.maximize_4,
                            color: FColors.white.withOpacity(0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              color: FColors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDefaultPoster() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EventUtils.getEventColor(event.title),
            EventUtils.getEventColor(event.title).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: EventUtils.buildEventIcon(event.title, size: 56),
        ),
      ),
    );
  }
}

// ==================== Event Title Section ====================
class _EventTitleSection extends StatelessWidget {
  const _EventTitleSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? FColors.darkText : FColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Row(
          children: [
            Icon(
              Iconsax.calendar_1,
              size: 16,
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              event.timeUntilStart,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== Quick Info Section ====================
class _QuickInfoSection extends StatelessWidget {
  const _QuickInfoSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InfoCardWidget(
            icon: Iconsax.people,
            label: 'Participants',
            value: '${event.registeredCount}/${event.maxParticipants}',
            progressWidget: LinearProgressIndicator(
              value: event.registrationProgress,
              backgroundColor: FHelperFunctions.isDarkMode(context)
                  ? FColors.darkGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                event.isFullyBooked ? FColors.error : FColors.primary,
              ),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: InfoCardWidget(
            icon: Iconsax.clock,
            label: 'Duration',
            value: '${event.durationInHours.toStringAsFixed(1)}h',
          ),
        ),
      ],
    );
  }
}

// ==================== Date & Time Section ====================
class _DateTimeSection extends StatelessWidget {
  const _DateTimeSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md * 1.5),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDateTimeRow(
            context,
            icon: Iconsax.calendar_2,
            label: 'Start',
            date: FFormatter.formatDate(event.startDateTime),
            time: EventUtils.formatTime(event.startDateTime),
            iconColor: FColors.success,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: FSizes.md),
            child: Divider(
              height: 1,
              color: dark ? FColors.darkDivider : FColors.grey.withOpacity(0.2),
            ),
          ),
          _buildDateTimeRow(
            context,
            icon: Iconsax.calendar_tick,
            label: 'End',
            date: FFormatter.formatDate(event.endDateTime),
            time: EventUtils.formatTime(event.endDateTime),
            iconColor: FColors.error,
          ),
          if (!event.isRegistrationClosed) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FSizes.md),
              child: Divider(
                height: 1,
                color: dark ? FColors.darkDivider : FColors.grey.withOpacity(0.2),
              ),
            ),
            _buildDateTimeRow(
              context,
              icon: Iconsax.timer,
              label: 'Registration Deadline',
              date: FFormatter.formatDate(event.registrationDeadline),
              time: EventUtils.formatTime(event.registrationDeadline),
              iconColor: FColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String date,
        required String time,
        required Color iconColor,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.darkText : FColors.textPrimary,
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== Location Section ====================
class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.location, color: FColors.primary, size: 20),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.location.address.area.isNotEmpty
                      ? event.location.address.area
                      : 'Event Location',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.darkText : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.location.fullAddress,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMapConfirmation(context),
            icon: const Icon(Iconsax.direct, color: FColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showMapConfirmation(BuildContext context) {
    FLoaders.showMapNavigationDialog(
      onConfirm: () => EventUtils.openInGoogleMaps(event.location.geoPoint),
    );
  }
}

// ==================== Contact Section ====================
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildContactRow(
            context,
            icon: Iconsax.sms,
            label: 'Email',
            value: event.contactEmail,
            onTap: () => EventUtils.launchEmail(event.contactEmail),
          ),
          if (event.contactPhoneNo.isNotEmpty) ...[
            const SizedBox(height: FSizes.md),
            _buildContactRow(
              context,
              icon: Iconsax.call,
              label: 'Phone',
              value: event.contactPhoneNo,
              onTap: () => EventUtils.launchPhone(event.contactPhoneNo),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required VoidCallback onTap,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: FColors.primary, size: 16),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? FColors.darkText : FColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Description Section ====================
class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.md * 1.5),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.2),
        ),
      ),
      child: Text(
        event.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

// ==================== Registration Section ====================
class _RegistrationSection extends StatelessWidget {
  const _RegistrationSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return StreamBuilder<bool>(
      stream: controller.isUserRegistered(event.eventId),
      builder: (context, snapshot) {
        final isRegistered = snapshot.data ?? false;

        return Column(
          children: [
            // Reminder Toggle (only show if registered)
            if (isRegistered) ...[
              _ReminderToggle(event: event),
              const SizedBox(height: FSizes.md),
            ],

            // Registration Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: EventUtils.canRegister(event, isRegistered) &&
                    !controller.isRegistering.value
                    ? () => _handleRegistration(context, controller, isRegistered)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EventUtils.getButtonColor(event, isRegistered),
                  foregroundColor: FColors.white,
                  disabledBackgroundColor:
                  dark ? FColors.darkGrey : FColors.buttonDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isRegistered ? 0 : 2,
                  shadowColor: FColors.primary.withOpacity(0.3),
                ),
                child: controller.isRegistering.value
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: FColors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(EventUtils.getButtonIcon(event, isRegistered),
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      EventUtils.getButtonText(event, isRegistered),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  void _handleRegistration(
      BuildContext context, EventController controller, bool isRegistered) {
    if (isRegistered) {
      FLoaders.showCancellationDialog(
        onConfirm: () async => await controller.cancelRegistration(event),
      );
    } else {
      FLoaders.showRegistrationDialog(
        eventTitle: event.title,
        onConfirm: () async => await controller.registerForEvent(event),
      );
    }
  }
}

// ==================== Reminder Toggle ====================
class _ReminderToggle extends StatelessWidget {
  const _ReminderToggle({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(() {
      final hasReminder = controller.eventReminders[event.eventId] ?? false;

      return Container(
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: hasReminder
              ? FColors.primary.withOpacity(0.1)
              : (dark ? FColors.darkContainer : FColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasReminder
                ? FColors.primary.withOpacity(0.3)
                : (dark ? FColors.borderDark : FColors.borderPrimary.withOpacity(0.2)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasReminder
                    ? FColors.primary.withOpacity(0.2)
                    : FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasReminder ? Iconsax.notification5 : Iconsax.notification,
                color: FColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Reminder',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: dark ? FColors.darkText : FColors.textPrimary,
                    ),
                  ),
                  Text(
                    hasReminder
                        ? 'You will be notified 1 day before'
                        : 'Get notified before event',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: hasReminder,
              onChanged: (value) => controller.toggleReminder(event.eventId, value),
              activeColor: FColors.primary,
            ),
          ],
        ),
      );
    });
  }
}