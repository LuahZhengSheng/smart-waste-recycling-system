import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';

class WasteCategory {
  final String categoryId;
  final String name;
  final String description;
  final String disposalMethod;
  final IconData icon;
  final Color color;
  final double basePoints;
  final List<String> examples;
  final bool isRecyclable;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Constructor
  WasteCategory({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.disposalMethod,
    required this.icon,
    required this.color,
    required this.basePoints,
    required this.examples,
    required this.isRecyclable,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Empty factory constructor
  factory WasteCategory.empty() {
    return WasteCategory(
      categoryId: '',
      name: '',
      description: '',
      disposalMethod: '',
      icon: Iconsax.trash,
      color: Colors.grey,
      basePoints: 0.0,
      examples: [],
      isRecyclable: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Factory method to create from Firestore document
  factory WasteCategory.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return WasteCategory(
      categoryId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      disposalMethod: data['disposalMethod'] ?? '',
      icon: _parseIconData(data['icon'] ?? 'trash'),
      color: _parseColor(data['color']),
      basePoints: (data['basePoints'] ?? 0.0).toDouble(),
      examples: List<String>.from(data['examples'] ?? []),
      isRecyclable: data['isRecyclable'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore compatible Map
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'disposalMethod': disposalMethod,
      'icon': _iconToString(icon),
      'color': _colorToHex(color),
      'basePoints': basePoints,
      'examples': examples,
      'isRecyclable': isRecyclable,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Factory method to create from JSON
  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      disposalMethod: json['disposalMethod'] ?? '',
      icon: _parseIconData(json['icon'] ?? 'trash'),
      color: _parseColor(json['color']),
      basePoints: (json['basePoints'] ?? 0.0).toDouble(),
      examples: List<String>.from(json['examples'] ?? []),
      isRecyclable: json['isRecyclable'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Helper method to parse icon data from string
  static IconData _parseIconData(String iconString) {
    final iconMap = {
      'battery': Iconsax.battery_charging,
      'trash': Iconsax.trash,
      'box': Iconsax.box,
      'document': Iconsax.document,
      'glass': Iconsax.glass,
      'mobile': Iconsax.mobile,
      'brush': Iconsax.brush,
      'cake': Iconsax.cake,
      'warning': Iconsax.warning_2,
      'category': Iconsax.category,
      'cpu': Iconsax.cpu,
      'tree': Iconsax.tree,
    };
    return iconMap[iconString] ?? Iconsax.trash;
  }

  /// Helper method to convert icon to string
  static String _iconToString(IconData icon) {
    final iconMap = {
      Iconsax.battery_charging: 'battery',
      Iconsax.trash: 'trash',
      Iconsax.box: 'box',
      Iconsax.document: 'document',
      Iconsax.glass: 'glass',
      Iconsax.mobile: 'mobile',
      Iconsax.brush: 'brush',
      Iconsax.cake: 'cake',
      Iconsax.warning_2: 'warning',
      Iconsax.category: 'category',
      Iconsax.cpu: 'cpu',
      Iconsax.tree: 'tree',
    };
    return iconMap[icon] ?? 'trash';
  }

  /// Helper method to parse color from hex string
  static Color _parseColor(dynamic colorData) {
    if (colorData is String && colorData.isNotEmpty) {
      try {
        return Color(int.parse(colorData.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.green;
      }
    }
    return Colors.green;
  }

  /// Helper method to convert color to hex string
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  /// Create a copy with updated fields
  WasteCategory copyWith({
    String? categoryId,
    String? name,
    String? description,
    String? disposalMethod,
    IconData? icon,
    Color? color,
    double? basePoints,
    List<String>? examples,
    bool? isRecyclable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WasteCategory(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      disposalMethod: disposalMethod ?? this.disposalMethod,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      basePoints: basePoints ?? this.basePoints,
      examples: examples ?? this.examples,
      isRecyclable: isRecyclable ?? this.isRecyclable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted points string
  String get formattedPoints => '${basePoints.toStringAsFixed(1)} points/kg';

  /// Get examples as formatted string
  String get formattedExamples => examples.join(', ');

  /// Check if category is hazardous
  bool get isHazardous => name.contains('Battery') || name.contains('Hazardous');

  /// Get disposal method with emoji
  String get disposalMethodWithEmoji {
    if (disposalMethod.contains('Recycle')) return '♻️ $disposalMethod';
    if (disposalMethod.contains('Process')) return '⚡ $disposalMethod';
    if (disposalMethod.contains('Landfill')) return '🗑️ $disposalMethod';
    return disposalMethod;
  }

  /// Override toString for debugging
  @override
  String toString() {
    return 'WasteCategory(categoryId: $categoryId, name: $name, basePoints: $basePoints, isRecyclable: $isRecyclable)';
  }

  /// Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WasteCategory &&
              runtimeType == other.runtimeType &&
              categoryId == other.categoryId;

  /// Override hashCode
  @override
  int get hashCode => categoryId.hashCode;
}