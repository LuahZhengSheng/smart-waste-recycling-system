import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/notification_controller.dart';
import 'package:fyp/features/personalization/screens/notification/notification.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:get/get.dart';

class NotificationIcon extends StatelessWidget {
  final double? size;
  final VoidCallback? onTap;

  const NotificationIcon({
    super.key,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<NotificationController>(
      init: NotificationController(),
      builder: (controller) {
        return Obx(() {
          final unreadCount = controller.unreadCount;

          return GestureDetector(
            onTap: onTap ?? () => Get.to(NotificationScreen()),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: size,
                    color: FColors.accent, // Changed to cyan color
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: FColors.error,
                          borderRadius: BorderRadius.circular(8),
                          // Removed white border
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: FColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// Alternative notification icon for app bars
class AppBarNotificationIcon extends StatelessWidget {
  const AppBarNotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      init: NotificationController(),
      builder: (controller) {
        return Obx(() {
          final unreadCount = controller.unreadCount;

          return IconButton(
            onPressed: () => Get.toNamed('/notifications'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, color: FColors.accent), // Changed to cyan
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: FColors.error,
                        borderRadius: BorderRadius.circular(6),
                        // Removed white border
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: FColors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}