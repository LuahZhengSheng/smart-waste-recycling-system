import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

/// Segmented button for Step 1
class FuelSegmentButton extends StatelessWidget {
  const FuelSegmentButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius:
        BorderRadius.circular(FSizes.borderRadiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.sm,
            vertical: FSizes.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? FColors.landTravel.withOpacity(0.16)
                : (dark
                ? FColors.darkBackground
                : FColors.lightContainer),
            borderRadius:
            BorderRadius.circular(FSizes.borderRadiusMd),
            border: Border.all(
              color: selected
                  ? FColors.landTravel
                  : (dark
                  ? FColors.borderDark
                  : FColors.borderSecondary),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: FSizes.iconSm,
                color: selected
                    ? FColors.landTravel
                    : (dark
                    ? FColors.darkTextSecondary
                    : FColors.textSecondary),
              ),
              const SizedBox(width: FSizes.xs),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? FColors.landTravel
                        : (dark
                        ? FColors.darkTextSecondary
                        : FColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}