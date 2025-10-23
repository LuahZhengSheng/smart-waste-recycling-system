import 'package:flutter/material.dart';
import 'package:fyp/features/community/screens/edit_post/edit_post.dart';
import 'package:fyp/features/community/screens/my_post/my_post.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/post_model.dart';

import '../../../../data/repositories/community/post_repository.dart';
import '../../../../utils/popups/loaders.dart';

class PostsController extends GetxController with SingleGetTickerProviderMixin {
  static PostsController get instance => Get.find();

  // Repositories
  final PostRepository _postRepository = PostRepository();

  // Controllers
  late TabController tabController;

  final searchController = TextEditingController();

  // Reactive variables
  final selectedTimeFilter = 'All Time'.obs;
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  // Posts streams for different tabs
  final allPosts = <PostModel>[].obs;
  final tipPosts = <PostModel>[].obs;
  final questionPosts = <PostModel>[].obs;
  final discussionPosts = <PostModel>[].obs;

  // Combined filtered posts for current tab
  final filteredPosts = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // 初始化 TabController，使用 SingleGetTickerProviderMixin
    tabController = TabController(length: 4, vsync: this);

    _initializePosts();
    _setupTabListener();
    _setupSearchListener();
    _setupFilterListener();
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Initialize posts streams
  void _initializePosts() {
    try {
      // Listen to all posts stream
      ever(allPosts, (_) => _filterPosts());

      // Start listening to Firestore streams
      _postRepository.getAllPostsStream().listen((posts) {
        allPosts.assignAll(posts);
        _categorizePosts(posts);
      }, onError: (error) {
        FLoaders.errorSnackBar(title: 'Error', message: error.toString());
      });

    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Categorize posts by type
  void _categorizePosts(List<PostModel> posts) {
    tipPosts.assignAll(posts.where((post) => post.postType == 'tip').toList());
    questionPosts.assignAll(posts.where((post) => post.postType == 'question').toList());
    discussionPosts.assignAll(posts.where((post) => post.postType == 'discussion').toList());
  }

  // Setup tab listener
  void _setupTabListener() {
    tabController.addListener(() {
      _filterPosts();
    });
  }

  // Setup search listener
  void _setupSearchListener() {
    ever(searchQuery, (_) => _filterPosts());
    ever(selectedTimeFilter, (_) => _filterPosts());
  }

  // 设置过滤监听器
  void _setupFilterListener() {
    ever(selectedFilter, (_) => _applyHeaderFilter());
  }

  // 应用头部过滤
  void _applyHeaderFilter() {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      List<PostModel> sourcePosts;

      // Get posts based on selected filter
      switch (selectedFilter.value) {
        case 'Tips':
          sourcePosts = List.from(tipPosts);
          break;
        case 'Question':
          sourcePosts = List.from(questionPosts);
          break;
        case 'Discussion':
          sourcePosts = List.from(discussionPosts);
          break;
        default: // 'All'
          sourcePosts = List.from(allPosts);
      }

      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        sourcePosts = sourcePosts.where((post) =>
            post.content.toLowerCase().contains(searchQuery.value.toLowerCase())
        ).toList();
      }

      // Apply time filter
      sourcePosts = _applyTimeFilter(sourcePosts);

      // Update filtered posts
      filteredPosts.assignAll(sourcePosts);

    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filter posts based on current tab, search query and time filter
  void _filterPosts() {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      List<PostModel> sourcePosts;

      // Get posts based on current tab
      switch (tabController.index) {
        case 0: // All
          sourcePosts = List.from(allPosts);
          break;
        case 1: // Tips
          sourcePosts = List.from(tipPosts);
          break;
        case 2: // Questions
          sourcePosts = List.from(questionPosts);
          break;
        case 3: // Discussion
          sourcePosts = List.from(discussionPosts);
          break;
        default:
          sourcePosts = List.from(allPosts);
      }

      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        sourcePosts = sourcePosts.where((post) =>
            post.content.toLowerCase().contains(searchQuery.value.toLowerCase())
        ).toList();
      }

      // Apply time filter
      sourcePosts = _applyTimeFilter(sourcePosts);

      // Update filtered posts
      filteredPosts.assignAll(sourcePosts);

    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Apply time filter to posts
  List<PostModel> _applyTimeFilter(List<PostModel> posts) {
    final now = DateTime.now();

    switch (selectedTimeFilter.value) {
      case 'Today':
        return posts.where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 1)))
        ).toList();
      case 'This Week':
        return posts.where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 7)))
        ).toList();
      case 'This Month':
        return posts.where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 30)))
        ).toList();
      case 'This Year':
        return posts.where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 365)))
        ).toList();
      default: // All Time
        return posts;
    }
  }

  // 设置头部过滤
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Set time filter
  void setTimeFilter(String filter) {
    selectedTimeFilter.value = filter;
  }

  // Get current user ID (replace with your auth logic)
  String getCurrentUserId() {
    // TODO: Replace with actual user ID from your authentication
    return 'current_user_id'; // This should come from your auth service
  }

  // Check if post belongs to current user
  bool isUserPost(PostModel post) {
    return post.userId == getCurrentUserId();
  }

  // 在 PostsController 中修改 toggleLike 方法
  Future<void> toggleLike(String postId) async {
    try {
      final post = allPosts.firstWhere((p) => p.postId == postId);
      final currentUserId = getCurrentUserId();
      final newLikes = List<String>.from(post.likes);

      if (newLikes.contains(currentUserId)) {
        newLikes.remove(currentUserId);
      } else {
        newLikes.add(currentUserId);
      }

      await _postRepository.updatePostLikes(postId, newLikes);

      // 更新本地状态
      final index = allPosts.indexWhere((p) => p.postId == postId);
      if (index != -1) {
        allPosts[index] = allPosts[index].copyWith(likes: newLikes);
        update(); // 通知 GetBuilder 更新
      }

    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void navigateToMyPosts() {
    // TODO: Implement post details navigation
    Get.to(MyPostsScreen());
  }

  // Navigate to post details
  void navigateToPostDetails(String postId) {
    // TODO: Implement post details navigation
    Get.to(PostDetailsScreen(postId: postId));
  }

  // Navigate to edit post
  void navigateToEditPost(PostModel post) {
    // TODO: Implement edit post navigation
    Get.to(EditPostScreen(post: post));
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      FLoaders.showLoading('Deleting post...');
      await _postRepository.deletePost(postId);
      FLoaders.successSnackBar(title: 'Success', message: 'Post deleted successfully');

      // Remove from local state immediately
      allPosts.removeWhere((post) => post.postId == postId);

    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      FLoaders.stopLoading();
    }
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    try {
      isLoading.value = true;
      // The stream will automatically update the posts
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}