import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/personalization/models/recycle_activity_model.dart';

class RecyclingActivityRepository extends GetxController {
  static RecyclingActivityRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Make recyclingActivities collection name a variable
  final String _recyclingActivitiesCollection = 'recyclingActivities';

  /// Get recycling activity by ID
  Future<RecyclingActivity> getActivityById(String activityId) async {
    try {
      final snapshot = await _db.collection(_recyclingActivitiesCollection).doc(activityId).get();
      if (!snapshot.exists) {
        throw 'Activity not found';
      }
      return RecyclingActivity.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to fetch activity: $e';
    }
  }

  /// Get user's approved recycling activities stream
  Stream<List<RecyclingActivity>> getUserApprovedActivitiesStream(String userId) {
    return _db
        .collection(_recyclingActivitiesCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList());
  }

  /// Get all user's recycling activities stream
  Stream<List<RecyclingActivity>> getUserActivitiesStream(String userId) {
    return _db
        .collection(_recyclingActivitiesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList());
  }

  /// Get activities within date range stream
  Stream<List<RecyclingActivity>> getUserActivitiesInRangeStream(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return _db
        .collection(_recyclingActivitiesCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RecyclingActivity.fromSnapshot(doc))
        .toList());
  }

  /// Get single activity stream by ID
  Stream<RecyclingActivity> getActivityStream(String activityId) {
    return _db
        .collection(_recyclingActivitiesCollection)
        .doc(activityId)
        .snapshots()
        .map((snapshot) => RecyclingActivity.fromSnapshot(snapshot));
  }
}