import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../event/models/event_registration_model.dart';
import '../../../controllers/event_management/event_detail_controller.dart';

class AdminEventDetailsScreen extends StatelessWidget {
  final String eventId;

  const AdminEventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminEventDetailsController());
    final dark = FHelperFunctions.isDarkMode(context);

    // Load event details when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadEventDetails(eventId);
    });

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(controller, dark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventInfoCards(controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    _buildRegistrationSection(controller, dark),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(AdminEventDetailsController controller, bool dark) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      elevation: 0,
      leading: IconButton(
        onPressed: controller.goBack,
        icon: Container(
          padding: const EdgeInsets.all(FSizes.xs),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.arrow_left_2, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
          ),
          child: Text(
            controller.event.value.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            controller.event.value.poster.isNotEmpty
                ? GestureDetector(
              onTap: controller.toggleImageExpansion,
              child: Image.network(
                controller.event.value.poster,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                  child: Icon(
                    Iconsax.image,
                    size: 80,
                    color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  ),
                ),
              ),
            )
                : Container(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              child: Icon(
                Iconsax.image,
                size: 80,
                color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            if (controller.event.value.poster.isNotEmpty)
              Positioned(
                top: 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: controller.toggleImageExpansion,
                    child: const Icon(
                      Iconsax.maximize_1,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfoCards(AdminEventDetailsController controller, bool dark) {
    return Column(
      children: [
        // Main Info Card
        _buildInfoCard(
          dark: dark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    size: 24,
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
              _buildEventDescription(controller.event.value.description, dark),
              const SizedBox(height: FSizes.md),
              _buildEventMetrics(controller, dark),
            ],
          ),
        ),

        const SizedBox(height: FSizes.md),

        // Contact & Details Card
        _buildInfoCard(
          dark: dark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.call,
                    color: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                    size: 24,
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
              _buildContactAndScheduleInfo(controller, dark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required bool dark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEventDescription(String description, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Text(
        description,
        style: TextStyle(
          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildEventMetrics(AdminEventDetailsController controller, bool dark) {
    final event = controller.event.value;

    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            icon: Iconsax.people,
            label: 'Capacity',
            value: '${event.registeredCount}/${event.maxParticipants}',
            color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            dark: dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildMetricItem(
            icon: Iconsax.percentage_circle,
            label: 'Fill Rate',
            value: '${(event.registrationProgress * 100).toInt()}%',
            color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
            dark: dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildMetricItem(
            icon: event.isPublish ? Iconsax.eye : Iconsax.eye_slash,
            label: 'Status',
            value: event.isPublish ? 'Published' : 'Draft',
            color: event.isPublish
                ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
            dark: dark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
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
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAndScheduleInfo(AdminEventDetailsController controller, bool dark) {
    final event = controller.event.value;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Iconsax.calendar,
                label: 'Start Date',
                value: FHelperFunctions.getFormattedDate(
                    event.startDateTime,
                    format: 'dd MMM yyyy, HH:mm'
                ),
                dark: dark,
              ),
            ),
            const SizedBox(width: FSizes.lg),
            Expanded(
              child: _buildInfoRow(
                icon: Iconsax.calendar_tick,
                label: 'End Date',
                value: FHelperFunctions.getFormattedDate(
                    event.endDateTime,
                    format: 'dd MMM yyyy, HH:mm'
                ),
                dark: dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Iconsax.clock,
                label: 'Registration Deadline',
                value: FHelperFunctions.getFormattedDate(
                    event.registrationDeadline,
                    format: 'dd MMM yyyy, HH:mm'
                ),
                dark: dark,
              ),
            ),
            const SizedBox(width: FSizes.lg),
            Expanded(
              child: _buildInfoRow(
                icon: Iconsax.timer,
                label: 'Duration',
                value: '${event.durationInHours.toStringAsFixed(1)} hours',
                dark: dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Iconsax.sms,
                label: 'Email',
                value: event.contactEmail,
                dark: dark,
              ),
            ),
            const SizedBox(width: FSizes.lg),
            Expanded(
              child: _buildInfoRow(
                icon: Iconsax.call,
                label: 'Phone',
                value: event.contactPhoneNo,
                dark: dark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool dark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(FSizes.xs),
          decoration: BoxDecoration(
            color: dark ? FColors.adminDarkPrimary.withOpacity(0.1) : FColors.adminLightPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
          ),
          child: Icon(
            icon,
            size: 16,
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
        ),
        const SizedBox(width: FSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationSection(AdminEventDetailsController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Registration Statistics
        _buildRegistrationStats(controller, dark),

        const SizedBox(height: FSizes.lg),

        // Registration List
        _buildInfoCard(
          dark: dark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRegistrationHeader(controller, dark),
              const SizedBox(height: FSizes.lg),
              _buildRegistrationList(controller, dark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationStats(AdminEventDetailsController controller, bool dark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.people,
            title: 'Total Registrations',
            value: controller.totalRegistrations.value.toString(),
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            dark: dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.user_tick,
            title: 'Active',
            value: controller.activeRegistrations.value.toString(),
            color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            dark: dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.user_minus,
            title: 'Cancelled',
            value: controller.cancelledRegistrations.value.toString(),
            color: dark ? FColors.adminDarkError : FColors.adminLightError,
            dark: dark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationHeader(AdminEventDetailsController controller, bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.user_octagon,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              size: 24,
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              'Event Registrations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  width: 0.5,
                ),
              ),
              child: DropdownButton<String>(
                value: controller.filterBy.value,
                onChanged: (value) => controller.setFilterBy(value!),
                underline: const SizedBox(),
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: 14,
                ),
                dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                icon: Icon(
                  Iconsax.arrow_down_1,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: FSizes.sm),

            // Sort Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                border: Border.all(
                  color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  width: 0.5,
                ),
              ),
              child: DropdownButton<String>(
                value: controller.sortBy.value,
                onChanged: (value) => controller.setSortBy(value!),
                underline: const SizedBox(),
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                  DropdownMenuItem(value: 'name', child: Text('By Name')),
                ],
                style: TextStyle(
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  fontSize: 14,
                ),
                dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                icon: Icon(
                  Iconsax.arrow_down_1,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegistrationList(AdminEventDetailsController controller, bool dark) {
    return Obx(() {
      if (controller.filteredRegistrations.isEmpty) {
        return _buildEmptyState(dark);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredRegistrations.length,
        separatorBuilder: (context, index) => Divider(
          color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final regWithUser = controller.filteredRegistrations[index];
          return _buildRegistrationCard(regWithUser, controller, dark);
        },
      );
    });
  }

  Widget _buildEmptyState(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      child: Column(
        children: [
          Icon(
            Iconsax.user_minus,
            size: 64,
            color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'No registrations found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'No registrations match the current filter criteria.',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(
      EventRegistrationWithUser regWithUser,
      AdminEventDetailsController controller,
      bool dark
      ) {
    final registration = regWithUser.registration;
    final user = regWithUser.user;

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: user.profileImg != null && user.profileImg!.isNotEmpty
                  ? Image.network(
                user.profileImg!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(user.username, dark),
              )
                  : _buildDefaultAvatar(user.username, dark),
            ),
          ),

          const SizedBox(width: FSizes.md),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                        ),
                      ),
                    ),
                    _buildStatusChip(registration, controller, dark),
                  ],
                ),
                const SizedBox(height: FSizes.xs),
                Row(
                  children: [
                    Icon(
                      Iconsax.sms,
                      size: 14,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(
                      child: Text(
                        user.email,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (user.phoneNo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: FSizes.xs),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.call,
                          size: 14,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                        const SizedBox(width: FSizes.xs),
                        Text(
                          user.phoneNo!,
                          style: TextStyle(
                            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: FSizes.md),

          // Registration Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Registered',
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                controller.getTimeAgo(registration.createdAt),
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
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

  Widget _buildDefaultAvatar(String name, bool dark) {
    return Container(
      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(
      EventRegistration registration,
      AdminEventDetailsController controller,
      bool dark
      ) {
    final color = controller.getRegistrationStatusColor(registration, dark);
    final text = controller.getRegistrationStatusText(registration);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: FSizes.xs),
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

// Full Screen Image Viewer (optional enhancement)
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
            const Icon(
              Iconsax.image,
              color: Colors.white,
              size: 100,
            ),
          ),
        ),
      ),
    );
  }
}