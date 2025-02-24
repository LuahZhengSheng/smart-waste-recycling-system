import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/device/device_utility.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class MySearchContainer extends StatelessWidget {
  const MySearchContainer({
    super.key, required this.text, this.icon, this.showBackground = true, this.showBorder = true,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MySizes.defaultSpace),
      child: Container(
        width: MyDeviceUtils.getScreenWidth(),
        padding: const EdgeInsets.all(MySizes.md),
        decoration: BoxDecoration(
          color: showBackground ? dark ? MyColors.dark : MyColors.light : Colors.transparent,
          borderRadius: BorderRadius.circular(MySizes.cardRadiusLg),
          border: showBorder ? Border.all(color: MyColors.grey) : null,
        ),
        child: Row(
          children: [
            const Icon(Iconsax.search_normal, color: MyColors.grey),
            const SizedBox(width: MySizes.spaceBtwItems),
            Text(text, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}