import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';

class UserModel extends RoleModel {
  final String? gender;
  final DateTime? dob;
  final DateTime joinDate;
  final int rewardPoint; // 用户当前剩余积分（可消费）
  final int monthlyRewardPoint; // 月度累计积分（用于排行榜）
  final int totalRewardPoint; // 历史总积分（用于排行榜）
  final List<NotificationModel> notifications;

  UserModel({
    // RoleModel fields
    required super.userId,
    required super.username,
    required super.email,
    required super.loginAttemptCount,
    required super.role,
    required super.isVerified,
    required super.isActive,
    super.phoneNo,
    super.profileImg,
    super.lastFailedLogin,

    // UserModel fields
    this.gender,
    this.dob,
    required this.joinDate,
    this.rewardPoint = 0, // 当前剩余积分
    this.monthlyRewardPoint = 0, // 月度积分
    this.totalRewardPoint = 0, // 总积分
    this.notifications = const [],
  });

  /// ✅ Firestore 转换
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      userId: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNo: data['phoneNo'],
      profileImg: data['profileImg'],
      loginAttemptCount: data['loginAttemptCount'] ?? 0,
      lastFailedLogin: data['lastFailedLogin'] != null
          ? (data['lastFailedLogin'] as Timestamp).toDate()
          : null,
      role: data['role'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? false,
      gender: data['gender'],
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : DateTime.now(),
      rewardPoint: data['rewardPoint'] ?? 0, // 当前剩余积分
      monthlyRewardPoint: data['monthlyRewardPoint'] ?? 0, // 月度积分
      totalRewardPoint: data['totalRewardPoint'] ?? 0, // 总积分
      notifications: data['notifications'] != null
          ? List<NotificationModel>.from(
          (data['notifications'] as List<dynamic>)
              .map((n) => NotificationModel.fromMap(n)))
          : [],
    );
  }

  /// ✅ Map 转换（用于本地缓存）
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phoneNo'],
      profileImg: map['profileImg'],
      loginAttemptCount: map['loginAttemptCount'] ?? 0,
      lastFailedLogin: map['lastFailedLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastFailedLogin'])
          : null,
      role: map['role'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? false,

      gender: map['gender'],
      dob: map['dob'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dob'])
          : null,
      joinDate: DateTime.fromMillisecondsSinceEpoch(map['joinDate']),
      rewardPoint: map['rewardPoint'] ?? 0, // 当前剩余积分
      monthlyRewardPoint: map['monthlyRewardPoint'] ?? 0, // 月度积分
      totalRewardPoint: map['totalRewardPoint'] ?? 0, // 总积分
      notifications: map['notifications'] != null
          ? List<NotificationModel>.from(
          map['notifications']?.map((x) => NotificationModel.fromMap(x)))
          : [],
    );
  }

  factory UserModel.profileOnly({
    required String userId,
    required String username,
    required String profileImg,
  }) {
    return UserModel(
      userId: userId,
      username: username,
      profileImg: profileImg,
      email: '',
      phoneNo: null,
      loginAttemptCount: 0,
      role: '',
      isVerified: false,
      isActive: true,
      gender: null,
      dob: null,
      joinDate: DateTime.now(),
      rewardPoint: 0,
      monthlyRewardPoint: 0,
      totalRewardPoint: 0,
      notifications: [],
    );
  }

  /// ✅ 转 Firestore JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'phoneNo': phoneNo,
      'profileImg': profileImg,
      'loginAttemptCount': loginAttemptCount,
      'lastFailedLogin': lastFailedLogin != null ? Timestamp.fromDate(lastFailedLogin!) : FieldValue.serverTimestamp(),
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'gender': gender,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'joinDate': FieldValue.serverTimestamp(), // 使用服务器时间
      'rewardPoint': rewardPoint, // 当前剩余积分
      'monthlyRewardPoint': monthlyRewardPoint, // 月度积分
      'totalRewardPoint': totalRewardPoint, // 总积分
      'notifications': notifications.map((n) => n.toMap()).toList(),
    };
  }

  @override
  UserModel copyWith({
    String? gender,
    DateTime? dob,
    DateTime? joinDate,
    int? rewardPoint,
    int? monthlyRewardPoint,
    int? totalRewardPoint,
    List<NotificationModel>? notifications,
    String? email,
    bool? isActive,
    bool? isVerified,
    DateTime? lastFailedLogin,
    int? loginAttemptCount,
    String? phoneNo,
    String? profileImg,
    String? role,
    String? userId,
    String? username,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImg: profileImg ?? this.profileImg,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastFailedLogin: lastFailedLogin ?? this.lastFailedLogin,
      loginAttemptCount: loginAttemptCount ?? this.loginAttemptCount,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      joinDate: joinDate ?? this.joinDate,
      rewardPoint: rewardPoint ?? this.rewardPoint,
      monthlyRewardPoint: monthlyRewardPoint ?? this.monthlyRewardPoint,
      totalRewardPoint: totalRewardPoint ?? this.totalRewardPoint,
      notifications: notifications ?? this.notifications,
    );
  }

  /// ✅ Empty User
  static UserModel empty() => UserModel(
    userId: '',
    username: '',
    email: '',
    loginAttemptCount: 0,
    role: '',
    isVerified: false,
    isActive: false,
    joinDate: DateTime.now(),
  );

  /// 添加积分（当回收活动被批准时调用）
  UserModel addPoints(int points) {
    return copyWith(
      rewardPoint: rewardPoint + points, // 增加当前剩余积分
      monthlyRewardPoint: monthlyRewardPoint + points, // 增加月度积分
      totalRewardPoint: totalRewardPoint + points, // 增加总积分
    );
  }

  /// 消费积分（当用户兑换奖励时调用）
  UserModel consumePoints(int points) {
    return copyWith(
      rewardPoint: rewardPoint - points, // 只减少当前剩余积分
      // 月度积分和总积分保持不变，因为它们代表累计获得
    );
  }

  /// 重置月度积分（每月初调用）
  UserModel resetMonthlyPoints() {
    return copyWith(
      monthlyRewardPoint: 0, // 只重置月度积分，不影响总积分和当前积分
    );
  }

  /// 获取当前月份（用于排行榜标识）
  String get currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// 获取积分统计信息
  Map<String, int> get pointsSummary {
    return {
      'current': rewardPoint,
      'monthly': monthlyRewardPoint,
      'total': totalRewardPoint,
    };
  }

  /// 检查是否有足够积分消费
  bool canConsume(int points) => rewardPoint >= points;
}