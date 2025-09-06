import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';
import 'package:fyp/features/leaderboard_achievement/models/user_achievement_model.dart';
import 'package:fyp/features/personalization/models/notification_model.dart';

class UserModel extends RoleModel {
  final String? gender;
  final DateTime? dob;
  final DateTime joinDate;
  final int rewardPoint;
  final List<NotificationModel> notifications;
  final List<UserAchievementModel> userAchievements;

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
    this.rewardPoint = 0,
    this.notifications = const [],
    this.userAchievements = const [],
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
      rewardPoint: data['RewardPoint'] ?? 0,
      notifications: data['Notifications'] != null
          ? List<NotificationModel>.from(
          (data['Notifications'] as List<dynamic>)
              .map((n) => NotificationModel.fromMap(n)))
          : [],
      userAchievements: data['UserAchievements'] != null
          ? List<UserAchievementModel>.from(
          (data['UserAchievements'] as List<dynamic>)
              .map((a) => UserAchievementModel.fromMap(a)))
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
      rewardPoint: map['rewardPoint'] ?? 0,
      notifications: map['notifications'] != null
          ? List<NotificationModel>.from(
          map['notifications']?.map((x) => NotificationModel.fromMap(x)))
          : [],
      userAchievements: map['userAchievements'] != null
          ? List<UserAchievementModel>.from(
          map['userAchievements']?.map((x) => UserAchievementModel.fromMap(x)))
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
      'RewardPoint': rewardPoint,
      'Notifications': notifications.map((n) => n.toMap()).toList(),
      'UserAchievements': userAchievements.map((ua) => ua.toMap()).toList(),
    };
  }

  @override
  UserModel copyWith({
    DateTime? dob,
    DateTime? joinDate,
    int? rewardPoint,
    List<NotificationModel>? notifications,
    List<UserAchievementModel>? userAchievements,
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
      dob: dob ?? this.dob,
      joinDate: joinDate ?? this.joinDate,
      rewardPoint: rewardPoint ?? this.rewardPoint,
      notifications: notifications ?? this.notifications,
      userAchievements: userAchievements ?? this.userAchievements,
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
}
