import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/leaderboard_controller.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        backgroundColor: dark ? FColors.communityDarkBackground : FColors.white,
        title: const Text('Leaderboard'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: FColors.primary),
          );
        }

        return Column(
          children: [
            _buildTabIndicator(context, controller, dark),
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: controller.pageController,
                    onPageChanged: (index) {
                      controller.selectedTab.value = index == 0 ? 'monthly' : 'alltime';
                    },
                    children: [
                      _buildLeaderboardContent(context, controller, dark),
                      _buildLeaderboardContent(context, controller, dark),
                    ],
                  ),
                  if (controller.isUserInTop20)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildCurrentUserCard(context, controller, dark),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLeaderboardContent(BuildContext context, LeaderboardController controller, bool dark) {
    return Obx(() {
      if (!controller.hasData) {
        return _buildEmptyState(context, dark);
      }

      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: controller.isUserInTop20 ? 120 : FSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            const SizedBox(height: FSizes.spaceBtwSections),
            _buildPodium(context, controller, dark),
            const SizedBox(height: FSizes.spaceBtwSections),
            _buildUsersList(context, controller, dark), // 显示完整的20名用户
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.chart,
            size: 80,
            color: dark ? FColors.darkGrey : FColors.grey,
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            'No Rankings Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.black,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace * 2),
            child: Text(
              'Start recycling to earn points and appear on the leaderboard!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIndicator(BuildContext context, LeaderboardController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace, vertical: FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              'Monthly',
              controller.selectedTab.value == 'monthly',
                  () {
                controller.switchTab('monthly');
                controller.pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              dark,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              'All Time',
              controller.selectedTab.value == 'alltime',
                  () {
                controller.switchTab('alltime');
                controller.pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              dark,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, bool isSelected, VoidCallback onTap, bool dark) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? FColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? FColors.white
                : (dark ? FColors.textSecondary : FColors.darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, LeaderboardController controller, bool dark) {
    final topThree = controller.topThree;

    return Container(
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      child: Stack(
        children: [
          // Podium bases
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildPodiumBase(
                    height: 100,
                    rank: 2,
                    user: topThree[0],
                    points: controller.getPoints(topThree[0]),
                    dark: dark,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: _buildPodiumBase(
                    height: 140,
                    rank: 1,
                    user: topThree[1],
                    points: controller.getPoints(topThree[1]),
                    dark: dark,
                  ),
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: _buildPodiumBase(
                    height: 80,
                    rank: 3,
                    user: topThree[2],
                    points: controller.getPoints(topThree[2]),
                    dark: dark,
                  ),
                ),
              ],
            ),
          ),
          // User avatars and crowns
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPodiumUser(topThree[0], 2, 100, dark)),
                Expanded(child: _buildPodiumUser(topThree[1], 1, 0, dark)),
                Expanded(child: _buildPodiumUser(topThree[2], 3, 100, dark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumBase({
    required double height,
    required int rank,
    required UserModel user,
    required int points,
    required bool dark,
  }) {
    final gradient = rank == 1
        ? FColors.goldGradient
        : rank == 2
        ? FColors.silverGradient
        : FColors.bronzeGradient;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '#$rank',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatPoints(points),
            style: const TextStyle(
              fontSize: FSizes.fontSizeMd,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(UserModel user, int rank, double topPadding, bool dark) {
    final controller = Get.find<LeaderboardController>();
    final isPlaceholder = controller.isPlaceholder(user);
    final size = rank == 1 ? 100.0 : 80.0;
    final borderColor = rank == 1
        ? FColors.leaderboardGold
        : rank == 2
        ? FColors.leaderboardSilver
        : FColors.leaderboardBronze;

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          if (rank == 1 && !isPlaceholder)
            Container(
              margin: const EdgeInsets.only(bottom: FSizes.sm),
              padding: const EdgeInsets.all(FSizes.sm),
              decoration: BoxDecoration(
                gradient: FColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: FColors.leaderboardGold.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.crown_15,
                color: Colors.white,
                size: 32,
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isPlaceholder
                      ? (dark ? FColors.darkGrey : FColors.grey)
                      : borderColor,
                  width: 4
              ),
              boxShadow: isPlaceholder ? [] : [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: isPlaceholder
                  ? _buildDefaultAvatar('', size, isPlaceholder: true, dark: dark)
                  : _buildUserAvatar(user, size, controller),
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            isPlaceholder ? '---' : user.username,
            style: TextStyle(
              fontSize: rank == 1 ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isPlaceholder
                  ? (dark ? FColors.darkGrey : FColors.grey)
                  : (dark ? FColors.white : FColors.black),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user, double size, LeaderboardController controller) {
    final imageUrl = controller.getProfileImageUrl(user.profileImg);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.username, size),
      );
    }

    return _buildDefaultAvatar(user.username, size);
  }

  Widget _buildDefaultAvatar(String username, double size, {bool isPlaceholder = false, bool dark = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaceholder
            ? (dark ? FColors.darkGrey : FColors.grey)
            : FColors.primary,
      ),
      child: Center(
        child: Icon(
          Iconsax.user,
          size: size * 0.5,
          color: FColors.white,
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, LeaderboardController controller, bool dark) {
    final users = controller.top20Users;

    // 显示所有20名用户，从第4名开始（前3名已经在领奖台显示）
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
      itemCount: users.length - 3, // 显示第4名到第20名
      itemBuilder: (context, index) {
        final user = users[index + 3];
        final rank = index + 4;
        final points = controller.getPoints(user);
        return _buildUserCard(context, user, rank, points, dark);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, int rank, int points, bool dark) {
    final controller = Get.find<LeaderboardController>();
    final imageUrl = controller.getProfileImageUrl(user.profileImg);

    return Container(
      margin: const EdgeInsets.only(bottom: FSizes.md),
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: FSizes.fontSizeMd,
                  fontWeight: FontWeight.bold,
                  color: FColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: FColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildSmallAvatar(user.username),
              )
                  : _buildSmallAvatar(user.username),
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dark ? FColors.white : FColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.textSecondary : FColors.darkGrey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.xs,
            ),
            decoration: BoxDecoration(
              color: FColors.primary,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
            ),
            child: Text(
              _formatPoints(points),
              style: const TextStyle(
                fontSize: FSizes.fontSizeMd,
                fontWeight: FontWeight.bold,
                color: FColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard(BuildContext context, LeaderboardController controller, bool dark) {
    return Obx(() {
      final currentUser = controller.currentUser.value;
      final rank = controller.currentUserRank;
      final points = controller.getPoints(currentUser);
      final imageUrl = controller.getProfileImageUrl(currentUser.profileImg);

      return Container(
        margin: const EdgeInsets.all(FSizes.defaultSpace),
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: FColors.primary,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          boxShadow: [
            BoxShadow(
              color: FColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(FSizes.borderRadiusSm),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: FSizes.fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: FColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: FSizes.md),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: FColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildSmallAvatar(currentUser.username),
                )
                    : _buildSmallAvatar(currentUser.username),
              ),
            ),
            const SizedBox(width: FSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentUser.username,
                    style: const TextStyle(
                      fontSize: FSizes.fontSizeMd,
                      fontWeight: FontWeight.bold,
                      color: FColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your Ranking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatPoints(points),
                    style: const TextStyle(
                      fontSize: FSizes.fontSizeLg,
                      fontWeight: FontWeight.bold,
                      color: FColors.primary,
                    ),
                  ),
                  const Text(
                    'Points',
                    style: TextStyle(
                      fontSize: 10,
                      color: FColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSmallAvatar(String username) {
    return Container(
      decoration: const BoxDecoration(
        color: FColors.primary,
      ),
      child: const Center(
        child: Icon(
          Iconsax.user,
          size: 24,
          color: FColors.white,
        ),
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}