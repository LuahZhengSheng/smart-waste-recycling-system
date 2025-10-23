import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/community/post_repository.dart';


class MyPostsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab Controller
  late TabController tabController;

  // Repository
  final PostRepository postRepository = Get.put(PostRepository());

  // Observable variables
  final _myPosts = <PostModel>[].obs;
  final _filteredPosts = <PostModel>[].obs;
  final _selectedFilter = 'All'.obs;
  final _isLoading = false.obs;

  // Filter mapping - 修复标签名称匹配问题
  final List<String> filters = ['All', 'Tips', 'Questions', 'Discussion'];

  // Getters
  List<PostModel> get myPosts => _myPosts;
  List<PostModel> get filteredPosts => _filteredPosts;
  RxString get selectedFilter => _selectedFilter;
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

  // Handle tab changes
  void _handleTabChange() {
    if (tabController.indexIsChanging || !tabController.indexIsChanging) {
      final newFilter = filters[tabController.index];
      if (_selectedFilter.value != newFilter) {
        _selectedFilter.value = newFilter;
        _applyFilters();
      }
    }
  }

  // Load user's posts from Firestore
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
        Get.snackbar('Error', 'Failed to load your posts: $error');
      });

    } catch (e) {
      Get.snackbar('Error', 'Failed to load your posts: $e');
    } finally {
      // Delay hiding loading to ensure smooth UI transition
      Future.delayed(const Duration(milliseconds: 500), () {
        _isLoading.value = false;
      });
    }
  }

  // Apply category filter - 修复过滤逻辑
  void _applyFilters() {
    var filtered = List<PostModel>.from(_myPosts);

    // Apply category filter
    if (_selectedFilter.value != 'All') {
      filtered = filtered.where((post) {
        final postType = post.postType.toLowerCase();
        final selectedType = _selectedFilter.value.toLowerCase();

        // 修复匹配逻辑
        if (selectedType == 'tips') {
          return postType == 'tips' || postType == 'tip';
        } else if (selectedType == 'questions') {
          return postType == 'questions' || postType == 'question';
        } else if (selectedType == 'discussion') {
          return postType == 'discussion';
        }
        return false;
      }).toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _filteredPosts.assignAll(filtered);
  }

  // Set category filter and sync with tab
  void setFilter(String filter) {
    _selectedFilter.value = filter;

    // Sync tab controller with filter change
    final filterIndex = filters.indexOf(filter);
    if (filterIndex != -1 && tabController.index != filterIndex) {
      tabController.animateTo(filterIndex);
    }

    _applyFilters();
  }

  // Toggle community like
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
      Get.snackbar('Error', 'Failed to update like: $e');
      // Reload posts to sync with server state
      loadMyPosts();
    }
  }

  // Delete community
  Future<void> deletePost(String postId) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this community? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Delete from Firestore using repository
        await postRepository.deletePost(postId);

        // Remove from local list
        _myPosts.removeWhere((post) => post.postId == postId);
        _applyFilters();

        Get.snackbar('Success', 'Post deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete community: $e');
    }
  }

  // Edit community
  Future<void> editPost(PostModel updatedPost) async {
    try {
      // Update in Firestore using repository
      await postRepository.savePost(updatedPost);

      // Update local state
      final postIndex = _myPosts.indexWhere((p) => p.postId == updatedPost.postId);
      if (postIndex != -1) {
        _myPosts[postIndex] = updatedPost;
        _myPosts.refresh();
        _applyFilters();
      }

      Get.snackbar('Success', 'Post updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update community: $e');
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    await loadMyPosts();
  }

  // Get current user ID
  String getCurrentUserId() {
    try {
      // Try to get from AuthController if available
      // final authController = Get.find<AuthController>();
      return 'current_user_id';
    } catch (e) {
      // Fallback to local storage or other method
      // You might need to implement this based on your auth setup
      return '';
    }
  }

  // Get community by ID
  PostModel? getPostById(String postId) {
    try {
      return _myPosts.firstWhere((post) => post.postId == postId);
    } catch (e) {
      return null;
    }
  }

  // Check if user has liked a community
  bool hasUserLikedPost(String postId) {
    final currentUserId = getCurrentUserId();
    final post = _myPosts.firstWhere(
          (p) => p.postId == postId,
      orElse: () => PostModel.empty(),
    );
    return post.likes.contains(currentUserId);
  }

  // Get posts statistics by type
  Map<String, int> getPostsStatistics() {
    return {
      'All': _myPosts.length,
      'Tips': _myPosts.where((post) =>
      post.postType.toLowerCase() == 'tips' || post.postType.toLowerCase() == 'tip').length,
      'Questions': _myPosts.where((post) =>
      post.postType.toLowerCase() == 'questions' || post.postType.toLowerCase() == 'question').length,
      'Discussion': _myPosts.where((post) =>
      post.postType.toLowerCase() == 'discussion').length,
    };
  }
}