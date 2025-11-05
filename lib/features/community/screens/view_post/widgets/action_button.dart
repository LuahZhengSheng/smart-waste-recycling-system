import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class FActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final bool hasHoverEffect;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const FActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    this.onPressed,
    this.hasHoverEffect = false,
    this.padding,
    this.borderRadius,
  });

  @override
  State<FActionButton> createState() => _FActionButtonState();
}

class _FActionButtonState extends State<FActionButton>
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
    if (widget.hasHoverEffect) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.hasHoverEffect) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.hasHoverEffect) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.hasHoverEffect ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding ?? const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: _isPressed && widget.hasHoverEffect
                    ? widget.backgroundColor.withOpacity(0.8)
                    : widget.backgroundColor,
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? FSizes.borderRadiusSm * 2,
                ),
                boxShadow: widget.hasHoverEffect
                    ? [
                  BoxShadow(
                    color: (dark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: _isPressed ? 2 : 4,
                    offset: Offset(0, _isPressed ? 1 : 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: FSizes.iconSm,
                    ),
                  ),
                  if (widget.text.isNotEmpty) ...[
                    const SizedBox(width: FSizes.xs),
                    Text(
                      widget.text,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: widget.textColor,
                        fontWeight: FontWeight.w500,
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
}