import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

import '../../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../../common/widgets/admin/badge.dart';
import '../../../../../reward_redemption/models/reward_model.dart';
import '../../../../controllers/reward_management/reward_management_controller.dart';

class RewardDataTable extends StatefulWidget {
  final List<RewardModel> rewards;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;
  final RewardManagementController controller;

  const RewardDataTable({
    super.key,
    required this.rewards,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
    required this.controller,
  });

  @override
  State<RewardDataTable> createState() => _AdminRewardDataTableState();
}

class _AdminRewardDataTableState extends State<RewardDataTable> {
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
    return 160 + 120 + 200 + 120 + 120 + 120 + 120 + 180 + 180 + 120 + 120 + 180;
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
    if (widget.rewards.isEmpty) {
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
                  rows: widget.rewards.map((reward) => DataRow(cells: [_buildActionCell(reward)])).toList(),
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
            Icon(Iconsax.gift, size: 80, color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Rewards Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              "There are no rewards matching your filters.",
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
      DataColumn(label: SizedBox(width: 160, child: _buildColumnHeader('Reward ID', 0))),
      DataColumn(label: SizedBox(width: 120, child: Text('Image', style: _headerStyle()))),
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Title', 2))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Points', 3)), numeric: true),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Total Qty', 4)), numeric: true),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Remaining', 5)), numeric: true),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Redeemed', 6)), numeric: true),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Valid Until', 7))),
      DataColumn(label: SizedBox(width: 180, child: _buildColumnHeader('Created', 8))),
      DataColumn(label: SizedBox(width: 120, child: _buildColumnHeader('Status', 9))),
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
    return widget.rewards.map((reward) {
      final computedStatus = widget.controller.getRewardComputedStatus(reward);
      return DataRow(cells: [
        _wrapSelectableText(reward.rewardId, 160),
        _buildImageCell(reward),
        _buildTitleCell(reward),
        DataCell(_buildPointsBadge(reward.pointsNeeded, widget.dark)),
        DataCell(Text(reward.quantity.toString(), style: _cellStyle())),
        _buildRemainingCell(reward),
        DataCell(
          Text(
            '${reward.redemptionCount}',
            style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _buildValidUntilCell(reward),
        DataCell(Text(_formatDateTime(reward.createdAt), style: _cellStyle())),
        _buildStatusBadge(computedStatus, widget.dark),
        _buildEmptySpacerCell(),
        if (!_showFixedActionColumn) _buildActionCell(reward),
      ]);
    }).toList();
  }

  DataCell _buildEmptySpacerCell() {
    return DataCell(
      Container(width: 120, child: const Text('')),
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

  DataCell _buildImageCell(RewardModel reward) {
    print('reward image: ${reward.rewardImage}');
    return DataCell(
      GestureDetector(
        onTap: () {
          Get.dialog(
            ImageLightbox(
              imageUrl: reward.rewardImage,
              title: reward.title,
            ),
            barrierDismissible: true,
          );
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            border: Border.all(
              color: widget.dark
                  ? FColors.adminDarkBorder.withOpacity(0.3)
                  : FColors.adminLightBorder.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
            child: Image.network(
              reward.rewardImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: widget.dark
                    ? FColors.adminDarkSurfaceVariant
                    : FColors.adminLightSurfaceVariant,
                child: Icon(
                  Iconsax.image,
                  color: widget.dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                  size: 20,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: widget.dark
                      ? FColors.adminDarkSurfaceVariant
                      : FColors.adminLightSurfaceVariant,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl, String title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: Get.width,
                height: Get.height,
                color: Colors.transparent,
              ),
            ),
            Center(
              child: Container(
                width: Get.width * 0.7,
                height: Get.height * 0.7,
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: widget.dark
                          ? FColors.adminDarkSurfaceVariant
                          : FColors.adminLightSurfaceVariant,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.image,
                            size: 64,
                            color: widget.dark
                                ? FColors.adminDarkTextMuted
                                : FColors.adminLightTextMuted,
                          ),
                          const SizedBox(height: FSizes.md),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: widget.dark
                                  ? FColors.adminDarkTextMuted
                                  : FColors.adminLightTextMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$title - Pinch to zoom',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildTitleCell(RewardModel reward) {
    return DataCell(
      Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              reward.title,
              style: _cellStyle().copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (reward.description.isNotEmpty)
              Text(
                reward.description,
                style: _cellStyle().copyWith(
                  fontSize: 12,
                  color: widget.dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
          ],
        ),
      ),
    );
  }

  DataCell _buildRemainingCell(RewardModel reward) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${reward.remainingQuantity}',
            style: _cellStyle().copyWith(
              color: reward.remainingQuantity == 0
                  ? (widget.dark
                  ? FColors.adminDarkError
                  : FColors.adminLightError)
                  : reward.remainingQuantity <= 10
                  ? (widget.dark
                  ? FColors.adminDarkWarning
                  : FColors.adminLightWarning)
                  : (widget.dark
                  ? FColors.adminDarkSuccess
                  : FColors.adminLightSuccess),
              fontWeight: reward.remainingQuantity <= 10
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: widget.dark
                  ? FColors.adminDarkBorder
                  : FColors.adminLightBorder,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: reward.quantity > 0
                  ? (reward.remainingQuantity / reward.quantity).clamp(0.0, 1.0)
                  : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: reward.remainingQuantity == 0
                      ? (widget.dark
                      ? FColors.adminDarkError
                      : FColors.adminLightError)
                      : reward.remainingQuantity <= 10
                      ? (widget.dark
                      ? FColors.adminDarkWarning
                      : FColors.adminLightWarning)
                      : (widget.dark
                      ? FColors.adminDarkSuccess
                      : FColors.adminLightSuccess),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildValidUntilCell(RewardModel reward) {
    return DataCell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatDateTime(reward.validUntil),
            style: _cellStyle()
          ),
          if (reward.isExpired)
            Text(
              'Expired',
              style: _cellStyle().copyWith(
                color: widget.dark
                    ? FColors.adminDarkError
                    : FColors.adminLightError,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  DataCell _buildStatusBadge(String status, bool dark) {
    Color color;
    IconData icon;
    String label;
    switch (status) {
      case 'active':
        color = dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        icon = Iconsax.tick_circle;
        label = 'Active';
        break;
      case 'inactive':
        color = dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        icon = Iconsax.minus_cirlce;
        label = 'Inactive';
        break;
      case 'expired':
        color = dark ? FColors.adminDarkError : FColors.adminLightError;
        icon = Iconsax.close_circle;
        label = 'Expired';
        break;
      case 'out_of_stock':
        color = dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        icon = Iconsax.box_remove;
        label = 'Out of Stock';
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

  Widget _buildPointsBadge(int points, bool dark) {
    final color = dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
    return CommonBadge(
      icon: Iconsax.medal,
      color: color,
      text: points.toString(),
      iconSize: 16,
      textStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      borderRadius: FSizes.cardRadiusMd,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      borderColor: color.withOpacity(0.3),
    );
  }

  DataCell _buildActionCell(RewardModel reward) {
    final computedStatus = widget.controller.getRewardComputedStatus(reward);

    return DataCell(
      SizedBox(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => widget.controller.viewReward(reward),
              icon: Icon(
                Iconsax.eye,
                color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'View Reward Details',
            ),
            if (computedStatus != 'deleted')
              IconButton(
                onPressed: () => widget.controller.editReward(reward),
                icon: Icon(
                  Iconsax.edit,
                  color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  size: 18,
                ),
                tooltip: 'Edit Reward',
              ),
            if (computedStatus != 'deleted')
              IconButton(
                onPressed: () => _showActivationConfirmation(reward),
                icon: Icon(
                  reward.status == 'active' ? Iconsax.minus_cirlce : Iconsax.tick_circle,
                  color: reward.status == 'active'
                      ? (widget.dark ? FColors.adminDarkError : FColors.adminLightError)
                      : (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
                  size: 18,
                ),
                tooltip: reward.status == 'active' ? 'Deactivate Reward' : 'Activate Reward',
              ),
          ],
        ),
      ),
    );
  }

  void _showActivationConfirmation(RewardModel reward) {
    final isActivating = reward.status != 'active';

    Get.dialog(
      AlertDialog(
        backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          isActivating ? 'Activate Reward' : 'Deactivate Reward',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          isActivating
              ? 'Are you sure you want to activate "${reward.title}"? It will be available for users to redeem.'
              : 'Are you sure you want to deactivate "${reward.title}"? Users will no longer be able to redeem this reward.',
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
              Get.back(); // 先关闭对话框

              // 再执行状态切换（内部会根据情况弹 warning / success snackbar）
              widget.controller.toggleRewardStatus(reward);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating
                  ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                  : (widget.dark ? FColors.adminDarkError : FColors.adminLightError),
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