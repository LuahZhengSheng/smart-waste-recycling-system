import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/personalization/controllers/activity_detail_controller.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/recycling_center/models/waste_category_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/loaders/circular_loader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/popups/loaders.dart';
import '../../../community/screens/create_post/widgets/media_lightbox.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityDetailController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Activity Details'),
        centerTitle: true,
        showBackArrow: true,
        actions: [
          Obx(() {
            final activity = controller.activity.value;
            if (activity == null || !activity.canDelete) return const SizedBox.shrink();

            return controller.isDeleting.value
                ? const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : IconButton(
              onPressed: () => _showDeleteConfirmation(activity, controller, context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.trash,
                  color: FColors.error,
                  size: 20,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        // Show loading indicator while data is being loaded
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: FColors.primary),
          );
        }

        if (controller.activity.value == null) {
          return const Center(child: FCircularLoader());
        }

        final activity = controller.activity.value!;
        final category = controller.getWasteCategory();

        if (category == null) {
          return _buildErrorState(context);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Image Section
              _buildHeroImageSection(activity, category, dark, context),

              // Content
              Padding(
                padding: const EdgeInsets.all(FSizes.defaultSpace),
                child: Column(
                  children: [
                    // Basic Info Card
                    _buildBasicInfoCard(activity, category, dark, controller),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Metrics Cards
                    _buildMetricsSection(activity, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Category Details Card
                    _buildCategoryDetailsCard(category, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Staff and Center Info Tabs
                    _buildStaffAndCenterTabs(controller, dark, context),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.warning_2,
              size: 48,
              color: FColors.warning,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Category Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'The waste category for this activity\ncould not be loaded.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FSizes.lg),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Iconsax.arrow_left_2),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.primary,
              foregroundColor: FColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImageSection(
      RecyclingActivity activity,
      WasteCategory category,
      bool dark,
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: () {
        _showImageLightbox(activity, context);
      },
      child: Hero(
        tag: 'activity_${activity.activityId}',
        child: Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
          ),
          child: FutureBuilder<String>(
            future: activity.getSupportImageUrl(activity.userId),
            builder: (context, snapshot) {
              final isLoading = snapshot.connectionState == ConnectionState.waiting;
              final hasError = snapshot.hasError;
              final imageUrl = snapshot.data;
              final hasValidImage = imageUrl != null && imageUrl.isNotEmpty;

              return Stack(
                children: [
                  // Background Image
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: category.color,
                      ),
                    )
                  else if (hasValidImage)
                    Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackIcon(category);
                      },
                    )
                  else
                    _buildFallbackIcon(category),

                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(FSizes.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: category.color,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      category.icon,
                                      size: 16,
                                      color: FColors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.name,
                                      style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                        color: FColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FSizes.sm),
                          Text(
                            activity.wasteObject,
                            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                              color: FColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 14,
                                color: FColors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                activity.formattedCreatedAt,
                                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                  color: FColors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap to enlarge hint (only show if we have a valid image)
                  if (hasValidImage && !isLoading)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.maximize_4,
                              size: 14,
                              color: FColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to enlarge',
                              style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                color: FColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(WasteCategory category) {
    return Center(
      child: Icon(
        category.icon,
        size: 80,
        color: category.color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBasicInfoCard(
      RecyclingActivity activity,
      WasteCategory category,
      bool dark,
      ActivityDetailController controller,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.info_circle,
                  color: FColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Activity Information',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          _buildInfoRow(
            'Activity ID',
            activity.activityId,
            Iconsax.code_circle,
            FColors.darkGrey,
          ),
          _buildInfoRow(
            'Submitted',
            activity.formattedCreatedAt,
            Iconsax.calendar,
            FColors.primary,
          ),
          _buildInfoRow(
            'Age',
            controller.activityAgeText,
            Iconsax.clock,
            FColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: FColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(RecyclingActivity activity, bool dark) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Weight',
            activity.formattedWeight,
            Iconsax.weight,
            FColors.info,
            dark,
          ),
        ),
        const SizedBox(width: FSizes.md),
        Expanded(
          child: _buildMetricCard(
            'Points',
            '${activity.pointsEarned}',
            Iconsax.star1,
            FColors.warning,
            dark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String label,
      String value,
      IconData icon,
      Color color,
      bool dark,
      ) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            value,
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailsCard(WasteCategory category, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Category Information',
                  style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            category.description,
            style: Theme.of(Get.context!).textTheme.bodyMedium,
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.star1,
                      size: 16,
                      color: category.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Base Points: ${category.formattedPoints}',
                      style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),
                Text(
                  'Examples: ${category.formattedExamples}',
                  style: Theme.of(Get.context!).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAndCenterTabs(
      ActivityDetailController controller,
      bool dark,
      BuildContext context,
      ) {
    return Obx(() {
      if (controller.staffUser.value == null || controller.recyclingCenter.value == null) {
        return Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            boxShadow: [
              BoxShadow(
                color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: FColors.primary),
          ),
        );
      }

      return DefaultTabController(
        length: 2,
        child: Container(
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
            boxShadow: [
              BoxShadow(
                color: (dark ? Colors.black : Colors.grey).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: dark ? FColors.darkGrey.withOpacity(0.3) : FColors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  labelColor: FColors.primary,
                  unselectedLabelColor: dark ? FColors.darkGrey : FColors.grey,
                  indicatorColor: FColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(
                      icon: Icon(Iconsax.user, size: 20),
                      text: 'Staff Info',
                    ),
                    Tab(
                      icon: Icon(Iconsax.building, size: 20),
                      text: 'Center Info',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    _buildStaffInfoTab(controller, dark),
                    _buildCenterInfoTab(controller, dark, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStaffInfoTab(ActivityDetailController controller, bool dark) {
    final staff = controller.staffUser.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FColors.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: staff.profileImg != null && staff.profileImg!.isNotEmpty
                        ? Image.network(
                      staff.profileImg!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Iconsax.user,
                          size: 50,
                          color: FColors.primary,
                        );
                      },
                    )
                        : Icon(
                      Iconsax.user,
                      size: 50,
                      color: FColors.primary,
                    ),
                  ),
                ),
                // const SizedBox(height: 4),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: FColors.success.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     'Center Staff',
                //     style: TextStyle(
                //       color: FColors.success,
                //       fontSize: 12,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
                const SizedBox(height: FSizes.md),
                Text(
                  staff.username,
                  style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwSections),
          _buildStaffInfoItem(
            'Email',
            staff.email,
            Iconsax.sms,
            FColors.info,
          ),
          if (staff.phoneNo != null && staff.phoneNo!.isNotEmpty)
            _buildStaffInfoItem(
              'Phone',
              staff.phoneNo!,
              Iconsax.call,
              FColors.primary,
            ),
          _buildStaffInfoItem(
            'Staff ID',
            staff.userId,
            Iconsax.code_circle,
            FColors.darkGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: FColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterInfoTab(
      ActivityDetailController controller,
      bool dark,
      BuildContext context,
      ) {
    final center = controller.recyclingCenter.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center Image
          if (center.image.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnifiedMediaLightbox(
                      mediaItems: [
                        UnifiedMediaItem.network(
                          id: center.centerId,
                          networkUrl: center.image,
                          isVideo: false,
                        ),
                      ],
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: FColors.primary.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    center.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Iconsax.building,
                          size: 50,
                          color: FColors.primary.withOpacity(0.5),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: FColors.primary),
                      );
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: FSizes.md),

          // Center Name
          Text(
            center.name,
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: FSizes.sm),

          // Rating
          if (center.rating != null)
            Row(
              children: [
                Icon(Iconsax.star1, color: FColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(
                  center.rating!.toStringAsFixed(1),
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FColors.warning,
                  ),
                ),
                if (center.userRatingsTotal != null) ...[
                  Text(
                    ' (${center.userRatingsTotal} reviews)',
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: dark ? FColors.darkGrey : FColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: FSizes.md),

          // Center Info
          _buildCenterInfoRow(
            Iconsax.location,
            center.centerLocation.address.fullAddress ?? 'No address',
            FColors.primary,
          ),
          _buildCenterInfoRow(
            Iconsax.call,
            center.formattedPhoneNo,
            FColors.info,
          ),
          if (center.email.isNotEmpty)
            _buildCenterInfoRow(
              Iconsax.sms,
              center.email,
              FColors.success,
            ),
          const SizedBox(height: FSizes.md),

          // Direction Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDirectionConfirmation(center, context),
              icon: const Icon(Iconsax.routing),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FColors.primary,
                foregroundColor: FColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(Get.context!).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showDirectionConfirmation(dynamic center, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        backgroundColor: FHelperFunctions.isDarkMode(context) ? FColors.darkContainer : FColors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.routing, color: FColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Open Google Maps')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Would you like to navigate to this recycling center?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: FSizes.md),
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.location, color: FColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      center.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: FColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openGoogleMaps(center);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.primary,
              foregroundColor: FColors.white,
            ),
            child: const Text('Open Maps'),
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(dynamic center) async {
    final lat = center.centerLocation.geoPoint.latitude;
    final lng = center.centerLocation.geoPoint.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not open Google Maps',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open Google Maps: ${e.toString()}',
      );
    }
  }

  // 新增方法：处理图片查看
  void _showImageLightbox(RecyclingActivity activity, BuildContext context) {
    Future<String> imageUrlFuture = activity.getSupportImageUrl(activity.userId);

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: FColors.primary),
            );
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            Navigator.pop(context);
            return const SizedBox();
          }

          final imageUrl = snapshot.data!;
          return UnifiedMediaLightbox(
            mediaItems: [
              UnifiedMediaItem.network(
                id: activity.activityId,
                networkUrl: imageUrl,
                isVideo: false,
              ),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      RecyclingActivity activity,
      ActivityDetailController controller,
      BuildContext context,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        backgroundColor: FHelperFunctions.isDarkMode(context) ? FColors.darkContainer : FColors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.trash, color: FColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Activity'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this activity?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, color: FColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteActivity();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.error,
              foregroundColor: FColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}