import 'package:flutter/material.dart';
import 'package:fyp/features/event/screens/event/widgets/event_card.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/event_controller.dart';
import '../event_detail/event_detail.dart';
import '../my_event/my_event.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: AppBar(
        backgroundColor: dark ? FColors.dark : FColors.light,
        elevation: 0,
        title: Text(
          'Events',
          style: Theme
              .of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
        actions: [
          // My Events Button
          TextButton.icon(
            onPressed: () => Get.to(() => const MyEventsScreen()),
            icon: Icon(
              Iconsax.calendar_1,
              size: FSizes.iconSm,
              color: FColors.primary,
            ),
            label: Text(
              'My Events',
              style: TextStyle(
                color: FColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: FSizes.sm),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: dark ? FColors.darkContainer : FColors.white,
                    borderRadius: BorderRadius.circular(
                        FSizes.inputFieldRadius),
                    border: Border.all(
                      color: dark ? FColors.darkGrey : FColors.borderPrimary,
                    ),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      suffixIcon: Obx(() =>
                      controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          color: dark ? FColors.darkGrey : FColors
                              .textSecondary,
                        ),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.updateSearchQuery('');
                        },
                      )
                          : const SizedBox()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.md,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: FSizes.md),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Status Filter
                      Obx(() =>
                          _buildFilterChip(
                            context,
                            'All',
                            controller.selectedStatus.value == 'All',
                                () => controller.updateStatusFilter('All'),
                          )),
                      const SizedBox(width: FSizes.sm),
                      Obx(() =>
                          _buildFilterChip(
                            context,
                            'Open',
                            controller.selectedStatus.value == 'Open',
                                () => controller.updateStatusFilter('Open'),
                          )),
                      const SizedBox(width: FSizes.sm),
                      Obx(() =>
                          _buildFilterChip(
                            context,
                            'Full',
                            controller.selectedStatus.value == 'Full',
                                () => controller.updateStatusFilter('Full'),
                          )),
                      const SizedBox(width: FSizes.sm),
                      Obx(() =>
                          _buildFilterChip(
                            context,
                            'Closed',
                            controller.selectedStatus.value == 'Closed',
                                () => controller.updateStatusFilter('Closed'),
                          )),
                      const SizedBox(width: FSizes.sm),

                      // Date Filter
                      GestureDetector(
                        onTap: () => _showDatePicker(context, controller),
                        child: Obx(() =>
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.md,
                                vertical: FSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: controller.selectedDate.value != null
                                    ? FColors.primary
                                    : (dark ? FColors.darkContainer : FColors
                                    .white),
                                borderRadius: BorderRadius.circular(
                                    FSizes.borderRadiusLg),
                                border: Border.all(
                                  color: controller.selectedDate.value != null
                                      ? FColors.primary
                                      : (dark ? FColors.darkGrey : FColors
                                      .borderPrimary),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.calendar,
                                    size: FSizes.iconSm,
                                    color: controller.selectedDate.value != null
                                        ? FColors.white
                                        : (dark ? FColors.darkGrey : FColors
                                        .textSecondary),
                                  ),
                                  const SizedBox(width: FSizes.xs),
                                  Text(
                                    controller.selectedDate.value != null
                                        ? '${controller.selectedDate.value!
                                        .day}/${controller.selectedDate.value!
                                        .month}'
                                        : 'Date',
                                    style: TextStyle(
                                      color: controller.selectedDate.value !=
                                          null
                                          ? FColors.white
                                          : (dark ? FColors.darkGrey : FColors
                                          .textSecondary),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),

                      const SizedBox(width: FSizes.sm),

                      // Clear Filters
                      Obx(() =>
                      (controller.searchQuery.value.isNotEmpty ||
                          controller.selectedStatus.value != 'All' ||
                          controller.selectedDate.value != null)
                          ? GestureDetector(
                        onTap: controller.clearFilters,
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.sm),
                          decoration: BoxDecoration(
                            color: FColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                FSizes.borderRadiusLg),
                          ),
                          child: Icon(
                            Iconsax.refresh,
                            size: FSizes.iconSm,
                            color: FColors.error,
                          ),
                        ),
                      )
                          : const SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: FColors.primary),
                );
              }

              if (controller.filteredEvents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.calendar_remove,
                        size: 64,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      const SizedBox(height: FSizes.md),
                      Text(
                        'No events found',
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: dark ? FColors.darkGrey : FColors
                              .textSecondary,
                        ),
                      ),
                      const SizedBox(height: FSizes.sm),
                      Text(
                        'Try adjusting your search or filters',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: dark ? FColors.darkGrey : FColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: FColors.primary,
                onRefresh: controller.loadEvents,
                child: ListView.builder(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  itemCount: controller.filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = controller.filteredEvents[index];
                    return EventCard(
                      event: event,
                      onTap: () =>
                          Get.to(() => EventDetailsScreen(event: event)),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Build filter chip widget
  Widget _buildFilterChip(BuildContext context,
      String label,
      bool isSelected,
      VoidCallback onTap,) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? FColors.primary
              : (dark ? FColors.darkContainer : FColors.white),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: isSelected
                ? FColors.primary
                : (dark ? FColors.darkGrey : FColors.borderPrimary),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? FColors.white
                : (dark ? FColors.darkGrey : FColors.textSecondary),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Show date picker
  Future<void> _showDatePicker(BuildContext context,
      EventController controller) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final dark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: dark ? FColors.darkContainer : FColors.white,
              onSurface: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.updateDateFilter(selectedDate);
    }
  }

  /// Show My Events bottom sheet
  void _showMyEventsBottomSheet(BuildContext context,
      EventController controller) {
    final dark = FHelperFunctions.isDarkMode(context);
    final userEvents = controller.getUserEvents();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.7,
            decoration: BoxDecoration(
              color: dark ? FColors.dark : FColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(FSizes.cardRadiusLg),
                topRight: Radius.circular(FSizes.cardRadiusLg),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: FSizes.md),
                  decoration: BoxDecoration(
                    color: dark ? FColors.darkGrey : FColors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Get.to(() => const MyEventsScreen()),
                        icon: Icon(
                          Iconsax.calendar_1,
                          size: FSizes.iconSm,
                          color: FColors.primary,
                        ),
                        label: Text(
                          'My Events',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? FColors.white : FColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Iconsax.close_circle,
                          color: dark ? FColors.darkGrey : FColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Events List
                Expanded(
                  child: userEvents.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.calendar_remove,
                          size: 64,
                          color: dark ? FColors.darkGrey : FColors
                              .textSecondary,
                        ),
                        const SizedBox(height: FSizes.md),
                        Text(
                          'No registered events',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: dark ? FColors.darkGrey : FColors
                                .textSecondary,
                          ),
                        ),
                        const SizedBox(height: FSizes.sm),
                        Text(
                          'Register for events to see them here',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: dark ? FColors.darkGrey : FColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    itemCount: userEvents.length,
                    itemBuilder: (context, index) {
                      final event = userEvents[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => EventDetailsScreen(event: event));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}