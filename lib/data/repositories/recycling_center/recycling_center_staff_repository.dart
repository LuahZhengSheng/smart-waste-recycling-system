import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/recycling_center_staff_model.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

class RecyclingCenterStaffRepository extends GetxController {
  static RecyclingCenterStaffRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get staff by ID
  Future<RecyclingCenterStaff?> getStaffById(String staffId) async {
    try {
      if (staffId.isEmpty) return null;

      final docSnapshot = await _db
          .collection('users') // 或者你的员工集合名称
          .doc(staffId)
          .get();

      if (docSnapshot.exists) {
        return RecyclingCenterStaff.fromSnapshot(docSnapshot);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print('Firebase error getting staff by ID: $e');
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on FPlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      print('Unexpected error getting staff by ID: $e');
      return null;
    }
  }

  /// Get staff by center ID
  Future<List<RecyclingCenterStaff>> getStaffByCenterId(String centerId) async {
    try {
      final querySnapshot = await _db
          .collection('users') // 或者你的员工集合名称
          .where('centerId', isEqualTo: centerId)
          .where('role', whereIn: ['staff', 'admin']) // 根据你的角色定义调整
          .get();

      return querySnapshot.docs
          .map((doc) => RecyclingCenterStaff.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error getting staff by center ID: $e');
      return [];
    }
  }
}