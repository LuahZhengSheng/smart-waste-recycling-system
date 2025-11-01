import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/common/models/role_model.dart';

class RecyclingCenterStaffModel extends RoleModel {
  final String centerId;
  final String? gender;
  final DateTime joinDate;

  RecyclingCenterStaffModel({
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

    // RecyclingCenterStaffModel fields
    required this.centerId,
    this.gender,
    required this.joinDate,
  });

  /// ✅ Firestore 转换
  factory RecyclingCenterStaffModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RecyclingCenterStaffModel(
      userId: doc.id,
      username: data['Username'] ?? '',
      email: data['Email'] ?? '',
      phoneNo: data['PhoneNo'],
      profileImg: data['ProfileImage'],
      loginAttemptCount: data['LoginAttemptCount'] ?? 0,
      lastFailedLogin: data['LastFailedLogin'] != null
          ? (data['LastFailedLogin'] as Timestamp).toDate()
          : null,
      role: data['Role'] ?? '',
      isVerified: data['IsVerified'] ?? false,
      isActive: data['IsActive'] ?? false,

      centerId: data['CenterId'],
      gender: data['Gender'],
      joinDate: data['JoinDate'] != null
          ? (data['JoinDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// ✅ Map 转换（用于本地缓存）
  factory RecyclingCenterStaffModel.fromMap(Map<String, dynamic> map) {
    return RecyclingCenterStaffModel(
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

      centerId: map['centerId'],
      gender: map['gender'],
      joinDate: DateTime.fromMillisecondsSinceEpoch(map['joinDate']),
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
      'ProfileImage': profileImg,
      'LoginAttemptCount': loginAttemptCount,
      'LastFailedLogin':
      lastFailedLogin != null ? Timestamp.fromDate(lastFailedLogin!) : null,
      'Role': role,
      'IsVerified': isVerified,
      'IsActive': isActive,
      'centerId': centerId,
      'Gender': gender,
      'JoinDate': Timestamp.fromDate(joinDate),
    };
  }

  @override
  RecyclingCenterStaffModel copyWith({
    String? centerId,
    String? gender,
    DateTime? joinDate,
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
    return RecyclingCenterStaffModel(
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
      centerId: centerId ?? this.centerId,
      gender: gender ?? this.gender,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  /// ✅ Empty User
  static RecyclingCenterStaffModel empty() => RecyclingCenterStaffModel(
    userId: '',
    username: '',
    email: '',
    loginAttemptCount: 0,
    role: '',
    isVerified: false,
    isActive: false,
    centerId: '',
    joinDate: DateTime.now(),
  );
}
