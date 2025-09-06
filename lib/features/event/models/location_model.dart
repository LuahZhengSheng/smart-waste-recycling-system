import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';
import 'geopoint_model.dart';

/// Model representing a location with address and geographical coordinates
class Location {
  final Address address;
  final GeoPointModel geoPoint;

  const Location({
    required this.address,
    required this.geoPoint,
  });

  /// Creates an empty Location instance
  static Location empty() => Location(
    address: Address.empty(),
    geoPoint: GeoPointModel.empty(),
  );

  /// Creates Location instance from JSON map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: Address.fromJson(json['address'] ?? {}),
      geoPoint: GeoPointModel.fromJson(json['geoPoint'] ?? {}),
    );
  }

  /// Creates Location instance from Firebase DocumentSnapshot
  factory Location.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return Location.fromJson(snapshot.data()!);
    }
    return Location.empty();
  }

  /// Converts Location instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'address': address.toJson(),
      'geoPoint': geoPoint.toJson(),
    };
  }

  /// Returns the full formatted address
  String get fullAddress => address.formattedAddress;

  /// Returns the short formatted address
  String get shortAddress => address.shortAddress;

  /// Returns formatted coordinates
  String get coordinates => geoPoint.formattedCoordinates;

  /// Calculates distance to another location in kilometers
  double distanceTo(Location other) {
    return geoPoint.distanceTo(other.geoPoint);
  }

  /// Checks if location data is valid
  bool get isValid {
    return address.area.isNotEmpty &&
        address.city.isNotEmpty &&
        address.state.isNotEmpty &&
        geoPoint.isValid;
  }

  /// Creates a copy of Location with updated fields
  Location copyWith({
    Address? address,
    GeoPointModel? geoPoint,
  }) {
    return Location(
      address: address ?? this.address,
      geoPoint: geoPoint ?? this.geoPoint,
    );
  }

  @override
  String toString() {
    return 'Location(address: $address, geoPoint: $geoPoint)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.address == address &&
        other.geoPoint == geoPoint;
  }

  @override
  int get hashCode => address.hashCode ^ geoPoint.hashCode;
}