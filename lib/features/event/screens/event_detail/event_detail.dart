import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_enums.dart';
import '../../models/event_model.dart';
import '../../utils/event_utils.dart';
import '../common_event_widgets/common_event_widgets.dart';
import 'widgets/reminder_toggle_button.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
    this.isCancelled = false,
    this.isFromMyEvents = false,
  });

  final Event event;
  final bool isCancelled;
  final bool isFromMyEvents;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      body: StreamBuilder<Event>(
        stream: controller.getEventStream(event.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: FColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final currentEvent = snapshot.data ?? event;

          return CustomScrollView(
            slivers: [
              // 🆕 Modern App Bar with Image
              _buildSliverAppBar(currentEvent, dark),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🆕 Title & Status Section
                    _TitleSection(
                      event: currentEvent,
                      isCancelled: isCancelled,
                      isFromMyEvents: isFromMyEvents,
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // 🆕 Date & Time Cards
                    _DateTimeSection(event: currentEvent),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // 🆕 Quick Info Cards
                    _QuickInfoCards(event: currentEvent),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // 🆕 Location Section
                    _LocationSection(event: currentEvent),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // 🆕 Contact Section
                    _ContactSection(event: currentEvent),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // 🆕 Description Section
                    _DescriptionSection(event: currentEvent),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Registration Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.defaultSpace),
                      child: _RegistrationSection(
                        event: currentEvent,
                        isFromMyEvents: isFromMyEvents,
                        isCancelled: isCancelled,
                      ),
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🆕 Modern Sliver App Bar
  Widget _buildSliverAppBar(Event event, bool dark) {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: dark ? FColors.dark : FColors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: dark
                ? FColors.dark.withOpacity(0.8)
                : FColors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: dark ? FColors.white : FColors.black,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Event Poster
            event.poster.isNotEmpty
                ? Image.network(
                    event.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),

            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (dark ? FColors.dark : FColors.white).withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Status Badge
            Positioned(
              top: 35,
              right: 16,
              child: _StatusBadge(
                event: event,
                isCancelled: isCancelled,
                isFromMyEvents: isFromMyEvents,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: FColors.primary.withOpacity(0.1),
      child: const Icon(
        Iconsax.calendar,
        size: 80,
        color: FColors.primary,
      ),
    );
  }
}

// ==================== 🆕 Title Section ====================
class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.event,
    required this.isCancelled,
    required this.isFromMyEvents,
  });

  final Event event;
  final bool isCancelled;
  final bool isFromMyEvents;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        border: Border(
          bottom: BorderSide(
            color: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            event.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  decoration: isCancelled || event.isCancelledByOrganizer
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: FColors.error,
                  decorationThickness: 2,
                ),
          ),

          const SizedBox(height: 12),

          // Participants Progress
          EventProgressWidget(event: event),
        ],
      ),
    );
  }
}

// ==================== 🆕 Date & Time Section ====================
class _DateTimeSection extends StatelessWidget {
  const _DateTimeSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Event Schedule', icon: Iconsax.calendar_1),
          const SizedBox(height: 12),

          // Date Cards Row
          Row(
            children: [
              // Start Date
              Expanded(
                child: _DateCard(
                  label: 'Starts',
                  date: event.startDateTime,
                  icon: Iconsax.play_circle,
                  color: FColors.success,
                ),
              ),
              const SizedBox(width: 12),

              // End Date
              Expanded(
                child: _DateCard(
                  label: 'Ends',
                  date: event.endDateTime,
                  icon: Iconsax.stop_circle,
                  color: FColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Registration Deadline
          _DateCard(
            label: 'Registration Deadline',
            date: event.registrationDeadline,
            icon: Iconsax.timer_1,
            color: FColors.warning,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Date Card Widget ====================
class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  final String label;
  final DateTime date;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon & Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date
          Text(
            EventUtils.formatDate(date),
            style: TextStyle(
              color: dark ? FColors.white : FColors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Time
          Text(
            EventUtils.formatTime(date),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Quick Info Cards ====================
class _QuickInfoCards extends StatelessWidget {
  const _QuickInfoCards({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Row(
        children: [
          // Capacity
          Expanded(
            child: _InfoCard(
              icon: Iconsax.people,
              label: 'Capacity',
              value: '${event.registeredCount}/${event.maxParticipants}',
              color: FColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          // Status
          Expanded(
            child: _InfoCard(
              icon: Iconsax.status,
              label: 'Status',
              value: event.isRegistrationOpen
                  ? 'Open'
                  : (event.isFullyBooked ? 'Full' : 'Closed'),
              color: event.isRegistrationOpen
                  ? FColors.success
                  : (event.isFullyBooked ? FColors.error : FColors.darkGrey),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Info Card Widget ====================
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? FColors.darkGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: dark ? FColors.white : FColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Location Section ====================
class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Location', icon: Iconsax.location),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark
                    ? FColors.darkGrey.withOpacity(0.3)
                    : FColors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue Name
                Row(
                  children: [
                    Icon(
                      Iconsax.building,
                      color: FColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        event.location.venueName.isNotEmpty
                            ? event.location.venueName
                            : 'Event Venue',
                        style: TextStyle(
                          color: dark ? FColors.white : FColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Full Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.map_1,
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        event.location.fullAddress,
                        style: TextStyle(
                          color: dark ? FColors.darkText : FColors.textPrimary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Open Map Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(context, event.location),
                    icon: const Icon(Iconsax.map, size: 18),
                    label: const Text('Open in Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      foregroundColor: FColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🆕 Open Map with Confirmation
  Future<void> _openMap(BuildContext context, dynamic location) async {
    // Show confirmation dialog
    final confirmed = await FLoaders.showMapConfirmationDialog(
      venueName: location.venueName,
      address: location.fullAddress,
    );

    if (confirmed != true) return;

    // Open map
    final lat = location.latitude;
    final lng = location.longitude;
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open maps',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open maps: $e',
      );
    }
  }
}

// ==================== 🆕 Contact Section ====================
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Contact Information', icon: Iconsax.call),
          const SizedBox(height: 12),

          // Email
          if (event.contactEmail.isNotEmpty)
            _ContactCard(
              icon: Iconsax.sms,
              label: 'Email',
              value: event.contactEmail,
              onTap: () => _launchEmail(event.contactEmail),
              onCopy: () =>
                  _copyToClipboard(context, event.contactEmail, 'Email'),
            ),

          if (event.contactEmail.isNotEmpty && event.contactPhoneNo.isNotEmpty)
            const SizedBox(height: 12),

          // Phone
          if (event.contactPhoneNo.isNotEmpty)
            _ContactCard(
              icon: Iconsax.call,
              label: 'Phone',
              value: event.contactPhoneNo,
              onTap: () => _launchPhone(event.contactPhoneNo),
              onCopy: () => _copyToClipboard(
                  context, event.contactPhoneNo, 'Phone number'),
            ),
        ],
      ),
    );
  }

  /// Launch Email
  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open email app',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open email: $e',
      );
    }
  }

  /// Launch Phone
  Future<void> _launchPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open phone app',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open phone: $e',
      );
    }
  }

  /// Copy to Clipboard
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    FLoaders.successSnackBar(
      title: 'Copied',
      message: '$label copied to clipboard',
    );
  }
}

// ==================== 🆕 Contact Card ====================
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? FColors.darkGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Icon(icon, color: FColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: TextStyle(
              color: dark ? FColors.white : FColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: Icon(
                    label == 'Email'
                        ? Iconsax.direct_send
                        : Iconsax.call_calling,
                    size: 16,
                  ),
                  label: Text(label == 'Email' ? 'Send Email' : 'Call Now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FColors.primary,
                    side: const BorderSide(color: FColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Copy Button
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Iconsax.copy, size: 16),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: dark ? FColors.white : FColors.black,
                  side: BorderSide(
                    color: dark ? FColors.darkGrey : FColors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Description Section ====================
class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'About Event', icon: Iconsax.document_text),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark
                    ? FColors.darkGrey.withOpacity(0.3)
                    : FColors.grey.withOpacity(0.2),
              ),
            ),
            child: Text(
              event.description.isNotEmpty
                  ? event.description
                  : 'No description available',
              style: TextStyle(
                color: dark ? FColors.darkText : FColors.textPrimary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Registration Section ====================
class _RegistrationSection extends StatelessWidget {
  const _RegistrationSection({
    required this.event,
    required this.isFromMyEvents,
    required this.isCancelled,
  });

  final Event event;
  final bool isFromMyEvents;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();

    return StreamBuilder<bool>(
      stream: controller.isUserRegistered(event.eventId),
      builder: (context, snapshot) {
        final isRegistered = snapshot.data ?? false;

        // 🆕 确定当前状态
        final attendanceStatus = _getAttendanceStatus();
        final showReminder = isFromMyEvents &&
            isRegistered &&
            attendanceStatus == AttendanceStatus.upcoming;

        return Column(
          children: [
            // 🆕 Reminder Toggle - 只有 Upcoming events 才显示
            if (showReminder) ...[
              // 🆕 获取 registrationId 并传递给 ReminderToggleButton
              FutureBuilder<String?>(
                future: controller.getRegistrationId(event.eventId),
                builder: (context, regSnapshot) {
                  if (!regSnapshot.hasData || regSnapshot.data == null || regSnapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ReminderToggleButton(
                    registrationId: regSnapshot.data!,
                    eventTitle: event.title,
                    eventStartDateTime: event.startDateTime,
                  );
                },
              ),
              const SizedBox(height: FSizes.md),
            ],

            // Registration Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: EventUtils.canRegister(event, isRegistered) &&
                    !controller.isRegistering.value
                    ? () => _handleRegistration(
                    context, controller, isRegistered)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  EventUtils.getButtonColor(event, isRegistered),
                  foregroundColor: FColors.white,
                  disabledBackgroundColor: FColors.buttonDisabled,
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
                    Icon(
                      EventUtils.getButtonIcon(event, isRegistered),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
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

  /// 获取 Attendance Status
  AttendanceStatus _getAttendanceStatus() {
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

// ==================== 🆕 Status Badge ====================
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.event,
    required this.isCancelled,
    required this.isFromMyEvents,
  });

  final Event event;
  final bool isCancelled;
  final bool isFromMyEvents;

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isFromMyEvents) {
      // 🆕 从 My Events 进来 - 使用 AttendanceStatus
      final status = EventUtils.getEventStatus(event, isCancelled);
      statusText = status.displayName;
      statusColor = EventUtils.getAttendanceStatusColor(status);
      statusIcon = EventUtils.getAttendanceStatusIcon(status);
    } else {
      // 🆕 从 Event Screen 进来 - 使用 RegistrationStatus
      RegistrationStatus registrationStatus;

      if (event.isFullyBooked) {
        registrationStatus = RegistrationStatus.full;
      } else if (event.isRegistrationClosed) {
        registrationStatus = RegistrationStatus.closed;
      } else {
        registrationStatus = RegistrationStatus.open;
      }

      statusText = registrationStatus.displayName;
      statusColor = registrationStatus.color;
      statusIcon = registrationStatus.icon;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: FColors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: const TextStyle(
              color: FColors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 🆕 Section Title ====================
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: FColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: FColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: dark ? FColors.white : FColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
