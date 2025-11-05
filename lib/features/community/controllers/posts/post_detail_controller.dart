import 'dart:async';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/community/comment_repository.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class PostDetailsController extends GetxController {
  // Repositories
  final PostRepository postRepository = Get.put(PostRepository());
  final CommentRepository commentRepository = Get.put(CommentRepository());

  // Observable variables
  final _post = Rx<PostModel?>(null);
  final _comments = <Comment>[].obs;
  final _isLoading = false.obs;
  final _commentSortType = CommentSortType.newestFirst.obs; // 默认改为 newestFirst

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
  Rx<CommentSortType> get commentSortType => _commentSortType; // 直接返回枚举
  RxBool get isLoading => _isLoading;

  List<Comment> get sortedComments {
    final commentsList = List<Comment>.from(_comments);

    switch (_commentSortType.value) {
      case CommentSortType.topComments:
        commentsList.sort((a, b) => b.likes.length.compareTo(a.likes.length));
        break;
      case CommentSortType.newestFirst:
        commentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return commentsList;
  }

  @override
  void onClose() {
    _postSubscription?.cancel();
    _commentsSubscription?.cancel();
    super.onClose();
  }

  /// Load post details and comments
  Future<void> loadPostDetails(String postId) async {
    _isLoading.value = true;
    _currentPostId = postId;

    try {
      // Subscribe to post stream
      _postSubscription?.cancel();
      _postSubscription = postRepository.getPostByIdStream(postId).listen(
            (post) {
          if (post != null) {
            _post.value = post;
          }
        },
        onError: (error) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to load post: $error',
          );
        },
      );

      // Subscribe to comments stream
      _commentsSubscription?.cancel();
      _commentsSubscription = commentRepository.getCommentsStream(postId).listen(
            (commentsList) {
          _comments.assignAll(commentsList);
        },
        onError: (error) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to load comments: $error',
          );
        },
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load post details: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Set comment sort type using enum
  void setSortType(CommentSortType sortType) {
    _commentSortType.value = sortType;
  }

  /// Toggle post like
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
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update like: $e',
      );
    }
  }

  /// Get current user ID
  String getCurrentUserId() {
    return AuthenticationRepository.instance.authUser?.uid ?? '';
  }

}