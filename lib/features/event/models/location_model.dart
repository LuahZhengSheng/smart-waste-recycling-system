import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';
import 'geopoint_model.dart';

/// Model representing a location with address and geographical coordinates
class Location {
  final String venueName; // 🆕 添加场地名称
  final Address address;
  final GeoPointModel geoPoint;

  const Location({
    this.venueName = '', // 🆕 默认为空字符串
    required this.address,
    required this.geoPoint,
  });

  /// Creates an empty Location instance
  static Location empty() => Location(
    venueName: '', // 🆕
    address: Address.empty(),
    geoPoint: GeoPointModel.empty(),
  );

  /// Creates Location instance from JSON map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      venueName: json['venueName'] ?? '', // 🆕
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
      'venueName': venueName, // 🆕
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

  /// 🆕 Returns latitude
  double get latitude => geoPoint.latitude;

  /// 🆕 Returns longitude
  double get longitude => geoPoint.longitude;

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
    String? venueName, // 🆕
    Address? address,
    GeoPointModel? geoPoint,
  }) {
    return Location(
      venueName: venueName ?? this.venueName, // 🆕
      address: address ?? this.address,
      geoPoint: geoPoint ?? this.geoPoint,
    );
  }

  @override
  String toString() {
    return 'Location(venueName: $venueName, address: $address, geoPoint: $geoPoint)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.venueName == venueName && // 🆕
        other.address == address &&
        other.geoPoint == geoPoint;
  }

  @override
  int get hashCode => venueName.hashCode ^ address.hashCode ^ geoPoint.hashCode;
}