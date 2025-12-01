import 'package:flutter/material.dart';
import 'package:fyp/features/personalization/controllers/notification_controller.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();

    // 【关键修复】延迟标记为已读，让用户先看到 "New" 标签
    final NotificationModel notification = Get.arguments as NotificationModel;
    if (!notification.isRead) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final controller = Get.find<NotificationController>();
          controller.markAsRead(notification.notificationId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationModel initialNotification = Get.arguments as NotificationModel;
    final controller = Get.find<NotificationController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Notification Details'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: dark ? FColors.darkSurface : FColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Iconsax.trash,
                color: FColors.error,
                size: 20,
              ),
              onPressed: () => _showDeleteConfirmation(
                context,
                initialNotification,
                controller,
                dark,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<NotificationModel?>(
        stream: controller.getNotificationStream(initialNotification.notificationId),
        initialData: initialNotification,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: FColors.primary),
            );
          }

          final notification = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(notification, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      _buildMessageCard(notification, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      _buildMetadataCard(notification, controller, dark),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(NotificationModel notification, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: FColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: dark ? FColors.darkText : FColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getTypeLabel(notification.type),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 【显示 "New" 标签】
          if (!notification.isRead)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: FColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(NotificationModel notification, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.message_text,
                  size: 18,
                  color: FColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.darkText : FColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            notification.message,
            style: TextStyle(
              fontSize: 15,
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(
      NotificationModel notification,
      NotificationController controller,
      bool dark,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      decoration: BoxDecoration(
        color: dark ? FColors.darkSurface : FColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.info_circle,
                  size: 18,
                  color: FColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.darkText : FColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          _buildMetadataRow(
            'Received',
            _formatDateTime(notification.createdAt),
            Iconsax.clock,
            dark,
          ),
          const SizedBox(height: FSizes.sm),
          _buildMetadataRow(
            'Status',
            notification.isRead ? 'Read' : 'Unread',
            notification.isRead ? Iconsax.tick_circle : Iconsax.record_circle,
            dark,
          ),
          const SizedBox(height: FSizes.sm),
          _buildMetadataRow(
            'Type',
            _getTypeLabel(notification.type),
            _getTypeIcon(notification.type),
            dark,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon, bool dark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: dark ? FColors.darkText : FColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: dark ? FColors.darkText : FColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark ? FColors.darkText : FColors.textPrimary,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'system':
        return Iconsax.info_circle;
      case 'achievement':
        return Iconsax.medal_star;
      case 'event_updated':
        return Iconsax.timer;
      default:
        return Iconsax.notification;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'system':
        return 'System Notification';
      case 'achievement':
        return 'Achievement';
      case 'event_updated':
        return 'Event Updates';
      case 'community_post':
        return 'Community Post';
      default:
        return 'Notification';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 24) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final hourStr = hour == 0 ? '12' : hour.toString();
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');

      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return 'Today at $hourStr:$minuteStr $period';
    } else if (difference.inDays == 1) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final hourStr = hour == 0 ? '12' : hour.toString();
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return 'Yesterday at $hourStr:$minuteStr $period';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showDeleteConfirmation(
      BuildContext context,
      NotificationModel notification,
      NotificationController controller,
      bool dark,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dark ? FColors.darkSurface : FColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.trash,
                  color: FColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Notification',
                style: TextStyle(
                  color: dark ? FColors.darkText : FColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
            style: TextStyle(
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // 先关闭 dialog，再执行删除，最后回退
                Get.back(); // 关闭 dialog

                try {
                  Get.back();
                  await controller.deleteNotification(notification.notificationId);
                } catch (e) {
                  // 如果删除失败，显示错误
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete notification: $e'),
                        backgroundColor: FColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.error,
                foregroundColor: FColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
