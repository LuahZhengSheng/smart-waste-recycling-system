import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// Function to save user data to Firestore
  Future<void> saveUserRecord(UserModel user) async {
    try {
      // 获取当前设备的 FCM token
      String? fcmToken = await _firebaseMessaging.getToken();

      // 创建用户数据，包含 FCM token
      Map<String, dynamic> userData = user.toJson();
      if (fcmToken != null) {
        userData['fcmToken'] = fcmToken;
      }

      // 保存用户数据到 Firestore
      await _db.collection("users").doc(user.userId).set(userData);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function to fetch user details based on user ID
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db.collection("users").doc(AuthenticationRepository.instance.authUser?.uid).get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function to update user data in Firestore
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db.collection("users").doc(updatedUser.userId).update(updatedUser.toJson());
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function to update user data in Firestore
  Future<void> updateStringField(Map<String, dynamic> json) async {
    try {
      await _db.collection("users").doc(AuthenticationRepository.instance.authUser?.uid ).update(json);
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch(_) {
      throw const FFormatException();
    } on PlatformException catch (e) {
      throw FPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function to remove user data from Firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw FFirebaseException(e.code).message;
    } on FormatException catch(_) {
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
      final snapshot = await _db.collection('users').doc(userId).get();
      if (!snapshot.exists) {
        throw 'User not found';
      }
      return snapshot.data()?['rewardPoint'] ?? 0;
    } catch (e) {
      throw 'Failed to fetch user points: $e';
    }
  }

  /// Deduct points from user after redemption
  Future<void> deductPoints(String userId, int points) async {
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('Users').doc(userId);
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
        });
      });
    } catch (e) {
      throw 'Failed to deduct points: $e';
    }
  }

  /// Add points to user (for testing or admin purposes)
  Future<void> addPoints(String userId, int points) async {
    try {
      await _db.collection('users').doc(userId).update({
        'rewardPoint': FieldValue.increment(points),
        'TotalRewardPoint': FieldValue.increment(points),
      });
    } catch (e) {
      throw 'Failed to add points: $e';
    }
  }

  /// Stream of user's reward points
  Stream<int> getUserPointsStream(String userId) {
    return _db
        .collection('Users')
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