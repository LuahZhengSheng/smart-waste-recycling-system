import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import '../../../config/google_places_config.dart';
import '../../event/models/location_model.dart';

class PartnerRecyclingCenter {
  final String centerId;
  final String name;
  final String email;
  final String phoneNo;
  final String website;
  final Location centerLocation;
  final String image;
  final Map<String, dynamic>? openingHours;
  final List<String> acceptedMaterials;
  final int numberOfStaff;
  final DateTime createdAt; // 存储 UTC 时间
  final String status;
  final double? rating;
  final int? userRatingsTotal;
  final String? placeId;

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
    createdAt: DateTime.now().toUtc(), // 使用 UTC 时间
    status: 'inactive',
  );

  /// 用于创建新回收中心的工厂方法
  static PartnerRecyclingCenter createNew({
    required String name,
    required String email,
    required String phoneNo,
    required String website,
    required Location centerLocation,
    String image = '',
    Map<String, dynamic>? openingHours,
    List<String> acceptedMaterials = const [],
    required int numberOfStaff,
    String status = 'active',
    double? rating,
    int? userRatingsTotal,
    String? placeId,
  }) {
    return PartnerRecyclingCenter(
      centerId: '', // 由 Firestore 自动生成
      name: name,
      email: email,
      phoneNo: phoneNo,
      website: website,
      centerLocation: centerLocation,
      image: image,
      openingHours: openingHours,
      acceptedMaterials: acceptedMaterials,
      numberOfStaff: numberOfStaff,
      createdAt: DateTime.now().toUtc(), // 临时 UTC 时间，写入时会被 ServerTime 替换
      status: status,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      placeId: placeId,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
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
      'status': status,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'placeId': placeId,
    };

    // 使用 ServerTime 存储 UTC 时间
    if (centerId.isEmpty) {
      // 新文档：使用 ServerTime
      json['createdAt'] = FieldValue.serverTimestamp();
    } else {
      // 现有文档：保持原有的 UTC 时间
      json['createdAt'] = Timestamp.fromDate(createdAt);
    }

    return json;
  }

  factory PartnerRecyclingCenter.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // 直接读取 ServerTime (UTC)
      DateTime createdAt;
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else {
        // 降级方案：使用当前 UTC 时间
        createdAt = DateTime.now().toUtc();
      }

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
        createdAt: createdAt, // 存储 UTC 时间
        status: data['status'] ?? 'inactive',
        rating: data['rating']?.toDouble(),
        userRatingsTotal: data['userRatingsTotal'],
        placeId: data['placeId'],
      );
    } else {
      return PartnerRecyclingCenter.empty();
    }
  }

  /// 从 JSON 创建（用于 API 响应等）
  factory PartnerRecyclingCenter.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
    } else {
      createdAt = DateTime.now().toUtc();
    }

    return PartnerRecyclingCenter(
      centerId: json['centerId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      website: json['website'] ?? '',
      centerLocation: Location.fromJson(Map<String, dynamic>.from(json['centerLocation'] ?? {})),
      image: json['image'] ?? '',
      openingHours: Map<String, dynamic>.from(json['openingHours'] ?? {}),
      acceptedMaterials: List<String>.from(json['acceptedMaterials'] ?? []),
      numberOfStaff: (json['numberOfStaff'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      status: json['status'] ?? 'inactive',
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'],
      placeId: json['placeId'],
    );
  }

  /// 显示为马来西亚时间 (UTC+8)
  DateTime get displayTime {
    return createdAt.add(const Duration(hours: 8));
  }

  /// 获取当前马来西亚时间（用于营业判断）
  static DateTime _getCurrentMalaysiaTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 8));
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

  /// 格式化显示时间（马来西亚时间）
  String get formattedCreatedAt {
    return FFormatter.formatDate(displayTime);
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

  /// 营业时间判断使用当前马来西亚时间
  bool get isOpenNow {
    if (openingHours == null) return false;
    return _isOpenAtTime(_getCurrentMalaysiaTime());
  }

  /// 私有方法：统一的营业时间判断逻辑
  bool _isOpenAtTime(DateTime time) {
    final weekday = time.weekday;

    final periods = openingHours!['periods'] as List<dynamic>?;
    if (periods == null) return false;

    for (var period in periods) {
      final open = period['open'];
      if (open != null && open['day'] == weekday - 1) {
        final openTime = open['time'] as String?;
        final closeTime = period['close']?['time'] as String?;

        if (openTime != null && closeTime != null) {
          final currentTimeStr = '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}';
          return currentTimeStr.compareTo(openTime) >= 0 && currentTimeStr.compareTo(closeTime) < 0;
        }
      }
    }
    return false;
  }

  List<String> get weekdayText {
    if (openingHours != null && openingHours!['weekday_text'] is List) {
      return List<String>.from(openingHours!['weekday_text']);
    }

    return ['Monday: Unknown', 'Tuesday: Unknown', 'Wednesday: Unknown',
      'Thursday: Unknown', 'Friday: Unknown', 'Saturday: Unknown', 'Sunday: Unknown'];
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
    return 'PartnerRecyclingCenter(centerId: $centerId, name: $name, isActive: $isActive, rating: $rating, createdAt: $createdAt)';
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