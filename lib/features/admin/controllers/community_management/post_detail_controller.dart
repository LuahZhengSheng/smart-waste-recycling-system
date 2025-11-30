import 'dart:async';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/models/reply_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/data/repositories/community/comment_repository.dart';
import 'package:fyp/data/repositories/community/reply_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

class PostDetailController extends GetxController {
  final PostModel initialPost;

  PostDetailController(this.initialPost);

  final PostRepository postRepository = Get.put(PostRepository());
  final CommentRepository commentRepository = Get.put(CommentRepository());
  final ReplyRepository replyRepository = Get.put(ReplyRepository());
  final UserRepository userRepository = Get.put(UserRepository());

  // Observables
  final Rx<PostModel> currentPost = PostModel.empty().obs;
  final RxList<Comment> comments = <Comment>[].obs;
  final RxMap<String, UserModel> usersCache = <String, UserModel>{}.obs;

  final RxBool isLoadingComments = false.obs;
  final RxBool hasMoreComments = true.obs;

  final RxBool hasContentChanged = false.obs;

  /// 只负责提示有 comment 数变化，不自动刷新
  final RxBool hasCommentsChanged = false.obs;

  /// 显示在界面上的评论数（只在 refresh 时更新，不跟 stream）
  final RxInt displayCommentCount = 0.obs;

  final RxInt commentsPage = 1.obs;
  final int commentsPerPage = 20;

  /// 标记是否正在进行初始加载（用于显示 loading 状态）
  final RxBool isInitialLoading = true.obs;

  // Reply 相关
  final RxMap<String, bool> expandedComments = <String, bool>{}.obs;
  final RxMap<String, List<Reply>> commentReplies = <String, List<Reply>>{}.obs;
  final RxMap<String, bool> loadingReplies = <String, bool>{}.obs;
  final RxMap<String, bool> hasMoreRepliesMap = <String, bool>{}.obs;
  final RxMap<String, int> repliesPageMap = <String, int>{}.obs;
  final int repliesPerPage = 20;

  // Stream subscriptions
  StreamSubscription<PostModel?>? postStreamSubscription;
  StreamSubscription<PostModel?>? commentCountStreamSubscription;

  // Stream 监听到的最新 comment 数量（不直接显示在 UI）
  int latestCommentCount = 0;
  // 添加标记，表示是否已经完成初始加载
  bool _isInitialLoadComplete = false;

  @override
  void onInit() {
    super.onInit();
    currentPost.value = initialPost;
    latestCommentCount = initialPost.commentCount;
    displayCommentCount.value = 0; // 改为 0，等加载完才更新

    // 先执行初始加载
    loadInitialData().then((_) {
      // 初始加载完成后才启动 stream 监听
      listenToPostChanges();
      listenToCommentCountChanges();
    });
  }

  /// 实时监听 post 本身（内容、类型、禁用状态、media 长度等）
  void listenToPostChanges() {
    postStreamSubscription =
        postRepository.getPostByIdStream(initialPost.postId).listen((post) {
          if (post != null) {
            if (hasImportantChanges(currentPost.value, post)) {
              hasContentChanged.value = true;
            }
            currentPost.value = post;
          }
        });
  }

  /// Stream 监听 commentCount 变化，用于显示提醒（但不更新 UI 显示的数量）
  void listenToCommentCountChanges() {
    commentCountStreamSubscription =
        postRepository.getPostByIdStream(initialPost.postId).listen((post) {
          if (post != null && post.commentCount != latestCommentCount) {
            // 只有在初始加载完成后才显示通知
            if (_isInitialLoadComplete) {
              // 检测到 comment 数量变化，显示提醒
              hasCommentsChanged.value = true;
            }

            // 更新 stream 监听到的最新数量（但不更新 displayCommentCount）
            latestCommentCount = post.commentCount;
          }
        });
  }

  bool hasImportantChanges(PostModel oldPost, PostModel newPost) {
    if (oldPost.postId.isEmpty) return false;
    return oldPost.content != newPost.content ||
        oldPost.postType != newPost.postType ||
        oldPost.isDisabled != newPost.isDisabled ||
        oldPost.media.length != newPost.media.length;
  }

  Future<void> loadInitialData() async {
    try {
      isInitialLoading.value = true; // 开始初始加载

      // 先获取最新的 post 数据
      final latestPost =
      await postRepository.getPostById(currentPost.value.postId);
      if (latestPost != null) {
        currentPost.value = latestPost;
        latestCommentCount = latestPost.commentCount;
        displayCommentCount.value = latestPost.commentCount;
      }

      // 加载发帖人
      await loadUserData(currentPost.value.userId);

      // 首次加载 comments
      await loadMoreComments();

      // 标记初始加载完成
      _isInitialLoadComplete = true;
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load post details: $e',
      );
    } finally {
      isInitialLoading.value = false; // 结束初始加载
    }
  }

  Future<void> loadMoreComments() async {
    if (isLoadingComments.value || !hasMoreComments.value) return;

    try {
      isLoadingComments.value = true;

      final newComments = await commentRepository.getCommentsPaginated(
        postId: currentPost.value.postId,
        limit: commentsPerPage,
        lastDoc: null,
      );

      if (newComments.isEmpty) {
        hasMoreComments.value = false;
      } else {
        // 加载评论作者信息
        final userIds = newComments.map((c) => c.userId).toSet();
        await loadUsersData(userIds);

        comments.addAll(newComments);
        commentsPage.value++;

        // 如果已经拿满当前显示数量，就不再显示 Load More
        if (comments.length >= displayCommentCount.value) {
          hasMoreComments.value = false;
        }
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load comments: $e',
      );
    } finally {
      isLoadingComments.value = false;
    }
  }

  /// 仅在用户点击 Refresh 按钮时调用
  Future<void> refreshComments() async {
    try {
      // 记录刷新前的评论数量
      final oldCommentCount = comments.length;

      // 清空当前 comments 和回复分页相关状态
      comments.clear();
      commentsPage.value = 1;
      hasMoreComments.value = true;

      expandedComments.clear();
      commentReplies.clear();
      loadingReplies.clear();
      hasMoreRepliesMap.clear();
      repliesPageMap.clear();

      // 隐藏顶部提示
      hasCommentsChanged.value = false;

      // 【关键】更新显示的评论数量为 stream 监听到的最新值
      displayCommentCount.value = latestCommentCount;

      // 重新加载 comments
      await loadMoreComments();

      // 计算变化
      final newCommentCount = comments.length;
      final difference = newCommentCount - oldCommentCount;

      // 只在有变化时才显示提示
      if (difference > 0) {
        final message = difference == 1
            ? 'Refreshed: 1 new comment added'
            : 'Refreshed: $difference new comments added';
        FLoaders.successSnackBar(
          title: 'Refreshed',
          message: message,
        );
      } else if (difference < 0) {
        final removed = difference.abs();
        final message = removed == 1
            ? 'Refreshed: 1 comment removed'
            : 'Refreshed: $removed comments removed';
        FLoaders.successSnackBar(
          title: 'Refreshed',
          message: message,
        );
      }
      // 如果 difference == 0，不显示任何提示
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to refresh comments: $e',
      );
    }
  }

  // ---- 以下为原有的用户/回复相关方法，保持不变 ----

  Future<void> toggleCommentExpansion(String commentId) async {
    final isCurrentlyExpanded = expandedComments[commentId] ?? false;

    if (isCurrentlyExpanded) {
      expandedComments[commentId] = false;
      expandedComments.refresh();
    } else {
      expandedComments[commentId] = true;
      expandedComments.refresh();

      if (commentReplies[commentId] == null ||
          commentReplies[commentId]!.isEmpty) {
        await loadReplies(commentId);
      }
    }
  }

  Future<void> loadReplies(String commentId) async {
    try {
      loadingReplies[commentId] = true;
      loadingReplies.refresh();

      repliesPageMap[commentId] = 1;

      final replies = await replyRepository.getRepliesPaginated(
        commentId: commentId,
        limit: repliesPerPage,
        lastDoc: null,
      );

      final userIds = replies.map((r) => r.userId).toSet();
      await loadUsersData(userIds);

      commentReplies[commentId] = replies;
      commentReplies.refresh();

      final comment = comments.firstWhere((c) => c.commentId == commentId);
      hasMoreRepliesMap[commentId] = replies.length < comment.replyCount;
      hasMoreRepliesMap.refresh();
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load replies: $e',
      );
    } finally {
      loadingReplies[commentId] = false;
      loadingReplies.refresh();
    }
  }

  Future<void> loadMoreReplies(String commentId) async {
    if (loadingReplies[commentId] == true) return;

    try {
      loadingReplies[commentId] = true;
      loadingReplies.refresh();

      final currentPage = repliesPageMap[commentId] ?? 1;
      repliesPageMap[commentId] = currentPage + 1;

      final newReplies = await replyRepository.getRepliesPaginated(
        commentId: commentId,
        limit: repliesPerPage,
        lastDoc: null,
      );

      if (newReplies.isEmpty) {
        hasMoreRepliesMap[commentId] = false;
      } else {
        final userIds = newReplies.map((r) => r.userId).toSet();
        await loadUsersData(userIds);

        final existingReplies = commentReplies[commentId] ?? [];
        commentReplies[commentId] = [...existingReplies, ...newReplies];

        final comment = comments.firstWhere((c) => c.commentId == commentId);
        if (commentReplies[commentId]!.length >= comment.replyCount) {
          hasMoreRepliesMap[commentId] = false;
        }
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load more replies: $e',
      );
    } finally {
      loadingReplies[commentId] = false;
      loadingReplies.refresh();
    }
  }

  Future<void> loadUserData(String userId) async {
    if (usersCache.containsKey(userId)) return;
    try {
      final user = await userRepository.fetchOtherUserDetails(userId);
      usersCache[userId] = user;
    } catch (e) {
      print('Failed to load user data for $userId: $e');
    }
  }

  Future<void> loadUsersData(Set<String> userIds) async {
    try {
      final newUserIds =
      userIds.where((id) => !usersCache.containsKey(id)).toSet();
      if (newUserIds.isNotEmpty) {
        final usersData = await userRepository.getUsersProfileData(newUserIds);
        usersCache.addAll(usersData);
      }
    } catch (e) {
      print('Failed to load users data: $e');
    }
  }

  void dismissContentChangedNotification() {
    hasContentChanged.value = false;
  }

  Future<void> togglePostStatus() async {
    try {
      final updatedPost = currentPost.value.copyWith(
        isDisabled: !currentPost.value.isDisabled,
        updatedAt: DateTime.now(),
      );
      await postRepository.savePost(updatedPost);
      FLoaders.successSnackBar(
        title: 'Success',
        message:
        'Post ${currentPost.value.isDisabled ? 'recovered' : 'disabled'} successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update post: $e',
      );
    }
  }

  @override
  void onClose() {
    postStreamSubscription?.cancel();
    commentCountStreamSubscription?.cancel();
    super.onClose();
  }
}
