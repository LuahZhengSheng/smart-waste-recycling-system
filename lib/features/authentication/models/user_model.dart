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
    super.profileImage,
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
      username: data['Username'] ?? '',
      email: data['Email'] ?? '',
      phoneNo: data['PhoneNo'],
      profileImage: data['ProfileImage'],
      loginAttemptCount: data['LoginAttemptCount'] ?? 0,
      lastFailedLogin: data['LastFailedLogin'] != null
          ? (data['LastFailedLogin'] as Timestamp).toDate()
          : null,
      role: data['Role'] ?? '',
      isVerified: data['IsVerified'] ?? false,
      isActive: data['IsActive'] ?? false,
      gender: data['Gender'],
      dob: data['Dob'] != null ? (data['Dob'] as Timestamp).toDate() : null,
      joinDate: data['JoinDate'] != null
          ? (data['JoinDate'] as Timestamp).toDate()
          : DateTime.now(),
      rewardPoint: data['RewardPoint'] ?? 0, // 当前剩余积分
      monthlyRewardPoint: data['MonthlyRewardPoint'] ?? 0, // 月度积分
      totalRewardPoint: data['TotalRewardPoint'] ?? 0, // 总积分
      notifications: data['Notifications'] != null
          ? List<NotificationModel>.from(
          (data['Notifications'] as List<dynamic>)
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
      profileImage: map['profileImage'],
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

  /// ✅ 转 Firestore JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Username': username,
      'Email': email,
      'PhoneNo': phoneNo,
      'ProfileImage': profileImage,
      'LoginAttemptCount': loginAttemptCount,
      'LastFailedLogin':
      lastFailedLogin != null ? Timestamp.fromDate(lastFailedLogin!) : null,
      'Role': role,
      'IsVerified': isVerified,
      'IsActive': isActive,
      'Gender': gender,
      'Dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'JoinDate': Timestamp.fromDate(joinDate),
      'RewardPoint': rewardPoint, // 当前剩余积分
      'MonthlyRewardPoint': monthlyRewardPoint, // 月度积分
      'TotalRewardPoint': totalRewardPoint, // 总积分
      'Notifications': notifications.map((n) => n.toMap()).toList(),
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
    String? profileImage,
    String? role,
    String? userId,
    String? username,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImage: profileImage ?? this.profileImage,
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