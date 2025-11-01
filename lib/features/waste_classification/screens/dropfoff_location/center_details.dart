import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../recycling_center/models/partner_recycling_center_model.dart';
import '../../controllers/dropoff_location_controller.dart';

class CenterDetailsScreen extends StatelessWidget {
  final PartnerRecyclingCenter center;

  const CenterDetailsScreen({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    final controller = DropoffLocationsController.instance;
    final dark = FHelperFunctions.isDarkMode(context);
    final isPartner = center.status == 'active';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: dark ? FColors.dark : FColors.white,
            leading: Container(
              margin: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: FColors.white),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Iconsax.share, color: FColors.white),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (center.hasPhotos)
                    CachedNetworkImage(
                      imageUrl: center.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: dark ? FColors.darkContainer : FColors.lightContainer,
                        child: Center(
                          child: CircularProgressIndicator(color: FColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: dark ? FColors.darkContainer : FColors.lightContainer,
                        child: Icon(
                          Iconsax.gallery,
                          size: 64,
                          color: dark ? FColors.darkGrey : FColors.grey,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      child: Icon(
                        Iconsax.gallery,
                        size: 64,
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                    ),
                  // Gradient overlay
                  Container(
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
                  ),
                  // Partner Badge
                  if (isPartner)
                    Positioned(
                      bottom: FSizes.lg,
                      left: FSizes.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.md,
                          vertical: FSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: FColors.primary,
                          borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: FColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.medal_star,
                              color: FColors.white,
                              size: FSizes.iconSm,
                            ),
                            const SizedBox(width: FSizes.xs),
                            Text(
                              'Partner Recycling Center',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: FColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: dark ? FColors.dark : FColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(FSizes.cardRadiusLg + 8),
                  topRight: Radius.circular(FSizes.cardRadiusLg + 8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      center.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: FSizes.sm),

                    // Rating and Status Row
                    Row(
                      children: [
                        if (center.rating != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.sm,
                              vertical: FSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.star1,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: FSizes.xs),
                                Text(
                                  '${center.rating}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: dark ? FColors.white : FColors.textPrimary,
                                  ),
                                ),
                                if (center.userRatingsTotal != null) ...[
                                  const SizedBox(width: FSizes.xs),
                                  Text(
                                    '(${center.userRatingsTotal})',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FSizes.sm,
                            vertical: FSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: center.isOpenNow
                                ? FColors.success.withOpacity(0.1)
                                : FColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: center.isOpenNow ? FColors.success : FColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: FSizes.xs),
                              Text(
                                center.isOpenNow ? 'Open Now' : 'Closed',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: center.isOpenNow ? FColors.success : FColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwItems),

                    // Quick Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Iconsax.location,
                            label: 'Distance',
                            value: _getDistance(controller),
                            dark: dark,
                          ),
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Iconsax.clock,
                            label: 'Hours',
                            value: center.isOpenNow ? 'Open' : 'Closed',
                            valueColor: center.isOpenNow ? FColors.success : FColors.error,
                            dark: dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Address Section
                    if (center.centerLocation.fullAddress.isNotEmpty)
                      _buildSection(
                        context,
                        icon: Iconsax.map,
                        title: 'Address',
                        dark: dark,
                        child: Text(
                          center.centerLocation.fullAddress,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),

                    // Opening Hours Section
                    if (center.openingHours != null && center.openingHours!.isNotEmpty) ...[
                      const SizedBox(height: FSizes.spaceBtwSections),
                      _buildSection(
                        context,
                        icon: Iconsax.clock,
                        title: 'Opening Hours',
                        dark: dark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: center.weekdayText
                              .map((hours) => Padding(
                            padding: const EdgeInsets.only(bottom: FSizes.xs),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: FColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: FSizes.sm),
                                Expanded(
                                  child: Text(
                                    hours,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                    ],

                    // Accepted Materials Section
                    if (center.acceptedMaterials.isNotEmpty) ...[
                      const SizedBox(height: FSizes.spaceBtwSections),
                      _buildSection(
                        context,
                        icon: Iconsax.box,
                        title: 'Accepted Materials',
                        dark: dark,
                        child: Wrap(
                          spacing: FSizes.sm,
                          runSpacing: FSizes.sm,
                          children: center.acceptedMaterials.map((material) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FSizes.md,
                                vertical: FSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: FColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                border: Border.all(
                                  color: FColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.tick_circle,
                                    color: FColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: FSizes.xs),
                                  Text(
                                    material,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: FColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // Contact Info
                    if (center.phoneNo.isNotEmpty || center.website.isNotEmpty || center.email.isNotEmpty) ...[
                      const SizedBox(height: FSizes.spaceBtwSections),
                      _buildSection(
                        context,
                        icon: Iconsax.call,
                        title: 'Contact Information',
                        dark: dark,
                        child: Column(
                          children: [
                            if (center.phoneNo.isNotEmpty)
                              _buildContactItem(
                                context,
                                icon: Iconsax.call,
                                label: center.formattedPhoneNo,
                                dark: dark,
                                onTap: () async {
                                  final url = 'tel:${center.phoneNo}';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                              ),
                            if (center.website.isNotEmpty) ...[
                              if (center.phoneNo.isNotEmpty) const SizedBox(height: FSizes.sm),
                              _buildContactItem(
                                context,
                                icon: Iconsax.global,
                                label: 'Visit Website',
                                dark: dark,
                                onTap: () async {
                                  String url = center.website;
                                  // Ensure URL has a scheme
                                  if (!url.startsWith('http://') && !url.startsWith('https://')) {
                                    url = 'https://$url';
                                  }
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                              ),
                            ],
                            if (center.email.isNotEmpty) ...[
                              if (center.phoneNo.isNotEmpty || center.website.isNotEmpty)
                                const SizedBox(height: FSizes.sm),
                              _buildContactItem(
                                context,
                                icon: Iconsax.sms,
                                label: center.email,
                                dark: dark,
                                onTap: () async {
                                  final url = 'mailto:${center.email}';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Partner Benefits (if partner)
                    if (isPartner) ...[
                      const SizedBox(height: FSizes.spaceBtwSections),
                      _buildSection(
                        context,
                        icon: Iconsax.medal_star,
                        title: 'Partner Benefits',
                        dark: dark,
                        child: Column(
                          children: [
                            _buildBenefitItem(
                              context,
                              'Earn reward points for every recycling activity',
                              dark,
                            ),
                            _buildBenefitItem(
                              context,
                              'Track your recycling history',
                              dark,
                            ),
                            _buildBenefitItem(
                              context,
                              'Redeem points for exclusive rewards',
                              dark,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: FSizes.spaceBtwSections),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => controller.openGoogleMapsNavigation(center),
                            icon: const Icon(Iconsax.routing, size: FSizes.iconMd),
                            label: const Text('Get Directions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FColors.primary,
                              side: BorderSide(color: FColors.primary.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                            ),
                          ),
                        ),
                        if (isPartner) ...[
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Start recycling activity
                              },
                              icon: const Icon(Iconsax.repeate_one, size: FSizes.iconMd),
                              label: const Text('Recycle Here'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FColors.primary,
                                foregroundColor: FColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).padding.bottom + FSizes.md),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        Color? valueColor,
        required bool dark,
      }) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: FColors.primary,
            size: FSizes.iconMd,
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? (dark ? FColors.white : FColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget child,
        required bool dark,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Icon(
                icon,
                color: FColors.primary,
                size: FSizes.iconSm,
              ),
            ),
            const SizedBox(width: FSizes.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.md),
        child,
      ],
    );
  }

  Widget _buildContactItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool dark,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
        child: Container(
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.lightContainer,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: FColors.primary,
                size: FSizes.iconMd,
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? FColors.white : FColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.tick_circle,
              color: FColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: FSizes.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDistance(DropoffLocationsController controller) {
    if (controller.currentLocation.value == null) return 'Unknown';

    final distanceKm = controller.calculateDistance(
      controller.currentLocation.value!.latitude,
      controller.currentLocation.value!.longitude,
      center.centerLocation.geoPoint.latitude,
      center.centerLocation.geoPoint.longitude,
    );

    return controller.formatDistance(distanceKm);
  }
}