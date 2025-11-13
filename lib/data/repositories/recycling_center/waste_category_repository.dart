import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/recycling_center/models/waste_category_model.dart';

class WasteCategoryRepository extends GetxController {
  static WasteCategoryRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _wasteCategoriesCollection = 'wasteCategories';

  /// Get all waste categories
  Future<List<WasteCategory>> getAllWasteCategories() async {
    try {
      final snapshot = await _db
          .collection(_wasteCategoriesCollection)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WasteCategory.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch waste categories: $e';
    }
  }

  /// Get waste categories stream
  Stream<List<WasteCategory>> getWasteCategoriesStream() {
    return _db
        .collection(_wasteCategoriesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => WasteCategory.fromSnapshot(doc))
        .toList());
  }

  /// Get waste category by ID
  Future<WasteCategory> getCategoryById(String categoryId) async {
    try {
      final doc = await _db
          .collection(_wasteCategoriesCollection)
          .doc(categoryId)
          .get();

      if (!doc.exists) {
        throw 'Category not found';
      }

      return WasteCategory.fromSnapshot(doc);
    } catch (e) {
      throw 'Failed to fetch category: $e';
    }
  }

  /// Get recyclable categories only
  Future<List<WasteCategory>> getRecyclableCategories() async {
    try {
      final snapshot = await _db
          .collection(_wasteCategoriesCollection)
          .where('isRecyclable', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => WasteCategory.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to fetch recyclable categories: $e';
    }
  }

  /// Create new waste category (Admin only)
  Future<String> createCategory(WasteCategory category) async {
    try {
      final docRef = await _db
          .collection(_wasteCategoriesCollection)
          .add(category.toJson());

      return docRef.id;
    } catch (e) {
      throw 'Failed to create category: $e';
    }
  }

  /// Update waste category (Admin only)
  Future<void> updateCategory(WasteCategory category) async {
    try {
      await _db
          .collection(_wasteCategoriesCollection)
          .doc(category.categoryId)
          .update(category.toJson());
    } catch (e) {
      throw 'Failed to update category: $e';
    }
  }

  /// Delete waste category (Admin only)
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _db
          .collection(_wasteCategoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw 'Failed to delete category: $e';
    }
  }

  /// Get category by name
  Future<WasteCategory?> getCategoryByName(String name) async {
    try {
      final snapshot = await _db
          .collection(_wasteCategoriesCollection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return WasteCategory.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      throw 'Failed to fetch category by name: $e';
    }
  }

  /// Search categories by name or description
  Future<List<WasteCategory>> searchCategories(String query) async {
    try {
      final snapshot = await _db
          .collection(_wasteCategoriesCollection)
          .orderBy('name')
          .get();

      final allCategories = snapshot.docs
          .map((doc) => WasteCategory.fromSnapshot(doc))
          .toList();

      // Filter by query
      final filteredCategories = allCategories.where((category) {
        final nameLower = category.name.toLowerCase();
        final descLower = category.description.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) || descLower.contains(queryLower);
      }).toList();

      return filteredCategories;
    } catch (e) {
      throw 'Failed to search categories: $e';
    }
  }
}