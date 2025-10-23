import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';
import 'package:uuid/uuid.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Stream to get all posts in real-time
  Stream<List<PostModel>> getAllPostsStream() {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromSnapshot(doc))
        .toList());
  }

  /// Stream to get single post by ID
  Stream<PostModel?> getPostByIdStream(String postId) {
    return _db
        .collection("posts")
        .doc(postId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data()?['isDisabled'] != true) {
        return PostModel.fromSnapshot(doc);
      }
      return null;
    });
  }

  /// Stream to get posts by type
  Stream<List<PostModel>> getPostsByTypeStream(String postType) {
    return _db
        .collection("posts")
        .where('postType', isEqualTo: postType)
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromSnapshot(doc))
        .toList());
  }

  /// Stream to get posts by user
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _db
        .collection("posts")
        .where('userId', isEqualTo: userId)
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromSnapshot(doc))
        .toList());
  }

  /// Function to save community data to Firestore
  Future<void> savePost(PostModel post) async {
    try {
      await _db.collection("posts").doc(post.postId).set(post.toJson());
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

  /// Update community likes
  Future<void> updatePostLikes(String postId, List<String> likes) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'likes': likes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

  /// Update community comment count
  Future<void> updateCommentCount(String postId, int commentCount) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'commentCount': commentCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

  /// Delete community (soft delete by setting isDisabled to true)
  Future<void> deletePost(String postId) async {
    try {
      // Soft delete the community
      await _db.collection("posts").doc(postId).update({
        'isDisabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

  /// Get single community by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _db.collection("posts").doc(postId).get();
      if (doc.exists && doc.data()?['isDisabled'] != true) {
        return PostModel.fromSnapshot(doc);
      }
      return null;
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

  /// Search posts by content
  Stream<List<PostModel>> searchPosts(String query) {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromSnapshot(doc))
        .where((post) => post.content.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }

  /// Get posts with pagination
  Future<List<PostModel>> getPostsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _db
          .collection("posts")
          .where('isDisabled', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
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
}