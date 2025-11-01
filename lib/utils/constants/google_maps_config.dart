
class GoogleMapsConfig {
  GoogleMapsConfig._();

  // Store your API key securely - consider using flutter_dotenv or similar
  static const String _apiKey = 'AIzaSyDxxkSWPJGDFFpcejtULq6hHohdYuTLQ5A';

  static String get apiKey {
    // Add validation
    if (_apiKey == 'AIzaSyDxxkSWPJGDFFpcejtULq6hHohdYuTLQ5A') {
      throw Exception('Google Maps API key not configured. Please add your API key.');
    }
    return _apiKey;
  }

  // Google Maps API endpoints
  static const String placesApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String directionsApiBaseUrl = 'https://maps.googleapis.com/maps/api/directions';
  static const String distanceMatrixApiBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix';

  // Default map settings
  static const double defaultZoom = 14.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;

  // Search radius settings (in km)
  static const double defaultSearchRadiusKm = 5.0;
  static const double minSearchRadiusKm = 1.0;
  static const double maxSearchRadiusKm = 50.0;

  // Nearby search settings
  static const int nearbySearchResultsPerRequest = 20; // Google Places API limit
  static const int maxNearbySearchPages = 3; // Max pages to fetch (60 results total)

  // Search types
  static const List<String> recyclingCenterTypes = [
    'recycling_center',
    'waste_management',
  ];

  static const String recyclingCenterKeyword = 'recycling';
}