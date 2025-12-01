import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/event_controller.dart';
import '../common_event_widgets/common_event_widgets.dart';
import '../event_detail/event_detail.dart';
import '../my_event/my_event.dart';
import 'widgets/event_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text('Events'),
        centerTitle: false,
        showBackArrow: false,
        titleIcon: Iconsax.calendar_2,
        actionButtonText: 'My Events',
        actionButtonIcon: Iconsax.calendar_1,
        onActionButtonPressed: () => Get.to(() => const MyEventsScreen()),
        backgroundColor: dark ? FColors.dark : FColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar with Pills Design
            Container(
              color: dark ? FColors.dark : FColors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.defaultSpace, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: controller.tabController,
                  labelColor: FColors.white,
                  unselectedLabelColor:
                      dark ? FColors.darkGrey : FColors.textSecondary,
                  indicator: BoxDecoration(
                    color: FColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: FColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Open'),
                    Tab(text: 'Full'),
                    Tab(text: 'Closed'),
                  ],
                ),
              ),
            ),

            // Search Bar and Time Filter
            Container(
              padding: const EdgeInsets.fromLTRB(
                  FSizes.defaultSpace, 8, FSizes.defaultSpace, 8),
              color: dark ? FColors.dark : FColors.white,
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: dark
                            ? FColors.darkerGrey
                            : FColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.updateSearchQuery,
                        decoration: InputDecoration(
                          hintText: "Search events...",
                          hintStyle: TextStyle(
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Iconsax.search_normal_1,
                            color:
                                dark ? FColors.darkGrey : FColors.textSecondary,
                            size: 20,
                          ),
                          suffixIcon:
                              Obx(() => controller.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Iconsax.close_circle,
                                        color: dark
                                            ? FColors.darkGrey
                                            : FColors.textSecondary,
                                        size: 20,
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
                        style: TextStyle(
                          color: dark ? FColors.white : FColors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Time Filter Dropdown
                  Obx(() {
                    final isFiltered =
                        controller.selectedTimeFilter.value != 'All Time';
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showTimeFilterBottomSheet(
                            context, controller, dark),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isFiltered
                                ? FColors.primary.withOpacity(0.1)
                                : (dark
                                    ? FColors.darkerGrey
                                    : FColors.grey.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFiltered
                                  ? FColors.primary
                                  : (dark
                                      ? FColors.darkGrey.withOpacity(0.3)
                                      : FColors.grey.withOpacity(0.2)),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTimeFilterIcon(
                                    controller.selectedTimeFilter.value),
                                color: isFiltered
                                    ? FColors.primary
                                    : (dark
                                        ? FColors.darkGrey
                                        : FColors.textSecondary),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.selectedTimeFilter.value,
                                style: TextStyle(
                                  color: isFiltered
                                      ? FColors.primary
                                      : (dark ? FColors.white : FColors.black),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Iconsax.arrow_down_1,
                                color: isFiltered
                                    ? FColors.primary
                                    : (dark
                                        ? FColors.darkGrey
                                        : FColors.textSecondary),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Events List
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: List.generate(4, (index) {
                  return RefreshIndicator(
                    color: FColors.primary,
                    onRefresh: controller.refreshEvents,
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child:
                              CircularProgressIndicator(color: FColors.primary),
                        );
                      }

                      if (controller.filteredEvents.isEmpty) {
                        return EmptyStateWidget(
                          icon: Iconsax.calendar_remove,
                          title: 'No events found',
                          subtitle:
                              'Try adjusting your filters or check back later!',
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.defaultSpace,
                          vertical: 12,
                        ),
                        itemCount: controller.filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = controller.filteredEvents[index];
                          print('event poster0: ${event.poster}');
                          return EventCard(
                            event: event,
                            onTap: () =>
                                Get.to(() => EventDetailsScreen(event: event)),
                          );
                        },
                      );
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTimeFilterIcon(String filter) {
    switch (filter) {
      case 'Today':
        return Iconsax.sun_1;
      case 'This Week':
        return Iconsax.calendar_1;
      case 'This Month':
        return Iconsax.calendar;
      case 'This Year':
        return Iconsax.calendar_2;
      default:
        return Iconsax.clock;
    }
  }

  void _showTimeFilterBottomSheet(
      BuildContext context, EventController controller, bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkerGrey : FColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? FColors.darkGrey : FColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.filter,
                      color: FColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter by Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Options
              Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimeFilterOption(
                          'All Time', controller, dark, context),
                      _buildTimeFilterOption(
                          'Today', controller, dark, context),
                      _buildTimeFilterOption(
                          'This Week', controller, dark, context),
                      _buildTimeFilterOption(
                          'This Month', controller, dark, context),
                      _buildTimeFilterOption(
                          'This Year', controller, dark, context),
                    ],
                  )),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterOption(String filter, EventController controller,
      bool dark, BuildContext context) {
    final isSelected = controller.selectedTimeFilter.value == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.setTimeFilter(filter);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.defaultSpace,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? FColors.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FColors.primary.withOpacity(0.2)
                      : (dark
                          ? FColors.darkGrey.withOpacity(0.2)
                          : FColors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTimeFilterIcon(filter),
                  color: isSelected
                      ? FColors.primary
                      : (dark ? FColors.darkGrey : FColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? FColors.primary
                        : (dark ? FColors.white : FColors.black),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Iconsax.tick_circle5,
                  color: FColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
