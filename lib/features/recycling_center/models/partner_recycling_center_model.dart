import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import '../../../utils/constants/google_places_config.dart';
import '../../event/models/location_model.dart';

class PartnerRecyclingCenter {
  final String centerId;
  final String name;
  final String email;
  final String phoneNo;
  final String website;
  final Location centerLocation;
  final String image;
  final Map<String, dynamic>? openingHours; // Changed to match Google Places format
  final List<String> acceptedMaterials;
  final int numberOfStaff;
  final DateTime createdAt;
  final String status;
  final double? rating;
  final int? userRatingsTotal;
  final String? placeId;

  // Removed: final List<String> photoReferences;

  PartnerRecyclingCenter({
    required this.centerId,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.website,
    required this.centerLocation,
    required this.image,
    this.openingHours,
    this.acceptedMaterials = const [],
    required this.numberOfStaff,
    required this.createdAt,
    required this.status,
    this.rating,
    this.userRatingsTotal,
    this.placeId,
  });

  static PartnerRecyclingCenter empty() => PartnerRecyclingCenter(
    centerId: '',
    name: '',
    email: '',
    phoneNo: '',
    website: '',
    centerLocation: Location.empty(),
    image: '',
    openingHours: null,
    acceptedMaterials: [],
    numberOfStaff: 0,
    createdAt: DateTime.now(),
    status: 'inactive',
  );

  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'website': website,
      'centerLocation': centerLocation.toJson(),
      'image': image,
      'openingHours': openingHours,
      'acceptedMaterials': acceptedMaterials,
      'numberOfStaff': numberOfStaff,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'placeId': placeId,
    };
  }

  factory PartnerRecyclingCenter.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return PartnerRecyclingCenter(
        centerId: document.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phoneNo: data['phoneNo'] ?? '',
        website: data['website'] ?? '',
        centerLocation: Location.fromJson(Map<String, dynamic>.from(data['centerLocation'] ?? {})),
        image: data['image'] ?? '',
        openingHours: Map<String, dynamic>.from(data['openingHours'] ?? {}),
        acceptedMaterials: List<String>.from(data['acceptedMaterials'] ?? []),
        numberOfStaff: (data['numberOfStaff'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
        status: data['status'] ?? 'inactive',
        rating: data['rating']?.toDouble(),
        userRatingsTotal: data['userRatingsTotal'],
        placeId: data['placeId'],
      );
    } else {
      return PartnerRecyclingCenter.empty();
    }
  }

  bool isValid() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phoneNo.isNotEmpty &&
        website.isNotEmpty &&
        status.isNotEmpty;
  }

  bool get hasValidEmail {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool get hasValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phoneNo.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  bool get hasValidWebsite {
    final websiteRegex = RegExp(r'^(http|https):\/\/[^ "]+$');
    return websiteRegex.hasMatch(website);
  }

  String get formattedCreatedAt {
    return FFormatter.formatDate(createdAt);
  }

  String get formattedPhoneNo {
    if (phoneNo.length == 10) {
      return '${phoneNo.substring(0, 3)}-${phoneNo.substring(3, 6)}-${phoneNo.substring(6)}';
    }
    return phoneNo;
  }

  String get displayNameWithId {
    return '$name (ID: ${centerId.substring(0, 8)})';
  }

  bool get isActive {
    return status == 'active';
  }

  bool get isOpenNow {
    if (openingHours == null) return false;

    final now = DateTime.now();
    final weekday = now.weekday; // 1=Monday, 7=Sunday

    // Google Places opening hours format
    final periods = openingHours!['periods'] as List<dynamic>?;
    if (periods == null) return false;

    for (var period in periods) {
      final open = period['open'];
      if (open != null && open['day'] == weekday - 1) { // Google uses 0=Sunday, 6=Saturday
        final openTime = open['time'] as String?;
        final closeTime = period['close']?['time'] as String?;

        if (openTime != null && closeTime != null) {
          final currentTimeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
          return currentTimeStr.compareTo(openTime) >= 0 && currentTimeStr.compareTo(closeTime) < 0;
        }
      }
    }

    return false;
  }

  List<String> get weekdayText {
    final List<String> result = [];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    if (openingHours != null && openingHours!['weekday_text'] is List) {
      return List<String>.from(openingHours!['weekday_text']);
    }

    // Fallback if weekday_text is not available
    for (final day in days) {
      result.add('$day: Unknown');
    }
    return result;
  }

  bool get hasPhotos => image.isNotEmpty;

  bool acceptsMaterial(String material) {
    return acceptedMaterials.any((m) => m.toLowerCase().contains(material.toLowerCase()));
  }

  PartnerRecyclingCenter copyWith({
    String? centerId,
    String? name,
    String? email,
    String? phoneNo,
    String? website,
    Location? centerLocation,
    String? image,
    Map<String, dynamic>? openingHours,
    List<String>? acceptedMaterials,
    int? numberOfStaff,
    DateTime? createdAt,
    String? status,
    double? rating,
    int? userRatingsTotal,
    String? placeId,
  }) {
    return PartnerRecyclingCenter(
      centerId: centerId ?? this.centerId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      website: website ?? this.website,
      centerLocation: centerLocation ?? this.centerLocation,
      image: image ?? this.image,
      openingHours: openingHours ?? this.openingHours,
      acceptedMaterials: acceptedMaterials ?? this.acceptedMaterials,
      numberOfStaff: numberOfStaff ?? this.numberOfStaff,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      placeId: placeId ?? this.placeId,
    );
  }

  @override
  String toString() {
    return 'PartnerRecyclingCenter(centerId: $centerId, name: $name, isPartner: ${isActive}, rating: $rating)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PartnerRecyclingCenter &&
              runtimeType == other.runtimeType &&
              centerId == other.centerId;

  @override
  int get hashCode => centerId.hashCode;
}