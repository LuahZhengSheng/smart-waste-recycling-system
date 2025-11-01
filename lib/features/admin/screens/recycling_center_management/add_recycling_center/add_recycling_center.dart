import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../../common/widgets/inputs/location_input_dialog.dart';
import '../../../controllers/recycling_center_management/add_center_controller.dart';

class AddPartnerCenterScreen extends StatelessWidget {
  const AddPartnerCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddPartnerCenterController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Add Partner Recycling Center',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Save Draft Button
          TextButton.icon(
            onPressed: controller.saveDraft,
            icon: Icon(
              Iconsax.save_2,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              size: 18,
            ),
            label: Text(
              'Save Draft',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: FSizes.sm),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(controller, dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Basic Information Section
              _buildSectionCard(
                dark: dark,
                title: 'Basic Information',
                icon: Iconsax.building,
                child: Column(
                  children: [
                    // Center Name
                    _buildInputField(
                      controller: controller.nameController,
                      label: 'Center Name',
                      hint: 'e.g., Green Recycling Center KL',
                      icon: Iconsax.building_4,
                      dark: dark,
                      validator: controller.validateName,
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    // Email and Phone Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: controller.emailController,
                            label: 'Email Address',
                            hint: 'center@example.com',
                            icon: Iconsax.sms,
                            dark: dark,
                            keyboardType: TextInputType.emailAddress,
                            validator: controller.validateEmail,
                          ),
                        ),
                        const SizedBox(width: FSizes.md),
                        Expanded(
                          child: _buildInputField(
                            controller: controller.phoneController,
                            label: 'Phone Number',
                            hint: '+60 12-345 6789',
                            icon: Iconsax.call,
                            dark: dark,
                            keyboardType: TextInputType.phone,
                            validator: controller.validatePhone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    // Website
                    _buildInputField(
                      controller: controller.websiteController,
                      label: 'Website',
                      hint: 'https://www.example.com',
                      icon: Iconsax.global,
                      dark: dark,
                      keyboardType: TextInputType.url,
                      validator: controller.validateWebsite,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Location Section
              _buildSectionCard(
                dark: dark,
                title: 'Location',
                icon: Iconsax.location,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => controller.selectedLocation.value == null
                        ? _buildLocationSelector(controller, dark)
                        : _buildLocationDisplay(controller, dark)),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Center Image Section
              _buildSectionCard(
                dark: dark,
                title: 'Center Image',
                icon: Iconsax.gallery,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => controller.selectedImage.value == null
                        ? _buildImageUploader(controller, dark)
                        : _buildImagePreview(controller, dark)),
                    const SizedBox(height: FSizes.sm),
                    Text(
                      'Upload a clear image of the recycling center. This will be displayed in the app.',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Operating Hours Section
              _buildSectionCard(
                dark: dark,
                title: 'Operating Hours',
                icon: Iconsax.clock,
                child: _buildOperatingHours(controller, dark),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              // Staff and Status Section
              _buildSectionCard(
                dark: dark,
                title: 'Additional Information',
                icon: Iconsax.user_octagon,
                child: Column(
                  children: [
                    // Staff Count
                    _buildInputField(
                      controller: controller.staffCountController,
                      label: 'Number of Staff',
                      hint: 'e.g., 15',
                      icon: Iconsax.people,
                      dark: dark,
                      keyboardType: TextInputType.number,
                      validator: controller.validateStaffCount,
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    // Status Dropdown
                    _buildDropdownField<String>(
                      value: controller.selectedStatus.value,
                      onChanged: (value) => controller.selectedStatus.value = value!,
                      label: 'Status',
                      hint: 'Select center status',
                      icon: Iconsax.status,
                      dark: dark,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      ],
                      validator: controller.validateStatus,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections * 2),

              // Action Buttons
              _buildActionButtons(controller, dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(AddPartnerCenterController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Progress',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Obx(() => LinearProgressIndicator(
            value: controller.formProgress.value,
            backgroundColor: dark
                ? FColors.adminDarkSurfaceVariant
                : FColors.adminLightSurfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
          )),
          const SizedBox(height: FSizes.xs),
          Obx(() => Text(
            '${(controller.formProgress.value * 100).toInt()}% Complete',
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool dark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
                  color: (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
                child: Icon(
                  icon,
                  color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool dark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            prefixIcon: Icon(
              icon,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required Function(T?) onChanged,
    required String label,
    required String hint,
    required IconData icon,
    required bool dark,
    required List<DropdownMenuItem<T>> items,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
            ),
            prefixIcon: Icon(
              icon,
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              borderSide: BorderSide(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                width: 1,
              ),
            ),
          ),
          dropdownColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
          items: items,
        ),
      ],
    );
  }

  Widget _buildLocationSelector(AddPartnerCenterController controller, bool dark) {
    return GestureDetector(
      onTap: () => _showLocationDialog(controller, dark),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark
                ? FColors.adminDarkBorder.withOpacity(0.3)
                : FColors.adminLightBorder.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.location_add,
              size: 32,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Add Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Tap to set the center location',
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDisplay(AddPartnerCenterController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.location_tick,
                color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                size: 20,
              ),
              const SizedBox(width: FSizes.sm),
              Expanded(
                child: Text(
                  'Location Set',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showLocationDialog(controller, dark),
                icon: Icon(
                  Iconsax.edit,
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  size: 18,
                ),
              ),
              IconButton(
                onPressed: controller.clearLocation,
                icon: Icon(
                  Iconsax.trash,
                  color: dark ? FColors.adminDarkError : FColors.adminLightError,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.sm),
          Obx(() => Text(
            controller.selectedLocation.value!.fullAddress,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          )),
        ],
      ),
    );
  }

  void _showLocationDialog(AddPartnerCenterController controller, bool dark) {
    Get.dialog(
      LocationInputDialog(
        dark: dark,
        initialLocation: controller.selectedLocation.value,
        onLocationSelected: controller.setLocation,
      ),
    );
  }

  Widget _buildImageUploader(AddPartnerCenterController controller, bool dark) {
    return GestureDetector(
      onTap: () => _showImagePickerDialog(controller, dark),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          border: Border.all(
            color: dark
                ? FColors.adminDarkBorder.withOpacity(0.3)
                : FColors.adminLightBorder.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gallery_add,
              size: 48,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Upload Center Image',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Tap to select image from gallery or take photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(AddPartnerCenterController controller, bool dark) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            child: Obx(() => Image.file(
              File(controller.selectedImage.value!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )),
          ),
          Positioned(
            top: FSizes.sm,
            right: FSizes.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                  ),
                  child: IconButton(
                    onPressed: () => _showImagePickerDialog(controller, dark),
                    icon: const Icon(
                      Iconsax.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.xs),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                  ),
                  child: IconButton(
                    onPressed: controller.clearImage,
                    icon: const Icon(
                      Iconsax.trash,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog(AddPartnerCenterController controller, bool dark) {
    Get.dialog(
      Dialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Container(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.pickImage(ImageSource.camera);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      icon: const Icon(Iconsax.camera, color: Colors.white),
                      label: const Text('Camera', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.pickImage(ImageSource.gallery);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark ? FColors.adminDarkSecondary : FColors.adminLightSecondary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                        ),
                      ),
                      icon: const Icon(Iconsax.gallery, color: Colors.white),
                      label: const Text('Gallery', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatingHours(AddPartnerCenterController controller, bool dark) {
    return Column(
      children: [
        ...controller.daysOfWeek.map((day) {
          return Container(
            margin: const EdgeInsets.only(bottom: FSizes.md),
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectTime(day, 'open'),
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.md),
                          decoration: BoxDecoration(
                            color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                            border: Border.all(
                              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.clock,
                                size: 16,
                                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                              ),
                              const SizedBox(width: FSizes.sm),
                              Text(
                                controller.getTimeDisplay(day, 'open'),
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Text(
                      'to',
                      style: TextStyle(
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectTime(day, 'close'),
                        child: Container(
                          padding: const EdgeInsets.all(FSizes.md),
                          decoration: BoxDecoration(
                            color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                            border: Border.all(
                              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.clock,
                                size: 16,
                                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                              ),
                              const SizedBox(width: FSizes.sm),
                              Text(
                                controller.getTimeDisplay(day, 'close'),
                                style: TextStyle(
                                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(AddPartnerCenterController controller, bool dark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
              padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.createCenter,
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              padding: const EdgeInsets.symmetric(vertical: FSizes.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              disabledBackgroundColor: (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted).withOpacity(0.5),
            ),
            child: controller.isLoading.value
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Create Partner Center',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ),
      ],
    );
  }
}