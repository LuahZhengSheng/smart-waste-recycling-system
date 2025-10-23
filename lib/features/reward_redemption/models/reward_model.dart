import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:fyp/utils/formatters/formatter.dart';

class RewardModel {
  String rewardId;
  String title;
  String description;
  String termsConditions;
  String rewardImage;
  int pointsNeeded;
  int quantity;
  DateTime validUntil;
  int redemptionCount;
  DateTime createdAt;
  String status;
  List<RedemptionModel> redemptions;

  /// Constructor
  RewardModel({
    required this.rewardId,
    required this.title,
    required this.description,
    required this.termsConditions,
    required this.rewardImage,
    required this.pointsNeeded,
    required this.quantity,
    required this.validUntil,
    required this.redemptionCount,
    required this.createdAt,
    required this.status,
    this.redemptions = const [],
  });

  /// Static function to create empty reward model
  static RewardModel empty() => RewardModel(
    rewardId: '',
    title: '',
    description: '',
    termsConditions: '',
    rewardImage: '',
    pointsNeeded: 0,
    quantity: 0,
    validUntil: DateTime.now(),
    redemptionCount: 0,
    createdAt: DateTime.now(),
    status: 'active',
    redemptions: [],
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'title': title,
      'description': description,
      'termsConditions': termsConditions,
      'rewardImage': rewardImage,
      'pointsNeeded': pointsNeeded,
      'quantity': quantity,
      'validUntil': validUntil.toIso8601String(),
      'redemptionCount': redemptionCount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  /// Factory method to create a RewardModel from a Firebase document snapshot
  factory RewardModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() != null) {
      final data = doc.data()!;
      return RewardModel(
        rewardId: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        termsConditions: data['termsConditions'] ?? '',
        rewardImage: data['rewardImage'] ?? '',
        pointsNeeded: data['pointsNeeded'] ?? 0,
        quantity: data['quantity'] ?? 0,
        validUntil: (data['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now(),
        redemptionCount: data['redemptionCount'] ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: data['status'] ?? 'active',
        redemptions: (data['redemptions'] as List<dynamic>?)
            ?.map((redemptionData) => RedemptionModel.fromJson(redemptionData))
            .toList() ?? [],
      );
    } else {
      return RewardModel.empty();
    }
  }

  /// Factory method to create a RewardModel from a JSON map
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      rewardId: json['rewardId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      termsConditions: json['termsConditions'] ?? '',
      rewardImage: json['rewardImage'] ?? '',
      pointsNeeded: json['pointsNeeded'] ?? 0,
      quantity: json['quantity'] ?? 0,
      validUntil: DateTime.parse(json['validUntil'] ?? DateTime.now().toIso8601String()),
      redemptionCount: json['redemptionCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      redemptions: (json['redemptions'] as List<dynamic>?)
          ?.map((redemptionData) => RedemptionModel.fromJson(redemptionData))
          .toList() ?? [],
    );
  }

  /// Helper method to check if reward is available for redemption
  bool get isAvailable {
    return status == 'active' &&
        quantity > 0 &&
        validUntil.isAfter(DateTime.now());
  }

  /// Helper method to check if reward has expired
  bool get isExpired {
    return validUntil.isBefore(DateTime.now());
  }

  /// Helper method to get remaining quantity
  int get remainingQuantity {
    return quantity - redemptions.length;
  }

  /// Helper method to get total redemptions count
  int get totalRedemptions {
    return redemptions.length;
  }

  /// Helper method to get formatted valid until date
  String get formattedValidUntil {
    return FFormatter.formatDate(validUntil);
  }

  /// Helper method to get formatted created at date
  String get formattedCreatedAt {
    return FFormatter.formatDate(createdAt);
  }

  /// Helper method to get status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'expired':
        return 'Expired';
      case 'out_of_stock':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }

  /// Helper method to check if user has already redeemed this reward
  bool hasUserRedeemed(String userId) {
    return redemptions.any((redemption) => redemption.userId == userId);
  }

  /// Helper method to get user's redemption for this reward
  RedemptionModel? getUserRedemption(String userId) {
    try {
      return redemptions.firstWhere((redemption) => redemption.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Helper method to add a new redemption
  void addRedemption(RedemptionModel redemption) {
    redemptions.add(redemption);
  }

  /// Helper method to remove a redemption
  void removeRedemption(String redemptionId) {
    redemptions.removeWhere((redemption) => redemption.redemptionId == redemptionId);
  }

  /// Helper method to update reward status based on conditions
  void updateStatus() {
    if (validUntil.isBefore(DateTime.now())) {
      status = 'expired';
    } else if (remainingQuantity <= 0) {
      status = 'out_of_stock';
    } else if (status == 'expired' || status == 'out_of_stock') {
      status = 'active'; // Reactivate if conditions are met again
    }
  }

  /// Helper method to validate reward data
  bool isValid() {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        pointsNeeded > 0 &&
        quantity > 0 &&
        validUntil.isAfter(DateTime.now());
  }

  /// Override toString for debugging purposes
  @override
  String toString() {
    return 'RewardModel(rewardId: $rewardId, title: $title, pointsNeeded: $pointsNeeded, quantity: $quantity, status: $status)';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RewardModel &&
              runtimeType == other.runtimeType &&
              rewardId == other.rewardId;

  /// Override hashCode
  @override
  int get hashCode => rewardId.hashCode;

  /// Create a copy of the reward with updated fields
  RewardModel copyWith({
    String? rewardId,
    String? title,
    String? description,
    String? termsConditions,
    String? rewardImage,
    int? pointsNeeded,
    int? quantity,
    DateTime? validUntil,
    int? redemptionCount,
    DateTime? createdAt,
    String? status,
    List<RedemptionModel>? redemptions,
  }) {
    return RewardModel(
      rewardId: rewardId ?? this.rewardId,
      title: title ?? this.title,
      description: description ?? this.description,
      termsConditions: termsConditions ?? this.termsConditions,
      rewardImage: rewardImage ?? this.rewardImage,
      pointsNeeded: pointsNeeded ?? this.pointsNeeded,
      quantity: quantity ?? this.quantity,
      validUntil: validUntil ?? this.validUntil,
      redemptionCount: redemptionCount ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      redemptions: redemptions ?? this.redemptions,
    );
  }
}