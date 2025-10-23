import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fyp/features/reward_redemption/models/reward_model.dart';
import 'package:get/get.dart';

class RewardRepository extends GetxController {
  static RewardRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get all active rewards
  Future<List<RewardModel>> getAllRewards() async {
    try {
      final snapshot = await _db
          .collection('rewards')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RewardModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch rewards: $e';
    }
  }

  /// Get reward by ID
  Future<RewardModel> getRewardById(String rewardId) async {
    try {
      final snapshot = await _db.collection('rewards').doc(rewardId).get();
      if (!snapshot.exists) {
        throw 'Reward not found';
      }
      return RewardModel.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to fetch reward: $e';
    }
  }

  /// Get available rewards stream (active, not expired, has quantity) - REAL TIME
  Stream<List<RewardModel>> getAvailableRewardsStream() {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: 'active')
        .where('validUntil', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('validUntil')
        .orderBy('pointsNeeded')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RewardModel.fromSnapshot(doc))
        .where((reward) => reward.quantity > 0)
        .toList());
  }

  /// Update reward quantity after redemption
  Future<void> updateRewardQuantity(String rewardId, int newQuantity) async {
    try {
      await _db.collection('rewards').doc(rewardId).update({
        'quantity': newQuantity,
        'redemptionCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to update reward quantity: $e';
    }
  }

  /// Check if reward is still available
  Future<bool> isRewardAvailable(String rewardId) async {
    try {
      final reward = await getRewardById(rewardId);
      return reward.isAvailable;
    } catch (e) {
      throw 'Failed to check reward availability: $e';
    }
  }

  /// Get reward image URL from Firebase Storage
  Future<String> getRewardImageUrl(String imagePath) async {
    try {
      if (imagePath.isEmpty) return '';
      final ref = _storage.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      return ''; // Return empty string if image doesn't exist
    }
  }

  /// Stream of all active rewards
  Stream<List<RewardModel>> getRewardsStream() {
    return _db
        .collection('rewards')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RewardModel.fromSnapshot(doc))
        .toList());
  }

  /// Stream of single reward
  Stream<RewardModel> getRewardStream(String rewardId) {
    return _db
        .collection('rewards')
        .doc(rewardId)
        .snapshots()
        .map((snapshot) => RewardModel.fromSnapshot(snapshot));
  }
}