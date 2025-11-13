import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/models/user_model.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/popups/loaders.dart';

class LeaderboardController extends GetxController {
  static LeaderboardController get instance => Get.find();

  // 依赖注入
  final UserRepository _userRepository = UserRepository.instance;
  final AuthenticationRepository _authRepo = AuthenticationRepository.instance;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedTab = 'monthly'.obs;
  final RxList<UserModel> monthlyTopUsers = <UserModel>[].obs;
  final RxList<UserModel> allTimeTopUsers = <UserModel>[].obs;
  final Rx<UserModel> currentUser = UserModel.empty().obs;

  // Page controller for swipe gesture
  late PageController pageController;

  // Track loading states
  final RxBool _monthlyLoaded = false.obs;
  final RxBool _allTimeLoaded = false.obs;
  final RxBool _currentUserLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);

    // 使用微任务延迟初始化，确保widget树构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLeaderboard();
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Initialize leaderboard with real-time updates
  void _initializeLeaderboard() async {
    // 显示loading对话框
    // _showLoadingDialog();
    isLoading.value = true;

    // 重置加载状态
    _monthlyLoaded.value = false;
    _allTimeLoaded.value = false;
    _currentUserLoaded.value = false;

    // 使用 UserRepository 监听数据（现在UserRepository会直接返回包含头像URL的数据）
    _setupMonthlyLeaderboardListener();
    _setupAllTimeLeaderboardListener();
    _setupCurrentUserListener();
  }

  /// 显示loading对话框
  void _showLoadingDialog() {
    if (Get.overlayContext != null) {
      FLoaders.showLoading('Loading leaderboard...');
    } else {
      // 如果上下文不可用，稍后重试
      Future.delayed(const Duration(milliseconds: 100), () {
        _showLoadingDialog();
      });
    }
  }

  /// 设置月度排行榜监听 - UserRepository现在会直接返回包含头像URL的数据
  void _setupMonthlyLeaderboardListener() {
    _userRepository.getMonthlyLeaderboardUsersStream().listen((users) {
      // 不再需要单独加载头像，UserRepository已经处理了
      monthlyTopUsers.value = users;
      _monthlyLoaded.value = true;
      _checkAllDataLoaded();
    }, onError: (error) {
      print('Error loading monthly leaderboard: $error');
      _monthlyLoaded.value = true; // 即使出错也标记为已加载
      _checkAllDataLoaded();
    });
  }

  /// 设置总排行榜监听 - UserRepository现在会直接返回包含头像URL的数据
  void _setupAllTimeLeaderboardListener() {
    _userRepository.getAllTimeLeaderboardUsersStream().listen((users) {
      // 不再需要单独加载头像，UserRepository已经处理了
      allTimeTopUsers.value = users;
      _allTimeLoaded.value = true;
      _checkAllDataLoaded();
    }, onError: (error) {
      print('Error loading all-time leaderboard: $error');
      _allTimeLoaded.value = true; // 即使出错也标记为已加载
      _checkAllDataLoaded();
    });
  }

  /// 设置当前用户监听 - UserRepository现在会直接返回包含头像URL的数据
  void _setupCurrentUserListener() {
    final userId = _authRepo.authUser?.uid;
    if (userId != null) {
      _userRepository.getCurrentUserStream(userId).listen((user) {
        // 不再需要单独加载头像，UserRepository已经处理了
        currentUser.value = user;
        _currentUserLoaded.value = true;
        _checkAllDataLoaded();
      }, onError: (error) {
        print('Error loading current user: $error');
        _currentUserLoaded.value = true; // 即使出错也标记为已加载
        _checkAllDataLoaded();
      });
    } else {
      _currentUserLoaded.value = true;
      _checkAllDataLoaded();
    }
  }

  /// 检查所有数据是否已加载完成
  void _checkAllDataLoaded() {
    if (_monthlyLoaded.value && _allTimeLoaded.value && _currentUserLoaded.value) {
      isLoading.value = false;

      // 延迟关闭loading对话框，确保状态已更新
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.overlayContext != null) {
          FLoaders.stopLoading();
        }
      });
    }
  }

  /// 获取头像URL - 使用UserRepository的公共方法
  String? getProfileImageUrl(String? fileName) {
    return _userRepository.getCachedProfileImageUrl(fileName);
  }

  /// Switch between monthly and all-time tabs
  void switchTab(String tab) {
    selectedTab.value = tab;
  }

  /// Get current leaderboard based on selected tab
  List<UserModel> get currentLeaderboard {
    return selectedTab.value == 'monthly' ? monthlyTopUsers : allTimeTopUsers;
  }

  /// Get top 20 users (with placeholders if needed) - 修复这里
  List<UserModel> get top20Users {
    final users = List<UserModel>.from(currentLeaderboard);

    // 确保至少有20个用户（用占位符填充）
    while (users.length < 20) {
      users.add(_createPlaceholderUser());
    }

    // 确保不超过20个用户
    return users.take(20).toList();
  }

  /// Get top 3 users for podium display (with placeholders)
  List<UserModel> get topThree {
    final users = List<UserModel>.from(currentLeaderboard);

    // Fill with placeholders if needed
    while (users.length < 3) {
      users.add(_createPlaceholderUser());
    }

    // Return in display order: 2nd, 1st, 3rd
    return [users[1], users[0], users[2]];
  }

  /// Create a placeholder user
  UserModel _createPlaceholderUser() {
    return UserModel(
      userId: 'placeholder_${DateTime.now().millisecondsSinceEpoch}',
      username: '---',
      email: '---',
      role: 'placeholder',
      isVerified: false,
      isActive: false,
      loginAttemptCount: 0,
      joinDate: DateTime.now(),
      rewardPoint: 0,
      monthlyRewardPoint: 0,
      totalRewardPoint: 0,
    );
  }

  /// Check if user is a placeholder
  bool isPlaceholder(UserModel user) {
    return user.role == 'placeholder';
  }

  /// Get current user rank
  int get currentUserRank {
    final users = currentLeaderboard;
    final index = users.indexWhere((user) => user.userId == currentUser.value.userId);
    return index >= 0 ? index + 1 : 0; // Return 0 if not in top 20
  }

  /// Get points for user based on current tab
  int getPoints(UserModel user) {
    if (isPlaceholder(user)) return 0;

    return selectedTab.value == 'monthly'
        ? user.monthlyRewardPoint
        : user.totalRewardPoint;
  }

  /// Check if leaderboard has data (at least one real user)
  bool get hasData {
    return currentLeaderboard.isNotEmpty && currentLeaderboard.any((user) => !isPlaceholder(user));
  }

  /// Check if user is in top 20
  bool get isUserInTop20 {
    return currentUserRank > 0 && currentUserRank <= 20;
  }

  /// 手动刷新排行榜数据
  Future<void> refreshLeaderboard() async {
    isLoading.value = true;

    // 重置加载状态
    _monthlyLoaded.value = false;
    _allTimeLoaded.value = false;
    _currentUserLoaded.value = false;

    // 重新初始化
    _initializeLeaderboard();
  }
}