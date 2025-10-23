import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../controllers/waste_category_guide_controller.dart';
import '../guideline_detail/waste_category_guide_detail.dart';

class WasteCategoryGuideScreen extends StatelessWidget {
  const WasteCategoryGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WasteCategoryController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: Text(
          "Waste Guide",
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(FSizes.defaultSpace),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? FColors.darkContainer : FColors.white,
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.searchCategories,
                  decoration: InputDecoration(
                    hintText: 'Search waste categories...',
                    hintStyle: TextStyle(
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Iconsax.search_normal,
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                    ),
                    suffixIcon: Obx(() =>
                    controller.searchText.value.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      onPressed: controller.clearSearch,
                    )
                        : SizedBox(),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.md,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Categories Grid
          Obx(() {
            if (controller.isLoading.value) {
              return SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: FColors.primary,
                    ),
                  ),
                ),
              );
            }

            if (controller.filteredCategories.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: 64,
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                        SizedBox(height: FSizes.spaceBtwItems),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: FSizes.sm),
                        Text(
                          'Try adjusting your search terms',
                          style: TextStyle(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: FSizes.gridViewSpacing,
                  mainAxisSpacing: FSizes.gridViewSpacing,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final category = controller.filteredCategories[index];
                    return _CategoryCard(category: category, dark: dark);
                  },
                  childCount: controller.filteredCategories.length,
                ),
              ),
            );
          }),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: FSizes.spaceBtwSections),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final bool dark;

  const _CategoryCard({
    required this.category,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => WasteCategoryDetailScreen(category: category)),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(FSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon with background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 35,
                  color: category.color,
                ),
              ),

              SizedBox(height: FSizes.spaceBtwItems),

              // Category Name
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: FSizes.xs),

              // Recyclable indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: category.isRecyclable
                      ? FColors.success.withOpacity(0.1)
                      : FColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.isRecyclable ? Iconsax.tick_circle : Iconsax.close_circle,
                      size: 12,
                      color: category.isRecyclable ? FColors.success : FColors.warning,
                    ),
                    SizedBox(width: FSizes.xs),
                    Text(
                      category.isRecyclable ? 'Recyclable' : 'Non-recyclable',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: category.isRecyclable ? FColors.success : FColors.warning,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: FSizes.xs),

              // Points
              Text(
                '${category.basePoints} pts/kg',
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}