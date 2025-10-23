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
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        showBackArrow: true,
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
                      final networkImage = controller.profileController.user.value.profileImage;
                      final image = networkImage != null && networkImage.isNotEmpty
                          ? NetworkImage(networkImage)
                          : null;

                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? FColors.darkContainer : FColors.white,
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
                              onTap: controller.profileController.showImageSourceSelection,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [FColors.primary, FColors.primary.withOpacity(0.8)],
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
                                child: controller.profileController.imageUploading.value
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
                      );
                    }),
                    const SizedBox(height: FSizes.md),
                    Text(
                      'Change Profile Picture',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FColors.primary,
                        fontWeight: FontWeight.w500,
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

                    _buildTextField(
                      context,
                      controller: controller.username,
                      label: 'Username',
                      icon: Iconsax.user_edit,
                      validator: (value) => FValidator.validateEmptyText('Username', value),
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    _buildTextField(
                      context,
                      controller: controller.email,
                      label: 'Email',
                      icon: Iconsax.direct,
                      enabled: false,
                      helperText: 'Email cannot be changed',
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    _buildTextField(
                      context,
                      controller: controller.phoneNumber,
                      label: 'Phone Number',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      validator: (value) => FValidator.validatePhoneNumber(value),
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    /// Personal Information
                    _buildSectionTitle(context, 'Personal Information'),
                    const SizedBox(height: FSizes.md),

                    _buildDropdownField(
                      context,
                      controller: controller.gender,
                      label: 'Gender',
                      icon: Iconsax.man,
                      items: ['Male', 'Female', 'Other', 'Prefer not to say'],
                      onChanged: (value) => controller.gender.text = value ?? '',
                    ),
                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    _buildDateField(
                      context,
                      controller: controller.dateOfBirth,
                      label: 'Date of Birth',
                      icon: Iconsax.calendar,
                      onTap: () => controller.selectDate(context),
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections * 1.5),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                            () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.updateUserProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                            ),
                            elevation: 0,
                            shadowColor: FColors.primary.withOpacity(0.3),
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

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
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        style: Theme.of(context).textTheme.bodyMedium,
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
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(icon, size: 20, color: FColors.primary),
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
          filled: true,
          fillColor: isDark ? FColors.darkContainer : FColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required List<String> items,
        required Function(String?) onChanged,
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
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(icon, size: 20, color: FColors.primary),
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
          fillColor: isDark ? FColors.darkContainer : FColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: isDark ? FColors.darkContainer : FColors.white,
        icon: Icon(Iconsax.arrow_down_1, color: FColors.primary, size: 20),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required VoidCallback onTap,
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
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(FSizes.sm),
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Icon(icon, size: 20, color: FColors.primary),
          ),
          suffixIcon: Icon(Iconsax.calendar_1, color: FColors.primary, size: 20),
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
          fillColor: isDark ? FColors.darkContainer : FColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.md,
          ),
        ),
      ),
    );
  }
}

// Validator class (if not exists)
class FValidator {
  static String? validateEmptyText(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Remove all non-digit characters
    final phoneNumber = value.replaceAll(RegExp(r'\D'), '');

    // Check if it's a valid length (10-11 digits)
    if (phoneNumber.length < 10 || phoneNumber.length > 11) {
      return 'Invalid phone number format';
    }

    return null;
  }
}