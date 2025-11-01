import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    final isDark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text(
          'Personal Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        showBackArrow: true,
        actions: [
          Obx(() => IconButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.toggleEditMode,
                icon: Icon(
                  controller.isEditing.value ? Icons.close : Iconsax.edit,
                  color: controller.isEditing.value
                      ? FColors.error
                      : FColors.primary,
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage =
                          controller.profileController.user.value.profileImg;
                      final image =
                          networkImage != null && networkImage.isNotEmpty
                              ? NetworkImage(networkImage)
                              : null;

                      return GestureDetector(
                        onTap: controller.profileController.viewProfileImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? FColors.darkContainer
                                    : FColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: FColors.primary.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: image,
                                backgroundColor: FColors.light,
                                child: image == null
                                    ? Icon(
                                        Iconsax.user,
                                        size: 40,
                                        color: FColors.darkGrey,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: controller
                                    .profileController.showImageSourceSelection,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FColors.primary,
                                        FColors.primary.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: FColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: controller.profileController
                                          .imageUploading.value
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Iconsax.camera,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: FSizes.md),
                    Text(
                      'Tap to view or change profile picture',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: FColors.darkGrey,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwSections),

              /// Form Section
              Form(
                key: controller.updateUserFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Basic Information
                    _buildSectionTitle(context, 'Basic Information'),
                    const SizedBox(height: FSizes.md),

                    Obx(() => _buildTextField(
                          context,
                          controller: controller.username,
                          label: 'Username',
                          icon: Iconsax.user_edit,
                          enabled: controller.isEditing.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        )),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    _buildTextField(
                      context,
                      controller: controller.email,
                      label: 'Email',
                      icon: Iconsax.direct,
                      enabled: false,
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    Obx(() => _buildTextField(
                          context,
                          controller: controller.phoneNumber,
                          label: 'Phone Number',
                          icon: Iconsax.call,
                          keyboardType: TextInputType.phone,
                          enabled: controller.isEditing.value,
                          validator: controller.validateMalaysianPhoneNumber,
                        )),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    /// Personal Information
                    _buildSectionTitle(context, 'Personal Information'),
                    const SizedBox(height: FSizes.md),

                    Obx(() => controller.isEditing.value
                        ? _buildDropdownField(
                            context,
                            selectedValue: controller.selectedGender.value,
                            label: 'Gender',
                            icon: Iconsax.man,
                            items: controller.genderOptions,
                            enabled: true,
                            onChanged: (value) {
                              controller.selectedGender.value = value;
                            },
                          )
                        : _buildReadOnlyGenderField(
                            context,
                            value: controller.selectedGender.value,
                            label: 'Gender',
                            icon: Iconsax.man,
                          )),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    Obx(() => _buildDateField(
                          context,
                          controller: controller.dateOfBirth,
                          label: 'Date of Birth',
                          icon: Iconsax.calendar,
                          enabled: controller.isEditing.value,
                          onTap: () => controller.selectDate(context),
                        )),

                    const SizedBox(height: FSizes.spaceBtwSections * 1.5),

                    /// Save Button (only show when editing)
                    Obx(() => controller.isEditing.value
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () => controller.updateUserProfile(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: FColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: FSizes.md),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          FSizes.borderRadiusLg),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: FSizes.md),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.resetForm,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: FSizes.md),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          FSizes.borderRadiusLg),
                                    ),
                                    side: BorderSide(color: FColors.darkGrey),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: FColors.darkGrey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox()),

                    const SizedBox(height: FSizes.defaultSpace),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: FColors.primary,
          ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    String? helperText,
  }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? (isDark ? FColors.darkContainer : FColors.white)
            : (isDark
                ? FColors.darkerGrey.withOpacity(0.3)
                : FColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled
                  ? (isDark ? FColors.white : FColors.black)
                  : FColors.darkGrey,
            ),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FColors.darkGrey,
              ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: enabled
                  ? FColors.primary.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? FColors.primary : FColors.darkGrey,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: FColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: FColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: FColors.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled
              ? (isDark ? FColors.darkContainer : FColors.white)
              : (isDark
                  ? FColors.darkerGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.3)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
      ),
    );
  }

  // 下拉菜单构建方法（仅在编辑模式下使用）
  Widget _buildDropdownField(
    BuildContext context, {
    required String? selectedValue,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? (isDark ? FColors.darkContainer : FColors.white)
            : (isDark
                ? FColors.darkerGrey.withOpacity(0.3)
                : FColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: enabled
                  ? FColors.primary.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? FColors.primary : FColors.darkGrey,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: FColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: enabled
              ? (isDark ? FColors.darkContainer : FColors.white)
              : (isDark
                  ? FColors.darkerGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.3)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? FColors.white : FColors.black,
                  ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: isDark ? FColors.darkContainer : FColors.white,
        icon: Icon(
          Iconsax.arrow_down_1,
          color: enabled ? FColors.primary : FColors.darkGrey,
          size: 20,
        ),
        hint: Text(
          'Select Gender',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FColors.darkGrey,
              ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? FColors.white : FColors.black,
            ),
      ),
    );
  }

  // 新增：只读模式下的性别显示
  Widget _buildReadOnlyGenderField(
    BuildContext context, {
    required String? value,
    required String label,
    required IconData icon,
  }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        readOnly: true,
        enabled: false,
        controller: TextEditingController(text: value ?? 'Not set'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FColors.darkGrey,
            ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: FColors.darkGrey,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark
              ? FColors.darkerGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final isDark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? (isDark ? FColors.darkContainer : FColors.white)
            : (isDark
                ? FColors.darkerGrey.withOpacity(0.3)
                : FColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: enabled ? onTap : null,
        enabled: enabled,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled
                  ? (isDark ? FColors.white : FColors.black)
                  : FColors.darkGrey,
            ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: enabled
                  ? FColors.primary.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? FColors.primary : FColors.darkGrey,
            ),
          ),
          suffixIcon: Icon(
            Iconsax.calendar_1,
            color: enabled ? FColors.primary : FColors.darkGrey,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: FColors.primary, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled
              ? (isDark ? FColors.darkContainer : FColors.white)
              : (isDark
                  ? FColors.darkerGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.3)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
      ),
    );
  }
}
