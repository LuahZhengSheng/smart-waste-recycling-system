import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

class MyVerticalImageText extends StatelessWidget {
  const MyVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = MyColors.white,
    this.backgroundColor = MyColors.white,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: MySizes.spaceBtwItems),
        child: Column(
            children: [

              /// Circular Icon
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(MySizes.sm),
                decoration: BoxDecoration(
                  color: backgroundColor ?? (MyHelperFunctions.isDarkMode(context) ? MyColors.black : MyColors.white),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Image(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                      color: dark ? MyColors.light : MyColors.dark),
                ),
              ),

              /// Text
              const SizedBox(height: MySizes.spaceBtwItems / 2),
              SizedBox(
                width: 55,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
                ),
              ),
            ]
        ),
      ),
    );
  }
}