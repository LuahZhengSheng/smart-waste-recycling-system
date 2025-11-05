import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';

class RecyclingActivity {
  String activityId;
  String userId;
  String centerStaffId;
  String wasteObject;
  String wasteCategoryId;
  double weight;
  String supportImage;
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
    this.status = 'pending',
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
    status: 'pending',
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
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
        status: data['status'] ?? 'pending',
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
      status: json['status'] ?? 'pending',
    );
  }

  /// Factory method to create a new recycling activity
  factory RecyclingActivity.createNew({
    required String userId,
    required String centerStaffId,
    required String wasteObject,
    required String wasteCategoryId,
    required double weight,
    required String supportImage,
    int? customPoints,
  }) {
    final points = customPoints ?? _calculatePoints(weight, wasteObject);

    return RecyclingActivity(
      activityId: '', // Will be set by Firebase
      userId: userId,
      centerStaffId: centerStaffId,
      wasteObject: wasteObject,
      wasteCategoryId: wasteCategoryId,
      weight: weight,
      supportImage: supportImage,
      pointsEarned: points,
      createdAt: DateTime.now(),
      status: 'pending',
    );
  }

  /// Private method to calculate points based on weight and waste type
  static int _calculatePoints(double weight, String wasteObject) {
    double basePoints = weight * 10; // 10 points per kg

    // Adjust points based on waste type
    switch (wasteObject.toLowerCase()) {
      case 'electronics':
        return (basePoints * 1.5).round(); // 50% bonus for electronics
      case 'plastic':
        return (basePoints * 0.8).round(); // 20% less for plastic
      case 'paper':
        return (basePoints * 0.9).round(); // 10% less for paper
      case 'glass':
        return (basePoints * 1.2).round(); // 20% bonus for glass
      case 'metal':
        return (basePoints * 1.3).round(); // 30% bonus for metal
      default:
        return basePoints.round();
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

  /// Helper method to check if activity is pending approval
  bool get isPending {
    return status == 'pending';
  }

  /// Helper method to check if activity is approved
  bool get isApproved {
    return status == 'approved';
  }

  /// Helper method to check if activity is rejected
  bool get isRejected {
    return status == 'rejected';
  }

  /// Helper method to check if activity is completed
  bool get isCompleted {
    return status == 'completed';
  }

  /// Helper method to get formatted creation date
  String get formattedCreatedAt {
    return FFormatter.formatDate(createdAt);
  }

  /// Helper method to get formatted weight
  String get formattedWeight {
    return '${weight.toStringAsFixed(2)} kg';
  }

  /// Helper method to get status display text
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

  /// Helper method to get status color (for UI)
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

  /// Helper method to approve activity
  void approve() {
    status = 'approved';
  }

  /// Helper method to reject activity
  void reject() {
    status = 'rejected';
  }

  /// Helper method to complete activity
  void complete() {
    status = 'completed';
  }

  /// Helper method to reset to pending status
  void resetToPending() {
    status = 'pending';
  }

  /// Override toString for debugging purposes
  @override
  String toString() {
    return 'RecyclingActivity(activityId: $activityId, userId: $userId, centerStaffId: $centerStaffId, wasteObject: $wasteObject, weight: $weight, points: $pointsEarned, status: $status)';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RecyclingActivity &&
              runtimeType == other.runtimeType &&
              activityId == other.activityId;

  /// Override hashCode
  @override
  int get hashCode => activityId.hashCode;

  /// Create a copy with updated fields
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

  /// Helper method to get activity age in hours
  int get ageInHours {
    return DateTime.now().difference(createdAt).inHours;
  }

  /// Helper method to check if activity is recent (within 24 hours)
  bool get isRecent {
    return ageInHours < 24;
  }

  /// Helper method to recalculate points based on current weight and waste type
  void recalculatePoints() {
    pointsEarned = _calculatePoints(weight, wasteObject);
  }

  /// Helper method to check if activity can be edited (only pending activities)
  bool get canEdit {
    return isPending;
  }

  /// Helper method to check if activity can be deleted (only pending or rejected)
  bool get canDelete {
    return isPending || isRejected;
  }
}