import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../controllers/center_staff_home_controller.dart';
import '../add_recyling_activity/widgets/custom_qr_scanner.dart';
import '../assign_points/assign_points.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaffHomeController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.staffDarkBackground : FColors.staffLightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(dark),
              const SizedBox(height: FSizes.spaceBtwSections),

              // Search Card
              _buildSearchCard(context, controller, dark),
              const SizedBox(height: FSizes.spaceBtwItems),

              // Instructions
              _buildInstructions(dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Dashboard',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.staffDarkText : FColors.staffLightText,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          'Enter username or scan QR to start recycling session',
          style: TextStyle(
            fontSize: 16,
            color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context, StaffHomeController controller, bool dark) {
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
      child: Form(
        key: controller.userIdFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(FSizes.sm),
                  decoration: BoxDecoration(
                    color: dark ? FColors.staffDarkPrimary.withOpacity(0.2) : FColors.staffLightPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    Iconsax.user_search,
                    color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                    size: FSizes.iconMd,
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Text(
                  'User Identification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.staffDarkText : FColors.staffLightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Username Input
            TextFormField(
              controller: controller.userIdController,
              validator: controller.validateUserId,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter username or scan QR code',
                prefixIcon: const Icon(Iconsax.user),
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
            const SizedBox(height: FSizes.spaceBtwItems),

            // Search Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => _handleSearch(context, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
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
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.search_normal_1),
                    SizedBox(width: FSizes.xs),
                    Text('Search User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )),

            // QR Code Button
            const SizedBox(height: FSizes.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleQRScan(context, controller),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.buttonRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.scan_barcode,
                      color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? FColors.staffDarkPrimary : FColors.staffLightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.staffDarkInfo.withOpacity(0.1)
            : FColors.staffLightInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: dark ? FColors.staffDarkInfo : FColors.staffLightInfo,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: dark ? FColors.staffDarkInfo : FColors.staffLightInfo,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dark ? FColors.staffDarkText : FColors.staffLightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.md),
          _buildInstructionItem(
            '1. Enter the username or scan their QR code',
            dark,
          ),
          _buildInstructionItem(
            '2. Once user is found, you can add recycling activities',
            dark,
          ),
          _buildInstructionItem(
            '3. Add all waste items they want to recycle',
            dark,
          ),
          _buildInstructionItem(
            '4. Submit all activities to award points to the user',
            dark,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: FSizes.sm),
            decoration: BoxDecoration(
              color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: dark ? FColors.staffDarkTextSecondary : FColors.staffLightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSearch(BuildContext context, StaffHomeController controller) async {
    await controller.searchUser();

    if (controller.isValidUser.value) {
      Get.to(() => const AssignPointsScreen());
    }
  }

  Future<void> _handleQRScan(BuildContext context, StaffHomeController controller) async {
    final result = await Get.to<String>(
          () => CustomQRScanner(
        onQRScanned: (String qrData) {
          Get.back(result: qrData);
        },
        dark: FHelperFunctions.isDarkMode(context),
      ),
    );

    if (result != null && result.isNotEmpty) {
      await controller.validateAndSetUserFromQR(result);

      if (controller.isValidUser.value) {
        Get.to(() => const AssignPointsScreen());
      }
    }
  }
}