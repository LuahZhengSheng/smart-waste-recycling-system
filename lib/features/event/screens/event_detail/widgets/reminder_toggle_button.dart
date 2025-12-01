import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/services/event/event_reminder_service.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/popups/loaders.dart';

class ReminderToggleButton extends StatelessWidget {
  final String registrationId;
  final String eventTitle;
  final DateTime eventStartDateTime;

  const ReminderToggleButton({
    super.key,
    required this.registrationId,
    required this.eventTitle,
    required this.eventStartDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final ReminderService reminderService = Get.put(ReminderService());

    return StreamBuilder<bool>(
      stream: reminderService.reminderStatusStream(registrationId),
      builder: (context, snapshot) {
        // 🆕 处理加载状态
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final isEnabled = snapshot.data ?? true; // Default to enabled

        return Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Get.isDarkMode
                  ? FColors.darkGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.2),
            ),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: const Text(
              'Event Reminders',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              isEnabled
                  ? 'You will receive 3 reminders before the event'
                  : 'Reminders are disabled',
              style: TextStyle(
                fontSize: 13,
                color: Get.isDarkMode ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            value: isEnabled,
            activeColor: FColors.primary,
            onChanged: (value) async {
              try {
                // 🆕 显示 loading
                FLoaders.customToast(message: 'Updating reminders...');

                await reminderService.toggleReminders(
                  registrationId: registrationId,
                  eventTitle: eventTitle,
                  eventStartDateTime: eventStartDateTime,
                );

                // 🆕 显示成功消息
                FLoaders.successSnackBar(
                  title: value ? 'Reminders Enabled' : 'Reminders Disabled',
                  message: value
                      ? 'You will receive 3 notifications before the event:\n• 1 day before\n• 1 hour before\n• 15 minutes before'
                      : 'Event reminders have been disabled.',
                );
              } catch (e) {
                print('❌ Error toggling reminders: $e');
                FLoaders.errorSnackBar(
                  title: 'Error',
                  message: 'Failed to toggle reminders: $e',
                );
              }
            },
          ),
        );
      },
    );
  }
}
