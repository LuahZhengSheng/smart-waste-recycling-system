import 'package:flutter/material.dart';
import 'package:fyp/features/event/screens/event_detail/widgets/event_detail_card.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';

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
      appBar: AppBar(
        backgroundColor: dark ? FColors.dark : FColors.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Event Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // Share button (optional)
          IconButton(
            icon: Icon(
              Iconsax.share,
              color: dark ? FColors.white : FColors.textPrimary,
            ),
            onPressed: () => _shareEvent(event),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Obx(() => EventDetailsWidget(
          event: event,
          showRegisterButton: true,
          onRegister: () => _showRegistrationConfirmation(context, controller),
          isRegistering: controller.isRegistering.value,
        )),
      ),
    );
  }

  /// Show registration confirmation dialog
  void _showRegistrationConfirmation(BuildContext context, EventController controller) {
    final dark = FHelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dark ? FColors.darkContainer : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: FColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.calendar_tick,
                    size: 40,
                    color: FColors.primary,
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwItems),

                // Title
                Text(
                  'Confirm Registration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.white : FColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: FSizes.sm),

                // Description
                Text(
                  'Are you sure you want to register for this event?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: FSizes.md),

                // Event Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FSizes.md),
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.dark.withOpacity(0.5)
                        : FColors.primaryBackground,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FSizes.xs),
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            size: FSizes.iconSm,
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                          const SizedBox(width: FSizes.xs),
                          Expanded(
                            child: Text(
                              event.formattedStartDateTime,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: dark ? FColors.darkGrey : FColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.xs / 2),
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            size: FSizes.iconSm,
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                          const SizedBox(width: FSizes.xs),
                          Expanded(
                            child: Text(
                              event.location.shortAddress,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: dark ? FColors.darkGrey : FColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: FSizes.spaceBtwItems),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: dark ? FColors.darkGrey : FColors.borderPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: FSizes.md),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await controller.registerForEvent(event);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FColors.primary,
                          foregroundColor: FColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Share event (mock implementation)
  void _shareEvent(Event event) {
    // Mock implementation - replace with actual sharing functionality
    FLoaders.customToast(
      message: 'Event shared successfully!',
    );
  }
}