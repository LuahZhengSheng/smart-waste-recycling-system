import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a physical address
class Address {
  final String unitNo;
  final String area;
  final String postcode;
  final String city;
  final String state;

  const Address({
    required this.unitNo,
    required this.area,
    required this.postcode,
    required this.city,
    required this.state,
  });

  /// Creates an empty Address instance
  static Address empty() => const Address(
    unitNo: '',
    area: '',
    postcode: '',
    city: '',
    state: '',
  );

  /// Creates Address instance from JSON map
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      unitNo: json['unitNo'] ?? '',
      area: json['area'] ?? '',
      postcode: json['postcode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }

  /// Creates Address instance from Firebase DocumentSnapshot
  factory Address.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return Address.fromJson(snapshot.data()!);
    }
    return Address.empty();
  }

  /// Converts Address instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'unitNo': unitNo,
      'area': area,
      'postcode': postcode,
      'city': city,
      'state': state,
    };
  }

  /// Returns formatted address string
  String get formattedAddress {
    return '$unitNo, $area, $postcode $city, $state';
  }

  /// Returns short address format (area, city, state)
  String get shortAddress {
    return '$area, $city, $state';
  }

  /// Creates a copy of Address with updated fields
  Address copyWith({
    String? unitNo,
    String? area,
    String? postcode,
    String? city,
    String? state,
  }) {
    return Address(
      unitNo: unitNo ?? this.unitNo,
      area: area ?? this.area,
      postcode: postcode ?? this.postcode,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  @override
  String toString() {
    return 'Address(unitNo: $unitNo, area: $area, postcode: $postcode, city: $city, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.unitNo == unitNo &&
        other.area == area &&
        other.postcode == postcode &&
        other.city == city &&
        other.state == state;
  }

  @override
  int get hashCode {
    return unitNo.hashCode ^
    area.hashCode ^
    postcode.hashCode ^
    city.hashCode ^
    state.hashCode;
  }
}