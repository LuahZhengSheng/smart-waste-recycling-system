import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../community/screens/create_post/widgets/media_lightbox.dart';
import '../../controllers/center_staff_home_controller.dart';
import '../add_recyling_activity/add_recycling_activity.dart';

class AssignPointsScreen extends StatelessWidget {
  const AssignPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StaffHomeController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return WillPopScope(
      onWillPop: () async {
        return await _showDiscardDialog(controller);
      },
      child: Scaffold(
        backgroundColor: dark ? FColors.staffDarkBackground : FColors.staffLightBackground,
        appBar: FAppBar(
          title: Text(
            'Assign Points',
            style: TextStyle(
              color: dark ? FColors.staffDarkText : FColors.staffLightText,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: dark ? FColors.staffDarkSurface : FColors.staffLightSurface,
          showBackArrow: true,
          backArrowColor: dark ? FColors.staffDarkText : FColors.staffLightText,
          leadingOnPressed: () async {
            if (await _showDiscardDialog(controller)) {
              Get.back();
            }
          },
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildUserInfoHeader(controller, dark),
            Expanded(
              child: _buildActivitiesList(context, controller, dark),
            ),
            _buildSubmitButton(controller, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoHeader(StaffHomeController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      margin: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        gradient: dark ? FColors.staffPrimaryGradient : FColors.staffPrimaryGradient,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black38 : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          children: [
            FutureBuilder<String?>(
              future: controller.getUserProfileImageUrl(),
              builder: (context, snapshot) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    child: snapshot.hasData && snapshot.data != null
                        ? Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Iconsax.user,
                          color: FColors.staffLightPrimary,
                          size: 32,
                        );
                      },
                    )
                        : const Icon(
                      Iconsax.user,
                      color: FColors.staffLightPrimary,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    controller.userEmail.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.coin_1,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        '${controller.userRewardPoints.value} points',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActivitiesList(BuildContext context, StaffHomeController controller, bool dark) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md),
      itemCount: controller.currentActivitiesWithImages.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.currentActivitiesWithImages.length) {
          return _buildAddActivityCard(context, controller, dark);
        } else {
          return _buildActivityCard(context, controller, index, dark);
        }
      },
    ));
  }

  Widget _buildAddActivityCard(BuildContext context, StaffHomeController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => const AddRecyclingActivityScreen(
            isEditing: false,
          )),
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(FSizes.lg),
            decoration: BoxDecoration(
              color: dark ? FColors.staffDarkSurface : FColors.staffLightSurface,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              border: Border.all(
                color: dark
                    ? FColors.staffDarkPrimary.withOpacity(0.3)
                    : FColors.staffLightPrimary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: dark
                        ? FColors.staffDarkPrimary.withOpacity(0.2)
                        : FColors.staffLightPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                  ),
                  child: Icon(
                    Iconsax.add_circle,
                    color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                    size: FSizes.iconLg,
                  ),
                ),
                const SizedBox(height: FSizes.md),
                Text(
                  'Add Recycling Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.staffDarkText : FColors.staffLightText,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Tap to add a new waste item',
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, StaffHomeController controller, int index, bool dark) {
    final activityWithImage = controller.currentActivitiesWithImages[index];
    final activity = activityWithImage.activity;
    final imageFile = activityWithImage.imageFile;

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.staffDarkSurface : FColors.staffLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.staffDarkSecondary.withOpacity(0.2)
                      : FColors.staffLightSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
                child: Icon(
                  Iconsax.trash,
                  color: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
                  size: FSizes.iconMd,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.wasteObject,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.staffDarkText : FColors.staffLightText,
                      ),
                    ),
                    Text(
                      '${activity.formattedWeight} • ${activity.pointsEarned} points',
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => Get.to(() => AddRecyclingActivityScreen(
                      isEditing: true,
                      editIndex: index,
                      existingActivity: activity,
                    )),
                    icon: Icon(
                      Iconsax.edit,
                      color: dark ? FColors.staffDarkInfo : FColors.staffLightInfo,
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.deleteRecyclingActivity(index),
                    icon: Icon(
                      Iconsax.trash,
                      color: dark ? FColors.staffDarkError : FColors.staffLightError,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Show image preview from File (not uploaded yet)
          if (imageFile != null) ...[
            const SizedBox(height: FSizes.md),
            GestureDetector(
              onTap: () {
                final mediaItem = UnifiedMediaItem.file(
                  id: 'activity_image_${activity.activityId}_${DateTime.now().millisecondsSinceEpoch}',
                  file: imageFile,
                  isVideo: false,
                );
                Get.to(() => UnifiedMediaLightbox(
                  mediaItems: [mediaItem],
                  initialIndex: 0,
                ));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                child: Image.file(
                  imageFile,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(StaffHomeController controller, bool dark) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Column(
        children: [
          if (controller.currentActivitiesWithImages.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              margin: const EdgeInsets.only(bottom: FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.staffDarkSecondary.withOpacity(0.1)
                    : FColors.staffLightSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
                border: Border.all(
                  color: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${controller.currentActivitiesWithImages.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.staffDarkText : FColors.staffLightText,
                        ),
                      ),
                      Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${controller.totalSessionWeight.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.staffDarkText : FColors.staffLightText,
                        ),
                      ),
                      Text(
                        'Total Weight',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${controller.totalSessionPoints}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
                        ),
                      ),
                      Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.currentActivitiesWithImages.isEmpty
                  ? null
                  : (controller.isLoading.value ? null : controller.submitAllActivities),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                ),
                elevation: controller.currentActivitiesWithImages.isEmpty ? 0 : 4,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.send_1),
                  const SizedBox(width: FSizes.sm),
                  Text(
                    controller.currentActivitiesWithImages.isEmpty
                        ? 'Add Activities First'
                        : 'Submit All Activities',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<bool> _showDiscardDialog(StaffHomeController controller) async {
    if (controller.currentActivitiesWithImages.isEmpty) {
      return true;
    }

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved activities. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.resetForm();
              Get.back(result: true);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}