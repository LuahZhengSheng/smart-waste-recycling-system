import 'package:flutter/material.dart';
import 'package:fyp/features/event/models/event_enums.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event_model.dart';
import '../../utils/event_utils.dart';

/// Reusable Event Header Widget with Poster Background
class EventHeaderWidget extends StatelessWidget {
  final Event event;
  final bool showStatusBadge;
  final bool showDateBadge;
  final bool isCancelled;

  // 🆕 新增参数：指定使用哪种状态系统
  final RegistrationStatus? registrationStatus; // For Events Screen
  final AttendanceStatus? attendanceStatus;     // For My Events Screen

  const EventHeaderWidget({
    super.key,
    required this.event,
    this.showStatusBadge = true,
    this.showDateBadge = true,
    this.isCancelled = false,
    this.registrationStatus,
    this.attendanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    // 确定要显示的状态、颜色和图标
    final statusInfo = _getStatusInfo();

    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 【背景图片 - Poster】
            _buildPosterBackground(),

            // 【渐变遮罩层 - 确保文字可读性】
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),

            // Status Badge
            if (showStatusBadge && statusInfo != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusInfo['color'].withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusInfo['icon'],
                        size: 12,
                        color: FColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusInfo['text'],
                        style: const TextStyle(
                          color: FColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Date Badge
            if (showDateBadge && !_isCancelledByOrganizer())
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 12,
                        color: FColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        EventUtils.formatEventDate(event.startDateTime),
                        style: const TextStyle(
                          color: FColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 【主办方取消时的额外覆盖层】
            if (_isCancelledByOrganizer())
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 【新增】获取状态信息
  Map<String, dynamic>? _getStatusInfo() {
    // 优先级 1: 使用传入的 registrationStatus (Events Screen)
    if (registrationStatus != null) {
      return {
        'text': registrationStatus!.displayName,
        'icon': registrationStatus!.icon,
        'color': registrationStatus!.color,
      };
    }

    // 优先级 2: 使用传入的 attendanceStatus (My Events Screen)
    if (attendanceStatus != null) {
      return {
        'text': attendanceStatus!.displayName,
        'icon': attendanceStatus!.icon,
        'color': attendanceStatus!.color,
      };
    }

    // 优先级 3: 旧逻辑兼容
    if (_isCancelledByOrganizer()) {
      return {
        'text': 'Cancelled by Organizer',
        'icon': Iconsax.close_circle,
        'color': FColors.error,
      };
    }

    if (isCancelled) {
      return {
        'text': 'Cancelled by You',
        'icon': Iconsax.close_square,
        'color': FColors.error,
      };
    }

    return null;
  }

  /// 检查是否主办方取消
  bool _isCancelledByOrganizer() {
    return event.status == 'cancelled' || event.status == 'deleted';
  }

  /// 【构建 Poster 背景】
  Widget _buildPosterBackground() {
    // 如果有 poster URL，显示图片
    if (event.poster.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: event.poster,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildFallbackBackground(),
        errorWidget: (context, url, error) => _buildFallbackBackground(),
      );
    }

    // 没有 poster 时使用 fallback 背景
    return _buildFallbackBackground();
  }

  /// 【Fallback 背景 - 使用原来的颜色 + 图标】
  Widget _buildFallbackBackground() {
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
      child: Stack(
        children: [
          // Event Icon
          Positioned(
            right: 16,
            bottom: 16,
            child: Opacity(
              opacity: 0.3,
              child: EventUtils.buildEventIcon(event.title, size: 64),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Event Info Row Widget
class EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool showDivider;
  final VoidCallback? onTap;

  const EventInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.showDivider = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: FColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: FColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 16,
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: dark
                ? FColors.darkGrey.withOpacity(0.3)
                : FColors.grey.withOpacity(0.3),
          ),
      ],
    );
  }
}

/// Reusable Event Progress Widget
class EventProgressWidget extends StatelessWidget {
  final Event event;

  const EventProgressWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.people,
                  size: 14,
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Participants',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Text(
              '${event.registeredCount}/${event.maxParticipants}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? FColors.white : FColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: event.registrationProgress,
          backgroundColor: dark
              ? FColors.darkGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            event.isFullyBooked ? FColors.error : FColors.primary,
          ),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

/// Reusable Section Title Widget
class SectionTitleWidget extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionTitleWidget({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: FColors.primary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Reusable Info Card Widget
class InfoCardWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? progressWidget;
  final Color? iconColor;

  const InfoCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.progressWidget,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? FColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? FColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
          if (progressWidget != null) ...[
            const SizedBox(height: 8),
            progressWidget!,
          ],
        ],
      ),
    );
  }
}

/// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.defaultSpace * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: FColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: FSizes.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onButtonPressed,
                  icon: const Icon(Iconsax.search_normal, size: FSizes.iconSm),
                  label: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    foregroundColor: FColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: FSizes.md,
                      horizontal: FSizes.xl,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
