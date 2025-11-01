class GooglePlacesConfig {
  static const String apiKey = 'AIzaSyDxxkSWPJGDFFpcejtULq6hHohdYuTLQ5A';

  static const String placesApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String nearbySearchEndpoint = '/nearbysearch/json';
  static const String detailsEndpoint = '/details/json';
  static const String photoEndpoint = '/photo';
  static const String autocompleteEndpoint = '/autocomplete/json';

  // Search types
  static const String recyclingCenterType = 'recycling_center';
  static const String wasteManagementType = 'waste_management';

  // Default search parameters
  static const int defaultRadiusMeters = 5000; // 5km in meters
  static const int maxRadiusMeters = 50000; // 50km in meters
  static const String defaultCountry = 'my'; // Malaysia

  // Photo settings
  static const int defaultPhotoMaxWidth = 400;
  static const int highResPhotoMaxWidth = 800;
}