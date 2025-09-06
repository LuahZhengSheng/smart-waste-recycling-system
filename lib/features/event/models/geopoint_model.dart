import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing geographical coordinates
class GeoPointModel {
  final double latitude;
  final double longitude;

  const GeoPointModel({
    required this.latitude,
    required this.longitude,
  });

  /// Creates an empty GeoPointModel instance (coordinates: 0,0)
  static GeoPointModel empty() => const GeoPointModel(latitude: 0.0, longitude: 0.0);

  /// Creates GeoPointModel instance from JSON map
  factory GeoPointModel.fromJson(Map<String, dynamic> json) {
    return GeoPointModel(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  /// Creates GeoPointModel instance from Firebase GeoPoint
  factory GeoPointModel.fromGeoPoint(GeoPoint geoPoint) {
    return GeoPointModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }

  /// Creates GeoPointModel instance from Firebase DocumentSnapshot
  factory GeoPointModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return GeoPointModel.fromJson(snapshot.data()!);
    }
    return GeoPointModel.empty();
  }

  /// Converts GeoPointModel instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Converts to Firebase GeoPoint
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }

  /// Calculates distance to another point in kilometers using Haversine formula
  double distanceTo(GeoPointModel other) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _toRadians(other.latitude - latitude);
    double dLon = _toRadians(other.longitude - longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) * math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Converts degrees to radians
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Returns formatted coordinates string
  String get formattedCoordinates {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Checks if coordinates are valid
  bool get isValid {
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  /// Creates a copy of GeoPointModel with updated fields
  GeoPointModel copyWith({
    double? latitude,
    double? longitude,
  }) {
    return GeoPointModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'GeoPointModel(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoPointModel &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}