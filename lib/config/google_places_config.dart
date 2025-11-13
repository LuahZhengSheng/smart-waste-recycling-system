import 'env_config.dart';

class GooglePlacesConfig {
  // API Key from environment configuration
  static final String apiKey = EnvConfig.googlePlacesApiKey;

  // Base URLs and Endpoints
  static const String placesApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String nearbySearchEndpoint = '/nearbysearch/json';
  static const String textSearchEndpoint = '/textsearch/json';
  static const String detailsEndpoint = '/details/json';
  static const String photoEndpoint = '/photo';
  static const String autocompleteEndpoint = '/autocomplete/json';
  static const String geocodeEndpoint = '/geocode/json';
  static const String distanceMatrixApiBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix';

  // Search Types
  static const String recyclingCenterType = 'recycling_center';
  static const String wasteManagementType = 'waste_management';

  // Recycling-related keywords for search
  static const String recyclingCenterKeyword = 'recycling center';

  // Supported recycling center types
  static const List<String> recyclingCenterTypes = [
    'recycling_center',
    'waste_management',
    'scrap_yard',
    'recycling_plant'
  ];

  // Search Parameters
  static const int defaultRadiusMeters = 5000; // 5km default search radius
  static const int maxRadiusMeters = 50000; // 50km maximum search radius
  static const int minRadiusMeters = 1000; // 1km minimum search radius
  static const String defaultCountry = 'my'; // Malaysia country code
  static const String defaultLanguage = 'en'; // English language

  // Pagination Settings
  static const int maxNearbySearchPages = 3; // Maximum pages to fetch for paginated results
  static const Duration nextPageDelay = Duration(seconds: 2); // Delay between page requests (Google requirement)

  // Photo Settings
  static const int defaultPhotoMaxWidth = 400;
  static const int highResPhotoMaxWidth = 800;
  static const int thumbnailPhotoMaxWidth = 200;

  // Location Keywords for Query Analysis
  static const List<String> locationKeywords = [
    'near', 'in', 'at', 'area', 'district', 'city', 'town',
    'kuala lumpur', 'selangor', 'penang', 'johor', 'melaka',
    'putrajaya', 'cyberjaya', 'shah alam', 'petaling jaya'
  ];

  // Recycling Center Keywords for Query Analysis
  static const List<String> centerKeywords = [
    'recycling center', 'recycling', 'recycle', 'waste', 'center', 'centre'
  ];

  // Default Place Details Fields
  static const String defaultPlaceDetailsFields =
      'name,geometry,formatted_address,formatted_phone_number,'
      'website,rating,user_ratings_total,opening_hours,photos,types,url';

  // Default location (Kuala Lumpur coordinates)
  static const Map<String, double> defaultLocation = {
    'lat': 3.1390,
    'lng': 101.6869,
  };

  /// Build URL for nearby search with recycling centers
  static String buildNearbySearchUrl({
    required double latitude,
    required double longitude,
    int radius = defaultRadiusMeters,
    String? nextPageToken,
  }) {
    final validatedRadius = validateRadius(radius);
    String url = '$placesApiBaseUrl$nearbySearchEndpoint'
        '?location=$latitude,$longitude'
        '&radius=$validatedRadius'
        '&type=$recyclingCenterType'
        '&keyword=$recyclingCenterKeyword'
        '&key=$apiKey';

    if (nextPageToken != null) {
      url += '&pagetoken=$nextPageToken';
    }

    return url;
  }

  /// Build URL for text-based search
  static String buildTextSearchUrl({
    required String query,
    double? latitude,
    double? longitude,
    int radius = defaultRadiusMeters,
  }) {
    String url = '$placesApiBaseUrl$textSearchEndpoint'
        '?query=${Uri.encodeComponent(query)}'
        '&type=$recyclingCenterType'
        '&key=$apiKey';

    if (latitude != null && longitude != null) {
      url += '&location=$latitude,$longitude&radius=${validateRadius(radius)}';
    }

    return url;
  }

  /// Build URL for place details
  static String buildPlaceDetailsUrl(String placeId, {String fields = defaultPlaceDetailsFields}) {
    return '$placesApiBaseUrl$detailsEndpoint'
        '?place_id=$placeId'
        '&fields=$fields'
        '&key=$apiKey';
  }

  /// Build URL for place photos
  static String buildPhotoUrl(String photoReference, {int maxWidth = defaultPhotoMaxWidth}) {
    return '$placesApiBaseUrl$photoEndpoint'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }

  /// Build URL for autocomplete search
  static String buildAutocompleteUrl(String query) {
    return '$placesApiBaseUrl$autocompleteEndpoint'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:$defaultCountry'
        '&key=$apiKey';
  }

  /// Build URL for distance matrix calculation
  static String buildDistanceMatrixUrl({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return '$distanceMatrixApiBaseUrl/json'
        '?origins=$originLat,$originLng'
        '&destinations=$destLat,$destLng'
        '&key=$apiKey';
  }

  /// Build URL for geocoding (address to coordinates)
  static String buildGeocodeUrl(String address) {
    return 'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&components=country:$defaultCountry'
        '&key=$apiKey';
  }

  /// Build URL for reverse geocoding (coordinates to address)
  static String buildReverseGeocodeUrl(double latitude, double longitude) {
    return 'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=$apiKey';
  }

  /// Validate search radius is within acceptable limits
  static int validateRadius(int radius) {
    if (radius < minRadiusMeters) return minRadiusMeters;
    if (radius > maxRadiusMeters) return maxRadiusMeters;
    return radius;
  }

  /// Determine if a query is location-based
  static bool isLocationQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return locationKeywords.any((keyword) => lowerQuery.contains(keyword)) ||
        !lowerQuery.contains('recycle') && !lowerQuery.contains('center');
  }

  /// Determine if a query is for a specific recycling center
  static bool isSpecificCenterQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return centerKeywords.any((keyword) => lowerQuery.contains(keyword));
  }

  /// Get all supported recycling center types
  static List<String> get supportedRecyclingTypes => List.from(recyclingCenterTypes);
}