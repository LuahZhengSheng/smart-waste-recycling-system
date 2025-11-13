import '../../../config/google_places_config.dart';

class GooglePlace {
  final String placeId;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final List<String> photoReferences;
  final Map<String, dynamic>? openingHours;
  final List<String> types;
  final bool isPartner; // Matched with Firebase partner center
  final String? partnerCenterId; // Firebase center ID if matched

  GooglePlace({
    required this.placeId,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.photoReferences = const [],
    this.openingHours,
    this.types = const [],
    this.isPartner = false,
    this.partnerCenterId,
  });

  factory GooglePlace.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    return GooglePlace(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['vicinity'] ?? json['formatted_address'],
      latitude: location['lat']?.toDouble() ?? 0.0,
      longitude: location['lng']?.toDouble() ?? 0.0,
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      photoReferences: (json['photos'] as List<dynamic>?)
          ?.map((photo) => photo['photo_reference'] as String)
          .toList() ?? [],
      openingHours: json['opening_hours'],
      types: (json['types'] as List<dynamic>?)
          ?.map((type) => type.toString())
          .toList() ?? [],
    );
  }

  String getPhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=${GooglePlacesConfig.apiKey}';
  }

  String get firstPhotoUrl {
    if (photoReferences.isEmpty) return '';
    return getPhotoUrl(photoReferences.first);
  }

  bool get hasPhotos => photoReferences.isNotEmpty;

  bool get isOpenNow {
    return openingHours?['open_now'] ?? false;
  }

  List<String> get weekdayText {
    return (openingHours?['weekday_text'] as List<dynamic>?)
        ?.map((text) => text.toString())
        .toList() ?? [];
  }

  GooglePlace copyWith({
    bool? isPartner,
    String? partnerCenterId,
  }) {
    return GooglePlace(
      placeId: placeId,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber,
      website: website,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      photoReferences: photoReferences,
      openingHours: openingHours,
      types: types,
      isPartner: isPartner ?? this.isPartner,
      partnerCenterId: partnerCenterId ?? this.partnerCenterId,
    );
  }

  @override
  String toString() {
    return 'GooglePlace(name: $name, isPartner: $isPartner, lat: $latitude, lng: $longitude)';
  }
}