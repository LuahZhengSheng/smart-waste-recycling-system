import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../config/google_places_config.dart';

class GooglePlacesService {

  /// Search for nearby recycling centers with pagination support
  Future<List<Map<String, dynamic>>> searchNearbyRecyclingCenters({
    required double latitude,
    required double longitude,
    required int radius,
    bool includeDetails = true,
  }) async {
    try {
      List<Map<String, dynamic>> allResults = [];
      String? nextPageToken;
      int pageCount = 0;

      do {
        // Build URL using configuration
        String url = GooglePlacesConfig.buildNearbySearchUrl(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          nextPageToken: nextPageToken,
        );

        if (nextPageToken != null) {
          // Wait before requesting next page (Google API requirement)
          await Future.delayed(GooglePlacesConfig.nextPageDelay);
        }

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
            final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
            allResults.addAll(results);

            nextPageToken = data['next_page_token'];
            pageCount++;

            print('📄 Fetched page $pageCount: ${results.length} centers');
          } else {
            print('⚠️ Search status: ${data['status']}');
            break;
          }
        } else {
          print('❌ HTTP error: ${response.statusCode}');
          break;
        }
      } while (nextPageToken != null && pageCount < GooglePlacesConfig.maxNearbySearchPages);

      print('✅ Total centers found: ${allResults.length}');

      // Get detailed information if requested
      if (includeDetails && allResults.isNotEmpty) {
        final detailedResults = <Map<String, dynamic>>[];
        for (final place in allResults) {
          try {
            final details = await getPlaceDetails(place['place_id']);
            detailedResults.add({...place, ...details});
          } catch (e) {
            print('⚠️ Error getting details for ${place['name']}: $e');
            detailedResults.add(place);
          }
        }
        return detailedResults;
      }

      return allResults;
    } catch (e) {
      print('❌ Error searching nearby recycling centers: $e');
      return [];
    }
  }

  /// Calculate actual driving distance using Distance Matrix API
  Future<double?> calculateDrivingDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = GooglePlacesConfig.buildDistanceMatrixUrl(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          if (element['status'] == 'OK') {
            // Distance in meters, convert to km
            return (element['distance']['value'] as int) / 1000.0;
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ Error calculating driving distance: $e');
      return null;
    }
  }

  /// Search for a specific recycling center by name
  Future<List<Map<String, dynamic>>> searchRecyclingCenterByName({
    required String name,
    required double latitude,
    required double longitude,
    int radius = GooglePlacesConfig.defaultRadiusMeters,
  }) async {
    try {
      final url = GooglePlacesConfig.buildTextSearchUrl(
        query: '$name recycling center',
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = List<Map<String, dynamic>>.from(data['results']);

          // Get detailed information
          final detailedResults = <Map<String, dynamic>>[];
          for (final place in results) {
            try {
              final details = await getPlaceDetails(place['place_id']);
              detailedResults.add({...place, ...details});
            } catch (e) {
              detailedResults.add(place);
            }
          }
          return detailedResults;
        }
      }
      return [];
    } catch (e) {
      print('❌ Error searching recycling center by name: $e');
      return [];
    }
  }

  /// Search for places using autocomplete
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final url = GooglePlacesConfig.buildAutocompleteUrl(query);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['predictions']);
        }
      }
      return [];
    } catch (e) {
      print('❌ Error searching places: $e');
      return [];
    }
  }

  /// Get place details by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    try {
      final url = GooglePlacesConfig.buildPlaceDetailsUrl(placeId);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return {};
    } catch (e) {
      print('❌ Error getting place details: $e');
      return {};
    }
  }

  /// Get photo URL from photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = GooglePlacesConfig.defaultPhotoMaxWidth}) {
    return GooglePlacesConfig.buildPhotoUrl(photoReference, maxWidth: maxWidth);
  }

  /// Geocode an address to get coordinates
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final url = GooglePlacesConfig.buildGeocodeUrl(address);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'latitude': location['lat'].toDouble(),
            'longitude': location['lng'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error geocoding address: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to get address
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final url = GooglePlacesConfig.buildReverseGeocodeUrl(latitude, longitude);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error reverse geocoding: $e');
      return null;
    }
  }
}