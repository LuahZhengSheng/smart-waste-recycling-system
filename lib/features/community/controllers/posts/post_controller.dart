import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/create_post/create_post.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';

class PostsController extends GetxController with SingleGetTickerProviderMixin {
  static PostsController get instance => Get.find();

  // Repositories
  final PostRepository _postRepository = Get.put(PostRepository());

  // Controllers
  late TabController tabController;
  final searchController = TextEditingController();

  // Reactive variables
  final selectedTimeFilter = TimeFilter.allTime.obs;
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
    tabController = TabController(length: 4, vsync: this);
    _initializePosts();
    _setupTabListener();
    _setupSearchListener();
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Initialize posts streams
  void _initializePosts() {
    try {
      // 监听所有相关列表的变化
      ever(allPosts, (_) => _filterPosts());
      ever(tipPosts, (_) => _filterPosts());
      ever(questionPosts, (_) => _filterPosts());
      ever(discussionPosts, (_) => _filterPosts());

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

  /// Categorize posts by type using enum
  void _categorizePosts(List<PostModel> posts) {
    tipPosts.assignAll(
        posts.where((post) => PostType.fromString(post.postType) == PostType.tip).toList());
    questionPosts.assignAll(
        posts.where((post) => PostType.fromString(post.postType) == PostType.question).toList());
    discussionPosts.assignAll(
        posts.where((post) => PostType.fromString(post.postType) == PostType.discussion).toList());
  }

  /// Setup tab listener
  void _setupTabListener() {
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        _filterPosts();
      }
    });
  }

  /// Setup search listener
  void _setupSearchListener() {
    ever(searchQuery, (_) => _filterPosts());
    ever(selectedTimeFilter, (_) => _filterPosts());
  }

  /// Filter posts based on current tab, search query and time filter
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
        sourcePosts = sourcePosts
            .where((post) =>
            post.content.toLowerCase().contains(searchQuery.value.toLowerCase()))
            .toList();
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

  /// Apply time filter to posts using enum
  List<PostModel> _applyTimeFilter(List<PostModel> posts) {
    final now = DateTime.now();

    switch (selectedTimeFilter.value) {
      case TimeFilter.today:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 1))))
            .toList();
      case TimeFilter.thisWeek:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 7))))
            .toList();
      case TimeFilter.thisMonth:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
      case TimeFilter.thisYear:
        return posts
            .where((post) =>
            post.createdAt.isAfter(now.subtract(const Duration(days: 365))))
            .toList();
      case TimeFilter.allTime:
      return posts;
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Set time filter using enum
  void setTimeFilter(TimeFilter filter) {
    selectedTimeFilter.value = filter;
  }

  /// Get current user ID
  String getCurrentUserId() {
    return AuthenticationRepository.instance.authUser?.uid ?? '';
  }

  /// Check if post belongs to current user
  bool isUserPost(PostModel post) {
    return post.userId == getCurrentUserId();
  }

  /// Toggle like
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

      // Update local state
      final index = allPosts.indexWhere((p) => p.postId == postId);
      if (index != -1) {
        allPosts[index] = allPosts[index].copyWith(likes: newLikes);
        allPosts.refresh();
        _categorizePosts(allPosts);
      }
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Navigate to post details
  void navigateToPostDetails(String postId) {
    Get.to(() => PostDetailsScreen(postId: postId));
  }

  /// Navigate to edit post
  void navigateToEditPost(PostModel post) {
    Get.to(() => CreatePostScreen(), arguments: post);
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    try {
      FLoaders.showLoading('Deleting post...');
      await _postRepository.deletePost(postId);
      allPosts.removeWhere((post) => post.postId == postId);
      _categorizePosts(allPosts);
      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post deleted successfully',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      FLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}