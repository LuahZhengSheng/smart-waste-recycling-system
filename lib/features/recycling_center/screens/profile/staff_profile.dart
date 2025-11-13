import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';

import '../../../personalization/controllers/profile_controller.dart';
import '../../../personalization/screens/recycle_activity/recycle_activity.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      body: Obx(() {
        // Show loading state while fetching user data
        if (controller.user.value.userId.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              /// -- Profile Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: dark
                        ? [dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary.withOpacity(0.8), dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary.withOpacity(0.6)]
                        : [dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary, dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(FSizes.defaultSpace),
                    child: Column(
                      children: [
                        /// App Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.navigateToEditProfile(),
                              icon: const Icon(Iconsax.edit, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: FSizes.spaceBtwSections),

                        /// Profile Picture & Info
                        _buildProfileHeader(context, controller, dark),
                      ],
                    ),
                  ),
                ),
              ),

              /// -- Profile Options (QR Code section removed from here)
              Padding(
                padding: const EdgeInsets.all(FSizes.defaultSpace),
                child: Column(
                  children: [
                    /// Profile Information Section
                    _buildSectionTitle(context, 'Profile Information'),
                    const SizedBox(height: FSizes.sm),
                    _buildProfileOption(
                      context,
                      icon: Iconsax.user,
                      title: 'Personal Information',
                      subtitle: 'Manage your personal details',
                      onTap: () => controller.navigateToEditProfile(isStaffProfile: true),
                    ),
                    _buildProfileOption(
                      context,
                      icon: Iconsax.security_user,
                      title: 'Account Security',
                      subtitle: 'Password, security settings',
                      onTap: () => Get.to(() => const AccountSecurityScreen()),
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    /// Activity Section
                    _buildSectionTitle(context, 'Activity'),
                    const SizedBox(height: FSizes.sm),
                    _buildProfileOption(
                      context,
                      icon: Iconsax.refresh_circle,
                      title: 'Recycle History',
                      subtitle: 'Track your recycling activities',
                      onTap: () => Get.to(() => const RecycleHistoryScreen()),
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections),

                    /// Danger Zone
                    _buildSectionTitle(context, 'Danger Zone'),
                    const SizedBox(height: FSizes.sm),
                    _buildProfileOption(
                      context,
                      icon: Iconsax.trash,
                      title: 'Delete My Account',
                      subtitle: 'Permanently delete your account',
                      textColor: Colors.red,
                      onTap: controller.deleteAccountWarningPopup,
                    ),
                    _buildProfileOption(
                      context,
                      icon: Iconsax.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      textColor: Colors.red,
                      onTap: () => _showLogoutDialog(context),
                    ),

                    const SizedBox(height: FSizes.spaceBtwSections),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileController controller, bool dark) {
    return Obx(() {
      final user = controller.user.value;
      final profileImg = user.profileImg;
      final hasImage = profileImg != null && profileImg.isNotEmpty;
      final image = hasImage ? NetworkImage(profileImg) : null;

      return Column(
        children: [
          /// Profile Picture
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: hasImage ? controller.viewProfileImage : controller.showImageSourceSelection,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: image,
                    backgroundColor: Colors.white,
                    child: image == null
                        ? const Icon(Iconsax.user, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.showImageSourceSelection,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: controller.imageUploading.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Iconsax.camera,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          /// User Info with QR Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username.isNotEmpty ? user.username : 'User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            user.email.isNotEmpty ? user.email : 'No email',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: FSizes.sm),

          /// Join Date & Points
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                icon: Iconsax.calendar,
                text: 'Joined ${FFormatter.formatDate(user.joinDate)}',
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: FSizes.xs),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        Color? textColor,
        required VoidCallback onTap,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (textColor ?? (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: textColor ?? (dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary),
                    size: 24,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.grey : FColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: dark ? FColors.grey : FColors.darkGrey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final controller = Get.find<ProfileController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FSizes.cardRadiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.logout, size: 48, color: Colors.red),
              const SizedBox(height: FSizes.md),
              Text(
                'Logout',
                style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Are you sure you want to logout?',
                style: Get.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
}

// Account Security Screen
class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text(
          'Account Security',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          children: [
            _buildSecurityOption(
              context,
              icon: Iconsax.lock,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () {},
            ),
            _buildSecurityOption(
              context,
              icon: Iconsax.mobile,
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra security to your account',
              onTap: () {},
            ),
            _buildSecurityOption(
              context,
              icon: Iconsax.key,
              title: 'Login Sessions',
              subtitle: 'Manage your active sessions',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.darkContainer : FColors.white,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                  child: Icon(icon, color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary, size: 24),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? FColors.grey : FColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: dark ? FColors.grey : FColors.darkGrey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}