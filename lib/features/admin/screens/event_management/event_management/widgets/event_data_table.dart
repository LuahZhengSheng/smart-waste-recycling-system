import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import '../../../../../../common/widgets/admin/badge.dart';
import '../../../../../event/models/event_model.dart';
import '../../../../controllers/event_management/event_management_controller.dart';

class EventDataTable extends StatefulWidget {
  final List<Event> events;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final EventManagementController controller;

  const EventDataTable({
    super.key,
    required this.events,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<EventDataTable> createState() => _EventDataTableState();
}

class _EventDataTableState extends State<EventDataTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _fixedColumnVerticalController = ScrollController();
  bool _showFixedActionColumn = false;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(_onScroll);
    _verticalScrollController.addListener(_syncFixedColumnScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfActionColumnShouldBeFixed());
  }

  void _syncFixedColumnScroll() {
    if (_fixedColumnVerticalController.hasClients && _verticalScrollController.hasClients) {
      _fixedColumnVerticalController.jumpTo(_verticalScrollController.offset);
    }
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
    return 200 + 180 + 200 + 150 + 250 + 180 + 180 + 180 + 120 + 120 + 180 + 120 + 120 + 180;
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _fixedColumnVerticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return _buildEmptyState();
    }
    return Stack(
      children: [
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
                      widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.hovered)
                          ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                          : null,
                    ),
                    dataRowMinHeight: 80,
                    dataRowMaxHeight: double.infinity,
                    headingRowHeight: 60,
                    showCheckboxColumn: false,
                    columns: _buildColumns(),
                    rows: _buildRows(),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showFixedActionColumn)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 180,
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
              child: SingleChildScrollView(
                controller: _fixedColumnVerticalController,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    widget.dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                  ),
                  dataRowMinHeight: 80,
                  dataRowMaxHeight: double.infinity,
                  headingRowHeight: 60,
                  columns: [_buildActionColumn()],
                  rows: widget.events.map((event) => DataRow(cells: [_buildActionCell(event)])).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.calendar, size: 80, color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Events Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              "There are no events matching your filters.",
              style: TextStyle(
                fontSize: 14,
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final columns = [
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Event ID', 0))),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Title', 1))),
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Contact Email', 2))),
      DataColumn(label: SizedBox(width: 150, child: _buildColumnHeader('Contact Phone', 3))),
      DataColumn(label: SizedBox(width: 250, child: _buildColumnHeader('Address', 4))),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Start Date', 5))),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('End Date', 6))),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Reg. Deadline', 7))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Max', 8)), numeric: true),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Registered', 9)), numeric: true),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Created', 10))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Status', 11))),
      _buildEmptySpacerColumn(),
    ];
    if (!_showFixedActionColumn) {
      columns.add(_buildActionColumn());
    }
    return columns;
  }

  Widget _buildColumnHeader(String title, int columnIndex, {bool numeric = false}) {
    final isCurrentSort = widget.sortColumnIndex == columnIndex;
    return InkWell(
      onTap: () => widget.onSort(columnIndex, !widget.sortAscending),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Align(
              alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                title,
                style: _headerStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Icon(
            isCurrentSort
                ? (widget.sortAscending ? Iconsax.arrow_up_3 : Iconsax.arrow_down)
                : Iconsax.arrow_3,
            size: 16,
            color: isCurrentSort
                ? (widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
          ),
        ],
      ),
    );
  }

  DataColumn _buildEmptySpacerColumn() {
    return DataColumn(
      label: SizedBox(width: 120, child: const Text('')),
    );
  }

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: SizedBox(width: 180, child: Text('Actions', style: _headerStyle())),
    );
  }

  List<DataRow> _buildRows() {
    return widget.events.map((event) {
      final computedStatus = event.computedStatus;
      return DataRow(cells: [
        _wrapSelectableText(event.eventId, 200),
        _wrapText(event.title, 180),
        _wrapText(event.contactEmail, 200),
        _wrapText(event.contactPhoneNo, 150),
        _wrapText(event.location.fullAddress, 250),
        _wrapText(_formatDateTime(event.startDateTime), 180),
        _wrapText(_formatDateTime(event.endDateTime), 180),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(event.registrationDeadline), style: _cellStyle()),
            const SizedBox(height: 2),
            Text(
              event.daysUntilDeadlineText,
              style: TextStyle(
                fontSize: 11,
                color: event.daysUntilDeadlineText == 'Closed'
                    ? (widget.dark
                    ? FColors.adminDarkError
                    : FColors.adminLightError)
                    : (widget.dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted),
              ),
            ),
          ],
        )),
        DataCell(Text(event.maxParticipants.toString(), style: _cellStyle())),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${event.registeredCount}', style: _cellStyle()),
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: event.registrationProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        )),
        DataCell(Text(_formatDateTime(event.createdAt), style: _cellStyle())),
        _buildStatusBadge(computedStatus, widget.dark),
        _buildEmptySpacerCell(),
        if (!_showFixedActionColumn) _buildActionCell(event),
      ]);
    }).toList();
  }

  DataCell _buildEmptySpacerCell() {
    return DataCell(
      Container(width: 120, child: const Text('')),
    );
  }

  DataCell _wrapText(String text, double width) {
    return DataCell(
      Container(
        width: width,
        child: Text(
          text,
          style: _cellStyle(),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _wrapSelectableText(String text, double width) {
    return DataCell(
      Container(
        width: width,
        child: SelectableText(
          text,
          style: _cellStyle(),
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _buildStatusBadge(String status, bool dark) {
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
    }
    return DataCell(CommonBadge(
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
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    ));
  }

  DataCell _buildActionCell(Event event) {
    final computedStatus = event.computedStatus;

    return DataCell(
      Container(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => widget.controller.viewEvent(event.eventId),
              icon: Icon(
                Iconsax.eye,
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'View Event',
            ),
            if (computedStatus == 'upcoming')
              IconButton(
                onPressed: (computedStatus == 'completed' || computedStatus == 'cancelled')
                    ? null
                    : () => widget.controller.editEvent(event),
                icon: Icon(
                  Iconsax.edit,
                  color: (computedStatus == 'completed' || computedStatus == 'cancelled')
                      ? (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted)
                      : (widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                  size: 18,
                ),
                tooltip: (computedStatus == 'completed' || computedStatus == 'cancelled') ? 'Cannot edit completed event' : 'Edit Event',
              ),
            if (computedStatus == 'upcoming')
              IconButton(
                onPressed: () => widget.controller.togglePublishStatus(event),
                icon: Icon(
                  event.isPublish ? Iconsax.eye_slash : Iconsax.eye,
                  color: event.isPublish
                      ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                      : (widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary),
                  size: 18,
                ),
                tooltip: event.isPublish ? 'Unpublish Event' : 'Publish Event',
              ),
            if (computedStatus == 'upcoming' && event.status != 'cancelled')
              IconButton(
                onPressed: () => widget.controller.cancelEvent(event),
                icon: Icon(
                  Iconsax.close_circle,
                  color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                  size: 18,
                ),
                tooltip: 'Cancel Event',
              ),
            if ((computedStatus == 'completed' || event.status == 'cancelled') && event.status != 'deleted')
              IconButton(
                onPressed: () => widget.controller.deleteEvent(event),
                icon: Icon(
                  Iconsax.trash,
                  color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
                  size: 18,
                ),
                tooltip: 'Delete Event',
              ),
          ],
        ),
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
      fontSize: 13,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')} ${_getMonthName(dateTime.month)}, ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
