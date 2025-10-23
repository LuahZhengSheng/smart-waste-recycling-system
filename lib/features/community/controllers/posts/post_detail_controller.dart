import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/community/comment_repository.dart';
import '../../../../data/repositories/community/post_repository.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/edit_post/edit_post.dart';

class PostDetailsController extends GetxController {
  // Repositories
  final PostRepository postRepository = Get.put(PostRepository());
  final CommentRepository commentRepository = Get.put(CommentRepository());

  // Observable variables
  final _post = Rx<PostModel?>(null);
  final _comments = <Comment>[].obs;
  final _isLoading = false.obs;
  final _commentSortType = 'Top comments'.obs;
  final _userCache = <String, Map<String, String>>{}.obs;

  // Stream subscriptions
  StreamSubscription<PostModel?>? _postSubscription;
  StreamSubscription<List<Comment>>? _commentsSubscription;

  // Current post ID
  String _currentPostId = '';

  // Getters
  Rx<PostModel> get post => _post.value != null
      ? Rx<PostModel>(_post.value!)
      : Rx<PostModel>(PostModel.empty());
  List<Comment> get comments => _comments;
  RxString get commentSortType => _commentSortType;
  RxBool get isLoading => _isLoading;

  List<Comment> get sortedComments {
    final commentsList = List<Comment>.from(_comments);

    if (_commentSortType.value == 'Top comments') {
      commentsList.sort((a, b) => b.likes.length.compareTo(a.likes.length));
    } else {
      commentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return commentsList;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeUserCache();
  }

  @override
  void onClose() {
    _postSubscription?.cancel();
    _commentsSubscription?.cancel();
    super.onClose();
  }

  // Load post details and comments
  Future<void> loadPostDetails(String postId) async {
    _isLoading.value = true;
    _currentPostId = postId;

    try {
      // Subscribe to post stream for real-time updates
      _postSubscription?.cancel();
      _postSubscription = postRepository.getPostByIdStream(postId).listen(
            (post) {
          if (post != null) {
            _post.value = post;
          }
        },
        onError: (error) {
          Get.snackbar('Error', 'Failed to load post: $error');
        },
      );

      // Subscribe to comments stream for real-time updates
      _commentsSubscription?.cancel();
      _commentsSubscription = commentRepository.getCommentsStream(postId).listen(
            (commentsList) {
          _comments.assignAll(commentsList);
        },
        onError: (error) {
          Get.snackbar('Error', 'Failed to load comments: $error');
        },
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to load post details: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Set comment sort type
  void setSortType(String sortType) {
    _commentSortType.value = sortType;
  }

  // Toggle post like
  Future<void> togglePostLike() async {
    if (_post.value == null) return;

    try {
      final currentUserId = getCurrentUserId();
      final currentPost = _post.value!;

      List<String> updatedLikes = List.from(currentPost.likes);
      if (updatedLikes.contains(currentUserId)) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      // Optimistic update
      _post.value = currentPost.copyWith(likes: updatedLikes);

      // Update in Firestore
      await postRepository.updatePostLikes(currentPost.postId, updatedLikes);

    } catch (e) {
      Get.snackbar('Error', 'Failed to update like: $e');
      // Revert on error by reloading from stream
    }
  }

  // Get current user ID
  String getCurrentUserId() {
    // TODO: Get from authentication service
    // return AuthenticationRepository.instance.authUser?.uid ?? '';
    return 'current_user_id';
  }

  // Get user name by ID
  String getUserName(String userId) {
    // TODO: Implement user lookup from UserRepository
    return _userCache[userId]?['name'] ?? 'User ${userId.substring(0, 4)}';
  }

  // Get user avatar by ID
  String getUserAvatar(String userId) {
    // TODO: Implement user lookup from UserRepository
    return _userCache[userId]?['avatar'] ?? 'https://picsum.photos/100?random=$userId';
  }

  // Initialize user cache (temporary until user repository is implemented)
  void _initializeUserCache() {
    _userCache.addAll({
      'current_user_id': {
        'name': 'You',
        'avatar': 'https://picsum.photos/100?random=0',
      },
    });
  }

  // Reference to Firestore for ID generation
  final _db = FirebaseFirestore.instance;
}