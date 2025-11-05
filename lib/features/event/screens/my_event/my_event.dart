import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/my_event_controller.dart';
import '../../models/event_enums.dart';
import '../../utils/event_utils.dart';
import '../common_event_widgets/common_event_widgets.dart';
import '../event_detail/event_detail.dart';
import 'widgets/my_event_card.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyEventsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        backgroundColor: dark ? FColors.dark : FColors.white,
        title: Row(
          children: [
            Text(
              'My Events',
              style: TextStyle(
                color: dark ? FColors.white : FColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
                  color: dark
                      ? FColors.darkerGrey
                      : FColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: controller.tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
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
                  labelPadding:
                  const EdgeInsets.symmetric(horizontal: FSizes.md),
                  tabs: [
                    _buildTab('All', 0, controller),
                    _buildTab('Upcoming', 1, controller),
                    _buildTab('Ongoing', 2, controller),
                    _buildTab('Completed', 3, controller),
                    _buildTab('Cancelled', 4, controller),
                  ],
                ),
              ),
            ),

            // Time Filter
            Container(
              padding: const EdgeInsets.fromLTRB(
                  FSizes.defaultSpace, 8, FSizes.defaultSpace, 8),
              color: dark ? FColors.dark : FColors.white,
              child: Obx(() {
                final isFiltered =
                    controller.selectedTimeFilter.value != TimeFilter.allTime;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _showTimeFilterBottomSheet(context, controller, dark),
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
                        children: [
                          Icon(
                            EventUtils.getTimeFilterIcon(
                                controller.selectedTimeFilter.value),
                            color: isFiltered
                                ? FColors.primary
                                : (dark
                                ? FColors.darkGrey
                                : FColors.textSecondary),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.selectedTimeFilter.value.displayName,
                              style: TextStyle(
                                color: isFiltered
                                    ? FColors.primary
                                    : (dark ? FColors.white : FColors.black),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
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
            ),

            // Divider
            Container(
              height: 8,
              color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
            ),

            // Events List
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: List.generate(5, (index) {
                  return Obx(() {
                    if (controller.filteredEvents.isEmpty) {
                      return _buildEmptyState(index, dark);
                    }

                    return RefreshIndicator(
                      color: FColors.primary,
                      onRefresh: controller.refreshEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.defaultSpace,
                          vertical: 12,
                        ),
                        itemCount: controller.filteredEvents.length,
                        itemBuilder: (context, itemIndex) {
                          final event = controller.filteredEvents[itemIndex];
                          final isCancelled =
                              controller.cancelledEventIds[event.eventId] ??
                                  false;
                          return MyEventCard(
                            event: event,
                            isCancelled: isCancelled,
                            onTap: () =>
                                Get.to(() => EventDetailsScreen(event: event)),
                            showCancelButton: index == 0 ||
                                index ==
                                    1, // Show for All and Upcoming tabs
                          );
                        },
                      ),
                    );
                  });
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build custom tab with count
  Widget _buildTab(String title, int index, MyEventsController controller) {
    return Obx(() {
      final count = controller.getTabCount(index);
      final isSelected = controller.currentTabIndex.value == index;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FColors.white.withOpacity(0.25)
                      : FColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                      color: FColors.white.withOpacity(0.3), width: 0.5)
                      : Border.all(
                      color: FColors.primary.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? FColors.white : FColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Show time filter bottom sheet
  void _showTimeFilterBottomSheet(
      BuildContext context, MyEventsController controller, bool dark) {
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
                children: TimeFilter.values.map((filter) {
                  return _buildTimeFilterOption(
                      filter, controller, dark, context);
                }).toList(),
              )),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Build time filter option
  Widget _buildTimeFilterOption(
      TimeFilter filter,
      MyEventsController controller,
      bool dark,
      BuildContext context,
      ) {
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
                  EventUtils.getTimeFilterIcon(filter),
                  color: isSelected
                      ? FColors.primary
                      : (dark ? FColors.darkGrey : FColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  filter.displayName,
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

  /// Build empty state
  Widget _buildEmptyState(int tabIndex, bool dark) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No Events Found';
        subtitle =
        'You haven\'t registered for any events yet. Discover exciting events happening near you!';
        icon = Iconsax.calendar_remove;
        break;
      case 1:
        title = 'No Upcoming Events';
        subtitle =
        'You have no upcoming events to attend. Browse available events and join exciting activities!';
        icon = Iconsax.calendar_add;
        break;
      case 2:
        title = 'No Ongoing Events';
        subtitle =
        'No events are currently in progress. Check back when your registered events begin!';
        icon = Iconsax.calendar_tick;
        break;
      case 3:
        title = 'No Completed Events';
        subtitle =
        'You haven\'t attended any events yet. Start participating in community events today!';
        icon = Iconsax.medal_star;
        break;
      case 4:
        title = 'No Cancelled Events';
        subtitle =
        'You have no cancelled registrations. Keep exploring events that interest you!';
        icon = Iconsax.calendar_remove;
        break;
      default:
        title = 'No Events';
        subtitle = 'No events found for this category.';
        icon = Iconsax.calendar;
    }

    return EmptyStateWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      buttonText: 'Explore Events',
      onButtonPressed: () => Get.back(),
    );
  }
}