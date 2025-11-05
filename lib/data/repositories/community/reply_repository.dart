import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/models/reply_model.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

class ReplyRepository extends GetxController {
  static ReplyRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Stream to get all replies for a comment
  Stream<List<Reply>> getRepliesStream(String commentId) {
    return _db
        .collection("replies")
        .where('commentId', isEqualTo: commentId) // 根据 commentId 过滤
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Reply.fromSnapshot(doc))
        .toList());
  }

  /// Get replies with pagination
  Future<List<Reply>> getRepliesPaginated({
    required String commentId,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _db
          .collection("replies")
          .where('commentId', isEqualTo: commentId)
          .orderBy('createdAt', descending: false)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Reply.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
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

  /// Add a new reply
  Future<void> addReply(String commentId, Reply reply) async {
    try {
      // 创建包含额外字段的回复数据
      final replyData = reply.toJson();
      replyData['commentId'] = commentId; // 存储 commentId

      // 添加到独立的 replies 集合
      await _db
          .collection("replies")
          .doc(reply.replyId)
          .set(replyData);
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

  /// Update reply content
  Future<void> updateReply(String replyId, String content) async {
    try {
      await _db
          .collection("replies")
          .doc(replyId)
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

  /// Toggle reply like
  Future<void> toggleReplyLike(String replyId, List<String> likes) async {
    try {
      await _db
          .collection("replies")
          .doc(replyId)
          .update({
        'likes': likes,
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

  /// Delete reply
  Future<void> deleteReply(String replyId) async {
    try {
      // 从独立的 replies 集合中删除
      await _db
          .collection("replies")
          .doc(replyId)
          .delete();
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

  /// Get single reply by ID
  Future<Reply?> getReplyById(String replyId) async {
    try {
      final doc = await _db
          .collection("replies")
          .doc(replyId)
          .get();

      if (doc.exists) {
        return Reply.fromSnapshot(doc);
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
}