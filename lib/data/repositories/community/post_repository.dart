import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/exceptions/firebase_exceptions.dart';
import 'package:fyp/utils/exceptions/format_exceptions.dart';
import 'package:fyp/utils/exceptions/platform_exceptions.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// Get original post data without converting media paths to URLs
  /// This is used for edit mode to get the original storage paths
  Future<PostModel?> getOriginalPost(String postId) async {
    try {
      final doc = await _db.collection("posts").doc(postId).get();
      if (doc.exists && doc.data()?['isDisabled'] != true) {
        // Use fromSnapshot without URL conversion to get original storage paths
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
      throw 'Failed to get original post: $e';
    }
  }

  /// Get full media URL from storage path
  Future<String> getMediaUrl(String storagePath, String userId) async {
    try {
      final isVideo = storagePath.contains('.mp4') ||
          storagePath.contains('.mov') ||
          storagePath.contains('.avi');

      final fullPath = isVideo
          ? 'posts/$userId/videos/$storagePath'
          : 'posts/$userId/images/$storagePath';

      return await storage.ref(fullPath).getDownloadURL();
    } catch (e) {
      throw 'Failed to get media URL: $e';
    }
  }

  /// Get media URLs for a list of storage paths
  Future<List<String>> getMediaUrls(List<String> storagePaths, String userId) async {
    try {
      final urls = <String>[];
      for (var path in storagePaths) {
        final url = await getMediaUrl(path, userId);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw 'Failed to get media URLs: $e';
    }
  }

  /// Stream to get all posts in real-time (with media URLs)
  Stream<List<PostModel>> getAllPostsStream() {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
          // Skip this post and continue with others
        }
      }

      return posts;
    });
  }

  /// Stream to get single post by ID (with media URLs)
  Stream<PostModel?> getPostByIdStream(String postId) {
    return _db
        .collection("posts")
        .doc(postId)
        .snapshots()
        .asyncMap((doc) async {
      if (doc.exists) {
        var post = PostModel.fromSnapshot(doc);

        // Convert storage paths to URLs
        if (post.media.isNotEmpty) {
          final urls = await getMediaUrls(post.media, post.userId);
          post = post.copyWith(media: urls);
        }

        return post;
      }
      return null;
    });
  }

  /// Stream to get posts by type (with media URLs)
  Stream<List<PostModel>> getPostsByTypeStream(String postType) {
    return _db
        .collection("posts")
        .where('postType', isEqualTo: postType)
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Stream to get posts by user (with media URLs)
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _db
        .collection("posts")
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Function to save post data to Firestore
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

  /// Update post likes
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

  /// Update post comment count
  Future<void> increaseCommentCount(String postId) async {
    try {
      await _db.collection("posts").doc(postId).update({
        'commentCount': FieldValue.increment(1),
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

  /// Decrease post comment count
  Future<void> decreaseCommentCount(String postId) async {
    try {
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

  /// Delete post (soft delete by setting isDisabled to true)
  /// Also deletes associated media from storage
  Future<void> deletePost(String postId) async {
    try {
      // Get post data first
      final doc = await _db.collection("posts").doc(postId).get();
      if (!doc.exists) return;

      final post = PostModel.fromSnapshot(doc);

      // Delete media from storage
      if (post.media.isNotEmpty) {
        for (var storagePath in post.media) {
          try {
            final isVideo = storagePath.contains('.mp4') ||
                storagePath.contains('.mov') ||
                storagePath.contains('.avi');

            final fullPath = isVideo
                ? 'posts/${post.userId}/videos/$storagePath'
                : 'posts/${post.userId}/images/$storagePath';

            await storage.ref(fullPath).delete();
          } catch (e) {
            print('Failed to delete media $storagePath: $e');
          }
        }
      }

      // Soft delete the post
      await _db.collection("posts").doc(postId).update({
        'isDisabled': true,
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

  /// Get single post by ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _db.collection("posts").doc(postId).get();
      if (doc.exists && doc.data()?['isDisabled'] != true) {
        var post = PostModel.fromSnapshot(doc);

        // Convert storage paths to URLs
        if (post.media.isNotEmpty) {
          final urls = await getMediaUrls(post.media, post.userId);
          post = post.copyWith(media: urls);
        }

        return post;
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

  /// Search posts by content (with media URLs)
  Stream<List<PostModel>> searchPosts(String query) {
    return _db
        .collection("posts")
        .where('isDisabled', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc);

          if (post.content.toLowerCase().contains(query.toLowerCase())) {
            // Convert storage paths to URLs
            if (post.media.isNotEmpty) {
              final urls = await getMediaUrls(post.media, post.userId);
              post = post.copyWith(media: urls);
            }

            posts.add(post);
          }
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
    });
  }

  /// Get posts with pagination (with media URLs)
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
      final posts = <PostModel>[];

      for (var doc in snapshot.docs) {
        try {
          var post = PostModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);

          // Convert storage paths to URLs
          if (post.media.isNotEmpty) {
            final urls = await getMediaUrls(post.media, post.userId);
            post = post.copyWith(media: urls);
          }

          posts.add(post);
        } catch (e) {
          print('Error processing post ${doc.id}: $e');
        }
      }

      return posts;
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