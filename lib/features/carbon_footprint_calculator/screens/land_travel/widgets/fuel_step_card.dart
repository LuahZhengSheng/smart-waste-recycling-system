import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';


/// Generic step card container
class FuelStepCard extends StatelessWidget {
  const FuelStepCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.sm),
      decoration: BoxDecoration(
        color:
        dark ? FColors.darkBackground : FColors.lightContainer,
        borderRadius:
        BorderRadius.circular(FSizes.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: dark
                  ? FColors.darkGrey
                  : FColors.textSecondary,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          child,
        ],
      ),
    );
  }
}