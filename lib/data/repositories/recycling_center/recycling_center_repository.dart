import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';

class RecyclingCenterRepository extends GetxController {
  static RecyclingCenterRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _recyclingCentersCollection = 'partnerRecyclingCenters';
  final String _usersCollection = 'users'; // 员工数据存储在 users 集合
  final String _centerImagesFolder = 'recycling_centers'; // 回收中心图片文件夹

  /// Get recycling center by ID
  Future<PartnerRecyclingCenter> getCenterById(String centerId) async {
    try {
      final snapshot =
      await _db.collection(_recyclingCentersCollection).doc(centerId).get();
      if (!snapshot.exists) {
        throw 'Center not found';
      }
      final center = PartnerRecyclingCenter.fromSnapshot(snapshot);
      // 转换图片URL
      return await _convertImageToDownloadUrl(center);
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
        .asyncMap((snapshot) async {
      final center = PartnerRecyclingCenter.fromSnapshot(snapshot);
      return await _convertImageToDownloadUrl(center);
    });
  }

  /// Get all active centers
  Future<List<PartnerRecyclingCenter>> getAllActiveCenters() async {
    try {
      final snapshot = await _db
          .collection(_recyclingCentersCollection)
          .where('status', isEqualTo: 'active')
          .get();

      final centers = snapshot.docs
          .map((doc) => PartnerRecyclingCenter.fromSnapshot(doc))
          .toList();

      // 批量转换图片URL
      return await _convertImagesToDownloadUrls(centers);
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
        .asyncMap((snapshot) async {
      final centers = snapshot.docs
          .map((doc) => PartnerRecyclingCenter.fromSnapshot(doc))
          .toList();
      return await _convertImagesToDownloadUrls(centers);
    });
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

  /// Get center by staff ID - 修复版本
  Future<PartnerRecyclingCenter?> getCenterByStaffId(String staffId) async {
    try {
      print('🔄 Searching for center with staff ID: $staffId');

      // 方法1: 先从 users 集合获取员工数据
      final staffDoc = await _db.collection(_usersCollection).doc(staffId).get();

      if (!staffDoc.exists) {
        print('❌ Staff document not found in users collection for ID: $staffId');
        return null;
      }

      final staffData = staffDoc.data();
      final centerId = staffData?['centerId'] as String?;

      if (centerId == null || centerId.isEmpty) {
        print('❌ Staff $staffId has no centerId assigned');
        return null;
      }

      print('✅ Found centerId: $centerId for staff: $staffId');

      // 通过 centerId 查找回收中心
      final centerDoc = await _db.collection(_recyclingCentersCollection).doc(centerId).get();

      if (!centerDoc.exists) {
        print('❌ Recycling center not found for centerId: $centerId');
        return null;
      }

      final center = PartnerRecyclingCenter.fromSnapshot(centerDoc);
      // 转换图片URL
      final centerWithImageUrl = await _convertImageToDownloadUrl(center);
      print('✅ Recycling center loaded: ${centerWithImageUrl.name}');
      print('✅ Center image URL: ${centerWithImageUrl.image}');
      return centerWithImageUrl;

    } catch (e) {
      print('❌ Error in getCenterByStaffId: $e');
      return null;
    }
  }

  /// 备选方法: 直接查询包含该staffId的中心
  Future<PartnerRecyclingCenter?> getCenterByStaffIdAlternative(String staffId) async {
    try {
      print('🔄 Using alternative method to find center for staff: $staffId');

      // 查询所有中心，检查 staffIds 数组是否包含该员工ID
      final querySnapshot = await _db
          .collection(_recyclingCentersCollection)
          .where('staffIds', arrayContains: staffId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ No center found containing staff ID: $staffId');
        return null;
      }

      final center = PartnerRecyclingCenter.fromSnapshot(querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);
      // 转换图片URL
      final centerWithImageUrl = await _convertImageToDownloadUrl(center);
      print('✅ Center found via alternative method: ${centerWithImageUrl.name}');
      return centerWithImageUrl;

    } catch (e) {
      print('❌ Error in alternative method: $e');
      return null;
    }
  }

  /// Get center stream by staff ID - 修复版本
  Stream<PartnerRecyclingCenter?> getCenterByStaffIdStream(String staffId) {
    return _db
        .collection(_usersCollection) // 使用 users 集合
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

      final center = PartnerRecyclingCenter.fromSnapshot(centerSnapshot);
      return await _convertImageToDownloadUrl(center);
    });
  }

  /// 将单个回收中心的图片文件名转换为下载URL
  Future<PartnerRecyclingCenter> _convertImageToDownloadUrl(PartnerRecyclingCenter center) async {
    try {
      // 如果已经是完整URL，直接返回
      if (center.image.startsWith('http')) {
        return center;
      }

      // 如果是空的，返回原对象
      if (center.image.isEmpty) {
        return center;
      }

      // 从文件名构建完整下载URL
      final downloadUrl = await _getImageDownloadUrl(center.image);
      return center.copyWith(image: downloadUrl);

    } catch (e) {
      print('❌ Failed to convert image to download URL for center ${center.name}: $e');
      return center; // 返回原对象，保持原有图片字段
    }
  }

  /// 批量转换回收中心图片URL
  Future<List<PartnerRecyclingCenter>> _convertImagesToDownloadUrls(List<PartnerRecyclingCenter> centers) async {
    final List<PartnerRecyclingCenter> result = [];

    for (final center in centers) {
      try {
        final updatedCenter = await _convertImageToDownloadUrl(center);
        result.add(updatedCenter);
      } catch (e) {
        print('❌ Failed to convert image for center ${center.name}: $e');
        result.add(center); // 添加原对象
      }
    }

    return result;
  }

  /// 获取图片下载URL
  Future<String> _getImageDownloadUrl(String fileName) async {
    try {
      if (fileName.isEmpty) return '';

      // 构建存储路径
      final path = '$_centerImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      // 获取下载URL
      final downloadUrl = await ref.getDownloadURL();
      print('✅ Generated download URL for $fileName: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('❌ Image not found in storage: $fileName');
      }
      throw 'Failed to get image download URL: ${e.message}';
    } catch (e) {
      throw 'Failed to get image download URL: $e';
    }
  }

  /// 直接获取图片下载URL（公共方法）
  Future<String> getCenterImageUrl(String fileName) async {
    return await _getImageDownloadUrl(fileName);
  }
}