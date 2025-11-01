import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/utils/formatters/formatter.dart';

/// Model class representing user data
class RoleModel {
  // Keep those values final which you do not want to update
  final String userId;
  final String username;
  final String email;
  String? phoneNo;
  String? profileImg;
  final int loginAttemptCount;
  final DateTime? lastFailedLogin;
  final String role;
  final bool isVerified;
  final bool isActive;

  RoleModel({
    required this.userId,
    required this.username,
    required this.email,
    this.phoneNo,
    this.profileImg,
    required this.loginAttemptCount,
    this.lastFailedLogin,
    required this.role,
    required this.isVerified,
    required this.isActive,
  });

  RoleModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? phoneNo,
    String? profileImg,
    int? loginAttemptCount,
    DateTime? lastFailedLogin,
    String? role,
    bool? isVerified,
    bool? isActive,
  }) {
    return RoleModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      profileImg: profileImg ?? this.profileImg,
      loginAttemptCount: loginAttemptCount ?? this.loginAttemptCount,
      lastFailedLogin: lastFailedLogin ?? this.lastFailedLogin,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Helper function to format phone number.
  String get formattedPhoneNo => phoneNo != null ? FFormatter.formatPhoneNumber(phoneNo!) : '';

  /// Static function to crate an empty user model
  static RoleModel empty() => RoleModel(
    userId: '',
    username: '',
    email: '',
    loginAttemptCount: 0,
    role: '',
    isVerified: false,
    isActive: false,
  );

  /// Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Username': username,
      'Email': email,
      'PhoneNo': phoneNo,
      'ProfileImage': profileImg,
      'LoginAttemptCount': loginAttemptCount,
      'LastFailedLogin': lastFailedLogin != null ? Timestamp.fromDate(lastFailedLogin!) : FieldValue.serverTimestamp(),
      'Role': role,
      'IsVerified': isVerified,
      'IsActive': isActive,
    };
  }

  /// Factory method to crate a RoleModel from a Firebase document snapshot
  factory RoleModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return RoleModel(
        userId: document.id,
        username: data['Username'] ?? '',
        email: data['Email'] ?? '',
        phoneNo: data['PhoneNo'],
        profileImg: data['ProfileImage'],
        loginAttemptCount: data['LoginAttemptCount'] ?? 0,
        lastFailedLogin: data['LastFailedLogin'] != null ? (data['LastFailedLogin'] as Timestamp).toDate() : null,
        role: data['Role'] ?? '',
        isVerified: data['IsVerified'] ?? false,
        isActive: data['IsActive'] ?? false,
      );
    } else {
      // Handle the case when document.data() is null
      throw Exception("Document data is null for document ID: ${document.id}");
    }
  }
}