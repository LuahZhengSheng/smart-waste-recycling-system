import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/recycling_center/models/partner_recycling_center_model.dart';

class RecyclingCenterRepository extends GetxController {
  static RecyclingCenterRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Make recyclingCenters collection name a variable
  final String _recyclingCentersCollection = 'recyclingCenters';
  final String _recyclingCenterStaffCollection = 'recyclingCenterStaff';

  /// Get recycling center by ID
  Future<PartnerRecyclingCenter> getCenterById(String centerId) async {
    try {
      final snapshot = await _db.collection(_recyclingCentersCollection).doc(centerId).get();
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

  /// Get center by staff ID
  Future<PartnerRecyclingCenter?> getCenterByStaffId(String staffId) async {
    try {
      // First get staff document to get centerId
      final staffDoc = await _db.collection(_recyclingCenterStaffCollection).doc(staffId).get();
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

      final centerSnapshot = await _db.collection(_recyclingCentersCollection).doc(centerId).get();
      if (!centerSnapshot.exists) {
        return null;
      }

      return PartnerRecyclingCenter.fromSnapshot(centerSnapshot);
    });
  }
}