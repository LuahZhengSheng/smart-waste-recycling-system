import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FAppBar({
    super.key,
    this.title,
    this.showBackArrow = true,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
    this.backArrowColor,
    this.backgroundColor,
    this.titleColor,
    this.centerTitle = true,
    this.titleWidget, // 新增：支持自定义标题widget
    this.titleIcon, // 新增：标题图标
    this.titleIconColor, // 新增：标题图标颜色
    this.actionButton, // 新增：通用action按钮
    this.actionButtonText, // 新增：action按钮文字
    this.actionButtonIcon, // 新增：action按钮图标
    this.onActionButtonPressed, // 新增：action按钮点击回调
  });

  final Widget? title;
  final bool showBackArrow;
  final Color? backArrowColor;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool centerTitle;
  final Widget? titleWidget; // 自定义标题widget
  final IconData? titleIcon; // 标题图标
  final Color? titleIconColor; // 标题图标颜色
  final Widget? actionButton; // 通用action按钮
  final String? actionButtonText; // action按钮文字
  final IconData? actionButtonIcon; // action按钮图标
  final VoidCallback? onActionButtonPressed; // action按钮点击回调

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor ?? (dark ? Colors.black : Colors.white),
        centerTitle: centerTitle,
        leading: showBackArrow
            ? IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: backArrowColor ?? (dark ? Colors.white : Colors.black),
            size: 24,
          ),
        )
            : leadingIcon != null
            ? IconButton(
          onPressed: leadingOnPressed,
          icon: Icon(
            leadingIcon,
            color: backArrowColor ?? (dark ? Colors.white : Colors.black),
          ),
        )
            : null,
        title: _buildTitle(context, dark),
        actions: _buildActions(context, dark),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool dark) {
    // 如果有自定义标题widget，直接返回
    if (titleWidget != null) return titleWidget!;

    // 如果有标题图标，构建带图标的标题
    if (titleIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              titleIcon,
              color: titleIconColor ?? FColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          _buildTextTitle(context, dark),
        ],
      );
    }

    // 普通文本标题
    return _buildTextTitle(context, dark);
  }

  Widget _buildTextTitle(BuildContext context, bool dark) {
    if (title == null) return const SizedBox();

    if (title is Text) {
      final textWidget = title as Text;
      return Text(
        textWidget.data!,
        style: textWidget.style?.copyWith(
          fontSize: FSizes.appBarFontSize,
          color: titleColor ?? (dark ? Colors.white : Colors.black),
        ) ??
            TextStyle(
              fontSize: FSizes.appBarFontSize,
              color: titleColor ?? (dark ? Colors.white : Colors.black),
            ),
      );
    }

    return title!;
  }

  List<Widget>? _buildActions(BuildContext context, bool dark) {
    final List<Widget> actionWidgets = [];

    // 添加自定义的action按钮
    if (actionButton != null) {
      actionWidgets.add(actionButton!);
    }
    // 添加通用的action按钮
    else if (actionButtonText != null || actionButtonIcon != null) {
      actionWidgets.add(
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: FColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onActionButtonPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionButtonIcon != null) ...[
                      Icon(
                        actionButtonIcon,
                        size: 18,
                        color: FColors.primary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (actionButtonText != null)
                      Text(
                        actionButtonText!,
                        style: TextStyle(
                          color: FColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 添加其他自定义actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  @override
  Size get preferredSize => Size.fromHeight(FDeviceUtils.getAppBarHeight());
}