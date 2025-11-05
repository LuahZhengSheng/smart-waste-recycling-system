import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../leaderboard_achievement/models/achievement_model.dart';
import '../../controllers/achievement_management/achievement_management_controller.dart';
import 'achievement_management_detail/achievement_management_detail.dart';

class AchievementManagementScreen extends StatelessWidget {
  const AchievementManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AchievementManagementController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      body: Padding(
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Row
            Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search achievements by title, category, or max level...',
                        hintStyle: TextStyle(
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal_1,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(FSizes.md),
                      ),
                      style: TextStyle(
                        color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: FSizes.md),

                // Filters Button
                Container(
                  decoration: BoxDecoration(
                    color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Obx(() => IconButton(
                    onPressed: controller.showFilters,
                    icon: Stack(
                      children: [
                        Icon(
                          Iconsax.filter,
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                        if (controller.hasActiveFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Show entries dropdown
            Row(
              children: [
                Text(
                  'Show',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Obx(
                      () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: FSizes.sm),
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: DropdownButton<int>(
                      value: controller.itemsPerPage.value,
                      onChanged: controller.changeItemsPerPage,
                      items: [10, 25, 50, 100]
                          .map((int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            color: dark ? FColors.adminDarkText : FColors.adminLightText,
                          ),
                        ),
                      ))
                          .toList(),
                      underline: const SizedBox(),
                      dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Text(
                  'entries',
                  style: TextStyle(
                    color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: FSizes.spaceBtwItems),

            // Data Table
            Expanded(
              child: Container(
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
                    // Table
                    Expanded(
                      child: Obx(() => AdminAchievementDataTable(
                        achievements: controller.paginatedAchievements,
                        onSort: controller.sortAchievements,
                        sortColumnIndex: controller.sortColumnIndex.value,
                        sortAscending: controller.sortAscending.value,
                        dark: dark,
                        controller: controller,
                      )),
                    ),

                    // Pagination
                    Container(
                      padding: const EdgeInsets.all(FSizes.md),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Obx(() => _buildPagination(controller, dark)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(AchievementManagementController controller, bool dark) {
    // Calculate page numbers to show (up to 5 pages)
    int totalPages = (controller.totalAchievements / controller.itemsPerPage.value).ceil();
    int currentPage = controller.currentPage.value;

    List<int> pageNumbers = [];

    if (totalPages <= 5) {
      // Show all pages if total pages <= 5
      pageNumbers = List.generate(totalPages, (index) => index + 1);
    } else {
      // Show 5 pages centered around current page
      int start = (currentPage - 2).clamp(1, totalPages - 4);
      int end = (start + 4).clamp(5, totalPages);
      start = end - 4;

      pageNumbers = List.generate(5, (index) => start + index);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${controller.startIndex + 1} to ${controller.endIndex} of ${controller.totalAchievements} entries',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        Row(
          children: [
            // First page button
            _buildPaginationButton(
              icon: Iconsax.previous,
              onTap: controller.currentPage.value > 1 ? () => controller.goToPage(1) : null,
              tooltip: 'First page',
              dark: dark,
            ),

            // Previous page button
            _buildPaginationButton(
              icon: Iconsax.arrow_left_2,
              onTap: controller.canGoPreviousPage ? controller.previousPage : null,
              tooltip: 'Previous page',
              dark: dark,
            ),

            const SizedBox(width: FSizes.sm),

            // Page numbers
            ...pageNumbers.map((pageNum) => GestureDetector(
              onTap: () => controller.goToPage(pageNum),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                decoration: BoxDecoration(
                  color: pageNum == currentPage
                      ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                ),
                child: Text(
                  pageNum.toString(),
                  style: TextStyle(
                    color: pageNum == currentPage
                        ? Colors.white
                        : (dark ? FColors.adminDarkText : FColors.adminLightText),
                    fontWeight: pageNum == currentPage ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            )),

            const SizedBox(width: FSizes.sm),

            // Next page button
            _buildPaginationButton(
              icon: Iconsax.arrow_right_3,
              onTap: controller.canGoNextPage ? controller.nextPage : null,
              tooltip: 'Next page',
              dark: dark,
            ),

            // Last page button
            _buildPaginationButton(
              icon: Iconsax.next,
              onTap: controller.currentPage.value < totalPages ? () => controller.goToPage(totalPages) : null,
              tooltip: 'Last page',
              dark: dark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    required bool dark,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: onTap != null
            ? (dark ? FColors.adminDarkText : FColors.adminLightText)
            : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
        size: 18,
      ),
      tooltip: tooltip,
    );
  }
}

class AdminAchievementDataTable extends StatefulWidget {
  final List<Achievement> achievements;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final AchievementManagementController controller;

  const AdminAchievementDataTable({
    super.key,
    required this.achievements,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<AdminAchievementDataTable> createState() => _AdminAchievementDataTableState();
}

class _AdminAchievementDataTableState extends State<AdminAchievementDataTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  bool _showFixedActionColumn = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfActionColumnShouldBeFixed());
  }

  void _onScroll() {
    _checkIfActionColumnShouldBeFixed();
  }

  void _checkIfActionColumnShouldBeFixed() {
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width - (FSizes.lg * 2);
    final tableWidth = _calculateTableWidth();
    final hasHorizontalScroll = tableWidth > screenWidth;
    final isScrolledRight = _horizontalScrollController.offset > 0;

    final shouldShowFixed = hasHorizontalScroll && isScrolledRight;

    if (shouldShowFixed != _showFixedActionColumn) {
      setState(() {
        _showFixedActionColumn = shouldShowFixed;
      });
    }
  }

  double _calculateTableWidth() {
    return 1200.0; // Approximate total width including all columns
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main scrollable table
        Scrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - (FSizes.lg * 2),
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      widget.dark
                          ? FColors.adminDarkSurfaceVariant
                          : FColors.adminLightSurfaceVariant,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.hovered)
                          ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                          : null,
                    ),
                    sortColumnIndex: widget.sortColumnIndex,
                    sortAscending: widget.sortAscending,
                    columns: _buildColumns(),
                    rows: _buildRows(),
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 72,
                    dividerThickness: 0.5,
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: (widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Fixed action column with shadow
        if (_showFixedActionColumn)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 150, // Fixed width for action column
              decoration: BoxDecoration(
                color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(-5, 0),
                  ),
                ],
                border: Border(
                  left: BorderSide(
                    color: widget.dark
                        ? FColors.adminDarkBorder.withOpacity(0.5)
                        : FColors.adminLightBorder.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  widget.dark
                      ? FColors.adminDarkSurfaceVariant
                      : FColors.adminLightSurfaceVariant,
                ),
                dataRowColor: MaterialStateProperty.resolveWith(
                      (states) => states.contains(MaterialState.hovered)
                      ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                      : null,
                ),
                columns: [_buildActionColumn()],
                rows: widget.achievements
                    .map((achievement) => DataRow(
                  cells: [_buildActionCell(achievement)],
                  color: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.hovered)
                        ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                        : null,
                  ),
                ))
                    .toList(),
                dataRowMinHeight: 56,
                dataRowMaxHeight: 72,
                dividerThickness: 0.5,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: (widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider).withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text('Title', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(0, ascending),
      ),
      DataColumn(
        label: Text('Category', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(1, ascending),
      ),
      DataColumn(
        label: Text('Max Level', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(2, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Total Levels', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(3, ascending),
        numeric: true,
      ),
      DataColumn(
        label: Text('Created At', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(4, ascending),
      ),
      DataColumn(
        label: Text('Status', style: _headerStyle()),
        onSort: (columnIndex, ascending) => widget.onSort(5, ascending),
      ),
      if (!_showFixedActionColumn) _buildActionColumn(),
    ];
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: Text('Actions', style: _headerStyle()),
    );
  }

  List<DataRow> _buildRows() {
    return widget.achievements.map((achievement) {
      final status = widget.controller.getAchievementStatus(achievement);
      return DataRow(
        color: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.hovered)
              ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
              : null,
        ),
        cells: [
          DataCell(
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                achievement.title,
                style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
              decoration: BoxDecoration(
                color: _getCategoryColor(achievement.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
              ),
              child: Text(
                achievement.category,
                style: _cellStyle().copyWith(
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(achievement.category),
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              achievement.maxLevel.toString(),
              style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Text(
              achievement.achievementLevels.length.toString(),
              style: _cellStyle(),
            ),
          ),
          DataCell(Text(_formatDateTime(achievement.createdAt), style: _cellStyle())),
          DataCell(_buildStatusChip(status)),
          if (!_showFixedActionColumn) _buildActionCell(achievement),
        ],
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'recycling':
        return widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
      case 'scanning':
        return widget.dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
      case 'community':
        return widget.dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary;
      case 'streak':
        return widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
      default:
        return widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String displayText;

    switch (status) {
      case 'active':
        backgroundColor = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        displayText = 'Active';
        break;
      case 'inactive':
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = 'Inactive';
        break;
      default:
        backgroundColor = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  DataCell _buildActionCell(Achievement achievement) {
    final status = widget.controller.getAchievementStatus(achievement);

    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button - always available
          IconButton(
            onPressed: () => Get.to(
              () => AchievementDetailsScreen(),
              arguments: achievement,
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            ),
            icon: Icon(
              Iconsax.eye,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'View Achievement Details',
          ),

          // Edit button - always available
          IconButton(
            onPressed: () => widget.controller.editAchievement(achievement),
            icon: Icon(
              Iconsax.edit,
              color: widget.dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
              size: 18,
            ),
            tooltip: 'Edit Achievement',
          ),

          // Activate/Deactivate toggle
          IconButton(
            onPressed: () => _showActivationConfirmation(achievement, status),
            icon: Icon(
              status == 'active' ? Iconsax.pause_circle : Iconsax.play_circle,
              color: status == 'active'
                  ? (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning)
                  : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
              size: 18,
            ),
            tooltip: status == 'active' ? 'Deactivate Achievement' : 'Activate Achievement',
          ),
        ],
      ),
    );
  }

  void _showActivationConfirmation(Achievement achievement, String currentStatus) {
    final isActivating = currentStatus != 'active';

    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          isActivating ? 'Activate Achievement' : 'Deactivate Achievement',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          isActivating
              ? 'Are you sure you want to activate "${achievement.title}"? Users will be able to unlock this achievement and its levels.'
              : 'Are you sure you want to deactivate "${achievement.title}"? Users will no longer be able to unlock new levels for this achievement.',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.toggleAchievementStatus(achievement);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating
                  ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning),
            ),
            child: Text(
              isActivating ? 'Activate' : 'Deactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
  }

  TextStyle _cellStyle() {
    return TextStyle(
      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
      fontSize: 14,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)}, ${dateTime.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class AchievementFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AchievementFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<AchievementFilterDialog> createState() => _AchievementFilterDialogState();
}

class _AchievementFilterDialogState extends State<AchievementFilterDialog> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: widget.dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Category Filter
            _buildFilterSection(
              'Category',
              DropdownButton<String?>(
                value: filters['category'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['category'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  const DropdownMenuItem(value: 'Recycling', child: Text('Recycling')),
                  const DropdownMenuItem(value: 'Scanning', child: Text('Scanning')),
                  const DropdownMenuItem(value: 'Community', child: Text('Community')),
                  const DropdownMenuItem(value: 'Streak', child: Text('Streak')),
                  const DropdownMenuItem(value: 'Environmental', child: Text('Environmental')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // Status Filter
            _buildFilterSection(
              'Status',
              DropdownButton<String?>(
                value: filters['status'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['status'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Status')),
                  const DropdownMenuItem(value: 'active', child: Text('Active')),
                  const DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            // Max Level Range Filter
            _buildFilterSection(
              'Max Level Range',
              DropdownButton<String?>(
                value: filters['maxLevelRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['maxLevelRange'] = value),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Levels')),
                  const DropdownMenuItem(value: 'low', child: Text('Low (1-3 levels)')),
                  const DropdownMenuItem(value: 'medium', child: Text('Medium (4-6 levels)')),
                  const DropdownMenuItem(value: 'high', child: Text('High (7+ levels)')),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                style: TextStyle(
                  color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filters = {
                          'category': null,
                          'status': null,
                          'maxLevelRange': null,
                        };
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: widget.dark
                            ? FColors.adminDarkTextSecondary
                            : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(filters);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
          decoration: BoxDecoration(
            color: widget.dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: content,
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}