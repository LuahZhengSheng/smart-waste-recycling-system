import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/constants/image_strings.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:fyp/utils/helpers/network_manager.dart';
import 'package:fyp/utils/popups/full_screen_loader.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _uuid = const Uuid();

  // Declare Users as a variable
  final String _usersCollection = "users";
  final String _profileImagesFolder = "profile_images";
  // final String _defaultProfileImage = "default.webp";

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

  /// Get profile image URL from Firebase Storage
  Future<String?> getProfileImageUrl(String fileName) async {
    try {
      if (fileName.isEmpty) {
        // 如果文件名为空，返回null
        return null;
      }

      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);
      final downloadUrl = await ref.getDownloadURL();

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

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String fileName) async {
    try {
      if (fileName.isEmpty) return;

      // 如果是默认头像，不删除
      // if (fileName == _defaultProfileImage) {
      //   if (kDebugMode) {
      //     print('Cannot delete default profile image');
      //   }
      //   return;
      // }

      // 构建完整的存储路径
      final path = '$_profileImagesFolder/$fileName';
      final ref = _storage.ref().child(path);

      await ref.delete();

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
      return snapshot.data()?['RewardPoint'] ?? 0;
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

        final currentPoints = snapshot.data()?['RewardPoint'] ?? 0;

        if (currentPoints < points) {
          throw 'Insufficient points';
        }

        transaction.update(userRef, {
          'RewardPoint': FieldValue.increment(-points),
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
}

