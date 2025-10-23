import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

class CommentRepository extends GetxController {
  static CommentRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Stream to get all comments for a post
  Stream<List<Comment>> getCommentsStream(String postId) {
    return _db
        .collection("comments")
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Comment.fromSnapshot(doc))
        .toList());
  }

  /// Get comments with pagination
  Future<List<Comment>> getCommentsPaginated({
    required String postId,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _db
          .collection("comments")
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Comment.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
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

  /// Add a new comment
  Future<void> addComment(String postId, Comment comment) async {
    try {
      // 创建包含 postId 的评论数据
      final commentData = comment.toJson();
      commentData['postId'] = postId; // 添加 postId 字段

      // 添加到独立的 comments 集合
      await _db
          .collection("comments")
          .doc(comment.commentId)
          .set(commentData);

      // 更新帖子评论计数
      await _db.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(1),
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

  /// Update comment content with postId
  Future<void> updateComment(String commentId, String content) async {
    try {
      await _db
          .collection("comments")
          .doc(commentId)
          .update({
        'content': content,
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

  /// Toggle comment like
  Future<void> toggleCommentLike(String commentId, List<String> likes) async {
    try {
      await _db
          .collection("comments")
          .doc(commentId)
          .update({
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

  /// Delete comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // Delete comment document from independent collection
      await _db
          .collection("comments")
          .doc(commentId)
          .delete();

      // Update post comment count
      await _db.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(-1),
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

  /// Get single comment by ID
  Future<Comment?> getCommentById(String commentId) async {
    try {
      final doc = await _db
          .collection("comments")
          .doc(commentId)
          .get();

      if (doc.exists) {
        return Comment.fromSnapshot(doc);
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

  /// Update comment reply count
  Future<void> updateCommentReplyCount(String commentId, int delta) async {
    try {
      await _db
          .collection("comments")
          .doc(commentId)
          .update({
        'replyCount': FieldValue.increment(delta),
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
}