import 'package:get/get.dart';
import 'package:fyp/utils/constants/colors.dart';
import '../../../community/models/post_model.dart';
import '../../../community/models/comment_model.dart';
import '../../../community/models/reply_model.dart';

class PostDetailsController extends GetxController {
  final PostModel initialPost;

  PostDetailsController(this.initialPost);

  // Observables
  final Rx<PostModel> currentPost = PostModel.empty().obs;
  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCommentsExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    currentPost.value = initialPost;
    loadComments();
  }

  /// Load comments and replies for the community
  void loadComments() {
    isLoading.value = true;

    try {
      // Mock data - replace with actual API call
      comments.value = _generateMockComments();

      // Load replies for each comment
      for (int i = 0; i < comments.length; i++) {
        final comment = comments[i];
        final replies = _generateMockReplies(comment.commentId);
        comments[i] = comment.withReplies(replies);
      }

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load comments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FColors.error.withOpacity(0.1),
        colorText: FColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate mock comments data
  List<Comment> _generateMockComments() {
    final now = DateTime.now();

    switch (currentPost.value.postId) {
      case '1': // Tip community about plastic waste
        return [
          Comment(
            commentId: 'comment_1_1',
            userId: 'eco_warrior_2024',
            content: 'This is such a helpful tip! I\'ve been using reusable bags for years and it really does make a difference. Thanks for sharing!',
            likes: ['user456', 'user789', 'user101'],
            replyCount: 2,
            createdAt: now.subtract(const Duration(hours: 1)),
            updatedAt: now.subtract(const Duration(hours: 1)),
          ),
          Comment(
            commentId: 'comment_1_2',
            userId: 'green_living_mom',
            content: 'I love this! My family has been trying to reduce plastic waste. Do you have any recommendations for good reusable water bottles for kids?',
            likes: ['user123', 'user202'],
            replyCount: 3,
            createdAt: now.subtract(const Duration(minutes: 45)),
            updatedAt: now.subtract(const Duration(minutes: 45)),
          ),
          Comment(
            commentId: 'comment_1_3',
            userId: 'sustainability_student',
            content: 'Great community! I\'m writing a paper on plastic pollution and this is exactly the kind of practical advice people need.',
            likes: ['user123', 'user456'],
            replyCount: 0,
            createdAt: now.subtract(const Duration(minutes: 30)),
            updatedAt: now.subtract(const Duration(minutes: 30)),
          ),
        ];

      case '2': // Discussion about electric vehicles
        return [
          Comment(
            commentId: 'comment_2_1',
            userId: 'tech_enthusiast_92',
            content: 'Great question! While EV battery production does have environmental costs, studies show that over their lifetime, EVs are still significantly better for the environment than gas cars, especially as the grid gets cleaner.',
            likes: ['user123', 'user789', 'user101', 'user202'],
            replyCount: 4,
            createdAt: now.subtract(const Duration(hours: 8)),
            updatedAt: now.subtract(const Duration(hours: 8)),
          ),
          Comment(
            commentId: 'comment_2_2',
            userId: 'climate_researcher',
            content: 'The lifecycle analysis is key here. Yes, battery production is energy-intensive, but the operational emissions are much lower. Plus, battery recycling technology is improving rapidly.',
            likes: ['user456', 'user789', 'user303'],
            replyCount: 2,
            createdAt: now.subtract(const Duration(hours: 6)),
            updatedAt: now.subtract(const Duration(hours: 6)),
          ),
          Comment(
            commentId: 'comment_2_3',
            userId: 'skeptical_driver',
            content: 'I\'m still not convinced. What about the rare earth mining required for batteries? That seems pretty harmful to the environment too.',
            likes: ['user404'],
            replyCount: 5,
            createdAt: now.subtract(const Duration(hours: 4)),
            updatedAt: now.subtract(const Duration(hours: 4)),
          ),
        ];

      case '3': // Question about plastic container
        return [
          Comment(
            commentId: 'comment_3_1',
            userId: 'recycling_expert',
            content: 'From what I can see in the photo, that looks like a #5 PP (polypropylene) container. These are generally recyclable in most curbside programs, but check with your local facility to be sure!',
            likes: ['user789', 'user101'],
            replyCount: 1,
            createdAt: now.subtract(const Duration(minutes: 20)),
            updatedAt: now.subtract(const Duration(minutes: 20)),
          ),
          Comment(
            commentId: 'comment_3_2',
            userId: 'zero_waste_advocate',
            content: 'Pro tip: Download the Recycle Coach app! You can scan barcodes or take photos and it tells you exactly how to dispose of items in your area.',
            likes: ['user123', 'user456'],
            replyCount: 0,
            createdAt: now.subtract(const Duration(minutes: 15)),
            updatedAt: now.subtract(const Duration(minutes: 15)),
          ),
        ];

      case '4': // Achievement community
        return [
          Comment(
            commentId: 'comment_4_1',
            userId: 'inspired_newbie',
            content: 'Wow, this is so inspiring! I\'m just starting my zero waste journey and seeing your success gives me hope. What was the hardest part for you?',
            likes: ['user123', 'user456', 'user789'],
            replyCount: 2,
            createdAt: now.subtract(const Duration(hours: 2)),
            updatedAt: now.subtract(const Duration(hours: 2)),
          ),
          Comment(
            commentId: 'comment_4_2',
            userId: 'veteran_zero_waster',
            content: 'Congratulations! The first month is definitely the hardest. It gets so much easier as it becomes habit. Keep up the great work!',
            likes: ['user101', 'user202', 'user303'],
            replyCount: 1,
            createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
            updatedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          ),
          Comment(
            commentId: 'comment_4_3',
            userId: 'practical_parent',
            content: 'Love the photos! Do you have any tips for zero waste with kids? That\'s where I struggle the most.',
            likes: ['user456', 'user505'],
            replyCount: 3,
            createdAt: now.subtract(const Duration(minutes: 45)),
            updatedAt: now.subtract(const Duration(minutes: 45)),
          ),
        ];

      case '5': // DIY cleaning products tip
        return [
          Comment(
            commentId: 'comment_5_1',
            userId: 'chemical_free_home',
            content: 'Thank you for sharing this recipe! I\'ve been making my own cleaners for years. This one works amazingly well and smells great too.',
            likes: ['user456', 'user101'],
            replyCount: 1,
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          Comment(
            commentId: 'comment_5_2',
            userId: 'budget_conscious_mom',
            content: 'The cost savings are incredible! I calculated that I save about \$200 a year making my own cleaning products.',
            likes: ['user202', 'user303'],
            replyCount: 2,
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
        ];

      default:
        return [];
    }
  }

  /// Generate mock replies for a comment
  List<Reply> _generateMockReplies(String commentId) {
    final now = DateTime.now();

    switch (commentId) {
      case 'comment_1_1': // Replies to tip about reusable bags
        return [
          Reply(
            replyId: 'reply_1_1_1',
            userId: 'user123',
            content: 'Glad you found it helpful! Small changes really do add up over time.',
            likes: ['eco_warrior_2024', 'user789'],
            createdAt: now.subtract(const Duration(minutes: 55)),
            updatedAt: now.subtract(const Duration(minutes: 55)),
          ),
          Reply(
            replyId: 'reply_1_1_2',
            userId: 'sustainable_sarah',
            content: 'I keep forgetting to bring my reusable bags sometimes. Any tips for remembering?',
            likes: ['user456'],
            createdAt: now.subtract(const Duration(minutes: 40)),
            updatedAt: now.subtract(const Duration(minutes: 40)),
          ),
        ];

      case 'comment_1_2': // Replies to question about kids water bottles
        return [
          Reply(
            replyId: 'reply_1_2_1',
            userId: 'user123',
            content: 'I really like the Contigo brand for kids - they\'re durable and leak-proof!',
            likes: ['green_living_mom', 'user202'],
            createdAt: now.subtract(const Duration(minutes: 35)),
            updatedAt: now.subtract(const Duration(minutes: 35)),
          ),
          Reply(
            replyId: 'reply_1_2_2',
            userId: 'parent_reviewer',
            content: 'Hydro Flask has great kids sizes too, though they\'re pricier. Worth it for the durability though.',
            likes: ['user789'],
            createdAt: now.subtract(const Duration(minutes: 25)),
            updatedAt: now.subtract(const Duration(minutes: 25)),
          ),
          Reply(
            replyId: 'reply_1_2_3',
            userId: 'budget_parent',
            content: 'If you\'re looking for budget-friendly options, the Target brand ones work great too!',
            likes: ['green_living_mom'],
            createdAt: now.subtract(const Duration(minutes: 20)),
            updatedAt: now.subtract(const Duration(minutes: 20)),
          ),
        ];

      case 'comment_2_1': // Replies to EV discussion
        return [
          Reply(
            replyId: 'reply_2_1_1',
            userId: 'data_analyst',
            content: 'Do you have sources for those studies? I\'d love to read more about the lifecycle analysis.',
            likes: ['tech_enthusiast_92', 'user789'],
            createdAt: now.subtract(const Duration(hours: 7)),
            updatedAt: now.subtract(const Duration(hours: 7)),
          ),
          Reply(
            replyId: 'reply_2_1_2',
            userId: 'tech_enthusiast_92',
            content: '@data_analyst Check out the Union of Concerned Scientists report on EV emissions. Very comprehensive!',
            likes: ['data_analyst', 'user101'],
            createdAt: now.subtract(const Duration(hours: 6, minutes: 30)),
            updatedAt: now.subtract(const Duration(hours: 6, minutes: 30)),
          ),
          Reply(
            replyId: 'reply_2_1_3',
            userId: 'grid_engineer',
            content: 'And as more renewable energy comes online, EVs get even cleaner over time!',
            likes: ['user456', 'user202'],
            createdAt: now.subtract(const Duration(hours: 5)),
            updatedAt: now.subtract(const Duration(hours: 5)),
          ),
          Reply(
            replyId: 'reply_2_1_4',
            userId: 'policy_wonk',
            content: 'The infrastructure improvements needed for widespread EV adoption are also creating jobs in clean energy sectors.',
            likes: ['tech_enthusiast_92'],
            createdAt: now.subtract(const Duration(hours: 3)),
            updatedAt: now.subtract(const Duration(hours: 3)),
          ),
        ];

      case 'comment_2_2': // Replies to climate researcher comment
        return [
          Reply(
            replyId: 'reply_2_2_1',
            userId: 'battery_tech_student',
            content: 'I\'m studying battery recycling in my engineering program. The new processes can recover over 95% of materials!',
            likes: ['climate_researcher', 'user303'],
            createdAt: now.subtract(const Duration(hours: 5, minutes: 30)),
            updatedAt: now.subtract(const Duration(hours: 5, minutes: 30)),
          ),
          Reply(
            replyId: 'reply_2_2_2',
            userId: 'materials_scientist',
            content: 'The solid-state batteries coming out in the next few years will be even better for recycling.',
            likes: ['user789', 'user101'],
            createdAt: now.subtract(const Duration(hours: 4)),
            updatedAt: now.subtract(const Duration(hours: 4)),
          ),
        ];

      case 'comment_2_3': // Replies to skeptical driver
        return [
          Reply(
            replyId: 'reply_2_3_1',
            userId: 'mining_geologist',
            content: 'Valid concern! However, most EV batteries use lithium, cobalt, and nickel - not rare earth elements. And mining practices are improving.',
            likes: ['climate_researcher', 'user456'],
            createdAt: now.subtract(const Duration(hours: 3, minutes: 30)),
            updatedAt: now.subtract(const Duration(hours: 3, minutes: 30)),
          ),
          Reply(
            replyId: 'reply_2_3_2',
            userId: 'supply_chain_expert',
            content: 'Companies like Tesla are working on supply chains that minimize environmental impact. It\'s not perfect but getting better.',
            likes: ['user789'],
            createdAt: now.subtract(const Duration(hours: 2, minutes: 45)),
            updatedAt: now.subtract(const Duration(hours: 2, minutes: 45)),
          ),
          Reply(
            replyId: 'reply_2_3_3',
            userId: 'comparative_analyst',
            content: 'Oil extraction and refining also have significant environmental costs that are often overlooked in these comparisons.',
            likes: ['tech_enthusiast_92', 'user202'],
            createdAt: now.subtract(const Duration(hours: 2)),
            updatedAt: now.subtract(const Duration(hours: 2)),
          ),
          Reply(
            replyId: 'reply_2_3_4',
            userId: 'economics_prof',
            content: 'The externalized costs of fossil fuels (health, climate damage) aren\'t reflected in gas prices, which skews the comparison.',
            likes: ['user101', 'user303'],
            createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
            updatedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          ),
          Reply(
            replyId: 'reply_2_3_5',
            userId: 'skeptical_driver',
            content: 'Thanks everyone for the thoughtful responses. I have some research to do!',
            likes: ['tech_enthusiast_92', 'climate_researcher'],
            createdAt: now.subtract(const Duration(minutes: 45)),
            updatedAt: now.subtract(const Duration(minutes: 45)),
          ),
        ];

      case 'comment_3_1': // Reply to recycling expert
        return [
          Reply(
            replyId: 'reply_3_1_1',
            userId: 'user789',
            content: 'Thanks! I checked and my local facility does accept #5 plastics. Much appreciated!',
            likes: ['recycling_expert'],
            createdAt: now.subtract(const Duration(minutes: 15)),
            updatedAt: now.subtract(const Duration(minutes: 15)),
          ),
        ];

      case 'comment_4_1': // Replies to inspired newbie
        return [
          Reply(
            replyId: 'reply_4_1_1',
            userId: 'user101',
            content: 'For me, the hardest part was finding alternatives to convenient packaged foods. Meal prep became essential!',
            likes: ['inspired_newbie', 'user456'],
            createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
            updatedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
          ),
          Reply(
            replyId: 'reply_4_1_2',
            userId: 'meal_prep_master',
            content: 'Batch cooking on Sundays was a game-changer for me! Glass containers are your best friend.',
            likes: ['user789', 'user202'],
            createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
            updatedAt: now.subtract(const Duration(hours: 1, minutes: 20)),
          ),
        ];

      case 'comment_4_2': // Reply to veteran zero waster
        return [
          Reply(
            replyId: 'reply_4_2_1',
            userId: 'user101',
            content: 'Thank you! It\'s so encouraging to hear from someone who\'s been doing this longer. Looking forward to month 2!',
            likes: ['veteran_zero_waster'],
            createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
            updatedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
          ),
        ];

      case 'comment_4_3': // Replies about zero waste with kids
        return [
          Reply(
            replyId: 'reply_4_3_1',
            userId: 'user101',
            content: 'Kids were definitely a challenge! I started by getting them their own reusable water bottles and lunch containers. Making it "their special thing" helped a lot.',
            likes: ['practical_parent', 'user456'],
            createdAt: now.subtract(const Duration(minutes: 35)),
            updatedAt: now.subtract(const Duration(minutes: 35)),
          ),
          Reply(
            replyId: 'reply_4_3_2',
            userId: 'environmental_teacher',
            content: 'Try involving them in the process! Kids love helping make bulk snacks and learning about waste reduction.',
            likes: ['user505', 'user202'],
            createdAt: now.subtract(const Duration(minutes: 25)),
            updatedAt: now.subtract(const Duration(minutes: 25)),
          ),
          Reply(
            replyId: 'reply_4_3_3',
            userId: 'crafty_parent',
            content: 'We turned it into craft projects! Decorating reusable containers and making their own snack bags from fabric.',
            likes: ['practical_parent', 'user789'],
            createdAt: now.subtract(const Duration(minutes: 20)),
            updatedAt: now.subtract(const Duration(minutes: 20)),
          ),
        ];

      case 'comment_5_1': // Reply to chemical-free home
        return [
          Reply(
            replyId: 'reply_5_1_1',
            userId: 'user202',
            content: 'What essential oils do you add for scent? I\'m always looking for new combinations!',
            likes: ['chemical_free_home'],
            createdAt: now.subtract(const Duration(days: 1, hours: 20)),
            updatedAt: now.subtract(const Duration(days: 1, hours: 20)),
          ),
        ];

      case 'comment_5_2': // Replies about cost savings
        return [
          Reply(
            replyId: 'reply_5_2_1',
            userId: 'user202',
            content: 'Wow, \$200 is amazing! I need to track my savings better. Do you have a spreadsheet or something?',
            likes: ['budget_conscious_mom'],
            createdAt: now.subtract(const Duration(hours: 18)),
            updatedAt: now.subtract(const Duration(hours: 18)),
          ),
          Reply(
            replyId: 'reply_5_2_2',
            userId: 'frugal_living_expert',
            content: 'I\'ve saved even more by buying ingredients in bulk! Costco has great prices on white vinegar and baking soda.',
            likes: ['user303', 'user505'],
            createdAt: now.subtract(const Duration(hours: 12)),
            updatedAt: now.subtract(const Duration(hours: 12)),
          ),
        ];

      default:
        return [];
    }
  }

  /// Toggle community enabled/disabled status
  void togglePostStatus() {
    try {
      // Create updated community with new status
      final updatedPost = PostModel(
        postId: currentPost.value.postId,
        userId: currentPost.value.userId,
        postType: currentPost.value.postType,
        content: currentPost.value.content,
        media: currentPost.value.media,
        likes: currentPost.value.likes,
        commentCount: currentPost.value.commentCount,
        createdAt: currentPost.value.createdAt,
        updatedAt: DateTime.now(),
        isDisabled: !currentPost.value.isDisabled,
        comments: currentPost.value.comments,
      );

      currentPost.value = updatedPost;

      // Show success message
      Get.snackbar(
        'Success',
        'Post ${updatedPost.isDisabled ? 'disabled' : 'enabled'} successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: updatedPost.isDisabled
            ? FColors.adminLightError.withOpacity(0.1)
            : FColors.adminLightSuccess.withOpacity(0.1),
        colorText: updatedPost.isDisabled
            ? FColors.adminLightError
            : FColors.adminLightSuccess,
        duration: const Duration(seconds: 3),
      );

      // TODO: Make API call to update community status in backend
      // await PostRepository.updatePostStatus(updatedPost.postId, updatedPost.isDisabled);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update community status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FColors.error.withOpacity(0.1),
        colorText: FColors.error,
      );
    }
  }

  /// Toggle comments section expanded/collapsed
  void toggleCommentsExpanded() {
    isCommentsExpanded.value = !isCommentsExpanded.value;
  }

  /// Refresh community and comments data
  Future<void> refreshData() async {
    isLoading.value = true;

    try {
      // TODO: Reload community data from API
      // final updatedPost = await PostRepository.getPost(currentPost.value.postId);
      // currentPost.value = updatedPost;

      // Reload comments
      loadComments();

      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FColors.primary.withOpacity(0.1),
        colorText: FColors.primary,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: FColors.error.withOpacity(0.1),
        colorText: FColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get community engagement statistics
  Map<String, dynamic> get postStats {
    return {
      'likes': currentPost.value.likes.length,
      'comments': comments.length,
      'replies': comments.fold<int>(0, (sum, comment) => sum + comment.replies.length),
      'totalEngagement': currentPost.value.likes.length +
          comments.length +
          comments.fold<int>(0, (sum, comment) => sum + comment.replies.length),
    };
  }

  /// Get most liked comment
  Comment? get mostLikedComment {
    if (comments.isEmpty) return null;

    return comments.reduce((current, next) =>
    current.likes.length > next.likes.length ? current : next);
  }

  /// Get most active commenter
  String? get mostActiveCommenter {
    if (comments.isEmpty) return null;

    final Map<String, int> userActivity = {};

    // Count comments
    for (final comment in comments) {
      userActivity[comment.userId] = (userActivity[comment.userId] ?? 0) + 1;

      // Count replies
      for (final reply in comment.replies) {
        userActivity[reply.userId] = (userActivity[reply.userId] ?? 0) + 1;
      }
    }

    if (userActivity.isEmpty) return null;

    return userActivity.entries
        .reduce((current, next) => current.value > next.value ? current : next)
        .key;
  }

  /// Check if community has media content
  bool get hasMediaContent => currentPost.value.media.isNotEmpty;

  /// Get media count by type
  Map<String, int> get mediaStats {
    final Map<String, int> stats = {'images': 0, 'videos': 0};

    for (final mediaUrl in currentPost.value.media) {
      if (_isImageUrl(mediaUrl)) {
        stats['images'] = (stats['images'] ?? 0) + 1;
      } else {
        stats['videos'] = (stats['videos'] ?? 0) + 1;
      }
    }

    return stats;
  }

  bool _isImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}