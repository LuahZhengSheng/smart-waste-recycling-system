import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp/utils/formatters/formatter.dart';

class RecyclingActivity {
  String activityId;
  String userId;
  String centerStaffId;
  String wasteObject;
  String wasteCategoryId;
  double weight;
  String supportImage; // Only stores the filename
  int pointsEarned;
  DateTime createdAt;
  String status;

  /// Constructor
  RecyclingActivity({
    required this.activityId,
    required this.userId,
    required this.centerStaffId,
    required this.wasteObject,
    required this.wasteCategoryId,
    required this.weight,
    required this.supportImage,
    required this.pointsEarned,
    required this.createdAt,
    this.status = 'completed', // Changed default to completed
  });

  /// Static function to create empty activity model
  static RecyclingActivity empty() => RecyclingActivity(
    activityId: '',
    userId: '',
    centerStaffId: '',
    wasteObject: '',
    wasteCategoryId: '',
    weight: 0.0,
    supportImage: '',
    pointsEarned: 0,
    createdAt: DateTime.now(),
    status: 'completed',
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'centerStaffId': centerStaffId,
      'wasteObject': wasteObject,
      'wasteCategoryId': wasteCategoryId,
      'weight': weight,
      'supportImage': supportImage,
      'pointsEarned': pointsEarned,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  /// Factory method to create from a Firebase document snapshot
  factory RecyclingActivity.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return RecyclingActivity(
        activityId: document.id,
        userId: data['userId'] ?? '',
        centerStaffId: data['centerStaffId'] ?? '',
        wasteObject: data['wasteObject'] ?? '',
        wasteCategoryId: data['wasteCategoryId'] ?? '',
        weight: (data['weight'] ?? 0.0).toDouble(),
        supportImage: data['supportImage'] ?? '',
        pointsEarned: (data['pointsEarned'] ?? 0).toInt(),
        createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
        status: data['status'] ?? 'completed',
      );
    } else {
      return RecyclingActivity.empty();
    }
  }

  /// Factory method to create from a JSON map
  factory RecyclingActivity.fromJson(Map<String, dynamic> json) {
    return RecyclingActivity(
      activityId: json['activityId'] ?? '',
      userId: json['userId'] ?? '',
      centerStaffId: json['centerStaffId'] ?? '',
      wasteObject: json['wasteObject'] ?? '',
      wasteCategoryId: json['wasteCategoryId'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      supportImage: json['supportImage'] ?? '',
      pointsEarned: (json['pointsEarned'] ?? 0).toInt(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'completed',
    );
  }

  /// Factory method to create a new recycling activity (without activityId)
  factory RecyclingActivity.createNew({
    required String userId,
    required String centerStaffId,
    required String wasteObject,
    required String wasteCategoryId,
    required double weight,
    required String supportImage,
    int? customPoints,
  }) {
    final points = customPoints ?? _calculatePoints(weight, wasteCategoryId);

    return RecyclingActivity(
      activityId: '', // Will be set by Firestore
      userId: userId,
      centerStaffId: centerStaffId,
      wasteObject: wasteObject,
      wasteCategoryId: wasteCategoryId,
      weight: weight,
      supportImage: supportImage,
      pointsEarned: points,
      createdAt: DateTime.now(),
      status: 'completed', // Set as completed by default
    );
  }

  /// Private method to calculate points based on weight and category
  static int _calculatePoints(double weight, String wasteCategoryId) {
    double basePoints = weight * 10;
    return basePoints.round();
  }

  /// Helper method to get full image URL
  Future<String> getSupportImageUrl(String userId) async {
    if (supportImage.isEmpty) return '';

    try {
      final ref = FirebaseStorage.instance
          .ref('recycling_activities')
          .child(userId)
          .child(supportImage);

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return '';
    }
  }

  /// Helper method to check if activity data is valid
  bool isValid() {
    return userId.isNotEmpty &&
        centerStaffId.isNotEmpty &&
        wasteObject.isNotEmpty &&
        weight > 0 &&
        supportImage.isNotEmpty;
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';

  String get formattedCreatedAt => FFormatter.formatDate(createdAt);
  String get formattedWeight => '${weight.toStringAsFixed(2)} kg';

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'completed':
        return 'blue';
      default:
        return 'grey';
    }
  }

  void approve() => status = 'approved';
  void reject() => status = 'rejected';
  void complete() => status = 'completed';
  void resetToPending() => status = 'pending';

  @override
  String toString() {
    return 'RecyclingActivity(activityId: $activityId, userId: $userId, centerStaffId: $centerStaffId, wasteObject: $wasteObject, weight: $weight, points: $pointsEarned, status: $status)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RecyclingActivity &&
              runtimeType == other.runtimeType &&
              activityId == other.activityId;

  @override
  int get hashCode => activityId.hashCode;

  RecyclingActivity copyWith({
    String? activityId,
    String? userId,
    String? centerStaffId,
    String? wasteObject,
    String? wasteCategoryId,
    double? weight,
    String? supportImage,
    int? pointsEarned,
    DateTime? createdAt,
    String? status,
  }) {
    return RecyclingActivity(
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      centerStaffId: centerStaffId ?? this.centerStaffId,
      wasteObject: wasteObject ?? this.wasteObject,
      wasteCategoryId: wasteCategoryId ?? this.wasteCategoryId,
      weight: weight ?? this.weight,
      supportImage: supportImage ?? this.supportImage,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  int get ageInHours => DateTime.now().difference(createdAt).inHours;
  bool get isRecent => ageInHours < 24;

  void recalculatePoints() {
    pointsEarned = _calculatePoints(weight, wasteCategoryId);
  }

  bool get canEdit => isPending;
  bool get canDelete => isPending || isRejected;
}