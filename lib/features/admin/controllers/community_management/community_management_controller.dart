import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/constants/colors.dart';
import '../../../community/models/post_model.dart';
import '../../screens/community_management/community_management.dart';

class CommunityManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<PostModel> allPosts = <PostModel>[].obs;
  final RxList<PostModel> filteredPosts = <PostModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'postType': null,
    'isDisabled': null,
    'mediaType': null,
    'dateRange': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(),
        time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());
  }

  void loadPosts() {
    // Mock data - replace with actual API call
    allPosts.value = _generateMockPosts();
    filteredPosts.value = List.from(allPosts);
  }

  List<PostModel> _generateMockPosts() {
    final now = DateTime.now();
    return [
      PostModel(
        postId: '1',
        userId: 'user123',
        postType: 'tip',
        content: 'Here\'s a great tip for reducing plastic waste: Always carry a reusable water bottle and shopping bags. This simple change can make a huge difference in reducing single-use plastics.',
        media: [
          'https://example.com/image1.jpg',
          'https://example.com/image2.png',
        ],
        likes: ['user456', 'user789', 'user101'],
        commentCount: 12,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        isDisabled: false,
      ),
      PostModel(
        postId: '2',
        userId: 'user456',
        postType: 'discussion',
        content: 'What are your thoughts on electric vehicles? Are they really better for the environment considering battery production?',
        media: [],
        likes: ['user123', 'user789'],
        commentCount: 24,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isDisabled: false,
      ),
      PostModel(
        postId: '3',
        userId: 'user789',
        postType: 'question',
        content: 'Can someone help me identify what type of plastic this container is? I want to make sure I\'m recycling it correctly.',
        media: [
          'https://example.com/container.jpg',
        ],
        likes: ['user123'],
        commentCount: 8,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isDisabled: true,
      ),
      PostModel(
        postId: '4',
        userId: 'user101',
        postType: 'achievement',
        content: 'Just completed my first month of zero-waste living! It was challenging but so rewarding. Here are some photos of my journey.',
        media: [
          'https://example.com/achievement1.jpg',
          'https://example.com/achievement2.jpg',
          'https://example.com/achievement3.jpg',
          'https://example.com/achievement4.jpg',
        ],
        likes: ['user123', 'user456', 'user789', 'user202', 'user303'],
        commentCount: 18,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        isDisabled: false,
      ),
      PostModel(
        postId: '5',
        userId: 'user202',
        postType: 'tip',
        content: 'DIY cleaning products are not only better for the environment but also cheaper! Here\'s my favorite recipe for all-purpose cleaner.',
        media: [
          'https://example.com/diy_cleaner.mp4',
        ],
        likes: ['user456', 'user101'],
        commentCount: 15,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
        isDisabled: false,
      ),
      PostModel(
        postId: '6',
        userId: 'user303',
        postType: 'discussion',
        content: 'Local recycling centers seem to be overwhelmed lately. Has anyone noticed this in their area? What solutions do you think would help?',
        media: [],
        likes: ['user123', 'user789', 'user101'],
        commentCount: 32,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 6)),
        isDisabled: true,
      ),
      PostModel(
        postId: '7',
        userId: 'user404',
        postType: 'question',
        content: 'Is composting really worth it for apartment dwellers? I\'m concerned about smell and pests.',
        media: [],
        likes: ['user202'],
        commentCount: 9,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        isDisabled: false,
      ),
      PostModel(
        postId: '8',
        userId: 'user505',
        postType: 'tip',
        content: 'Upcycling old furniture can give your home a fresh look while keeping items out of landfills. Here are some before and after photos of my latest project!',
        media: [
          'https://example.com/before1.jpg',
          'https://example.com/after1.jpg',
          'https://example.com/before2.jpg',
          'https://example.com/after2.jpg',
          'https://example.com/process.mp4',
        ],
        likes: [
          'user123',
          'user456',
          'user789',
          'user101',
          'user202',
          'user303'
        ],
        commentCount: 28,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 11)),
        isDisabled: false,
      ),
    ];
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<PostModel> result = List.from(allPosts);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((post) {
        return post.content.toLowerCase().contains(
            searchQuery.value.toLowerCase()) ||
            post.postType.toLowerCase().contains(
                searchQuery.value.toLowerCase()) ||
            post.userId.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply filters
    if (activeFilters['postType'] != null) {
      result =
          result.where((post) => post.postType == activeFilters['postType'])
              .toList();
    }

    if (activeFilters['isDisabled'] != null) {
      result =
          result.where((post) => post.isDisabled == activeFilters['isDisabled'])
              .toList();
    }

    if (activeFilters['mediaType'] != null) {
      switch (activeFilters['mediaType']) {
        case 'hasMedia':
          result = result.where((post) => post.media.isNotEmpty).toList();
          break;
        case 'noMedia':
          result = result.where((post) => post.media.isEmpty).toList();
          break;
      }
    }

    if (activeFilters['dateRange'] != null) {
      final now = DateTime.now();
      DateTime? startDate;

      switch (activeFilters['dateRange']) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          result = result.where((post) => post.createdAt.isAfter(startDate!))
              .toList();
          break;
        case 'last7days':
          startDate = now.subtract(const Duration(days: 7));
          result = result.where((post) => post.createdAt.isAfter(startDate!))
              .toList();
          break;
        case 'last30days':
          startDate = now.subtract(const Duration(days: 30));
          result = result.where((post) => post.createdAt.isAfter(startDate!))
              .toList();
          break;
        case 'thisMonth':
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);
          result = result.where((post) =>
          post.createdAt.isAfter(startOfMonth) &&
              post.createdAt.isBefore(endOfMonth)
          ).toList();
          break;
      }
    }

    filteredPosts.value = result;
    currentPage.value = 1; // Reset to first page after filtering
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['postType'] != null ||
        activeFilters['isDisabled'] != null ||
        activeFilters['mediaType'] != null ||
        activeFilters['dateRange'] != null;
  }

  // Sorting functionality
  void sortPosts(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredPosts.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // User ID
          aValue = a.userId;
          bValue = b.userId;
          break;
        case 1: // Post Type
          aValue = a.postType;
          bValue = b.postType;
          break;
        case 2: // Likes count
          aValue = a.likes.length;
          bValue = b.likes.length;
          break;
        case 3: // Comments count
          aValue = a.commentCount;
          bValue = b.commentCount;
          break;
        case 4: // Created At
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 5: // Updated At
          aValue = a.updatedAt;
          bValue = b.updatedAt;
          break;
        case 6: // Status (isDisabled)
          aValue = a.isDisabled ? 1 : 0;
          bValue = b.isDisabled ? 1 : 0;
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

  // Post actions
  void togglePostStatus(PostModel post) {
    final postIndex = allPosts.indexWhere((p) => p.postId == post.postId);
    if (postIndex != -1) {
      // Create a new community with updated status
      final updatedPost = PostModel(
        postId: post.postId,
        userId: post.userId,
        postType: post.postType,
        content: post.content,
        media: post.media,
        likes: post.likes,
        commentCount: post.commentCount,
        createdAt: post.createdAt,
        updatedAt: DateTime.now(),
        isDisabled: !post.isDisabled,
        comments: post.comments,
      );

      allPosts[postIndex] = updatedPost;
      applyFiltersAndSearch();

      // Show confirmation message
      Get.snackbar(
        'Success',
        'Post ${post.isDisabled ? 'enabled' : 'disabled'} successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FColors.primary.withOpacity(0.1),
        colorText: FColors.primary,
      );
    }
  }

  void viewPost(PostModel post) {
    // Navigate to community detail screen
    // This would typically navigate to a detailed view where admins can see comments and replies
    Get.snackbar(
      'View Post',
      'Opening detailed view for community: ${post.postId}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FColors.info.withOpacity(0.1),
      colorText: FColors.info,
    );

    // TODO: Implement navigation to community detail screen
    // Get.to(() => PostDetailScreen(community: community));
  }

  // Pagination functionality
  List<PostModel> get paginatedPosts {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(
        0, filteredPosts.length);

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
    if (canGoPreviousPage) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1; // Reset to first page
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      CommunityFilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }

  // Analytics and statistics
  Map<String, int> get postTypeStats {
    final stats = <String, int>{};
    for (final post in allPosts) {
      stats[post.postType] = (stats[post.postType] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> get postStatusStats {
    return {
      'active': allPosts
          .where((post) => !post.isDisabled)
          .length,
      'disabled': allPosts
          .where((post) => post.isDisabled)
          .length,
    };
  }

  int get totalLikes =>
      allPosts.fold(0, (sum, post) => sum + post.likes.length);

  int get totalComments =>
      allPosts.fold(0, (sum, post) => sum + post.commentCount);

  int get postsWithMedia =>
      allPosts
          .where((post) => post.media.isNotEmpty)
          .length;

  // Bulk actions (for future implementation)
  void bulkToggleStatus(List<PostModel> posts, bool disable) {
    for (final post in posts) {
      final postIndex = allPosts.indexWhere((p) => p.postId == post.postId);
      if (postIndex != -1) {
        final updatedPost = PostModel(
          postId: post.postId,
          userId: post.userId,
          postType: post.postType,
          content: post.content,
          media: post.media,
          likes: post.likes,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          updatedAt: DateTime.now(),
          isDisabled: disable,
          comments: post.comments,
        );
        allPosts[postIndex] = updatedPost;
      }
    }
    applyFiltersAndSearch();

    Get.snackbar(
      'Success',
      'Bulk action completed: ${posts.length} posts ${disable
          ? 'disabled'
          : 'enabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FColors.primary.withOpacity(0.1),
      colorText: FColors.primary,
    );
  }

  // Export functionality (for future implementation)
  void exportFilteredPosts() {
    // TODO: Implement CSV export of filtered posts
    Get.snackbar(
      'Export',
      'Exporting ${filteredPosts.length} posts to CSV...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: FColors.info.withOpacity(0.1),
      colorText: FColors.info,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}