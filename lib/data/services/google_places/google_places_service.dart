import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/constants/google_maps_config.dart';
import '../../../utils/constants/google_places_config.dart';

class GooglePlacesService {
  final String _apiKey = GooglePlacesConfig.apiKey;
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

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
        String url = '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius';

        // Add type filter for recycling centers
        url += '&type=${GoogleMapsConfig.recyclingCenterTypes[0]}';
        url += '&keyword=${GoogleMapsConfig.recyclingCenterKeyword}';

        if (nextPageToken != null) {
          url += '&pagetoken=$nextPageToken';
          // Wait 2 seconds before requesting next page (Google requirement)
          await Future.delayed(const Duration(seconds: 2));
        }

        url += '&key=$_apiKey';

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
      } while (nextPageToken != null && pageCount < GoogleMapsConfig.maxNearbySearchPages);

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
      final url = Uri.parse(
        '${GoogleMapsConfig.distanceMatrixApiBaseUrl}/json?origins=$originLat,$originLng&destinations=$destLat,$destLng&key=$_apiKey',
      );

      final response = await http.get(url);

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
    int radius = 5000, // 5km default radius for name search
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=$name recycling center&location=$latitude,$longitude&radius=$radius&type=recycling_center&key=$_apiKey',
      );

      final response = await http.get(url);

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

  /// Determine if search query is a location or specific center name
  bool isLocationQuery(String query) {
    final locationKeywords = [
      'near', 'in', 'at', 'area', 'district', 'city', 'town',
      'kuala lumpur', 'selangor', 'penang', 'johor', 'melaka',
      'putrajaya', 'cyberjaya', 'shah alam', 'petaling jaya'
    ];

    final lowerQuery = query.toLowerCase();
    return locationKeywords.any((keyword) => lowerQuery.contains(keyword)) ||
        !lowerQuery.contains('recycle') && !lowerQuery.contains('center');
  }

  /// Search for places using autocomplete
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/autocomplete/json?input=$query&components=country:my&key=$_apiKey',
      );

      final response = await http.get(url);

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
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=name,geometry,formatted_address,formatted_phone_number,website,rating,user_ratings_total,opening_hours,photos,types,url&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];

          // Extract recycling items from about information
          // final recyclingItems = _extractRecyclingItemsFromAbout(result);
          // if (recyclingItems != null) {
          //   result['recycling_items'] = recyclingItems;
          // }

          return result;
        }
      }
      return {};
    } catch (e) {
      print('❌ Error getting place details: $e');
      return {};
    }
  }

  // /// Extract recycling items from editorial summary
  // List<String>? _extractRecyclingItemsFromEditorialSummary(Map<String, dynamic> placeData) {
  //   try {
  //     final editorialSummary = placeData['editorial_summary'];
  //     if (editorialSummary == null) return null;
  //
  //     final String overview = editorialSummary['overview']?.toString().toLowerCase() ?? '';
  //     final String description = editorialSummary['description']?.toString().toLowerCase() ?? '';
  //
  //     final String fullText = '$overview $description';
  //     if (fullText.trim().isEmpty) return null;
  //
  //     return _parseRecyclingItemsFromText(fullText);
  //   } catch (e) {
  //     print('⚠️ Error extracting from editorial summary: $e');
  //     return null;
  //   }
  // }

  /// Get photo URL from photo reference
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  /// Check if query is likely a specific center name vs location
  bool isSpecificCenterQuery(String query) {
    final centerKeywords = ['recycling center', 'recycling', 'recycle', 'waste', 'center', 'centre'];
    final lowerQuery = query.toLowerCase();
    return centerKeywords.any((keyword) => lowerQuery.contains(keyword));
  }

  /// Geocode an address to get coordinates
  Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&components=country:MY&key=$_apiKey',
      );

      final response = await http.get(url);

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
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
      );

      final response = await http.get(url);

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