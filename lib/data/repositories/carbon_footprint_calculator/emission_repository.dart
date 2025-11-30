import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../config/emission_config/air_travel.dart';
import '../../../features/carbon_footprint_calculator/models/emission_model.dart';

class EmissionRepository extends GetxController {
  static EmissionRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache for average emissions
  final Rx<DateTime?> _lastAverageFetchTime = Rx<DateTime?>(null);
  final RxMap<String, double> _cachedAverageEmissions = <String, double>{}.obs;

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Stream user's emissions by category
  Stream<List<EmissionModel>> streamUserEmissionsByCategory(String category) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('emissions')
        .where('userId', isEqualTo: _currentUserId)
        .where('category', isEqualTo: category)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EmissionModel.fromSnapshot(doc))
        .toList());
  }

  /// Stream all user's emissions
  Stream<List<EmissionModel>> streamUserEmissions() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('emissions')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EmissionModel.fromSnapshot(doc))
        .toList());
  }

  /// Get user's total emissions by category
  Stream<Map<String, double>> streamUserEmissionsByCategories() {
    if (_currentUserId == null) {
      return Stream.value({});
    }

    return _db
        .collection('emissions')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        final emission = EmissionModel.fromSnapshot(doc);
        categoryTotals[emission.category] =
            (categoryTotals[emission.category] ?? 0.0) + emission.emissionValue;
      }

      return categoryTotals;
    });
  }

  /// Get latest emission for a category
  Future<EmissionModel?> getLatestEmissionByCategory(String category) async {
    if (_currentUserId == null) return null;

    try {
      final snapshot = await _db
          .collection('emissions')
          .where('userId', isEqualTo: _currentUserId)
          .where('category', isEqualTo: category)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return EmissionModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      throw 'Error fetching emission: $e';
    }
  }

  /// Save or update emission
  Future<void> saveEmission(EmissionModel emission) async {
    if (_currentUserId == null) throw 'User not authenticated';

    try {
      if (emission.emissionId.isEmpty) {
        // Create new emission
        final docRef = await _db.collection('emissions').add(emission.toMap());
        // Update with the generated ID
        await docRef.update({'emissionId': docRef.id});
      } else {
        // Update existing emission
        await _db
            .collection('emissions')
            .doc(emission.emissionId)
            .update(emission.updateTimestamp().toMap());
      }
    } catch (e) {
      throw 'Error saving emission: $e';
    }
  }

  /// Delete emission
  Future<void> deleteEmission(String emissionId) async {
    try {
      await _db.collection('emissions').doc(emissionId).delete();
    } catch (e) {
      throw 'Error deleting emission: $e';
    }
  }

  /// Get average emissions for all users (with caching)
  Future<Map<String, double>> getAverageEmissions({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // Check if cache is still valid
    if (!forceRefresh &&
        _lastAverageFetchTime.value != null &&
        now.difference(_lastAverageFetchTime.value!) < AirTravelEmissionConfig.avgEmissionsCacheDuration &&
        _cachedAverageEmissions.isNotEmpty) {
      return Map<String, double>.from(_cachedAverageEmissions);
    }

    try {
      // Fetch all emissions except current user's
      final snapshot = await _db
          .collection('emissions')
          .where('userId', isNotEqualTo: _currentUserId ?? '')
          .get();

      if (snapshot.docs.isEmpty) {
        return {};
      }

      // Calculate average by category
      final Map<String, List<double>> categoryEmissions = {};

      for (var doc in snapshot.docs) {
        final emission = EmissionModel.fromSnapshot(doc);
        if (!categoryEmissions.containsKey(emission.category)) {
          categoryEmissions[emission.category] = [];
        }
        categoryEmissions[emission.category]!.add(emission.emissionValue);
      }

      // Calculate averages
      final Map<String, double> averages = {};
      categoryEmissions.forEach((category, emissions) {
        averages[category] = emissions.reduce((a, b) => a + b) / emissions.length;
      });

      // Update cache
      _cachedAverageEmissions.value = averages;
      _lastAverageFetchTime.value = now;

      return averages;
    } catch (e) {
      throw 'Error fetching average emissions: $e';
    }
  }

  /// Check if user has any emissions
  Future<bool> hasEmissions() async {
    if (_currentUserId == null) return false;

    try {
      final snapshot = await _db
          .collection('emissions')
          .where('userId', isEqualTo: _currentUserId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedAverageEmissions.clear();
    _lastAverageFetchTime.value = null;
  }
}