import 'package:cloud_firestore/cloud_firestore.dart';

class EmissionModel {
  final String emissionId;
  final String userId;
  final String category;
  final Map<String, dynamic> inputs;
  final double emissionValue;
  final DateTime createdAt; // 存储 UTC 时间
  final DateTime updatedAt; // 存储 UTC 时间

  const EmissionModel({
    required this.emissionId,
    required this.userId,
    required this.category,
    required this.inputs,
    required this.emissionValue,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从 Firebase DocumentSnapshot 创建 EmissionModel
  factory EmissionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // 直接读取 ServerTime (UTC)
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      // 降级方案：使用当前 UTC 时间
      createdAt = DateTime.now().toUtc();
    }

    DateTime updatedAt;
    if (data['updatedAt'] is Timestamp) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    } else {
      // 降级方案：使用当前 UTC 时间
      updatedAt = DateTime.now().toUtc();
    }

    return EmissionModel(
      emissionId: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      inputs: Map<String, dynamic>.from(data['inputs'] ?? {}),
      emissionValue: (data['emissionValue'] ?? 0.0).toDouble(),
      createdAt: createdAt, // 存储 UTC 时间
      updatedAt: updatedAt, // 存储 UTC 时间
    );
  }

  // 从 Map 创建 EmissionModel
  factory EmissionModel.fromMap(Map<String, dynamic> map) {
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else {
      // 使用当前 UTC 时间
      createdAt = DateTime.now().toUtc();
    }

    DateTime updatedAt;
    if (map['updatedAt'] is Timestamp) {
      updatedAt = (map['updatedAt'] as Timestamp).toDate();
    } else {
      // 使用当前 UTC 时间
      updatedAt = DateTime.now().toUtc();
    }

    return EmissionModel(
      emissionId: map['emissionId'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      inputs: Map<String, dynamic>.from(map['inputs'] ?? {}),
      emissionValue: (map['emissionValue'] ?? 0.0).toDouble(),
      createdAt: createdAt, // 存储 UTC 时间
      updatedAt: updatedAt, // 存储 UTC 时间
    );
  }

  // 转换为 Map (用于 Firebase 存储)
  Map<String, dynamic> toMap() {
    final map = {
      'userId': userId,
      'category': category,
      'inputs': inputs,
      'emissionValue': emissionValue,
    };

    // 使用 ServerTime 存储 UTC 时间
    if (emissionId.isEmpty) {
      // 新文档：使用 ServerTime
      map['createdAt'] = FieldValue.serverTimestamp();
      map['updatedAt'] = FieldValue.serverTimestamp();
    } else {
      // 现有文档：保持原有的 UTC 时间
      map['createdAt'] = Timestamp.fromDate(createdAt);
      map['updatedAt'] = Timestamp.fromDate(updatedAt);
    }

    return map;
  }

  // 转换为 JSON (包含所有字段)
  Map<String, dynamic> toJson() {
    return {
      'emissionId': emissionId,
      'userId': userId,
      'category': category,
      'inputs': inputs,
      'emissionValue': emissionValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 创建副本并更新指定字段
  EmissionModel copyWith({
    String? emissionId,
    String? userId,
    String? category,
    Map<String, dynamic>? inputs,
    double? emissionValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmissionModel(
      emissionId: emissionId ?? this.emissionId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      inputs: inputs ?? Map<String, dynamic>.from(this.inputs),
      emissionValue: emissionValue ?? this.emissionValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 更新 updatedAt 时间戳
  EmissionModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now().toUtc());
  }

  // 添加或更新 inputs 中的特定字段
  EmissionModel updateInput(String key, dynamic value) {
    final newInputs = Map<String, dynamic>.from(inputs);
    newInputs[key] = value;
    return copyWith(
      inputs: newInputs,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  // 移除 inputs 中的特定字段
  EmissionModel removeInput(String key) {
    final newInputs = Map<String, dynamic>.from(inputs);
    newInputs.remove(key);
    return copyWith(
      inputs: newInputs,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  // 重新计算排放值 (如果有计算逻辑)
  EmissionModel recalculateEmission(double newEmissionValue) {
    return copyWith(
      emissionValue: newEmissionValue,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  // 检查模型是否有效
  bool isValid() {
    return emissionId.isNotEmpty &&
        userId.isNotEmpty &&
        category.isNotEmpty &&
        emissionValue >= 0;
  }

  // 获取友好的显示文本
  String get displayText {
    return '$category: ${emissionValue.toStringAsFixed(2)} kg CO2e';
  }

  // 显示为马来西亚时间 (UTC+8)
  DateTime get displayCreatedAt {
    return createdAt.add(const Duration(hours: 8));
  }

  DateTime get displayUpdatedAt {
    return updatedAt.add(const Duration(hours: 8));
  }

  // 检查是否为今天创建的记录 (使用马来西亚时间)
  bool get isCreatedToday {
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));
    final createdMalaysia = displayCreatedAt;
    return createdMalaysia.year == now.year &&
        createdMalaysia.month == now.month &&
        createdMalaysia.day == now.day;
  }

  // 检查是否在指定日期范围内 (使用马来西亚时间)
  bool isInDateRange(DateTime startDate, DateTime endDate) {
    final createdMalaysia = displayCreatedAt;
    return createdMalaysia.isAfter(startDate.subtract(const Duration(days: 1))) &&
        createdMalaysia.isBefore(endDate.add(const Duration(days: 1)));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmissionModel &&
        other.emissionId == emissionId &&
        other.userId == userId &&
        other.category == category &&
        other.emissionValue == emissionValue &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _mapEquals(other.inputs, inputs);
  }

  @override
  int get hashCode {
    return Object.hash(
      emissionId,
      userId,
      category,
      emissionValue,
      createdAt,
      updatedAt,
      inputs.hashCode,
    );
  }

  @override
  String toString() {
    return 'EmissionModel('
        'emissionId: $emissionId, '
        'userId: $userId, '
        'category: $category, '
        'inputs: $inputs, '
        'emissionValue: $emissionValue, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }

  // 辅助方法：比较两个 Map 是否相等
  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }

  // 静态方法：创建空的 EmissionModel
  static EmissionModel empty() {
    return EmissionModel(
      emissionId: '',
      userId: '',
      category: '',
      inputs: {},
      emissionValue: 0.0,
      createdAt: DateTime.now().toUtc(), // 使用 UTC 时间
      updatedAt: DateTime.now().toUtc(), // 使用 UTC 时间
    );
  }

  // 静态方法：创建新的 EmissionModel (用于添加新记录)
  static EmissionModel create({
    required String userId,
    required String category,
    required Map<String, dynamic> inputs,
    required double emissionValue,
  }) {
    final now = DateTime.now().toUtc(); // 使用 UTC 时间
    return EmissionModel(
      emissionId: '', // Firebase 会自动生成
      userId: userId,
      category: category,
      inputs: inputs,
      emissionValue: emissionValue,
      createdAt: now,
      updatedAt: now,
    );
  }
}