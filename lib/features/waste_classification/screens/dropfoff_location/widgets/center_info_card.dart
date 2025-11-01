import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../recycling_center/models/partner_recycling_center_model.dart';
import '../../../controllers/dropoff_location_controller.dart';
import '../center_details.dart';

class CenterInfoCard extends StatelessWidget {
  final PartnerRecyclingCenter center;
  final VoidCallback onClose;

  const CenterInfoCard({
    super.key,
    required this.center,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final controller = DropoffLocationsController.instance;
    final dark = FHelperFunctions.isDarkMode(context);
    final distance = _calculateDistance(controller);
    final isPartner = center.status == 'active';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.dark : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Header
          if (center.hasPhotos)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(FSizes.borderRadiusLg),
                    topRight: Radius.circular(FSizes.borderRadiusLg),
                  ),
                  child: center.image.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: center.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: FColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: dark ? FColors.darkContainer : FColors.lightContainer,
                      child: Icon(
                        Iconsax.gallery,
                        color: dark ? FColors.darkGrey : FColors.grey,
                        size: FSizes.iconLg,
                      ),
                    ),
                  )
                      : Container(
                    height: 150,
                    color: dark ? FColors.darkContainer : FColors.lightContainer,
                    child: Icon(
                      Iconsax.gallery,
                      color: dark ? FColors.darkGrey : FColors.grey,
                      size: FSizes.iconLg,
                    ),
                  ),
                ),
                // Close button overlay
                Positioned(
                  top: FSizes.sm,
                  right: FSizes.sm,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: FColors.white),
                      onPressed: onClose,
                      iconSize: 20,
                    ),
                  ),
                ),
                // Partner Badge
                if (isPartner)
                  Positioned(
                    top: FSizes.sm,
                    left: FSizes.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.sm,
                        vertical: FSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: FColors.primary,
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
                        boxShadow: [
                          BoxShadow(
                            color: FColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.medal_star,
                            color: FColors.white,
                            size: 14,
                          ),
                          const SizedBox(width: FSizes.xs),
                          Text(
                            'Partner',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

          // Content
          Padding(
            padding: const EdgeInsets.all(FSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Close (if no image)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        center.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? FColors.white : FColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!center.hasPhotos)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: dark ? FColors.darkGrey : FColors.textSecondary,
                        ),
                        onPressed: onClose,
                      ),
                  ],
                ),
                const SizedBox(height: FSizes.sm),

                // Info Row
                Wrap(
                  spacing: FSizes.md,
                  runSpacing: FSizes.xs,
                  children: [
                    // Distance
                    _buildInfoChip(
                      context,
                      icon: Iconsax.location,
                      label: distance,
                      dark: dark,
                    ),
                    // Rating
                    if (center.rating != null)
                      _buildInfoChip(
                        context,
                        icon: Iconsax.star1,
                        label: '${center.rating}',
                        iconColor: Colors.amber,
                        dark: dark,
                      ),
                    // Status
                    _buildInfoChip(
                      context,
                      icon: Iconsax.clock,
                      label: center.isOpenNow ? 'Open Now' : 'Closed',
                      iconColor: center.isOpenNow ? FColors.success : FColors.error,
                      dark: dark,
                    ),
                  ],
                ),

                // Address
                if (center.centerLocation.fullAddress.isNotEmpty) ...[
                  const SizedBox(height: FSizes.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Iconsax.map,
                        size: FSizes.iconSm,
                        color: dark ? FColors.darkGrey : FColors.textSecondary,
                      ),
                      const SizedBox(width: FSizes.xs),
                      Expanded(
                        child: Text(
                          center.centerLocation.fullAddress,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: FSizes.md),

                // Action Buttons
                Row(
                  children: [
                    // Directions Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.openGoogleMapsNavigation(center),
                        icon: const Icon(Iconsax.routing, size: FSizes.iconSm),
                        label: const Text('Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FColors.primary,
                          side: BorderSide(color: FColors.primary.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),

                    // View Details Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCenterDetails(context, center),
                        icon: const Icon(Iconsax.eye, size: FSizes.iconSm),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FColors.primary,
                          foregroundColor: FColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: FSizes.sm),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        Color? iconColor,
        required bool dark,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.lightContainer,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? (dark ? FColors.darkGrey : FColors.textSecondary),
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.white : FColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDistance(DropoffLocationsController controller) {
    if (controller.currentLocation.value == null) {
      return 'Unknown';
    }

    final distanceKm = controller.calculateDistance(
      controller.currentLocation.value!.latitude,
      controller.currentLocation.value!.longitude,
      center.centerLocation.geoPoint.latitude,
      center.centerLocation.geoPoint.longitude,
    );

    return controller.formatDistance(distanceKm);
  }

  void _showCenterDetails(BuildContext context, PartnerRecyclingCenter center) {
    Get.to(() => CenterDetailsScreen(center: center));
  }
}