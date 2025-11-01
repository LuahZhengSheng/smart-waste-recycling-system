import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';

class RecyclingCenterRepository extends GetxController {
  static RecyclingCenterRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _recyclingCentersCollection = 'recyclingCenters';
  final String _recyclingCenterStaffCollection = 'recyclingCenterStaff';

  /// Get recycling center by ID
  Future<PartnerRecyclingCenter> getCenterById(String centerId) async {
    try {
      final snapshot =
      await _db.collection(_recyclingCentersCollection).doc(centerId).get();
      if (!snapshot.exists) {
        throw 'Center not found';
      }
      return PartnerRecyclingCenter.fromSnapshot(snapshot);
    } catch (e) {
      throw 'Failed to fetch center: $e';
    }
  }

  /// Get center stream by ID
  Stream<PartnerRecyclingCenter> getCenterStream(String centerId) {
    return _db
        .collection(_recyclingCentersCollection)
        .doc(centerId)
        .snapshots()
        .map((snapshot) => PartnerRecyclingCenter.fromSnapshot(snapshot));
  }

  /// Get all active centers
  Future<List<PartnerRecyclingCenter>> getAllActiveCenters() async {
    try {
      final snapshot = await _db
          .collection(_recyclingCentersCollection)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((doc) => PartnerRecyclingCenter.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch centers: $e';
    }
  }

  /// Get all active centers stream
  Stream<List<PartnerRecyclingCenter>> getActiveCentersStream() {
    return _db
        .collection(_recyclingCentersCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PartnerRecyclingCenter.fromSnapshot(doc))
        .toList());
  }

  /// Get centers within radius (client-side filtering)
  Future<List<PartnerRecyclingCenter>> getCentersNearLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final allCenters = await getAllActiveCenters();

      // Filter by distance
      return allCenters.where((center) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          center.centerLocation.geoPoint.latitude,
          center.centerLocation.geoPoint.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw 'Failed to fetch nearby centers: $e';
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Get center by staff ID
  Future<PartnerRecyclingCenter?> getCenterByStaffId(String staffId) async {
    try {
      final staffDoc = await _db
          .collection(_recyclingCenterStaffCollection)
          .doc(staffId)
          .get();
      if (!staffDoc.exists) {
        return null;
      }

      final centerId = staffDoc.data()?['centerId'];
      if (centerId == null) {
        return null;
      }

      return await getCenterById(centerId);
    } catch (e) {
      throw 'Failed to fetch center by staff ID: $e';
    }
  }

  /// Get center stream by staff ID
  Stream<PartnerRecyclingCenter?> getCenterByStaffIdStream(String staffId) {
    return _db
        .collection(_recyclingCenterStaffCollection)
        .doc(staffId)
        .snapshots()
        .asyncMap((staffSnapshot) async {
      if (!staffSnapshot.exists) {
        return null;
      }

      final centerId = staffSnapshot.data()?['centerId'];
      if (centerId == null) {
        return null;
      }

      final centerSnapshot =
      await _db.collection(_recyclingCentersCollection).doc(centerId).get();
      if (!centerSnapshot.exists) {
        return null;
      }

      return PartnerRecyclingCenter.fromSnapshot(centerSnapshot);
    });
  }
}