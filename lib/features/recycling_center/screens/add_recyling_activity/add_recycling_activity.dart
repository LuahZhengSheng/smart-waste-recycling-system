import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../community/screens/create_post/widgets/media_lightbox.dart';
import '../../../personalization/models/recycle_activity_model.dart';
import '../../controllers/add_activity_controller.dart';
import '../../controllers/center_staff_home_controller.dart';

class AddRecyclingActivityScreen extends StatelessWidget {
  final bool isEditing;
  final int? editIndex;
  final RecyclingActivity? existingActivity;

  const AddRecyclingActivityScreen({
    super.key,
    required this.isEditing,
    this.editIndex,
    this.existingActivity,
  });

  @override
  Widget build(BuildContext context) {
    final staffController = Get.find<StaffHomeController>();
    final controller = Get.put(
      AddActivityFormController(
        isEditing: isEditing,
        existingActivity: existingActivity,
        wasteCategories: staffController.wasteCategories,
      ),
    );
    final dark = FHelperFunctions.isDarkMode(context);

    return WillPopScope(
      onWillPop: () async {
        if (controller.hasUnsavedChanges) {
          return await _showUnsavedChangesDialog(controller);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: dark ? FColors.staffDarkBackground : FColors.staffLightBackground,
        appBar: FAppBar(
          title: Text(
            isEditing ? 'Edit Activity' : 'Add Recycling Activity',
            style: TextStyle(
              color: dark ? FColors.staffDarkText : FColors.staffLightText,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: dark ? FColors.staffDarkSurface : FColors.staffLightSurface,
          elevation: 0,
          showBackArrow: true,
          backArrowColor: dark ? FColors.staffDarkText : FColors.staffLightText,
          leadingOnPressed: () async {
            if (controller.hasUnsavedChanges) {
              if (await _showUnsavedChangesDialog(controller)) {
                Get.back();
              }
            } else {
              Get.back();
            }
          },
          centerTitle: true,
        ),
        body: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWasteCategorySection(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),

                _buildWasteObjectSection(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),

                _buildWeightSection(controller, dark),
                const SizedBox(height: FSizes.spaceBtwSections),

                _buildImageUploadSection(controller, dark, staffController),
                const SizedBox(height: FSizes.spaceBtwSections),

                Obx(() => controller.calculatedPoints.value > 0
                    ? _buildPointsPreview(controller, dark)
                    : const SizedBox()),

                if (controller.calculatedPoints.value > 0)
                  const SizedBox(height: FSizes.spaceBtwSections),

                _buildSubmitButton(staffController, controller, dark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWasteCategorySection(AddActivityFormController controller, bool dark) {
    return Container(
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
              Icon(
                Iconsax.category,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Waste Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.staffDarkText : FColors.staffLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          Obx(() => Wrap(
            spacing: FSizes.sm,
            runSpacing: FSizes.sm,
            children: controller.wasteCategories.map((category) {
              final isSelected = controller.selectedCategory.value?.categoryId == category.categoryId;

              return GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
                        : (dark ? FColors.staffDarkSurfaceVariant : FColors.staffLightSurfaceVariant),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    border: Border.all(
                      color: isSelected
                          ? (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
                          : (dark ? FColors.staffDarkBorder : FColors.staffLightBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected
                            ? Colors.white
                            : (dark ? FColors.staffDarkText : FColors.staffLightText),
                        size: 16,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (dark ? FColors.staffDarkText : FColors.staffLightText),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildWasteObjectSection(AddActivityFormController controller, bool dark) {
    return Container(
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
              Icon(
                Iconsax.edit,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Waste Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.staffDarkText : FColors.staffLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          TextFormField(
            controller: controller.wasteObjectController,
            validator: controller.validateWasteObject,
            decoration: InputDecoration(
              labelText: 'Waste Item Description',
              hintText: 'e.g., Plastic bottles, Newspaper, Old laptop',
              prefixIcon: const Icon(Iconsax.document_text),
              filled: true,
              fillColor: dark ? FColors.staffDarkSurfaceVariant : FColors.staffLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide(
                  color: dark ? FColors.staffDarkBorder : FColors.staffLightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide(
                  color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSection(AddActivityFormController controller, bool dark) {
    return Container(
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
              Icon(
                Iconsax.weight_1,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Weight (kg)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.staffDarkText : FColors.staffLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          TextFormField(
            controller: controller.weightController,
            validator: controller.validateWeight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => controller.calculatePoints(),
            decoration: InputDecoration(
              labelText: 'Weight',
              hintText: '0.00',
              prefixIcon: const Icon(Iconsax.weight_1),
              suffixText: 'kg',
              filled: true,
              fillColor: dark ? FColors.staffDarkSurfaceVariant : FColors.staffLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide(
                  color: dark ? FColors.staffDarkBorder : FColors.staffLightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.inputFieldRadius),
                borderSide: BorderSide(
                  color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(AddActivityFormController controller, bool dark, StaffHomeController staffController) {
    return Container(
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
              Icon(
                Iconsax.camera,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Support Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.staffDarkText : FColors.staffLightText,
                ),
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                '* (Max 1 image, 10MB)',
                style: TextStyle(
                  color: dark ? FColors.staffDarkError : FColors.staffLightError,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          Obx(() {
            if (controller.selectedImage.value != null) {
              return _buildImagePreview(controller, dark);
            } else if (controller.hasExistingImage.value && isEditing) {
              return _buildNetworkImagePreview(controller, dark, staffController);
            } else {
              return _buildImageUploadButton(controller, dark);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton(AddActivityFormController controller, bool dark) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.staffDarkSurfaceVariant : FColors.staffLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          border: Border.all(
            color: dark
                ? FColors.staffDarkPrimary.withOpacity(0.3)
                : FColors.staffLightPrimary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                color: dark
                    ? FColors.staffDarkPrimary.withOpacity(0.2)
                    : FColors.staffLightPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
              child: Icon(
                Iconsax.camera,
                color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                size: FSizes.iconLg,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Tap to upload image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark ? FColors.staffDarkText : FColors.staffLightText,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Take a photo of the waste items',
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(AddActivityFormController controller, bool dark) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            final mediaItem = UnifiedMediaItem.file(
              id: 'selected_image_${DateTime.now().millisecondsSinceEpoch}',
              file: controller.selectedImage.value!,
              isVideo: false,
            );
            Get.to(() => UnifiedMediaLightbox(
              mediaItems: [mediaItem],
              initialIndex: 0,
            ));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            child: Image.file(
              controller.selectedImage.value!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: FSizes.sm,
          right: FSizes.sm,
          child: GestureDetector(
            onTap: controller.removeImage,
            child: Container(
              padding: const EdgeInsets.all(FSizes.xs),
              decoration: BoxDecoration(
                color: dark ? FColors.staffDarkError : FColors.staffLightError,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: const Icon(
                Iconsax.close_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: FSizes.sm,
          left: FSizes.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: const Text(
              'Tap to view fullscreen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImagePreview(AddActivityFormController controller, bool dark, StaffHomeController staffController) {
    // Use the controller method to get the image URL
    final imageUrl = controller.getExistingImageUrl(staffController.userId.value);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl.isNotEmpty) {
              final mediaItem = UnifiedMediaItem.network(
                id: 'network_image_${DateTime.now().millisecondsSinceEpoch}',
                networkUrl: imageUrl,
                isVideo: false,
              );
              Get.to(() => UnifiedMediaLightbox(
                mediaItems: [mediaItem],
                initialIndex: 0,
              ));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: dark ? Colors.grey[800] : Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Image loading error: $error');
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: dark ? Colors.grey[800] : Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.gallery_slash,
                        color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                        size: 40,
                      ),
                      const SizedBox(height: FSizes.sm),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: FSizes.xs),
                      Text(
                        'URL: ${imageUrl.substring(0, 50)}...',
                        style: TextStyle(
                          color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
                : Container(
              height: 200,
              width: double.infinity,
              color: dark ? Colors.grey[800] : Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.gallery_slash,
                    color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                    size: 40,
                  ),
                  const SizedBox(height: FSizes.sm),
                  Text(
                    'No image available',
                    style: TextStyle(
                      color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: FSizes.sm,
          right: FSizes.sm,
          child: GestureDetector(
            onTap: controller.removeImage,
            child: Container(
              padding: const EdgeInsets.all(FSizes.xs),
              decoration: BoxDecoration(
                color: dark ? FColors.staffDarkError : FColors.staffLightError,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: const Icon(
                Iconsax.close_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        if (imageUrl.isNotEmpty)
          Positioned(
            bottom: FSizes.sm,
            left: FSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: const Text(
                'Tap to view fullscreen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPointsPreview(AddActivityFormController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.staffDarkSecondary.withOpacity(0.1)
            : FColors.staffLightSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: const Icon(
              Iconsax.crown1,
              color: Colors.white,
              size: FSizes.iconLg,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Points Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.staffDarkText : FColors.staffLightText,
                  ),
                ),
                Text(
                  'User will earn ${controller.calculatedPoints.value} points',
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${controller.calculatedPoints.value}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(StaffHomeController staffController, AddActivityFormController controller, bool dark) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => _submitForm(staffController, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? FColors.staffDarkSecondary : FColors.staffLightSecondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.buttonRadius),
          ),
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
            Icon(isEditing ? Iconsax.edit : Iconsax.add),
            const SizedBox(width: FSizes.sm),
            Text(
              isEditing ? 'Update Activity' : 'Add Activity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _submitForm(StaffHomeController staffController, AddActivityFormController controller) async {
    if (controller.validateForm()) {
      try {
        final activity = controller.createActivity(
          staffController.userId.value,
          staffController.staffId.value,
        );

        // Get the image file
        final imageFile = controller.getImageFile();

        bool success;
        if (isEditing && editIndex != null) {
          success = await staffController.editRecyclingActivity(editIndex!, activity, imageFile);
        } else {
          success = await staffController.addRecyclingActivity(activity, imageFile);
        }

        if (success) {
          // Navigate back to assign points screen
          Get.back();
        } else {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to ${isEditing ? 'update' : 'add'} activity',
          );
        }
      } catch (e) {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to ${isEditing ? 'update' : 'add'} activity: $e',
        );
      }
    }
  }

  Future<bool> _showUnsavedChangesDialog(AddActivityFormController controller) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}