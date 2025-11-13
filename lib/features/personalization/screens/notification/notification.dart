import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/notification_controller.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.dark : FColors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: dark ? FColors.textWhite : FColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: dark ? FColors.textWhite : FColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.unreadCount > 0
              ? TextButton(
            onPressed: controller.markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: FColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
              : const SizedBox.shrink()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: dark ? FColors.dark : FColors.white,
            child: TabBar(
              controller: controller.tabController,
              indicatorColor: FColors.primary,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: FColors.primary,
              unselectedLabelColor: dark ? FColors.textSecondary : FColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('All'),
                      if (controller.allNotifications.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.allNotifications.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: FColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unread'),
                      if (controller.unreadNotifications.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.unreadNotifications.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: FColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Read'),
                      if (controller.readNotifications.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.readNotifications.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: FColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(FColors.primary),
            ),
          );
        }

        return TabBarView(
          controller: controller.tabController,
          children: [
            Obx(() => _NotificationsList(
              notifications: controller.allNotifications.toList(),
              controller: controller,
              dark: dark,
            )),
            Obx(() => _NotificationsList(
              notifications: controller.unreadNotifications,
              controller: controller,
              dark: dark,
            )),
            Obx(() => _NotificationsList(
              notifications: controller.readNotifications,
              controller: controller,
              dark: dark,
            )),
          ],
        );
      }),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final NotificationController controller;
  final bool dark;

  const _NotificationsList({
    required this.notifications,
    required this.controller,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: dark ? FColors.darkGrey : FColors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: dark ? FColors.textSecondary : FColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: FColors.primary,
      onRefresh: controller.refreshNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: dark ? FColors.darkGrey.withOpacity(0.2) : FColors.borderPrimary,
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationTile(
            notification: notification,
            controller: controller,
            dark: dark,
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final NotificationController controller;
  final bool dark;

  const _NotificationTile({
    required this.notification,
    required this.controller,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.viewNotificationDetails(notification),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: notification.isRead
            ? Colors.transparent
            : dark
            ? FColors.accent.withOpacity(0.2)
            : FColors.accent.withOpacity(0.15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar or Icon
            _buildAvatar(),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: dark ? FColors.textWhite : FColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.getTimeAgo(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: dark ? FColors.textSecondary : FColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.type == 'file_share') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? FColors.lightContainer.withOpacity(0.1)
                            : FColors.lightContainer,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: dark
                              ? FColors.borderPrimary.withOpacity(0.2)
                              : FColors.borderPrimary,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description,
                            size: 14,
                            color: FColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Demo File.pdf 2.2 MB',
                            style: TextStyle(
                              fontSize: 11,
                              color: dark ? FColors.textSecondary : FColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Unread indicator and menu
            Column(
              children: [
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: FColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                  color: dark ? FColors.lightContainer : FColors.white,
                  itemBuilder: (context) => [
                    if (!notification.isRead)
                      PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              size: 16,
                              color: dark ? FColors.textWhite : FColors.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mark as read',
                              style: TextStyle(
                                color: dark ? FColors.textWhite : FColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: FColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: FColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_read':
                        controller.markAsRead(notification.notificationId);
                        break;
                      case 'delete':
                        controller.deleteNotification(notification.notificationId);
                        break;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getAvatarColor(),
        shape: BoxShape.circle,
      ),
      child: notification.type == 'system'
          ? Icon(
        Icons.info_outline,
        color: FColors.white,
        size: 20,
      )
          : Center(
        child: Text(
          notification.title.split(' ').map((word) => word[0]).take(2).join().toUpperCase(),
          style: const TextStyle(
            color: FColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    switch (notification.type) {
      case 'system':
        return FColors.primary;
      case 'request':
        return FColors.secondary;
      case 'comment':
        return FColors.accent;
      case 'file_share':
        return FColors.lightGreen;
      default:
        return FColors.darkGrey;
    }
  }
}