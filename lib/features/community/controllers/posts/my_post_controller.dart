import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class MyPostsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab Controller
  late TabController tabController;

  // Repository
  final PostRepository postRepository = Get.put(PostRepository());

  // Observable variables
  final _myPosts = <PostModel>[].obs;
  final _filteredPosts = <PostModel>[].obs;
  final _selectedFilter = Rx<PostType?>(null); // 修改：使用 nullable 类型
  final _isLoading = false.obs;

  // Filter list using enum - 第一个是 null 表示 "All"
  final List<PostType?> filters = [
    null, // All
    PostType.tip,
    PostType.question,
    PostType.discussion,
  ];

  // Getters
  List<PostModel> get myPosts => _myPosts;
  List<PostModel> get filteredPosts => _filteredPosts;
  PostType? get selectedFilter => _selectedFilter.value;
  RxBool get isLoading => _isLoading;

  // Statistics
  int get totalPosts => _myPosts.length;
  int get activePosts => _myPosts.where((post) => !post.isDisabled).length;
  int get violatedPosts => _myPosts.where((post) => post.isDisabled).length;

  @override
  void onInit() {
    super.onInit();

    // Initialize TabController
    tabController = TabController(length: 4, vsync: this);

    // Listen to tab changes
    tabController.addListener(_handleTabChange);

    loadMyPosts();

    // Listen to changes and apply filters
    ever(_myPosts, (_) => _applyFilters());
    ever(_selectedFilter, (_) => _applyFilters());
  }

  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    super.onClose();
  }

  /// Handle tab changes
  void _handleTabChange() {
    if (tabController.indexIsChanging || !tabController.indexIsChanging) {
      final newFilter = filters[tabController.index];
      if (_selectedFilter.value != newFilter) {
        _selectedFilter.value = newFilter; // 直接设置，不需要默认值
        _applyFilters();
      }
    }
  }

  /// Load user's posts from Firestore
  Future<void> loadMyPosts() async {
    _isLoading.value = true;

    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Use the repository to get user posts stream
      final postsStream = postRepository.getUserPostsStream(currentUserId);

      // Listen to the stream and update posts
      postsStream.listen((posts) {
        _myPosts.assignAll(posts);
        _applyFilters();
      }, onError: (error) {
        FLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to load your posts: $error',
        );
      });
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load your posts: $e',
      );
    } finally {
      // Delay hiding loading to ensure smooth UI transition
      Future.delayed(const Duration(milliseconds: 500), () {
        _isLoading.value = false;
      });
    }
  }

  /// Apply category filter using enum - 修复过滤逻辑
  void _applyFilters() {
    var filtered = List<PostModel>.from(_myPosts);

    // 修复：只有当选择了具体的 filter 时才进行过滤
    if (_selectedFilter.value != null) {
      filtered = filtered.where((post) {
        final postType = PostType.fromString(post.postType);
        return postType == _selectedFilter.value;
      }).toList();
    }
    // 如果 _selectedFilter.value 是 null，则显示所有帖子

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _filteredPosts.assignAll(filtered);
  }

  /// Set category filter and sync with tab using enum
  void setFilter(PostType? filter) {
    _selectedFilter.value = filter; // 直接设置，不需要默认值

    // Sync tab controller with filter change
    final filterIndex = filters.indexOf(filter);
    if (filterIndex != -1 && tabController.index != filterIndex) {
      tabController.animateTo(filterIndex);
    }

    _applyFilters();
  }

  /// Toggle post like
  Future<void> toggleLike(String postId) async {
    try {
      final postIndex = _myPosts.indexWhere((p) => p.postId == postId);
      if (postIndex != -1) {
        final post = _myPosts[postIndex];
        final currentUserId = getCurrentUserId();

        List<String> updatedLikes = List<String>.from(post.likes);

        if (updatedLikes.contains(currentUserId)) {
          updatedLikes.remove(currentUserId);
        } else {
          updatedLikes.add(currentUserId);
        }

        // Update local state
        _myPosts[postIndex] = post.copyWith(likes: updatedLikes);
        _myPosts.refresh();
        _applyFilters();

        // Update Firestore using repository
        await postRepository.updatePostLikes(postId, updatedLikes);
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update like: $e',
      );
      // Reload posts to sync with server state
      loadMyPosts();
    }
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    try {
      FLoaders.showLoading('Deleting post...');

      // Delete from Firestore using repository
      await postRepository.deletePost(postId);

      // Remove from local list
      _myPosts.removeWhere((post) => post.postId == postId);
      _applyFilters();

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post deleted successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete post: $e',
      );
    }
  }

  /// Edit post
  Future<void> editPost(PostModel updatedPost) async {
    try {
      FLoaders.showLoading('Updating post...');

      // Update in Firestore using repository
      await postRepository.savePost(updatedPost);

      // Update local state
      final postIndex = _myPosts.indexWhere((p) => p.postId == updatedPost.postId);
      if (postIndex != -1) {
        _myPosts[postIndex] = updatedPost;
        _myPosts.refresh();
        _applyFilters();
      }

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post updated successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update post: $e',
      );
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    await loadMyPosts();
  }

  /// Get current user ID
  String getCurrentUserId() {
    return AuthenticationRepository.instance.authUser?.uid ?? '';
  }

  /// Get post by ID
  PostModel? getPostById(String postId) {
    try {
      return _myPosts.firstWhere((post) => post.postId == postId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has liked a post
  bool hasUserLikedPost(String postId) {
    final currentUserId = getCurrentUserId();
    final post = _myPosts.firstWhere(
          (p) => p.postId == postId,
      orElse: () => PostModel.empty(),
    );
    return post.likes.contains(currentUserId);
  }

  /// Get posts statistics by type using enum
  Map<String, int> getPostsStatistics() {
    return {
      'All': _myPosts.length,
      'Tips': _myPosts.where((post) => PostType.fromString(post.postType) == PostType.tip).length,
      'Questions': _myPosts.where((post) => PostType.fromString(post.postType) == PostType.question).length,
      'Discussion': _myPosts.where((post) => PostType.fromString(post.postType) == PostType.discussion).length,
    };
  }
}