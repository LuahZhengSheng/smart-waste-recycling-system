import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../utils/constants/google_maps_config.dart';
import '../../controllers/dropoff_location_controller.dart';
import 'widgets/center_info_card.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/info_dialog.dart';

class DropoffLocationsScreen extends StatelessWidget {
  const DropoffLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DropoffLocationsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Obx(() {
            if (controller.currentLocation.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: FColors.primary),
                    const SizedBox(height: FSizes.md),
                    Text(
                      'Getting your location...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentLocation.value!,
                zoom: GoogleMapsConfig.defaultZoom,
              ),
              onMapCreated: (GoogleMapController mapController) {
                if (!controller.mapController.isCompleted) {
                  controller.mapController.complete(mapController);
                  controller.isMapReady.value = true;
                  // Trigger marker update after map is ready
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.updateMarkers();
                  });
                }
              },
              markers: controller.markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              style: dark ? _darkMapStyle : null,
            );
          }),

          // Modern Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(FSizes.md),
                child: Column(
                  children: [
                    // Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? FColors.dark.withOpacity(0.95) : FColors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: dark ? FColors.white : FColors.black,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              'Drop-off Locations',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dark ? FColors.white : FColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Iconsax.refresh,
                              color: FColors.primary,
                            ),
                            onPressed: controller.refreshData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FSizes.sm),

                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.md,
                        vertical: FSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? FColors.dark.withOpacity(0.95) : FColors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: (value) => controller.searchLocation(value),
                              style: TextStyle(
                                color: dark ? FColors.white : FColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search locations or centers...',
                                hintStyle: TextStyle(
                                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.search_normal,
                                  color: FColors.primary,
                                  size: FSizes.iconMd,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: FSizes.sm,
                                  vertical: FSizes.md,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: FColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Iconsax.setting_4,
                                color: FColors.primary,
                                size: FSizes.iconMd,
                              ),
                              onPressed: () => _showFilterBottomSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Results Count Badge (Bottom Left)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: FSizes.md,
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: FColors.primary,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: FColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.location,
                    color: FColors.white,
                    size: FSizes.iconSm,
                  ),
                  const SizedBox(width: FSizes.xs),
                  Text(
                    controller.placeCountText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: FColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ),

          // Floating Info Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 200,
            right: FSizes.md,
            child: Container(
              decoration: BoxDecoration(
                color: FColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: FColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Iconsax.info_circle, color: FColors.white),
                onPressed: () => _showInfoDialog(context),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 180,
            right: FSizes.md,
            child: Container(
              decoration: BoxDecoration(
                color: dark ? FColors.dark : FColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Iconsax.location,
                  color: FColors.primary,
                ),
                onPressed: controller.returnToCurrentLocation,
              ),
            ),
          ),

          // Selected Center Info Card
          Obx(() {
            if (controller.selectedCenter.value != null) {
              return Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 0,
                right: 0,
                child: CenterInfoCard(
                  center: controller.selectedCenter.value!,
                  onClose: controller.deselectCenter,
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Loading Overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(FSizes.lg),
                    decoration: BoxDecoration(
                      color: dark ? FColors.dark : FColors.white,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: FColors.primary),
                        const SizedBox(height: FSizes.md),
                        Text(
                          'Loading centers...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(),
    );
  }

  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#263c3f"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#6b9a76"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#212a37"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9ca5b3"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1f2835"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#f3d19c"}]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [{"color": "#2f3948"}]
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#515c6d"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#17263c"}]
    }
  ]
  ''';
}