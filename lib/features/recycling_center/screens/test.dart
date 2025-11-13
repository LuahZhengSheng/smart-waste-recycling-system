import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../models/waste_category_model.dart';

class AddWasteCategoryScreen extends StatelessWidget {
  AddWasteCategoryScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add plastic waste category to Firestore
  Future<void> _addPlasticCategory() async {
    try {
      // Create plastic waste category - let Firestore generate ID
      final plasticCategory = WasteCategory(
        categoryId: '', // Empty string - Firestore will generate ID
        name: 'Plastic',
        description: 'Various types of plastic materials including bottles, containers, packaging, and other plastic products that can be recycled.',
        disposalMethod: 'Recycling',
        icon: Iconsax.box,
        color: Colors.blue,
        basePoints: 5.0,
        examples: [
          'Plastic bottles',
          'Food containers',
          'Plastic packaging',
          'Water bottles',
          'Shampoo bottles',
          'Detergent containers',
          'Plastic bags',
          'Plastic wrappers'
        ],
        isRecyclable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore - let Firestore generate document ID
      final docRef = await _firestore
          .collection('wasteCategories')
          .add(plasticCategory.toJson());

      Get.snackbar(
        'Success',
        'Plastic category added successfully!\nID: ${docRef.id}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      print('Plastic category added to Firestore with ID: ${docRef.id}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add plastic category: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error adding plastic category: $e');
    }
  }

  /// Add multiple waste categories at once
  Future<void> _addMultipleCategories() async {
    try {
      final categories = [
        // Plastic
        WasteCategory(
          categoryId: '',
          name: 'Plastic',
          description: 'Various types of plastic materials including bottles, containers, packaging, and other plastic products that can be recycled.',
          disposalMethod: 'Recycling',
          icon: Iconsax.box,
          color: Colors.blue,
          basePoints: 5.0,
          examples: [
            'Plastic bottles',
            'Food containers',
            'Plastic packaging',
            'Water bottles',
            'Shampoo bottles',
            'Detergent containers'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Paper
        WasteCategory(
          categoryId: '',
          name: 'Paper',
          description: 'Paper products including newspapers, magazines, cardboard, office paper, and other paper materials.',
          disposalMethod: 'Recycling',
          icon: Iconsax.document,
          color: Colors.brown,
          basePoints: 3.0,
          examples: [
            'Newspapers',
            'Magazines',
            'Cardboard boxes',
            'Office paper',
            'Books',
            'Paper packaging'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Glass
        WasteCategory(
          categoryId: '',
          name: 'Glass',
          description: 'Glass bottles and containers of various colors that can be recycled indefinitely.',
          disposalMethod: 'Recycling',
          icon: Iconsax.glass,
          color: Colors.green,
          basePoints: 4.0,
          examples: [
            'Glass bottles',
            'Glass jars',
            'Drinking glasses',
            'Window glass',
            'Glass containers'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Metal
        WasteCategory(
          categoryId: '',
          name: 'Metal',
          description: 'Metal items including aluminum cans, steel cans, metal containers, and other metallic products.',
          disposalMethod: 'Recycling',
          icon: Iconsax.cpu,
          color: Colors.orange,
          basePoints: 6.0,
          examples: [
            'Aluminum cans',
            'Steel cans',
            'Metal containers',
            'Aluminum foil',
            'Metal lids',
            'Food cans'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Electronic Waste
        WasteCategory(
          categoryId: '',
          name: 'Electronic Waste',
          description: 'Electronic devices and components that are no longer wanted or functional, containing valuable materials and hazardous substances.',
          disposalMethod: 'Special Recycling',
          icon: Iconsax.mobile,
          color: Colors.purple,
          basePoints: 8.0,
          examples: [
            'Mobile phones',
            'Laptops',
            'Televisions',
            'Computers',
            'Batteries',
            'Chargers',
            'Printers',
            'Circuit boards'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Battery
        WasteCategory(
          categoryId: '',
          name: 'Battery',
          description: 'Various types of batteries containing hazardous materials that require special handling and recycling.',
          disposalMethod: 'Hazardous Waste Recycling',
          icon: Iconsax.battery_charging,
          color: Colors.red,
          basePoints: 7.0,
          examples: [
            'AA batteries',
            'AAA batteries',
            'Lithium batteries',
            'Car batteries',
            'Phone batteries',
            'Rechargeable batteries',
            'Button cells'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Cardboard
        WasteCategory(
          categoryId: '',
          name: 'Cardboard',
          description: 'Cardboard packaging materials, boxes, and containers made from paper pulp.',
          disposalMethod: 'Recycling',
          icon: Iconsax.box,
          color: Colors.brown[800]!,
          basePoints: 2.5,
          examples: [
            'Shipping boxes',
            'Pizza boxes',
            'Cereal boxes',
            'Packaging boxes',
            'Cardboard tubes',
            'Egg cartons'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Organic Waste
        WasteCategory(
          categoryId: '',
          name: 'Organic Waste',
          description: 'Biodegradable waste from plants and animals that can be composted.',
          disposalMethod: 'Composting',
          icon: Iconsax.tree,
          color: Colors.green[700]!,
          basePoints: 1.0,
          examples: [
            'Food scraps',
            'Fruit peels',
            'Vegetable waste',
            'Coffee grounds',
            'Tea bags',
            'Eggshells',
            'Yard trimmings'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Hazardous Waste
        WasteCategory(
          categoryId: '',
          name: 'Hazardous Waste',
          description: 'Materials that are dangerous or potentially harmful to human health or the environment.',
          disposalMethod: 'Special Handling',
          icon: Iconsax.warning_2,
          color: Colors.red[800]!,
          basePoints: 0.0,
          examples: [
            'Paint cans',
            'Chemicals',
            'Pesticides',
            'Cleaning solvents',
            'Fluorescent bulbs',
            'Medical waste'
          ],
          isRecyclable: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Textile
        WasteCategory(
          categoryId: '',
          name: 'Textile',
          description: 'Clothing, fabrics, and other textile materials that can be reused or recycled.',
          disposalMethod: 'Reuse or Recycling',
          icon: Iconsax.brush,
          color: Colors.pink,
          basePoints: 3.5,
          examples: [
            'Old clothes',
            'Bed sheets',
            'Towels',
            'Curtains',
            'Shoes',
            'Bags',
            'Fabric scraps'
          ],
          isRecyclable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Add all categories to Firestore with auto-generated IDs
      final batch = _firestore.batch();

      for (final category in categories) {
        final docRef = _firestore.collection('wasteCategories').doc();
        batch.set(docRef, category.toJson());
      }

      await batch.commit();

      Get.snackbar(
        'Success',
        'All ${categories.length} waste categories added successfully with auto-generated IDs!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      print('All waste categories added to Firestore with auto-generated IDs');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add categories: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error adding categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Waste Categories'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Plastic Category Button
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Iconsax.box, size: 50, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Plastic Waste Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add plastic waste category with examples like bottles, containers, and packaging materials.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addPlasticCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Add Plastic Category'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Add All Categories Button
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Iconsax.category, size: 50, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'All Waste Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add multiple waste categories including plastic, paper, glass, metal, electronic waste, batteries, cardboard, and more.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addMultipleCategories,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Add All Categories (10 Categories)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Information Card
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Waste Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Waste categories help users identify and properly dispose of different types of waste. '
                          'Each category includes examples, disposal methods, and reward points for recycling. '
                          'Document IDs are automatically generated by Firestore.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}