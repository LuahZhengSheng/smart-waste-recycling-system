import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class FPostActions extends StatelessWidget {
  final PostModel post;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onSharePressed;

  const FPostActions({
    super.key,
    required this.post,
    required this.isLiked,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like Button
        _ActionButton(
          icon: isLiked ? Iconsax.like_15 : Iconsax.like_1,
          count: post.likes.length,
          isActive: isLiked,
          onPressed: onLikePressed,
          dark: dark,
        ),
        const SizedBox(width: FSizes.md),

        // Comment Button
        _ActionButton(
          icon: Iconsax.message,
          count: post.commentCount,
          isActive: false,
          onPressed: onCommentPressed,
          dark: dark,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback? onPressed;
  final bool dark;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.isActive,
    this.onPressed,
    required this.dark,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.sm,
                vertical: FSizes.xs,
              ),
              decoration: BoxDecoration(
                color: _isPressed
                    ? (widget.dark
                    ? FColors.communityDarkBorder
                    : FColors.grey.withOpacity(0.2))
                    : (widget.dark
                    ? FColors.communityDarkSurface
                    : FColors.lightContainer),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
                // border: Border.all(
                //   color: widget.isActive
                //       ? FColors.primary
                //       : (widget.dark
                //       ? FColors.communityDarkBorder
                //       : FColors.grey.withOpacity(0.3)),
                //   width: widget.isActive ? 1.5 : 1,
                // ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isActive
                        ? FColors.primary
                        : (widget.dark
                        ? FColors.darkTextSecondary
                        : FColors.textSecondary),
                    size: FSizes.iconSm,
                  ),
                  if (widget.count > 0) ...[
                    const SizedBox(width: FSizes.xs),
                    Text(
                      _formatCount(widget.count),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: widget.isActive
                            ? FColors.primary
                            : (widget.dark
                            ? FColors.darkTextSecondary
                            : FColors.textSecondary),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}