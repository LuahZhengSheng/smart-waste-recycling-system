import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/my_event_controller.dart';
import '../../models/event_model.dart';
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
      appBar: AppBar(
        backgroundColor: dark ? FColors.dark : FColors.light,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
        title: Text(
          'My Events',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // Enhanced Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                decoration: BoxDecoration(
                  color: (dark ? FColors.darkContainer : FColors.lightContainer).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: controller.tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    gradient: LinearGradient(
                      colors: [
                        FColors.primary,
                        FColors.primary.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: FColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: FColors.white,
                  unselectedLabelColor: dark ? FColors.darkGrey : FColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelPadding: const EdgeInsets.symmetric(horizontal: FSizes.md),
                  tabs: [
                    _buildTab('All', 0, controller),
                    _buildTab('Upcoming', 1, controller),
                    _buildTab('Ongoing', 2, controller),
                    _buildTab('Completed', 3, controller),
                    _buildTab('Cancelled', 4, controller),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.md * 1.5),

              // Date Filter Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() => GestureDetector(
                        onTap: () => _showDateFilterBottomSheet(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md,
                            vertical: FSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: dark ? FColors.darkContainer : FColors.white,
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                            border: Border.all(
                              color: controller.dateFilterType.value != 'All Time'
                                  ? FColors.primary
                                  : (dark ? FColors.darkGrey.withOpacity(0.3) : FColors.borderPrimary),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: controller.dateFilterType.value != 'All Time'
                                      ? FColors.primary.withOpacity(0.1)
                                      : (dark ? FColors.darkGrey.withOpacity(0.1) : FColors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Iconsax.calendar_1,
                                  size: 16,
                                  color: controller.dateFilterType.value != 'All Time'
                                      ? FColors.primary
                                      : (dark ? FColors.darkGrey : FColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: FSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.dateFilterType.value,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: controller.dateFilterType.value != 'All Time'
                                            ? FColors.primary
                                            : (dark ? FColors.white : FColors.textPrimary),
                                      ),
                                    ),
                                    if (controller.dateFilterType.value == 'Custom' &&
                                        controller.selectedDateRange.value != null)
                                      Text(
                                        controller.dateRangeText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Iconsax.arrow_down_1,
                                size: 14,
                                color: dark ? FColors.darkGrey : FColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),
                    if (controller.dateFilterType.value != 'All Time') ...[
                      const SizedBox(width: FSizes.sm),
                      GestureDetector(
                        onTap: controller.clearAllFilters,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: FColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: FColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Iconsax.close_circle,
                            size: 16,
                            color: FColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: FSizes.sm),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildEventsList(controller, 0),
          _buildEventsList(controller, 1),
          _buildEventsList(controller, 2),
          _buildEventsList(controller, 3),
          _buildEventsList(controller, 4),
        ],
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
                      ? Border.all(color: FColors.white.withOpacity(0.3), width: 0.5)
                      : Border.all(color: FColors.primary.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? FColors.white
                        : FColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Build events list for each tab
  Widget _buildEventsList(MyEventsController controller, int tabIndex) {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.filteredEvents.isEmpty) {
        return _buildEmptyState(tabIndex, dark);
      }

      return RefreshIndicator(
        color: FColors.primary,
        backgroundColor: dark ? FColors.darkContainer : FColors.white,
        onRefresh: controller.loadMyEvents,
        child: ListView.builder(
          padding: const EdgeInsets.all(FSizes.defaultSpace/2),
          itemCount: controller.filteredEvents.length,
          itemBuilder: (context, index) {
            final event = controller.filteredEvents[index];
            return MyEventCard(
              event: event,
              onTap: () => Get.to(() => EventDetailsScreen(event: event)),
              showCancelButton: tabIndex == 1, // Only show cancel button for upcoming events
              isCancelled: tabIndex == 4, // Mark as cancelled for cancelled tab
            );
          },
        ),
      );
    });
  }

  /// Show date filter bottom sheet
  void _showDateFilterBottomSheet(BuildContext context, MyEventsController controller) {
    final dark = FHelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(FSizes.cardRadiusLg),
            topRight: Radius.circular(FSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  Text(
                    'Filter by Date',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? FColors.white : FColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    (dark ? FColors.darkGrey : FColors.borderPrimary).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Date filter options
            Padding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Column(
                children: [
                  _buildFilterOption(
                    context,
                    'All Time',
                    'Show all events',
                    Iconsax.calendar,
                        () => _selectFilter(context, controller, 'All Time'),
                    controller,
                  ),
                  _buildFilterOption(
                    context,
                    'This Week',
                    'Events in current week',
                    Iconsax.calendar_1,
                        () => _selectFilter(context, controller, 'This Week'),
                    controller,
                  ),
                  _buildFilterOption(
                    context,
                    'This Month',
                    'Events in current month',
                    Iconsax.calendar_2,
                        () => _selectFilter(context, controller, 'This Month'),
                    controller,
                  ),
                  _buildFilterOption(
                    context,
                    'Custom Range',
                    'Pick your own date range',
                    Iconsax.calendar_edit,
                        () => _showCustomDatePicker(context, controller),
                    controller,
                  ),
                ],
              ),
            ),

            const SizedBox(height: FSizes.defaultSpace),
          ],
        ),
      ),
    );
  }

  /// Build filter option
  Widget _buildFilterOption(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      MyEventsController controller,
      ) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(() {
      final isSelected = controller.dateFilterType.value == title;

      return Container(
        margin: const EdgeInsets.only(bottom: FSizes.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            child: Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    FColors.primary.withOpacity(0.1),
                    FColors.primary.withOpacity(0.05),
                  ],
                )
                    : null,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: Border.all(
                  color: isSelected
                      ? FColors.primary
                      : (dark ? FColors.darkGrey.withOpacity(0.3) : FColors.borderPrimary),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(FSizes.sm),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [
                          FColors.primary,
                          FColors.primary.withOpacity(0.8),
                        ],
                      )
                          : LinearGradient(
                        colors: [
                          (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.2),
                          (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                    ),
                    child: Icon(
                      icon,
                      size: FSizes.iconSm,
                      color: isSelected
                          ? FColors.white
                          : (dark ? FColors.darkGrey : FColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? FColors.primary
                                : (dark ? FColors.white : FColors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: FColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.tick_circle,
                        color: FColors.primary,
                        size: FSizes.iconSm,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Select filter option
  void _selectFilter(BuildContext context, MyEventsController controller, String filterType) {
    controller.updateDateFilter(filterType);
    Navigator.pop(context);
  }

  /// Show custom date picker
  void _showCustomDatePicker(BuildContext context, MyEventsController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: controller.selectedDateRange.value,
      builder: (context, child) {
        final dark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: dark
                ? ColorScheme.dark(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: FColors.darkContainer,
              onSurface: FColors.white,
            )
                : ColorScheme.light(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: FColors.white,
              onSurface: FColors.textPrimary,
            ),
            dialogBackgroundColor: dark ? FColors.darkContainer : FColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.updateDateFilter('Custom', start: picked.start, end: picked.end);
      Navigator.pop(context);
    }
  }

  /// Build loading state
  Widget _buildLoadingState() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: FColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: FSizes.lg),
          Text(
            'Loading your events...',
            style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state for each tab
  Widget _buildEmptyState(int tabIndex, bool dark) {
    String title;
    String subtitle;
    String actionText;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No Events Found';
        subtitle = 'You haven\'t registered for any events yet. Discover exciting events happening near you!';
        actionText = 'Explore Events';
        icon = Iconsax.calendar_remove;
        break;
      case 1:
        title = 'No Upcoming Events';
        subtitle = 'You have no upcoming events to attend. Browse available events and join exciting activities!';
        actionText = 'Find Events';
        icon = Iconsax.calendar_add;
        break;
      case 2:
        title = 'No Ongoing Events';
        subtitle = 'No events are currently in progress. Check back when your registered events begin!';
        actionText = 'View All Events';
        icon = Iconsax.calendar_tick;
        break;
      case 3:
        title = 'No Completed Events';
        subtitle = 'You haven\'t attended any events yet. Start participating in community events today!';
        actionText = 'Join Events';
        icon = Iconsax.medal_star;
        break;
      case 4:
        title = 'No Cancelled Events';
        subtitle = 'You have no cancelled registrations. Keep exploring events that interest you!';
        actionText = 'Browse Events';
        icon = Iconsax.calendar_remove;
        break;
      default:
        title = 'No Events';
        subtitle = 'No events found for this category.';
        actionText = 'Explore';
        icon = Iconsax.calendar;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.1),
                    (dark ? FColors.darkGrey : FColors.grey).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (dark ? FColors.darkGrey : FColors.borderPrimary).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),

            const SizedBox(height: FSizes.xl),

            // Title
            Text(
              title,
              style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                color: dark ? FColors.white : FColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: FSizes.sm),

            // Subtitle
            Text(
              subtitle,
              style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),

            const SizedBox(height: FSizes.xl),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to events list or home
                  Get.back();
                },
                icon: Icon(
                  Iconsax.search_normal,
                  size: FSizes.iconSm,
                ),
                label: Text(
                  actionText,
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
        ),
      ),
    );
  }

  /// Show date range picker dialog
  void _showDateRangePicker(BuildContext context, MyEventsController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: controller.selectedDateRange.value,
      builder: (context, child) {
        final dark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: dark
                ? ColorScheme.dark(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: FColors.darkContainer,
              onSurface: FColors.white,
            )
                : ColorScheme.light(
              primary: FColors.primary,
              onPrimary: FColors.white,
              surface: FColors.white,
              onSurface: FColors.textPrimary,
            ),
            dialogBackgroundColor: dark ? FColors.darkContainer : FColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.updateDateFilter(picked as String);
    }
  }
}