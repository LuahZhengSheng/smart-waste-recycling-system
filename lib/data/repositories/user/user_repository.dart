import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _uuid = const Uuid();

  // Declare Users as a variable
  final String _usersCollection = "users";
  final String _profileImagesFolder = "profile_images";

  // 头像缓存 - 改为公共访问
  final Map<String, String> profileImageCache = {};

  // ========== 排行榜相关方法 ==========

  /// 获取月度排行榜用户流（包含完整头像URL）
  Stream<List<UserModel>> getMonthlyLeaderboardUsersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'user')
        .where('monthlyRewardPoint', isGreaterThan: 0)
        .orderBy('monthlyRewardPoint', descending: true)
        .limit(20)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      // 加载所有用户的头像URL
      await _loadProfileImagesForUsers(users);
      return users;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in monthly leaderboard stream: $error');
      }
      return <UserModel>[];
    });
  }

  /// 获取总排行榜用户流（包含完整头像URL）
  Stream<List<UserModel>> getAllTimeLeaderboardUsersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'user')
        .where('totalRewardPoint', isGreaterThan: 0)
        .orderBy('totalRewardPoint', descending: true)
        .limit(20)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      // 加载所有用户的头像URL
      await _loadProfileImagesForUsers(users);
      return users;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in all-time leaderboard stream: $error');
      }
      return <UserModel>[];
    });
  }

  /// 获取按字段排序的用户流（通用方法，包含完整头像URL）
  Stream<List<UserModel>> getUsersSortedByField({
    required String field,
    int limit = 20,
    bool descending = true,
    int minValue = 0,
  }) {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'user')
        .where(field, isGreaterThan: minValue)
        .orderBy(field, descending: descending)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      final users = snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      // 加载所有用户的头像URL
      await _loadProfileImagesForUsers(users);
      return users;
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in users sorted by $field stream: $error');
      }
      return <UserModel>[];
    });
  }

  /// 获取当前用户流（包含完整头像URL）
  Stream<UserModel> getCurrentUserStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((documentSnapshot) async {
      if (documentSnapshot.exists) {
        final user = UserModel.fromSnapshot(documentSnapshot);
        // 加载当前用户的头像URL
        if (user.profileImg != null && user.profileImg!.isNotEmpty) {
          await _loadProfileImage(user.profileImg!);
        }
        return user;
      } else {
        return UserModel.empty();
      }
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in current user stream: $error');
      }
      return UserModel.empty();
    });
  }

  /// 批量加载用户头像并更新用户对象的profileImg字段
  Future<void> _loadProfileImagesForUsers(List<UserModel> users) async {
    for (final user in users) {
      if (user.profileImg != null && user.profileImg!.isNotEmpty) {
        await _loadProfileImage(user.profileImg!);
      }
    }
  }

  /// 加载单个头像到缓存 - 私有方法
  Future<void> _loadProfileImage(String fileName) async {
    // Check if already cached
    if (profileImageCache.containsKey(fileName)) {
      return;
    }

    try {
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();
      profileImageCache[fileName] = downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load profile image $fileName: $e');
      }
    }
  }

  /// 获取头像URL - 公共方法，优先从缓存获取
  Future<String?> getProfileImageUrl(String fileName) async {
    try {
      if (fileName.isEmpty) {
        return null;
      }

      // 先检查缓存
      if (profileImageCache.containsKey(fileName)) {
        return profileImageCache[fileName];
      }

      // 缓存中没有，从存储加载
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();

      // 存入缓存
      profileImageCache[fileName] = downloadUrl;

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        if (kDebugMode) {
          print('Profile image not found: $fileName, using default');
        }
      }
      throw 'Failed to get profile image URL: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Failed to get profile image URL: $e';
    }
  }

  /// 从缓存获取头像URL（同步方法）
  String? getCachedProfileImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return null;
    return profileImageCache[fileName];
  }

  // ========== 用户管理方法 ==========

  /// Get username and profile image URL for a user
  Future<UserModel> getUserProfileData(String userId) async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data()!;
        final username = data['username'] as String? ?? 'User';
        final profileImgFileName = data['profileImg'] as String? ?? '';

        String? profileImgUrl;
        if (profileImgFileName.isNotEmpty) {
          try {
            profileImgUrl = await getProfileImageUrl(profileImgFileName);
          } catch (e) {
            if (kDebugMode) {
              print('Failed to get profile image URL for user $userId: $e');
            }
          }
        }

        return UserModel.profileOnly(
          userId: userId,
          username: username,
          profileImg: profileImgUrl ?? '',
        );
      } else {
        return UserModel.empty()..copyWith(userId: userId);
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get user profile data: $e';
    }
  }

  /// Get batch user profile data for multiple users
  Future<Map<String, UserModel>> getUsersProfileData(Set<String> userIds) async {
    try {
      print('=== START: Getting Users Profile Data ===');
      print('Requested user IDs count: ${userIds.length}');
      print('Requested user IDs: ${userIds.toList()}');

      if (userIds.isEmpty) {
        print('No user IDs provided, returning empty map');
        return {};
      }

      print('Querying Firestore for users data...');
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      print('Firestore query completed, found ${querySnapshot.docs.length} users');

      final Map<String, UserModel> result = {};

      for (final doc in querySnapshot.docs) {
        print('Processing user: ${doc.id}');
        final data = doc.data();

        final username = data['username'] as String? ?? 'User';
        final profileImgFileName = data['profileImg'] as String? ?? '';

        print('User ${doc.id} - username: $username, profileImgFileName: $profileImgFileName');

        String? profileImgUrl;
        if (profileImgFileName.isNotEmpty) {
          try {
            print('Fetching profile image URL for user ${doc.id}...');
            profileImgUrl = await getProfileImageUrl(profileImgFileName);
            print('Profile image URL fetched successfully for user ${doc.id}: ${profileImgUrl != null}');
          } catch (e) {
            print('❌ Failed to get profile image URL for user ${doc.id}: $e');
            if (kDebugMode) {
              print('Failed to get profile image URL for user ${doc.id}: $e');
            }
          }
        } else {
          print('No profile image file name for user ${doc.id}');
        }

        result[doc.id] = UserModel.profileOnly(
          userId: doc.id,
          username: username,
          profileImg: profileImgUrl ?? '',
        );

        print('✅ User ${doc.id} added to result map');
      }

      // Add default data for any missing users
      print('Checking for missing users...');
      final missingUsers = userIds.where((userId) => !result.containsKey(userId)).toList();

      if (missingUsers.isNotEmpty) {
        print('Found ${missingUsers.length} missing users: $missingUsers');
        for (final userId in missingUsers) {
          print('Adding default data for missing user: $userId');
          result[userId] = UserModel.empty()..copyWith(userId: userId);
        }
      } else {
        print('No missing users found');
      }

      print('=== END: Users Profile Data Retrieved ===');
      print('Final result contains ${result.length} users');
      print('Result keys: ${result.keys.toList()}');

      return result;
    } on FirebaseException catch (e) {
      print('❌ FirebaseException in getUsersProfileData: ${e.code} - ${e.message}');
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      print('❌ FormatException in getUsersProfileData');
      throw const FFormatException();
    } on PlatformException catch (e) {
      print('❌ PlatformException in getUsersProfileData: ${e.code} - ${e.message}');
      throw FPlatformException(e.code).message;
    } catch (e, stackTrace) {
      print('❌ Unexpected error in getUsersProfileData: $e');
      print('Stack trace: $stackTrace');
      throw 'Failed to get users profile data: $e';
    }
  }

  /// Save user record to Firestore
  Future<void> saveUserRecord(UserModel user) async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();

      Map<String, dynamic> userData = user.toJson();
      if (fcmToken != null) {
        userData['fcmToken'] = fcmToken;
      }

      // 添加服务器时间戳
      userData['createdAt'] = FieldValue.serverTimestamp();

      await _db.collection(_usersCollection).doc(user.userId).set(userData);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Fetch user details from Firestore
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();

      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Stream of user details - 实时更新
  Stream<UserModel> getUserDetailsStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((documentSnapshot) {
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    }).handleError((error) {
      if (kDebugMode) {
        print('Error in user stream: $error');
      }
      return UserModel.empty();
    });
  }

  /// Update user details in Firestore
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      Map<String, dynamic> userData = updatedUser.toJson();

      await _db.collection(_usersCollection).doc(updatedUser.userId).update(userData);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Update single field in Firestore
  Future<void> updateStringField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection(_usersCollection)
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Check if username is unique
  Future<bool> isUsernameUnique(String username, String currentUserId) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check username: $e';
    }
  }

  /// Check if phone number is unique
  Future<bool> isPhoneNumberUnique(String phoneNumber, String currentUserId) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('phoneNo', isEqualTo: phoneNumber)
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw 'Failed to check phone number: $e';
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile, String userId, String? oldFileName) async {
    try {
      // 生成唯一的文件名
      final fileName = '${_uuid.v4()}.webp';

      // 存储路径：profile_images/{fileName}
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      // 删除旧的头像（如果不是默认头像）
      if (oldFileName != null && oldFileName.isNotEmpty) {
        await deleteProfileImage(oldFileName);
      }

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/webp',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'profile_image',
            'fileName': fileName,
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 更新用户记录中的图片文件名
      await _db.collection(_usersCollection).doc(userId).update({
        'profileImg': fileName, // 只存储文件名
      });

      // 更新缓存
      profileImageCache[fileName] = downloadUrl;

      if (kDebugMode) {
        print('Profile image uploaded successfully:');
        print('File Name: $fileName');
        print('Storage Path: $path');
        print('Download URL: $downloadUrl');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Failed to upload image: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      // 构建完整的存储路径
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      await ref.delete();

      // 从缓存中移除
      profileImageCache.remove(fileName);

      if (kDebugMode) {
        print('Deleted profile image: $path');
      }
    } on FirebaseException catch (e) {
      // If file doesn't exist, ignore the error
      if (e.code == 'object-not-found') {
        if (kDebugMode) {
          print('Profile image not found, skipping deletion');
        }
      } else {
        if (kDebugMode) {
          print('Failed to delete profile image: ${e.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile image: $e');
      }
    }
  }

  /// Remove user record from Firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      // Get user data first to delete profile image
      final userDoc = await _db.collection(_usersCollection).doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final profileImage = userData?['profileImg'] as String?;

        if (profileImage != null && profileImage.isNotEmpty) {
          await deleteProfileImage(profileImage);
        }
      }

      // Delete user document
      await _db.collection(_usersCollection).doc(userId).delete();
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Get user's current reward points
  Future<int> getUserPoints(String userId) async {
    try {
      final snapshot = await _db.collection(_usersCollection).doc(userId).get();
      if (!snapshot.exists) {
        throw 'User not found';
      }
      return snapshot.data()?['rewardPoint'] ?? 0;
    } catch (e) {
      throw 'Failed to fetch user points: $e';
    }
  }

  /// Deduct points from user
  Future<void> deductPoints(String userId, int points) async {
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection(_usersCollection).doc(userId);
        final snapshot = await transaction.get(userRef);

        if (!snapshot.exists) {
          throw 'User not found';
        }

        final currentPoints = snapshot.data()?['rewardPoint'] ?? 0;

        if (currentPoints < points) {
          throw 'Insufficient points';
        }

        transaction.update(userRef, {
          'rewardPoint': FieldValue.increment(-points),
          'updatedAt': FieldValue.serverTimestamp(), // 添加更新时间戳
        });
      });
    } catch (e) {
      throw 'Failed to deduct points: $e';
    }
  }

  /// Add points to user
  Future<void> addPoints(String userId, int points) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        'rewardPoint': FieldValue.increment(points),
        'totalRewardPoint': FieldValue.increment(points),
      });
    } catch (e) {
      throw 'Failed to add points: $e';
    }
  }

  /// Stream of user's reward points
  Stream<int> getUserPointsStream(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['rewardPoint'] ?? 0);
  }

  /// Check if user has sufficient points
  Future<bool> hasSufficientPoints(String userId, int requiredPoints) async {
    try {
      final currentPoints = await getUserPoints(userId);
      return currentPoints >= requiredPoints;
    } catch (e) {
      throw 'Failed to check user points: $e';
    }
  }


  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('username', isEqualTo: username)
          .where('role', isEqualTo: 'user')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return UserModel.fromSnapshot(querySnapshot.docs.first);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to get user by username: $e';
    }
  }

  /// Get user by ID (different from fetchUserDetails which uses auth user)
  Future<UserModel> fetchOtherUserDetails(String userId) async {
    try {
      final documentSnapshot = await _db
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Failed to fetch user details: $e';
    }
  }

  /// Search users by username (partial match)
  Future<List<UserModel>> searchUsersByUsername(String query) async {
    try {
      if (query.isEmpty) return [];

      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('role', isEqualTo: 'user')
          .orderBy('username')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } catch (e) {
      throw 'Failed to search users: $e';
    }
  }
}