import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';

import '../../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../../common/widgets/admin/badge.dart';
import '../../../../../../utils/popups/admin_loaders.dart';
import '../../../../controllers/community_management/community_management_controller.dart';
import '../../community_management_detail/community_management_detail.dart';
import '../../widgets/admin_media_preview.dart';

class CommunityDataTable extends StatefulWidget {
  final List<PostModel> posts;
  final Map<String, UserModel> usersCache;
  final Function(int, bool) onSort;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool dark;

  const CommunityDataTable({
    super.key,
    required this.posts,
    required this.usersCache,
    required this.onSort,
    this.sortColumnIndex,
    required this.sortAscending,
    required this.dark,
  });

  @override
  State<CommunityDataTable> createState() => _CommunityDataTableState();
}

class _CommunityDataTableState extends State<CommunityDataTable> {
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

    final screenWidth = MediaQuery.of(context).size.width - (FSizes.lg * 5);
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
    // Post ID(200) + Poster(250) + Type(140) + Media(140) +
    // Likes(100) + Comments(100) + Created(150) + Updated(150) + Spacer(120) + Actions(180)
    return 200 + 250 + 140 + 140 + 100 + 100 + 150 + 150 + 120 + 180;
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
    if (widget.posts.isEmpty) {
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
                      widget.dark
                          ? FColors.adminDarkSurfaceVariant
                          : FColors.adminLightSurfaceVariant,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.hovered)
                          ? (widget.dark ? FColors.adminDarkHover : FColors.adminLightHover)
                          : null,
                    ),
                    showCheckboxColumn: false,
                    headingRowHeight: 60,
                    dataRowMinHeight: 100,
                    dataRowMaxHeight: double.infinity,
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
                  headingRowHeight: 60,
                  dataRowMinHeight: 100,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: MaterialStateProperty.all(
                    widget.dark
                        ? FColors.adminDarkSurfaceVariant
                        : FColors.adminLightSurfaceVariant,
                  ),
                  columns: [_buildActionColumn()],
                  rows: widget.posts
                      .map((post) => DataRow(cells: [_buildActionCell(post)]))
                      .toList(),
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
            Icon(
              Iconsax.message_question,
              size: 80,
              color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            const SizedBox(height: FSizes.lg),
            Text(
              "No Posts Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              "There are no posts matching your filters.",
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
      DataColumn(label: SizedBox(width: 200, child: _buildColumnHeader('Post ID', 0))),
      DataColumn(label: SizedBox(width: 250, child: _buildColumnHeader('Poster', 1))),
      DataColumn(label: SizedBox(width: 140, child: _buildColumnHeader('Type', 2))),
      DataColumn(label: SizedBox(width: 140, child: _buildColumnHeader('Media', 3))),
      DataColumn(label: SizedBox(width: 100, child: _buildColumnHeader('Likes', 4)), numeric: true),
      DataColumn(label: SizedBox(width: 100, child: _buildColumnHeader('Comments', 5)), numeric: true),
      DataColumn(label: SizedBox(width: 150, child: _buildColumnHeader('Created', 6))),
      DataColumn(label: SizedBox(width: 150, child: _buildColumnHeader('Updated', 7))),
      _buildEmptySpacerColumn(),
    ];

    if (!_showFixedActionColumn) {
      columns.add(_buildActionColumn());
    }

    return columns;
  }

  DataColumn _buildEmptySpacerColumn() {
    return DataColumn(
      label: SizedBox(width: 120, child: const Text('')),
    );
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

  DataColumn _buildActionColumn() {
    return DataColumn(
      label: SizedBox(width: 180, child: Text('Actions', style: _headerStyle())),
    );
  }

  List<DataRow> _buildRows() {
    return widget.posts.map((post) {
      final user = widget.usersCache[post.userId];

      final cells = [
        _wrapSelectableText(post.postId, 200),
        _buildPosterCell(user, post),
        _buildPostTypeBadge(post.postType),
        _buildMediaCell(post),
        DataCell(
          Container(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.heart,
                  size: 16,
                  color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  post.likes.length.toString(),
                  style: _cellStyle(),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Container(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.message,
                  size: 16,
                  color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  post.commentCount.toString(),
                  style: _cellStyle(),
                ),
              ],
            ),
          ),
        ),
        _buildDateTimeCell(post.createdAt),
        _buildUpdatedAtCell(post),
        _buildEmptySpacerCell(),
      ];

      if (!_showFixedActionColumn) {
        cells.add(_buildActionCell(post));
      }

      return DataRow(cells: cells);
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

  DataCell _buildPosterCell(UserModel? user, PostModel post) {
    return DataCell(
      Container(
        width: 250,
        child: user != null
            ? Row(
          children: [
            GestureDetector(
              onTap: () {
                if (user.profileImg != null && user.profileImg!.isNotEmpty) {
                  Get.dialog(
                    ImageLightbox(
                      imageUrl: user.profileImg!,
                      title: user.username,
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: widget.dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary,
                backgroundImage: user.profileImg != null && user.profileImg!.isNotEmpty
                    ? NetworkImage(user.profileImg!)
                    : null,
                child: user.profileImg == null || user.profileImg!.isEmpty
                    ? const Icon(
                  Iconsax.user,
                  color: Colors.white,
                  size: 24,
                )
                    : null,
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: widget.dark
                          ? FColors.adminDarkText
                          : FColors.adminLightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.dark
                          ? FColors.adminDarkTextSecondary
                          : FColors.adminLightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        )
            : Text('Loading...', style: _cellStyle()),
      ),
    );
  }

  DataCell _buildPostTypeBadge(String postType) {
    Color color;
    IconData icon;
    String label;

    switch (postType) {
      case 'question':
        color = widget.dark ? FColors.adminDarkInfo : FColors.adminLightInfo;
        icon = Iconsax.message_question;
        label = 'Question';
        break;
      case 'discussion':
        color = widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary;
        icon = Iconsax.messages_3;
        label = 'Discussion';
        break;
      case 'announcement':
        color = widget.dark ? FColors.adminDarkWarning : FColors.adminLightWarning;
        icon = Iconsax.microphone;
        label = 'Announcement';
        break;
      case 'event':
        color = widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess;
        icon = Iconsax.calendar;
        label = 'Event';
        break;
      default:
        color = widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted;
        icon = Iconsax.document;
        label = postType;
    }

    return DataCell(
      CommonBadge(
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
      ),
    );
  }

  DataCell _buildMediaCell(PostModel post) {
    return DataCell(
      Container(
        width: 140,
        child: AdminMediaPreview(
          mediaUrls: post.media,
          dark: widget.dark,
          size: 50,
          maxDisplay: 2,
        ),
      ),
    );
  }

  DataCell _buildDateTimeCell(DateTime dateTime) {
    return DataCell(
      Container(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDateTime(dateTime),
              style: _cellStyle(),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              FFormatter.formatTimeAgo(dateTime),
              style: TextStyle(
                fontSize: 11,
                color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildUpdatedAtCell(PostModel post) {
    final wasEdited = post.updatedAt.difference(post.createdAt).inSeconds > 60;

    if (!wasEdited) {
      return DataCell(
        Container(
          width: 150,
          child: Text(
            'Not edited',
            style: TextStyle(
              fontSize: 12,
              color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return DataCell(
      Container(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDateTime(post.updatedAt),
              style: _cellStyle(),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              FFormatter.formatTimeAgo(post.updatedAt),
              style: TextStyle(
                fontSize: 11,
                color: widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildActionCell(PostModel post) {
    return DataCell(
      Container(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => Get.to(() => PostDetailScreen(post: post)),
              icon: Icon(
                Iconsax.eye,
                color: widget.dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                size: 18,
              ),
              tooltip: 'View Details',
            ),
            IconButton(
              onPressed: () => _showActionDialog(post),
              icon: Icon(
                post.isDisabled ? Iconsax.refresh : Iconsax.close_circle,
                color: post.isDisabled
                    ? (widget.dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                    : (widget.dark ? FColors.adminDarkError : FColors.adminLightError),
                size: 18,
              ),
              tooltip: post.isDisabled ? 'Recover Post' : 'Disable Post',
            ),
          ],
        ),
      ),
    );
  }

  // void _showActionDialog(PostModel post) {
  //   if (post.isDisabled) {
  //     Get.dialog(
  //       RecoverPostDialog(post: post),
  //       barrierDismissible: false,
  //     );
  //   } else {
  //     Get.dialog(
  //       DisablePostDialog(post: post),
  //       barrierDismissible: false,
  //     );
  //   }
  // }

  void _showActionDialog(PostModel post) {
    final controller = CommunityManagementController.instance;

    FAdminLoaders.showPostDisableRecoverDialog(
      postContent: post.content.length > 50 ? '${post.content.substring(0, 50)}...' : post.content,
      isDisabled: post.isDisabled,
      onConfirm: () => controller.togglePostStatus(post),
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
}