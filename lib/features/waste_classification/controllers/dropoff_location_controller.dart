import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../data/services/google_places/google_places_service.dart';
import '../../../utils/constants/google_maps_config.dart';
import '../../../utils/constants/google_places_config.dart';
import '../../event/models/address_model.dart';
import '../../event/models/geopoint_model.dart';
import '../../event/models/location_model.dart';

enum OpeningHoursFilter { anyTime, openNow, open24Hours }

class DropoffLocationsController extends GetxController {
  static DropoffLocationsController get instance => Get.find();

  final centerRepository = Get.put(RecyclingCenterRepository());
  final googlePlacesService = GooglePlacesService();

  // Observables
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> searchedLocation = Rx<LatLng?>(null);
  final RxList<PartnerRecyclingCenter> allCenters = <PartnerRecyclingCenter>[].obs;
  final RxList<PartnerRecyclingCenter> filteredCenters = <PartnerRecyclingCenter>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rx<PartnerRecyclingCenter?> selectedCenter = Rx<PartnerRecyclingCenter?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isMapReady = false.obs;
  final RxString searchQuery = ''.obs;
  final RxDouble currentRadius = (GoogleMapsConfig.defaultSearchRadiusKm * 1000).obs;
  final RxBool showPartnerOnly = false.obs;
  final RxDouble minRating = 0.0.obs;
  final RxList<String> selectedMaterials = <String>[].obs;
  final RxBool isSearchMode = false.obs;
  final Rx<OpeningHoursFilter> openingHoursFilter = OpeningHoursFilter.anyTime.obs;

  // Map controller
  Completer<GoogleMapController> mapController = Completer();

  // Available materials for filtering
  final List<String> availableMaterials = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Electronics',
    'Cardboard',
    'Aluminum',
    'Batteries',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  @override
  void onClose() {
    try {
      mapController.future.then((controller) => controller.dispose());
    } catch (e) {
      print('Error disposing map controller: $e');
    }
    super.onClose();
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      print('🚀 Initializing location...');

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        print('❌ Location permission denied, using default location');
        FLoaders.errorSnackBar(
          title: 'Location Permission Required',
          message: 'Please enable location to view nearby recycling centers.',
        );
        currentLocation.value = const LatLng(3.1390, 101.6869);
      } else {
        print('📍 Getting current location...');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        currentLocation.value = LatLng(position.latitude, position.longitude);
        print('✅ Current location: ${currentLocation.value}');
      }

      await _loadCentersNearLocation(currentLocation.value!);

      // Update map camera position
      if (currentLocation.value != null && isMapReady.value) {
        try {
          final controller = await mapController.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation.value!,
                zoom: GoogleMapsConfig.defaultZoom,
              ),
            ),
          );
        } catch (e) {
          print('❌ Error moving camera: $e');
        }
      }
    } catch (e) {
      print('💥 Error initializing location: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to get location: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCentersNearLocation(LatLng location) async {
    try {
      print('📥 Loading centers near location...');
      isLoading.value = true;

      // Get partner centers from Firebase
      final partnerCenters = await centerRepository.getCentersNearLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: currentRadius.value / 1000,
      );

      print('✅ Found ${partnerCenters.length} partner centers');

      // Get Google Places centers
      final googleCenters = await googlePlacesService.searchNearbyRecyclingCenters(
        latitude: location.latitude,
        longitude: location.longitude,
        radius: currentRadius.value.toInt(),
        includeDetails: true,
      );

      print('✅ Found ${googleCenters.length} Google Places centers');

      // Convert Google Places to PartnerRecyclingCenter (non-partner)
      final nonPartnerCenters = <PartnerRecyclingCenter>[];
      for (final place in googleCenters) {
        if (!_isMatchingPartner(place['place_id'], partnerCenters)) {
          // Calculate actual driving distance
          final drivingDistance = await googlePlacesService.calculateDrivingDistance(
            originLat: location.latitude,
            originLng: location.longitude,
            destLat: place['geometry']['location']['lat'].toDouble(),
            destLng: place['geometry']['location']['lng'].toDouble(),
          );

          // Only include if within radius (actual driving distance)
          if (drivingDistance != null && drivingDistance <= currentRadius.value / 1000) {
            final center = _convertToPartnerCenter(place, isPartner: false);
            nonPartnerCenters.add(center);
          }
        }
      }

      print('✅ ${nonPartnerCenters.length} centers within actual driving distance');

      // Combine both lists
      allCenters.value = [...partnerCenters, ...nonPartnerCenters];
      print('✅ Total centers loaded: ${allCenters.length}');

      applyFilters();
    } catch (e) {
      print('❌ Error loading centers: $e');
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load centers',
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _isMatchingPartner(String? placeId, List<PartnerRecyclingCenter> partners) {
    if (placeId == null) return false;
    return partners.any((p) => p.placeId == placeId);
  }

  PartnerRecyclingCenter _convertToPartnerCenter(Map<String, dynamic> place, {required bool isPartner}) {
    final geometry = place['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    // Get first photo if available
    String imageUrl = '';
    final photos = place['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final firstPhoto = photos.first;
      final photoReference = firstPhoto['photo_reference'] as String?;
      if (photoReference != null) {
        imageUrl = googlePlacesService.getPhotoUrl(
          photoReference,
          maxWidth: GooglePlacesConfig.highResPhotoMaxWidth,
        );
      }
    }

    final List<String> acceptedMaterials = place['recycling_items'] != null
        ? List<String>.from(place['recycling_items'])
        : [];

    return PartnerRecyclingCenter(
      centerId: place['place_id'] ?? '',
      name: place['name'] ?? '',
      email: '',
      phoneNo: place['formatted_phone_number'] ?? '',
      website: place['website'] ?? '',
      centerLocation: Location(
        address: Address(
          unitNo: '',
          area: '',
          postcode: '',
          city: '',
          state: '',
          fullAddress: place['formatted_address'],
        ),
        geoPoint: GeoPointModel(
          latitude: location['lat']?.toDouble() ?? 0.0,
          longitude: location['lng']?.toDouble() ?? 0.0,
        ),
      ),
      image: imageUrl,
      openingHours: place['opening_hours'],
      acceptedMaterials: acceptedMaterials,
      numberOfStaff: 0,
      createdAt: DateTime.now(),
      status: isPartner ? 'active' : 'non-partner',
      rating: place['rating']?.toDouble(),
      userRatingsTotal: place['user_ratings_total'],
      placeId: place['place_id'],
    );
  }

  List<String> _extractMaterialsFromTypes(List<dynamic>? types) {
    if (types == null) return ['Plastic', 'Paper', 'Glass', 'Metal'];

    final materials = <String>[];
    if (types.contains('recycling_center') || types.contains('waste_management')) {
      materials.addAll(['Plastic', 'Paper', 'Glass', 'Metal', 'Cardboard']);
    }
    if (types.contains('electronics_store')) {
      materials.add('Electronics');
    }
    return materials.isEmpty ? ['Plastic', 'Paper', 'Glass', 'Metal'] : materials;
  }

  Future<bool> _handleLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;
      return true;
    } catch (e) {
      print('❌ Error handling location permission: $e');
      return false;
    }
  }

  void applyFilters() {
    try {
      print('🎯 Applying filters...');
      List<PartnerRecyclingCenter> filtered = List.from(allCenters);

      // Partner filter
      if (showPartnerOnly.value) {
        filtered = filtered.where((c) => c.status == 'active').toList();
      }

      // Rating filter
      if (minRating.value > 0) {
        filtered = filtered.where((c) => (c.rating ?? 0) >= minRating.value).toList();
      }

      // Material filter
      if (selectedMaterials.isNotEmpty) {
        filtered = filtered.where((center) {
          return selectedMaterials.any((material) => center.acceptsMaterial(material));
        }).toList();
      }

      // Opening hours filter
      if (openingHoursFilter.value == OpeningHoursFilter.openNow) {
        filtered = filtered.where((c) => c.isOpenNow).toList();
      } else if (openingHoursFilter.value == OpeningHoursFilter.open24Hours) {
        filtered = filtered.where((c) => _isOpen24Hours(c)).toList();
      }

      filteredCenters.value = filtered;
      print('✅ Filtered to ${filtered.length} centers');
      updateMarkers();
    } catch (e) {
      print('❌ Error applying filters: $e');
    }
  }

  bool _isOpen24Hours(PartnerRecyclingCenter center) {
    if (center.openingHours == null) return false;

    final periods = center.openingHours!['periods'] as List<dynamic>?;
    if (periods == null || periods.isEmpty) return false;

    // Check if there's only one period with open time '0000'
    return periods.length == 1 && periods[0]['open']?['time'] == '0000';
  }

  void updateMarkers() {
    try {
      print('📍 Updating markers...');
      final Set<Marker> newMarkers = {};

      for (var center in filteredCenters) {
        final bool isPartner = center.status == 'active';
        final BitmapDescriptor markerIcon = isPartner
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

        String distanceText = 'Unknown distance';
        final targetLocation = isSearchMode.value ? searchedLocation.value : currentLocation.value;
        if (targetLocation != null) {
          final distance = calculateDistance(
            targetLocation.latitude,
            targetLocation.longitude,
            center.centerLocation.geoPoint.latitude,
            center.centerLocation.geoPoint.longitude,
          );
          distanceText = formatDistance(distance);
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId(center.centerId),
            position: LatLng(
              center.centerLocation.geoPoint.latitude,
              center.centerLocation.geoPoint.longitude,
            ),
            icon: markerIcon,
            onTap: () => selectCenter(center),
            infoWindow: InfoWindow(
              title: center.name,
              snippet: '${isPartner ? '🤝 Partner' : '📍 Center'} • $distanceText${center.rating != null ? ' • ⭐${center.rating}' : ''}',
            ),
          ),
        );
      }

      markers.value = newMarkers;
      print('✅ Updated ${newMarkers.length} markers');
    } catch (e) {
      print('❌ Error updating markers: $e');
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  void selectCenter(PartnerRecyclingCenter center) {
    selectedCenter.value = center;
  }

  void deselectCenter() {
    selectedCenter.value = null;
  }

  Future<void> openGoogleMapsNavigation(PartnerRecyclingCenter center) async {
    try {
      await FLoaders.showMapNavigationDialog(
        onConfirm: () async {
          final url = 'https://www.google.com/maps/dir/?api=1&destination=${center.centerLocation.geoPoint.latitude},${center.centerLocation.geoPoint.longitude}';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            FLoaders.errorSnackBar(
              title: 'Error',
              message: 'Could not open Google Maps',
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error opening navigation: $e');
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      returnToCurrentLocation();
      return;
    }

    try {
      isLoading.value = true;
      searchQuery.value = query;

      // Check if searching for specific recycling center or location
      final isLocation = googlePlacesService.isLocationQuery(query);

      if (isLocation) {
        // Search for location and show nearby centers
        final predictions = await googlePlacesService.searchPlaces(query);

        if (predictions.isEmpty) {
          FLoaders.warningSnackBar(
            title: 'No Results',
            message: 'No locations found for "$query"',
          );
          return;
        }

        final placeDetails = await googlePlacesService.getPlaceDetails(predictions.first['place_id']);
        final geometry = placeDetails['geometry'] ?? {};
        final location = geometry['location'] ?? {};

        final searchedLat = location['lat']?.toDouble() ?? 0.0;
        final searchedLng = location['lng']?.toDouble() ?? 0.0;

        searchedLocation.value = LatLng(searchedLat, searchedLng);
        isSearchMode.value = true;

        await _loadCentersNearLocation(searchedLocation.value!);

        final controller = await mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: searchedLocation.value!,
              zoom: GoogleMapsConfig.defaultZoom,
            ),
          ),
        );

        FLoaders.successSnackBar(
          title: 'Location Found',
          message: 'Showing centers near ${predictions.first['description']}',
        );
      } else {
        // Search for specific recycling center
        if (currentLocation.value == null) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Location not available',
          );
          return;
        }

        final centers = await googlePlacesService.searchRecyclingCenterByName(
          name: query,
          latitude: currentLocation.value!.latitude,
          longitude: currentLocation.value!.longitude,
        );

        if (centers.isEmpty) {
          FLoaders.warningSnackBar(
            title: 'No Results',
            message: 'No recycling centers found for "$query"',
          );
          return;
        }

        // Convert to PartnerRecyclingCenter and filter
        allCenters.value = centers.map((place) {
          return _convertToPartnerCenter(place, isPartner: false);
        }).toList();

        isSearchMode.value = true;
        applyFilters();

        // Focus on first result
        if (filteredCenters.isNotEmpty) {
          final firstCenter = filteredCenters.first;
          final controller = await mapController.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  firstCenter.centerLocation.geoPoint.latitude,
                  firstCenter.centerLocation.geoPoint.longitude,
                ),
                zoom: GoogleMapsConfig.defaultZoom + 1,
              ),
            ),
          );

          FLoaders.successSnackBar(
            title: 'Center Found',
            message: 'Found ${filteredCenters.length} result(s) for "$query"',
          );
        }
      }
    } catch (e) {
      print('❌ Error searching location: $e');
      FLoaders.errorSnackBar(
        title: 'Search Error',
        message: 'Failed to search location',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> returnToCurrentLocation() async {
    try {
      if (currentLocation.value == null) return;

      isSearchMode.value = false;
      searchedLocation.value = null;
      searchQuery.value = '';

      await _loadCentersNearLocation(currentLocation.value!);

      final controller = await mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation.value!,
            zoom: GoogleMapsConfig.defaultZoom,
          ),
        ),
      );

      FLoaders.successSnackBar(
        title: 'Returned',
        message: 'Showing centers near your location',
      );
    } catch (e) {
      print('❌ Error returning to current location: $e');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void togglePartnerFilter() {
    showPartnerOnly.value = !showPartnerOnly.value;
    applyFilters();
  }

  Future<void> updateRadius(double radiusKm) async {
    currentRadius.value = radiusKm * 1000;
    final targetLocation = isSearchMode.value ? searchedLocation.value : currentLocation.value;
    if (targetLocation != null) {
      await _loadCentersNearLocation(targetLocation);
    }
  }

  void updateMinRating(double rating) {
    minRating.value = rating;
    applyFilters();
  }

  void toggleMaterialFilter(String material) {
    if (selectedMaterials.contains(material)) {
      selectedMaterials.remove(material);
    } else {
      selectedMaterials.add(material);
    }
    applyFilters();
  }

  void updateOpeningHoursFilter(OpeningHoursFilter filter) {
    openingHoursFilter.value = filter;
    applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    showPartnerOnly.value = false;
    minRating.value = 0.0;
    currentRadius.value = GoogleMapsConfig.defaultSearchRadiusKm * 1000;
    selectedMaterials.clear();
    openingHoursFilter.value = OpeningHoursFilter.anyTime;
    applyFilters();
  }

  String get placeCountText {
    final count = filteredCenters.length;
    final partnerCount = filteredCenters.where((c) => c.status == 'active').length;
    return '$count centers ($partnerCount partners)';
  }

  Future<void> refreshData() async {
    final targetLocation = isSearchMode.value ? searchedLocation.value : currentLocation.value;
    if (targetLocation != null) {
      await _loadCentersNearLocation(targetLocation);
    }
    FLoaders.successSnackBar(
      title: 'Refreshed',
      message: 'Centers updated successfully',
    );
  }
}