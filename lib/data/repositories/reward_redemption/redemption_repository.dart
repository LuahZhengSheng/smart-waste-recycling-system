import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/features/reward_redemption/models/redemption_model.dart';
import 'package:get/get.dart';

class RedemptionRepository extends GetxController {
  static RedemptionRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Make redemptions collection name a variable
  final String _redemptionsCollection = 'redemptions';

  /// Create a new redemption
  Future<RedemptionModel> createRedemption(RedemptionModel redemption) async {
    try {
      final docRef = await _db.collection(_redemptionsCollection).add(redemption.toJson());

      // Update the redemption with the generated ID
      await docRef.update({'redemptionId': docRef.id});

      // Fetch and return the created redemption
      final snapshot = await docRef.get();
      return RedemptionModel.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to create redemption: $e';
    }
  }

  /// Get all redemptions for a user
  Future<List<RedemptionModel>> getUserRedemptions(String userId) async {
    try {
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch user redemptions: $e';
    }
  }

  /// Get active redemptions (not expired)
  Future<List<RedemptionModel>> getActiveRedemptions(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .where((redemption) {
        // Check if redemption is still valid (within 30 days)
        final daysSinceRedemption = now.difference(redemption.createdAt).inDays;
        return daysSinceRedemption < 30;
      })
          .toList();
    } catch (e) {
      throw 'Failed to fetch active redemptions: $e';
    }
  }

  /// Get expired redemptions
  Future<List<RedemptionModel>> getExpiredRedemptions(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RedemptionModel.fromSnapshot(doc))
          .where((redemption) {
        final daysSinceRedemption = now.difference(redemption.createdAt).inDays;
        return daysSinceRedemption >= 30;
      })
          .toList();
    } catch (e) {
      throw 'Failed to fetch expired redemptions: $e';
    }
  }

  /// Get redemption by ID
  Future<RedemptionModel> getRedemptionById(String redemptionId) async {
    try {
      final snapshot = await _db.collection(_redemptionsCollection).doc(redemptionId).get();
      if (!snapshot.exists) {
        throw 'Redemption not found';
      }
      return RedemptionModel.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to fetch redemption: $e';
    }
  }

  /// Stream of user redemptions
  Stream<List<RedemptionModel>> getUserRedemptionsStream(String userId) {
    return _db
        .collection(_redemptionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RedemptionModel.fromSnapshot(doc))
        .toList());
  }

  /// Check if user has already redeemed a specific reward (for duplicate prevention if needed)
  Future<bool> hasUserRedeemedReward(String userId, String rewardId) async {
    try {
      final snapshot = await _db
          .collection(_redemptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('rewardId', isEqualTo: rewardId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Failed to check redemption status: $e';
    }
  }

  /// Get redemption details by ID as stream
  Stream<RedemptionModel> getRedemptionStream(String redemptionId) {
    return _db
        .collection(_redemptionsCollection)
        .doc(redemptionId)
        .snapshots()
        .map((snapshot) => RedemptionModel.fromSnapshot(snapshot));
  }
}