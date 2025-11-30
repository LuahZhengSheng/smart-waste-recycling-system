import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

enum PostStatusFilter { active, disabled }

class CommunityManagementController extends GetxController {
  static CommunityManagementController get instance => Get.find();

  final PostRepository _postRepository = Get.put(PostRepository());
  final UserRepository _userRepository = Get.put(UserRepository());
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<PostModel> allPosts = <PostModel>[].obs;
  final RxList<PostModel> filteredPosts = <PostModel>[].obs;
  final RxMap<String, UserModel> usersCache = <String, UserModel>{}.obs;
  final RxString searchQuery = ''.obs;
  final Rx<PostStatusFilter> currentFilter = PostStatusFilter.active.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasNewPosts = false.obs;
  final RxString newPostsMessage = ''.obs;

  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'postType': null,
    'mediaType': null,
    'dateRange': null,
  }.obs;

  // For tracking post count changes
  int _previousPostCount = 0;
  bool _isInitialLoad = true;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    _setupPostsCountListener();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
    ever(currentFilter, (_) => applyFiltersAndSearch());
  }

  void _setupPostsCountListener() {
    // Listen to posts count changes for new/deleted posts
    _postRepository.getPostsCountStream().listen((newCount) {
      if (_isInitialLoad) {
        _previousPostCount = newCount;
        _isInitialLoad = false;
        return;
      }

      if (newCount != _previousPostCount) {
        final difference = newCount - _previousPostCount;
        if (difference > 0) {
          newPostsMessage.value = '$difference new post${difference > 1 ? 's' : ''} available';
        } else if (difference < 0) {
          newPostsMessage.value = '${difference.abs()} post${difference.abs() > 1 ? 's' : ''} deleted';
        }
        hasNewPosts.value = true;
        _previousPostCount = newCount;
      }
    }, onError: (error) {
      print('Error listening to posts count: $error');
    });
  }

  Future<void> loadPosts() async {
    isLoading.value = true;

    try {
      // Use Future instead of Stream for initial load
      final posts = await _postRepository.getAllPosts();

      allPosts.value = posts;

      // Load user data for all unique user IDs
      final userIds = posts.map((post) => post.userId).toSet();
      await _loadUsersData(userIds);

      applyFiltersAndSearch();

      // Reset new posts notification after refresh
      hasNewPosts.value = false;
      newPostsMessage.value = '';

    } catch (error) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load posts: $error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUsersData(Set<String> userIds) async {
    try {
      final newUserIds = userIds.where((id) => !usersCache.containsKey(id)).toSet();

      if (newUserIds.isNotEmpty) {
        final usersData = await _userRepository.getUsersProfileData(newUserIds);
        usersCache.addAll(usersData);
      }
    } catch (e) {
      print('Failed to load users data: $e');
    }
  }

  void refreshPosts() {
    loadPosts();
  }

  void changeFilter(PostStatusFilter filter) {
    currentFilter.value = filter;
  }

  void applyFiltersAndSearch() {
    List<PostModel> result = List.from(allPosts);

    // æ·»åŠ è¯¦ç»†çš„è°ƒè¯•ä¿¡æ¯
    print('=== DEBUG: applyFiltersAndSearch() ===');
    print('Total posts in allPosts: ${allPosts.length}');
    print('Current filter: ${currentFilter.value}');
    print('Disabled posts count: ${allPosts.where((post) => post.isDisabled).length}');
    print('Active posts count: ${allPosts.where((post) => !post.isDisabled).length}');

    // æ‰“å°å‰å‡ ä¸ªå¸–å­çš„ isDisabled çŠ¶æ€
    if (allPosts.isNotEmpty) {
      print('First 5 posts isDisabled status:');
      for (int i = 0; i < allPosts.length && i < 5; i++) {
        final post = allPosts[i];
        print('  Post ${i + 1}: ID=${post.postId}, isDisabled=${post.isDisabled}');
      }
    }

    // Apply status filter
    switch (currentFilter.value) {
      case PostStatusFilter.active:
        result = result.where((post) => !post.isDisabled).toList();
        print('After active filter: ${result.length} posts (showing active posts only)');
        break;
      case PostStatusFilter.disabled:
        result = result.where((post) => post.isDisabled).toList();
        print('After disabled filter: ${result.length} posts (showing disabled posts only)');
        break;
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final beforeSearch = result.length;
      result = result.where((post) {
        final user = usersCache[post.userId];
        return post.content.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            post.postType.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            post.postId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user?.username.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
            (user?.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      }).toList();
      print('After search filter "${searchQuery.value}": $beforeSearch -> ${result.length} posts');
    }

    // Apply post type filter
    if (activeFilters['postType'] != null) {
      final beforePostType = result.length;
      result = result.where((post) => post.postType == activeFilters['postType']).toList();
      print('After postType filter "${activeFilters['postType']}": $beforePostType -> ${result.length} posts');
    }

    // Apply media type filter
    if (activeFilters['mediaType'] != null) {
      final beforeMedia = result.length;
      switch (activeFilters['mediaType']) {
        case 'hasMedia':
          result = result.where((post) => post.media.isNotEmpty).toList();
          break;
        case 'noMedia':
          result = result.where((post) => post.media.isEmpty).toList();
          break;
      }
      print('After mediaType filter "${activeFilters['mediaType']}": $beforeMedia -> ${result.length} posts');
    }

    // Apply date range filter
    if (activeFilters['dateRange'] != null) {
      final beforeDate = result.length;
      final now = DateTime.now();
      DateTime? startDate;

      switch (activeFilters['dateRange']) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'last7days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'last30days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'thisMonth':
          startDate = DateTime(now.year, now.month, 1);
          break;
      }

      if (startDate != null) {
        result = result.where((post) => post.createdAt.isAfter(startDate!)).toList();
      }
      print('After dateRange filter "${activeFilters['dateRange']}": $beforeDate -> ${result.length} posts');
    }

    filteredPosts.value = result;
    currentPage.value = 1;

    print('=== DEBUG: Final result ===');
    print('Filtered posts: ${filteredPosts.length}');
    print('Total pages: $totalPages');
    print('Current page: $currentPage');
    print('============================\n');
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  bool get hasActiveFilters {
    return activeFilters['postType'] != null ||
        activeFilters['mediaType'] != null ||
        activeFilters['dateRange'] != null;
  }

  void sortPosts(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredPosts.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Post ID
          aValue = a.postId;
          bValue = b.postId;
          break;
        case 1: // Username (from cache)
          aValue = usersCache[a.userId]?.username ?? '';
          bValue = usersCache[b.userId]?.username ?? '';
          break;
        case 2: // Post Type
          aValue = a.postType;
          bValue = b.postType;
          break;
        case 3: // Media count
          aValue = a.media.length;
          bValue = b.media.length;
          break;
        case 4: // Likes count
          aValue = a.likes.length;
          bValue = b.likes.length;
          break;
        case 5: // Comments count
          aValue = a.commentCount;
          bValue = b.commentCount;
          break;
        case 6: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 7: // Updated At
          aValue = a.updatedAt;
          bValue = b.updatedAt;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  Future<void> togglePostStatus(PostModel post) async {
    try {
      final updatedPost = post.copyWith(
        isDisabled: !post.isDisabled,
      );

      await _postRepository.savePost(updatedPost);

      // å®žæ—¶æ›´æ–°æœ¬åœ°æ•°æ®
      _updateLocalPost(updatedPost);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Post ${post.isDisabled ? 'recovered' : 'disabled'} successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update post: $e',
      );
    }
  }

  /// å®žæ—¶æ›´æ–°æœ¬åœ°å¸–å­æ•°æ®
  void _updateLocalPost(PostModel updatedPost) {
    // æ›´æ–° allPosts ä¸­çš„å¸–å­
    final index = allPosts.indexWhere((p) => p.postId == updatedPost.postId);
    if (index != -1) {
      allPosts[index] = updatedPost;
    }

    // æ›´æ–° filteredPosts ä¸­çš„å¸–å­
    final filteredIndex = filteredPosts.indexWhere((p) => p.postId == updatedPost.postId);
    if (filteredIndex != -1) {
      filteredPosts[filteredIndex] = updatedPost;
    }

    // é‡æ–°åº”ç”¨ç­›é€‰ï¼ˆç¡®ä¿å¸–å­åœ¨æ­£ç¡®çš„æ ‡ç­¾é¡µæ˜¾ç¤ºï¼‰
    applyFiltersAndSearch();
  }

  /// ç›‘å¬å•ä¸ªå¸–å­çš„å®žæ—¶æ›´æ–°ï¼ˆç”¨äºŽ disable/recover æ“ä½œï¼‰
  void _setupPostUpdateListener(String postId) {
    _postRepository.getPostByIdStream(postId).listen((updatedPost) {
      if (updatedPost != null) {
        _updateLocalPost(updatedPost);
      }
    });
  }

  // Pagination
  List<PostModel> get paginatedPosts {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredPosts.length);

    if (startIndex >= filteredPosts.length) {
      return [];
    }

    return filteredPosts.sublist(startIndex, endIndex);
  }

  int get totalPosts => filteredPosts.length;
  int get totalPages => (totalPosts / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalPosts);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) currentPage.value--;
  }

  void nextPage() {
    if (canGoNextPage) currentPage.value++;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}