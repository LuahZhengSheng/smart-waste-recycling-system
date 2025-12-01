import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/event_model.dart';
import '../../../models/event_enums.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../utils/event_utils.dart';
import '../../common_event_widgets/common_event_widgets.dart';

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

    // 🆕 确定 Registration Status
    final RegistrationStatus status = _getRegistrationStatus();

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
            // Event Header with Image/Icon
            EventHeaderWidget(
              event: event,
              showStatusBadge: true,
              showDateBadge: true,
              registrationStatus: status, // 🆕 传入状态
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
                      color: dark ? FColors.darkText : FColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Time
                  EventInfoRow(
                    icon: Iconsax.info_circle,
                    text: event.description,
                  ),

                  // Location
                  EventInfoRow(
                    icon: Iconsax.location,
                    text: event.location.venueName.isNotEmpty
                        ? event.location.venueName
                        : 'Event Location Not Set',
                  ),

                  const SizedBox(height: 12),

                  // Participants Progress
                  EventProgressWidget(event: event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🆕 确定 Registration Status
  RegistrationStatus _getRegistrationStatus() {
    // 1. 如果 registration deadline 已过 → Closed
    if (event.isRegistrationClosed) {
      return RegistrationStatus.closed;
    }

    // 2. 如果已满 → Full
    if (event.isFullyBooked) {
      return RegistrationStatus.full;
    }

    // 3. 其他情况 → Open
    return RegistrationStatus.open;
  }
}
