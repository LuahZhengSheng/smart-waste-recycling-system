import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/create_post_controller.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FPostTypeSelector extends StatelessWidget {
  const FPostTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatePostController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(
          () => Row(
        children: [
          Expanded(
            child: _PostTypeChip(
              label: 'Tip',
              icon: Iconsax.lamp_on,
              type: 'tip',
              isSelected: controller.selectedPostType == 'tip',
              dark: dark,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: _PostTypeChip(
              label: 'Discussion',
              icon: Iconsax.messages_3,
              type: 'discussion',
              isSelected: controller.selectedPostType == 'discussion',
              dark: dark,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: _PostTypeChip(
              label: 'Question',
              icon: Iconsax.message_question,
              type: 'question',
              isSelected: controller.selectedPostType == 'question',
              dark: dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String type;
  final bool isSelected;
  final bool dark;

  const _PostTypeChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.isSelected,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatePostController>();

    return InkWell(
      onTap: () => controller.setPostType(type),
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: FSizes.md,
          horizontal: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? FColors.primary
              : (dark ? FColors.darkerGrey : FColors.white),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: isSelected
                ? FColors.primary
                : (dark ? FColors.darkGrey : FColors.grey.withOpacity(0.3)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: FColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? FColors.white
                  : (dark ? FColors.white : FColors.black),
              size: FSizes.iconMd,
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? FColors.white
                    : (dark ? FColors.white : FColors.black),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}