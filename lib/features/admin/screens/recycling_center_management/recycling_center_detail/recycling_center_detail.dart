import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../../personalization/models/recycle_activity_model.dart';
import '../../../../recycling_center/models/recycling_center_staff_model.dart';
import '../../../controllers/recycling_center_management/recycling_center_detail_controller.dart';

class RecyclingCenterDetailsScreen extends StatelessWidget {
  final String centerId;

  const RecyclingCenterDetailsScreen({super.key, required this.centerId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        RecyclingCenterDetailsController(centerId: centerId));
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors
          .adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors
            .adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Obx(() =>
            Text(
              controller.center.value?.name ?? 'Center Details',
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontWeight: FontWeight.w600,
              ),
            )),
        actions: [
          IconButton(
            onPressed: controller.editCenter,
            icon: Icon(
              Iconsax.edit,
              color: dark ? FColors.adminDarkTextSecondary : FColors
                  .adminLightTextSecondary,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.center.value == null) {
          return const Center(child: Text('Center not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center Overview Card
              _buildCenterOverviewCard(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Statistics Row
              _buildStatisticsRow(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Staff Section
              _buildStaffSection(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Recent Activities Section
              _buildRecentActivitiesSection(controller, dark),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCenterOverviewCard(RecyclingCenterDetailsController controller,
      bool dark) {
    final center = controller.center.value!;

    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with image and basic info
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
              image: DecorationImage(
                image: NetworkImage(center.image),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(FSizes.cardRadiusLg),
                      topRight: Radius.circular(FSizes.cardRadiusLg),
                    ),
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
                // Image enlarge button
                Positioned(
                  top: FSizes.md,
                  right: FSizes.md,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    ),
                    child: IconButton(
                      onPressed: controller.showCenterImage,
                      icon: const Icon(Iconsax.maximize_4, color: Colors.white),
                    ),
                  ),
                ),
                // Center name and status
                Positioned(
                  bottom: FSizes.md,
                  left: FSizes.md,
                  right: FSizes.md,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              center.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: FSizes.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.sm,
                                vertical: FSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: controller.getCenterStatusColor(dark),
                                borderRadius: BorderRadius.circular(
                                    FSizes.cardRadiusXs),
                              ),
                              child: Text(
                                controller.centerStatusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details content
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Information
                _buildInfoSection(
                  'Contact Information',
                  [
                    _buildInfoRow(Iconsax.sms, 'Email', center.email, dark),
                    _buildInfoRow(
                        Iconsax.call, 'Phone', center.formattedPhoneNo, dark),
                    _buildInfoRow(
                        Iconsax.global, 'Website', center.website, dark,
                        isUrl: true),
                  ],
                  dark,
                ),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Location Information
                _buildInfoSection(
                  'Location',
                  [
                    _buildInfoRow(Iconsax.location, 'Address',
                        center.centerLocation.fullAddress, dark),
                    _buildInfoRow(Iconsax.map_1, 'Coordinates',
                        center.centerLocation.coordinates, dark),
                  ],
                  dark,
                ),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Operating Hours
                _buildOperatingHoursSection(controller, dark),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Additional Details
                _buildInfoSection(
                  'Additional Details',
                  [
                    _buildInfoRow(Iconsax.people, 'Total Staff',
                        center.numberOfStaff.toString(), dark),
                    _buildInfoRow(Iconsax.calendar_1, 'Created Date',
                        center.formattedCreatedAt, dark),
                    _buildInfoRow(
                        // Iconsax.clock, 'Age', '${center.ageInDays} days', dark),
                        Iconsax.clock, 'Age', 'center.ageInDays days', dark),
                  ],
                  dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool dark,
      {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkPrimary : FColors
                  .adminLightPrimary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            ),
            child: Icon(
              icon,
              size: 18,
              color: dark ? FColors.adminDarkPrimary : FColors
                  .adminLightPrimary,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextMuted : FColors
                        .adminLightTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors
                        .adminLightTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: isUrl ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHoursSection(
      RecyclingCenterDetailsController controller, bool dark) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Group consecutive days with same hours
    List<Map<String, dynamic>> groupedHours = _groupOperatingHours(controller, days, dayNames);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating Hours',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: Column(
            children: List.generate(groupedHours.length, (index) {
              final group = groupedHours[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == groupedHours.length - 1 ? 0 : FSizes.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        group['displayDays'],
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      flex: 2,
                      child: Text(
                        group['hours'],
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

// Helper function to group consecutive days with same operating hours
  List<Map<String, dynamic>> _groupOperatingHours(
      RecyclingCenterDetailsController controller,
      List<String> days,
      List<String> dayNames) {

    List<Map<String, dynamic>> groups = [];
    int startIndex = 0;

    while (startIndex < days.length) {
      String currentHours = controller.formatOperatingHours(days[startIndex]);
      int endIndex = startIndex;

      // Find consecutive days with same hours
      while (endIndex + 1 < days.length &&
          controller.formatOperatingHours(days[endIndex + 1]) == currentHours) {
        endIndex++;
      }

      // Create display string for days
      String displayDays;
      if (startIndex == endIndex) {
        // Single day
        displayDays = dayNames[startIndex];
      } else if (endIndex - startIndex == 1) {
        // Two consecutive days
        displayDays = '${dayNames[startIndex]}, ${dayNames[endIndex]}';
      } else {
        // Range of days
        displayDays = '${dayNames[startIndex]} - ${dayNames[endIndex]}';
      }

      groups.add({
        'displayDays': displayDays,
        'hours': currentHours,
        'startIndex': startIndex,
        'endIndex': endIndex,
      });

      startIndex = endIndex + 1;
    }

    return groups;
  }

  Widget _buildStatisticsRow(RecyclingCenterDetailsController controller,
      bool dark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today',
            controller.totalActivitiesToday,
            'Activities',
            Iconsax.calendar_tick,
            dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            'This Week',
            controller.totalActivitiesThisWeek,
            'Activities',
            Iconsax.chart_1,
            dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildStatCard(
            'Total Weight',
            controller.totalWeightProcessed,
            'Processed',
            Iconsax.weight,
            dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
            dark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle,
      IconData icon, Color color, bool dark) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                title,
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextMuted : FColors
                      .adminLightTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors
                  .adminLightTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection(RecyclingCenterDetailsController controller,
      bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff Members',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkText : FColors
                        .adminLightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md, vertical: FSizes.sm),
                  decoration: BoxDecoration(
                    color: (dark ? FColors.adminDarkPrimary : FColors
                        .adminLightPrimary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                  ),
                  child: Text(
                    '${controller.allStaff.length} Staff',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkPrimary : FColors
                          .adminLightPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.allStaff.length,
            separatorBuilder: (context, index) =>
                Divider(
                  color: (dark ? FColors.adminDarkDivider : FColors
                      .adminLightDivider).withOpacity(0.5),
                  height: 1,
                ),
            itemBuilder: (context, index) {
              final staff = controller.allStaff[index];
              final activityCount = controller.staffActivityCounts[staff
                  .userId] ?? 0;

              return _buildStaffTile(staff, activityCount, dark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTile(RecyclingCenterStaff staff, int activityCount,
      bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.lg, vertical: FSizes.md),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (dark ? FColors.adminDarkBorder : FColors
                    .adminLightBorder).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                staff.profileImg ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      color: dark ? FColors.adminDarkSurfaceVariant : FColors
                          .adminLightSurfaceVariant,
                      child: Icon(
                        Iconsax.user,
                        color: dark ? FColors.adminDarkTextMuted : FColors
                            .adminLightTextMuted,
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),

          // Staff Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.username,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors
                              .adminLightText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (staff.role == 'supervisor')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm, vertical: FSizes.xs),
                        decoration: BoxDecoration(
                          color: (dark ? FColors.adminDarkWarning : FColors
                              .adminLightWarning).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              FSizes.cardRadiusXs),
                        ),
                        child: Text(
                          'Supervisor',
                          style: TextStyle(
                            color: dark ? FColors.adminDarkWarning : FColors
                                .adminLightWarning,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  staff.email,
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextMuted : FColors
                        .adminLightTextMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Iconsax.activity,
                      size: 14,
                      color: dark ? FColors.adminDarkSuccess : FColors
                          .adminLightSuccess,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      '$activityCount activities handled',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkSuccess : FColors
                            .adminLightSuccess,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: staff.isActive
                  ? (dark ? FColors.adminDarkSuccess : FColors
                  .adminLightSuccess)
                  : (dark ? FColors.adminDarkTextMuted : FColors
                  .adminLightTextMuted),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection(
      RecyclingCenterDetailsController controller, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Padding(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkText : FColors
                            .adminLightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md, vertical: FSizes.sm),
                      decoration: BoxDecoration(
                        color: (dark ? FColors.adminDarkInfo : FColors
                            .adminLightInfo).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            FSizes.cardRadiusSm),
                      ),
                      child: Obx(() =>
                          Text(
                            '${controller.filteredActivities
                                .length} Activities',
                            style: TextStyle(
                              color: dark ? FColors.adminDarkInfo : FColors
                                  .adminLightInfo,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.md),

                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStaffFilterDropdown(controller, dark),
                    ),
                    const SizedBox(width: FSizes.md),
                    _buildSortDropdown(controller, dark),
                  ],
                ),
              ],
            ),
          ),

          // Activities List
          Obx(() =>
          controller.filteredActivities.isEmpty
              ? Container(
            padding: const EdgeInsets.all(FSizes.xl),
            child: Column(
              children: [
                Icon(
                  Iconsax.activity,
                  size: 48,
                  color: dark ? FColors.adminDarkTextMuted : FColors
                      .adminLightTextMuted,
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'No activities found',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextMuted : FColors
                        .adminLightTextMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredActivities.length,
            separatorBuilder: (context, index) =>
                Divider(
                  color: (dark ? FColors.adminDarkDivider : FColors
                      .adminLightDivider).withOpacity(0.5),
                  height: 1,
                ),
            itemBuilder: (context, index) {
              final activity = controller.filteredActivities[index];
              final staff = controller.getStaffById(activity.centerStaffId);
              final user = controller.getUserById(activity.userId);

              return _buildActivityTile(activity, staff, user, dark);
            },
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffFilterDropdown(RecyclingCenterDetailsController controller,
      bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors
            .adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Obx(() =>
          DropdownButton<String>(
            value: controller.selectedStaffFilter.value,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) => controller.changeStaffFilter(value!),
            dropdownColor: dark ? FColors.adminDarkSurface : FColors
                .adminLightSurface,
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
            items: [
              DropdownMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Iconsax.people,
                      size: 16,
                      color: dark ? FColors.adminDarkTextSecondary : FColors
                          .adminLightTextSecondary,
                    ),
                    const SizedBox(width: FSizes.sm),
                    const Text('All Staff'),
                  ],
                ),
              ),
              ...controller.allStaff.map((staff) =>
                  DropdownMenuItem(
                    value: staff.userId,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle),
                          child: ClipOval(
                            child: Image.network(
                              staff.profileImg ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Iconsax.user,
                                    size: 14,
                                    color: dark
                                        ? FColors.adminDarkTextMuted
                                        : FColors.adminLightTextMuted,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(child: Text(staff.username)),
                      ],
                    ),
                  )),
            ],
          )),
    );
  }

  Widget _buildSortDropdown(RecyclingCenterDetailsController controller,
      bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors
            .adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Obx(() =>
          DropdownButton<String>(
            value: controller.sortBy.value,
            underline: const SizedBox(),
            onChanged: (value) => controller.changeSorting(value!),
            dropdownColor: dark ? FColors.adminDarkSurface : FColors
                .adminLightSurface,
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
            items: [
              DropdownMenuItem(
                value: 'newest',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: dark ? FColors.adminDarkTextSecondary : FColors
                          .adminLightTextSecondary,
                    ),
                    const SizedBox(width: FSizes.sm),
                    const Text('Newest'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'oldest',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.arrow_up_1,
                      size: 16,
                      color: dark ? FColors.adminDarkTextSecondary : FColors
                          .adminLightTextSecondary,
                    ),
                    const SizedBox(width: FSizes.sm),
                    const Text('Oldest'),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildActivityTile(RecyclingActivity activity,
      RecyclingCenterStaff? staff, UserModel? user, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: (dark ? FColors.adminDarkBorder : FColors
                    .adminLightBorder).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              child: Image.network(
                activity.supportImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      color: dark ? FColors.adminDarkSurfaceVariant : FColors
                          .adminLightSurfaceVariant,
                      child: Icon(
                        Iconsax.image,
                        color: dark ? FColors.adminDarkTextMuted : FColors
                            .adminLightTextMuted,
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),

          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.wasteObject,
                        style: TextStyle(
                          color: dark ? FColors.adminDarkText : FColors
                              .adminLightText,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildActivityStatusChip(activity.status, dark),
                  ],
                ),
                const SizedBox(height: FSizes.xs),

                Row(
                  children: [
                    Icon(
                      Iconsax.weight,
                      size: 14,
                      color: dark ? FColors.adminDarkTextMuted : FColors
                          .adminLightTextMuted,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      activity.formattedWeight,
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextSecondary : FColors
                            .adminLightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Icon(
                      Iconsax.medal_star,
                      size: 14,
                      color: dark ? FColors.adminDarkWarning : FColors
                          .adminLightWarning,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      '${activity.pointsEarned} points',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkWarning : FColors
                            .adminLightWarning,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),

                // User and Staff Info
                Row(
                  children: [
                    // User Info
                    Expanded(
                      child: _buildPersonInfo(
                        'User',
                        user?.username ?? 'Unknown User',
                        user?.profileImg,
                        user?.rewardPoint.toString(),
                        Iconsax.medal_star,
                        dark,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    // Staff Info
                    Expanded(
                      child: _buildPersonInfo(
                        'Handled by',
                        staff?.username ?? 'Unknown Staff',
                        staff?.profileImg,
                        staff?.role,
                        Iconsax.user_tag,
                        dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),

                // Timestamp
                Row(
                  children: [
                    Icon(
                      Iconsax.clock,
                      size: 14,
                      color: dark ? FColors.adminDarkTextMuted : FColors
                          .adminLightTextMuted,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      _formatRelativeTime(activity.createdAt),
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextMuted : FColors
                            .adminLightTextMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfo(String label, String name, String? imageUrl,
      String? extraInfo, IconData extraIcon, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: dark ? FColors.adminDarkTextMuted : FColors
                .adminLightTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (dark ? FColors.adminDarkBorder : FColors
                      .adminLightBorder).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(
                        Iconsax.user,
                        size: 14,
                        color: dark ? FColors.adminDarkTextMuted : FColors
                            .adminLightTextMuted,
                      ),
                )
                    : Icon(
                  Iconsax.user,
                  size: 14,
                  color: dark ? FColors.adminDarkTextMuted : FColors
                      .adminLightTextMuted,
                ),
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: dark ? FColors.adminDarkTextSecondary : FColors
                          .adminLightTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (extraInfo != null)
                    Row(
                      children: [
                        Icon(
                          extraIcon,
                          size: 10,
                          color: dark ? FColors.adminDarkTextMuted : FColors
                              .adminLightTextMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          extraInfo,
                          style: TextStyle(
                            color: dark ? FColors.adminDarkTextMuted : FColors
                                .adminLightTextMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityStatusChip(String status, bool dark) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor =
        dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Completed';
        break;
      case 'approved':
        backgroundColor = dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        displayText = 'Approved';
        break;
      case 'pending':
        backgroundColor =
        dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        displayText = 'Pending';
        break;
      case 'rejected':
        backgroundColor =
        dark ? FColors.adminDarkError : FColors.adminLightError;
        displayText = 'Rejected';
        break;
      default:
        backgroundColor =
        dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}