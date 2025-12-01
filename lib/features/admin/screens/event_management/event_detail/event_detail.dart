import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../common/widgets/admin/badge.dart';
import '../../../../event/models/event_model.dart';
import '../../../controllers/event_management/event_detail_controller.dart';

class AdminEventDetailScreen extends StatelessWidget {
  final String eventId;

  const AdminEventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminEventDetailController());
    final dark = FHelperFunctions.isDarkMode(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadEventDetails(eventId);
    });

    return Scaffold(
      backgroundColor:
          dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor:
            dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Event Details',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() {
            final event = controller.event.value;
            final computedStatus = event.computedStatus;

            return Row(
              children: [
                // Edit button - not for ongoing/completed
                if (computedStatus == 'upcoming')
                  IconButton(
                    onPressed: () => controller.editEvent(),
                    icon: Icon(
                      Iconsax.edit,
                      color: dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                    ),
                    tooltip: 'Edit Event',
                  ),
                // Cancel button - only for upcoming
                if (computedStatus == 'upcoming' && event.status != 'cancelled')
                  IconButton(
                    onPressed: () => controller.cancelEvent(event),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: dark
                          ? FColors.adminDarkError
                          : FColors.adminLightError,
                    ),
                    tooltip: 'Cancel Event',
                  ),
                // Delete button - only for completed/cancelled
                if ((computedStatus == 'completed' ||
                        event.status == 'cancelled') &&
                    event.status != 'deleted')
                  IconButton(
                    onPressed: () => controller.deleteEvent(),
                    icon: Icon(
                      Iconsax.trash,
                      color: dark
                          ? FColors.adminDarkError
                          : FColors.adminLightError,
                    ),
                    tooltip: 'Delete Event',
                  ),
                const SizedBox(width: FSizes.sm),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color:
                  dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
          );
        }

        final event = controller.event.value;
        if (event.eventId.isEmpty) {
          return const Center(child: Text('Event not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventPoster(event, dark),
              const SizedBox(height: FSizes.spaceBtwSections),
              _buildEventInfo(event, dark),
              const SizedBox(height: FSizes.spaceBtwSections),
              _buildContactInfo(event, dark),
              const SizedBox(height: FSizes.spaceBtwSections),
              _buildRegistrationSection(controller, dark),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEventPoster(Event event, bool dark) {
    print('event detail poster: ${event.poster}');
    if (event.poster.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: dark
              ? FColors.adminDarkSurfaceVariant
              : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Center(
          child: Icon(
            Iconsax.image,
            size: 80,
            color:
                dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.dialog(
          ImageLightbox(
            imageUrl: event.poster,
            title: event.title,
          ),
        );
      },
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          image: DecorationImage(
            image: NetworkImage(event.poster),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: FSizes.md,
              right: FSizes.md,
              child: Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.maximize_1,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo(event, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color:
                    dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Event Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          _buildInfoRow('Event ID', event.eventId, dark, selectable: true),
          _buildInfoRow('Title', event.title, dark),
          _buildInfoRow('Description', event.description, dark),
          Padding(
            padding: const EdgeInsets.only(bottom: FSizes.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                ),
                _buildStatusBadge(event.computedStatus, dark),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Capacity',
                  '${event.registeredCount}/${event.maxParticipants}',
                  Iconsax.people,
                  dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildMetricCard(
                  'Fill Rate',
                  '${(event.registrationProgress * 100).toInt()}%',
                  Iconsax.percentage_circle,
                  dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: _buildMetricCard(
                  'Published',
                  event.isPublish ? 'Yes' : 'No',
                  event.isPublish ? Iconsax.eye : Iconsax.eye_slash,
                  event.isPublish
                      ? (dark
                          ? FColors.adminDarkSuccess
                          : FColors.adminLightSuccess)
                      : (dark
                          ? FColors.adminDarkTextMuted
                          : FColors.adminLightTextMuted),
                  dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(event, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.call,
                color: dark
                    ? FColors.adminDarkSecondary
                    : FColors.adminLightSecondary,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Contact & Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          _buildInfoRow('Email', event.contactEmail, dark),
          _buildInfoRow('Phone', event.contactPhoneNo, dark),
          _buildInfoRow('Address', event.location.fullAddress, dark),
          _buildInfoRow(
            'Start Date',
            FHelperFunctions.getFormattedDate(event.startDateTime,
                format: 'dd MMM yyyy, HH:mm'),
            dark,
          ),
          _buildInfoRow(
            'End Date',
            FHelperFunctions.getFormattedDate(event.endDateTime,
                format: 'dd MMM yyyy, HH:mm'),
            dark,
          ),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Registration Deadline',
                  FHelperFunctions.getFormattedDate(event.registrationDeadline,
                      format: 'dd MMM yyyy, HH:mm'),
                  dark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.sm, vertical: FSizes.xs),
                decoration: BoxDecoration(
                  color: (dark
                          ? FColors.adminDarkError
                          : FColors.adminLightError)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                ),
                child: Text(
                  event.daysUntilDeadlineText,
                  style: TextStyle(
                    color: event.daysUntilDeadlineText == 'Closed'
                        ? (dark
                            ? FColors.adminDarkError
                            : FColors.adminLightError)
                        : (dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          _buildInfoRow('Duration',
              '${event.durationInHours.toStringAsFixed(1)} hours', dark),
          _buildInfoRow(
            'Created At',
            FHelperFunctions.getFormattedDate(event.createdAt),
            dark,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(
      AdminEventDetailController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistics
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                controller.totalRegistrations.value.toString(),
                Iconsax.people,
                dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                dark,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: _buildStatCard(
                'Active',
                controller.activeRegistrations.value.toString(),
                Iconsax.user_tick,
                dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                dark,
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: _buildStatCard(
                'Cancelled',
                controller.cancelledRegistrations.value.toString(),
                Iconsax.user_minus,
                dark ? FColors.adminDarkError : FColors.adminLightError,
                dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.lg),

        // Registration List
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.user_octagon,
                        color: dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Text(
                        'Event Registrations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Filter
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md, vertical: FSizes.sm),
                        decoration: BoxDecoration(
                          color: dark
                              ? FColors.adminDarkSurfaceVariant
                              : FColors.adminLightSurfaceVariant,
                          borderRadius:
                              BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                        child: Obx(() => DropdownButton<String>(
                              value: controller.filterBy.value,
                              onChanged: (value) =>
                                  controller.setFilterBy(value!),
                              underline: const SizedBox(),
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('All')),
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'cancelled',
                                    child: Text('Cancelled')),
                              ],
                              style: TextStyle(
                                color: dark
                                    ? FColors.adminDarkText
                                    : FColors.adminLightText,
                                fontSize: 14,
                              ),
                              dropdownColor: dark
                                  ? FColors.adminDarkSurface
                                  : FColors.adminLightSurface,
                            )),
                      ),
                      const SizedBox(width: FSizes.sm),
                      // Sort
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md, vertical: FSizes.sm),
                        decoration: BoxDecoration(
                          color: dark
                              ? FColors.adminDarkSurfaceVariant
                              : FColors.adminLightSurfaceVariant,
                          borderRadius:
                              BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                        child: Obx(() => DropdownButton<String>(
                              value: controller.sortBy.value,
                              onChanged: (value) =>
                                  controller.setSortBy(value!),
                              underline: const SizedBox(),
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'newest',
                                    child: Text('Newest First')),
                                DropdownMenuItem(
                                    value: 'oldest',
                                    child: Text('Oldest First')),
                                DropdownMenuItem(
                                    value: 'name', child: Text('By Name')),
                              ],
                              style: TextStyle(
                                color: dark
                                    ? FColors.adminDarkText
                                    : FColors.adminLightText,
                                fontSize: 14,
                              ),
                              dropdownColor: dark
                                  ? FColors.adminDarkSurface
                                  : FColors.adminLightSurface,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: FSizes.lg),
              Obx(() {
                if (controller.filteredRegistrations.isEmpty) {
                  return _buildEmptyState(dark);
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredRegistrations.length,
                  separatorBuilder: (context, index) => Divider(
                    color: dark
                        ? FColors.adminDarkDivider
                        : FColors.adminLightDivider,
                  ),
                  itemBuilder: (context, index) {
                    final regWithUser = controller.filteredRegistrations[index];
                    return _buildRegistrationCard(
                        regWithUser, controller, dark);
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark,
      {bool selectable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
          ),
          Expanded(
            child: selectable
                ? SelectableText(
                    value,
                    style: TextStyle(
                      color: dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                    ),
                    maxLines: 2,
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: FSizes.xs),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return SizedBox(
      height: 200, // 或者 300，看你列表区域高度
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.user_minus,
              size: 64,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No registrations found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool dark) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'upcoming':
        color = dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        icon = Iconsax.calendar_1;
        label = 'Upcoming';
        break;
      case 'ongoing':
        color = dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        icon = Iconsax.activity;
        label = 'Ongoing';
        break;
      case 'completed':
        color = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        icon = Iconsax.tick_circle;
        label = 'Completed';
        break;
      case 'cancelled':
        color = dark ? FColors.adminDarkError : FColors.adminLightError;
        icon = Iconsax.close_circle;
        label = 'Cancelled';
        break;
      default:
        color = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        icon = Iconsax.slash;
        label = status;
        break;
    }

    return CommonBadge(
      icon: icon,
      color: color,
      text: label,
      iconSize: 14,
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      borderRadius: FSizes.cardRadiusMd,
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      borderColor: color.withOpacity(0.3),
    );
  }

  Widget _buildRegistrationCard(
      regWithUser, AdminEventDetailController controller, bool dark) {
    final registration = regWithUser.registration;
    final user = regWithUser.user;

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
            dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            backgroundImage:
            user.profileImg != null && user.profileImg!.isNotEmpty
                ? NetworkImage(user.profileImg!)
                : null,
            child: user.profileImg == null || user.profileImg!.isEmpty
                ? Text(
              user.username.isNotEmpty
                  ? user.username[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 只保留username
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark
                        ? FColors.adminDarkText
                        : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  user.email,
                  style: TextStyle(
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                if (user.phoneNo != null)
                  Text(
                    user.phoneNo!,
                    style: TextStyle(
                      color: dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: FSizes.md),
          // 右侧从上到下：StatusChip, Registered, Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 状态chip现在在最上面
              _buildStatusChip(registration, controller, dark),
              const SizedBox(height: FSizes.xs),
              Text(
                'Registered',
                style: TextStyle(
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                controller.getTimeAgo(registration.createdAt),
                style: TextStyle(
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      registration, AdminEventDetailController controller, bool dark) {
    final color = controller.getRegistrationStatusColor(registration, dark);
    final text = controller.getRegistrationStatusText(registration);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
