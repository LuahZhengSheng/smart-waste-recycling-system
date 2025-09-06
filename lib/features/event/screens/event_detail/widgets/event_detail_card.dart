import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatter.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/event_model.dart';

class EventDetailsWidget extends StatelessWidget {
  const EventDetailsWidget({
    super.key,
    required this.event,
    this.showRegisterButton = true,
    this.onRegister,
    this.isRegistering = false,
  });

  final Event event;
  final bool showRegisterButton;
  final VoidCallback? onRegister;
  final bool isRegistering;

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image/Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getEventColor(event.title),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            ),
            child: Stack(
              children: [
                // Background pattern or image placeholder
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getEventColor(event.title),
                        _getEventColor(event.title).withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Event icon
                Center(
                  child: _buildEventIcon(event.title),
                ),

                // Status badge
                Positioned(
                  top: FSizes.md,
                  right: FSizes.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.9),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    child: Text(
                      event.statusText,
                      style: const TextStyle(
                        color: FColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Event Title
          Text(
            event.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          ),

          const SizedBox(height: FSizes.spaceBtwItems),

          // Event Details Cards
          _buildDetailCard(
            context,
            icon: Iconsax.calendar,
            title: FFormatter.formatDate(event.startDateTime),
            subtitle: '${_formatTime(event.startDateTime)} - ${_formatTime(event.endDateTime)}',
          ),

          const SizedBox(height: FSizes.md),

          _buildDetailCard(
            context,
            icon: Iconsax.location,
            title: event.location.address.area.isNotEmpty
                ? event.location.address.area
                : 'Gala Convention Center',
            subtitle: event.location.shortAddress.isNotEmpty
                ? event.location.shortAddress
                : 'Penang, Malaysia',
            hasAction: true,
            actionText: 'Directions',
          ),

          const SizedBox(height: FSizes.md),

          _buildDetailCard(
            context,
            icon: Iconsax.clock,
            title: 'Registration Period',
            subtitle: 'Until ${FFormatter.formatDate(event.registrationDeadline)}',
          ),

          const SizedBox(height: FSizes.md),

          _buildDetailCard(
            context,
            icon: Iconsax.people,
            title: 'Max Participants',
            subtitle: '${event.registeredCount}/${event.maxParticipants} registered',
            child: Column(
              children: [
                const SizedBox(height: FSizes.sm),
                LinearProgressIndicator(
                  value: event.registrationProgress,
                  backgroundColor: dark
                      ? FColors.darkGrey.withOpacity(0.3)
                      : FColors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    event.isFullyBooked ? FColors.error : FColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
              ],
            ),
          ),

          const SizedBox(height: FSizes.md),

          _buildDetailCard(
            context,
            icon: Iconsax.sms,
            title: 'Contact Email',
            subtitle: event.contactEmail,
          ),

          const SizedBox(height: FSizes.spaceBtwSections),

          // Event Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              border: Border.all(
                color: dark ? FColors.darkGrey : FColors.borderPrimary,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About this event',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          if (showRegisterButton) ...[
            const SizedBox(height: FSizes.spaceBtwSections),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canRegister() ? onRegister : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(),
                  foregroundColor: FColors.white,
                  disabledBackgroundColor: dark
                      ? FColors.darkGrey
                      : FColors.buttonDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: isRegistering
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: FColors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  _getButtonText(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: FSizes.spaceBtwSections),
        ],
      ),
    );
  }

  /// Build detail card widget
  Widget _buildDetailCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        bool hasAction = false,
        String actionText = '',
        Widget? child,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.darkGrey : FColors.borderPrimary,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Icon(
              icon,
              color: FColors.primary,
              size: FSizes.iconMd,
            ),
          ),

          const SizedBox(width: FSizes.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                ),
                if (child != null) child,
              ],
            ),
          ),

          // Action button
          if (hasAction)
            TextButton(
              onPressed: () {},
              child: Text(
                actionText,
                style: const TextStyle(
                  color: FColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Format time to 12-hour format
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')}$period';
  }

  /// Get event color based on title keywords
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
      size: 48,
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

  /// Get button color
  Color _getButtonColor() {
    // Mock: Check if user is already registered
    final isUserRegistered = false; // Replace with actual check

    if (isUserRegistered) return FColors.success;
    return FColors.primary;
  }

  /// Get button text
  String _getButtonText() {
    // Mock: Check if user is already registered
    final isUserRegistered = false; // Replace with actual check

    if (isUserRegistered) return 'Registered';
    if (event.hasEnded) return 'Event Ended';
    if (event.isRegistrationClosed) return 'Registration Closed';
    if (event.isFullyBooked) return 'Event Full';
    return 'Register';
  }

  /// Check if user can register
  bool _canRegister() {
    // Mock: Check if user is already registered
    final isUserRegistered = false; // Replace with actual check

    return !isUserRegistered &&
        event.isRegistrationOpen &&
        !event.isFullyBooked &&
        !isRegistering;
  }
}