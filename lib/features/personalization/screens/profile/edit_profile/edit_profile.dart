import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({
    super.key,
    this.isStaffProfile = false,
  });

  final bool isStaffProfile;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    final dark = FHelperFunctions.isDarkMode(context);

    // 根据是否是 staff profile 选择颜色主题
    final Color primaryColor = isStaffProfile
        ? (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)
        : FColors.primary;

    final Color backgroundColor = isStaffProfile
        ? (dark ? FColors.staffDarkBackground : FColors.staffLightBackground)
        : (dark ? FColors.dark : FColors.light);

    final Color surfaceColor = isStaffProfile
        ? (dark ? FColors.staffDarkSurface : FColors.staffLightSurface)
        : (dark ? FColors.darkContainer : FColors.white);

    final Color textColor = isStaffProfile
        ? (dark ? FColors.staffDarkText : FColors.staffLightText)
        : (dark ? FColors.white : FColors.black);

    final Color textSecondaryColor = isStaffProfile
        ? (dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary)
        : FColors.darkGrey;

    final Color borderColor = isStaffProfile
        ? (dark ? FColors.staffDarkBorder : FColors.staffLightBorder)
        : (dark ? FColors.darkGrey : FColors.grey);

    final Color errorColor = isStaffProfile
        ? (dark ? FColors.staffDarkError : FColors.staffLightError)
        : FColors.error;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: FAppBar(
        showBackArrow: true,
        backgroundColor: backgroundColor,
        title: const Text('Personal Information'),
        actions: [
          Obx(() => IconButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.toggleEditMode,
            icon: Icon(
              controller.isEditing.value ? Icons.close : Iconsax.edit,
              color: controller.isEditing.value
                  ? errorColor
                  : primaryColor,
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
                                color: surfaceColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.1),
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
                                  color: textSecondaryColor,
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
                                        primaryColor,
                                        primaryColor.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
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
                        color: textSecondaryColor,
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
                    _buildSectionTitle(context, 'Basic Information', primaryColor),
                    const SizedBox(height: FSizes.md),

                    Obx(() => _buildTextField(
                      context,
                      controller: controller.username,
                      label: 'Username',
                      icon: Iconsax.user_edit,
                      enabled: controller.isEditing.value,
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      textSecondaryColor: textSecondaryColor,
                      borderColor: borderColor,
                      errorColor: errorColor,
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
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      textSecondaryColor: textSecondaryColor,
                      borderColor: borderColor,
                      errorColor: errorColor,
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    Obx(() => _buildTextField(
                      context,
                      controller: controller.phoneNumber,
                      label: 'Phone Number',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      enabled: controller.isEditing.value,
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      textSecondaryColor: textSecondaryColor,
                      borderColor: borderColor,
                      errorColor: errorColor,
                      validator: controller.validateMalaysianPhoneNumber,
                    )),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    /// Personal Information
                    _buildSectionTitle(context, 'Personal Information', primaryColor),
                    const SizedBox(height: FSizes.md),

                    Obx(() => controller.isEditing.value
                        ? _buildDropdownField(
                      context,
                      selectedValue: controller.selectedGender.value,
                      label: 'Gender',
                      icon: Iconsax.man,
                      items: controller.genderOptions,
                      enabled: true,
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      textSecondaryColor: textSecondaryColor,
                      borderColor: borderColor,
                      onChanged: (value) {
                        controller.selectedGender.value = value;
                      },
                    )
                        : _buildReadOnlyGenderField(
                      context,
                      value: controller.selectedGender.value,
                      label: 'Gender',
                      icon: Iconsax.man,
                      surfaceColor: surfaceColor,
                      textSecondaryColor: textSecondaryColor,
                    )),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    Obx(() => _buildDateField(
                      context,
                      controller: controller.dateOfBirth,
                      label: 'Date of Birth',
                      icon: Iconsax.calendar,
                      enabled: controller.isEditing.value,
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      textSecondaryColor: textSecondaryColor,
                      borderColor: borderColor,
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
                              backgroundColor: primaryColor,
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
                              side: BorderSide(color: textSecondaryColor),
                            ),
                            child: Text(
                              'Cancel',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: textSecondaryColor,
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

  Widget _buildSectionTitle(BuildContext context, String title, Color primaryColor) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required Color primaryColor,
        required Color surfaceColor,
        required Color textColor,
        required Color textSecondaryColor,
        required Color borderColor,
        required Color errorColor,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        bool enabled = true,
        String? helperText,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? surfaceColor
            : (dark
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
              ? textColor
              : textSecondaryColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textSecondaryColor,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: enabled
                  ? primaryColor.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? primaryColor : textSecondaryColor,
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
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide(color: errorColor, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled
              ? surfaceColor
              : (dark
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
        required Color primaryColor,
        required Color surfaceColor,
        required Color textColor,
        required Color textSecondaryColor,
        required Color borderColor,
        bool enabled = true,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? surfaceColor
            : (dark
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
                  ? primaryColor.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? primaryColor : textSecondaryColor,
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
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: enabled
              ? surfaceColor
              : (dark
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
                color: textColor,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: surfaceColor,
        icon: Icon(
          Iconsax.arrow_down_1,
          color: enabled ? primaryColor : textSecondaryColor,
          size: 20,
        ),
        hint: Text(
          'Select Gender',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textSecondaryColor,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor,
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
        required Color surfaceColor,
        required Color textSecondaryColor,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
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
          color: textSecondaryColor,
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
              color: textSecondaryColor,
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
          fillColor: dark
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
        required Color primaryColor,
        required Color surfaceColor,
        required Color textColor,
        required Color textSecondaryColor,
        required Color borderColor,
        bool enabled = true,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? surfaceColor
            : (dark
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
              ? textColor
              : textSecondaryColor,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: enabled
                  ? primaryColor.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? primaryColor : textSecondaryColor,
            ),
          ),
          suffixIcon: Icon(
            Iconsax.calendar_1,
            color: enabled ? primaryColor : textSecondaryColor,
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
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: enabled
              ? surfaceColor
              : (dark
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