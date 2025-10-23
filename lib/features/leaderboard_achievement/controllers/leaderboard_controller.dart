import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/models/user_model.dart';

class LeaderboardController extends GetxController {
  static LeaderboardController get instance => Get.find();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedTab = 'monthly'.obs;
  final RxList<UserModel> monthlyTopUsers = <UserModel>[].obs;
  final RxList<UserModel> allTimeTopUsers = <UserModel>[].obs;
  final Rx<UserModel> currentUser = UserModel.empty().obs;

  // Page controller for swipe gesture
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    loadLeaderboardData();
    loadCurrentUser();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Load current user data
  Future<void> loadCurrentUser() async {
    // TODO: Get current user from authentication service
    // For now, using mock data (John Smith - rank 8)
    currentUser.value = _getCurrentUserMockData();
  }

  /// Load leaderboard data
  Future<void> loadLeaderboardData() async {
    try {
      isLoading.value = true;

      // TODO: Replace with Firestore queries
      await Future.delayed(const Duration(milliseconds: 500));

      monthlyTopUsers.value = _getMonthlyMockData();
      allTimeTopUsers.value = _getAllTimeMockData();
    } catch (e) {
      print('Error loading leaderboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch between monthly and all-time tabs
  void switchTab(String tab) {
    selectedTab.value = tab;
  }

  /// Get current leaderboard based on selected tab
  List<UserModel> get currentLeaderboard {
    return selectedTab.value == 'monthly' ? monthlyTopUsers : allTimeTopUsers;
  }

  /// Get top 20 users
  List<UserModel> get top20Users {
    final users = currentLeaderboard;
    return users.length > 20 ? users.sublist(0, 20) : users;
  }

  /// Get top 3 users for podium display
  List<UserModel> get topThree {
    final users = currentLeaderboard;
    if (users.length < 3) return [];
    return [users[1], users[0], users[2]]; // 2nd, 1st, 3rd for display order
  }

  /// Get remaining users (rank 4-20)
  List<UserModel> get remainingUsers {
    final users = top20Users;
    return users.length > 3 ? users.sublist(3) : [];
  }

  /// Get current user rank
  int get currentUserRank {
    final users = currentLeaderboard;
    final index = users.indexWhere((user) => user.userId == currentUser.value.userId);
    return index >= 0 ? index + 1 : 999; // Return 999 if not in top
  }

  /// Get points for user based on current tab
  int getPoints(UserModel user) {
    return selectedTab.value == 'monthly'
        ? user.monthlyRewardPoint
        : user.totalRewardPoint;
  }

  // Mock data for current user
  UserModel _getCurrentUserMockData() {
    return UserModel(
      userId: '8',
      username: 'John Smith',
      email: 'johnsmith@gmail.com',
      role: 'user',
      isVerified: true,
      isActive: true,
      loginAttemptCount: 0,
      profileImage: 'https://i.pravatar.cc/150?img=8',
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      monthlyRewardPoint: 1000,
      totalRewardPoint: 5000,
    );
  }

  // Mock data for monthly leaderboard
  List<UserModel> _getMonthlyMockData() {
    return [
      UserModel(
        userId: '1',
        username: 'B.Simmons',
        email: 'b.simmons@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=1',
        joinDate: DateTime.now().subtract(const Duration(days: 180)),
        monthlyRewardPoint: 90000,
        totalRewardPoint: 450000,
      ),
      UserModel(
        userId: '2',
        username: 'W.Warren',
        email: 'w.warren@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=2',
        joinDate: DateTime.now().subtract(const Duration(days: 200)),
        monthlyRewardPoint: 80000,
        totalRewardPoint: 380000,
      ),
      UserModel(
        userId: '3',
        username: 'J.Cooper',
        email: 'j.cooper@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=3',
        joinDate: DateTime.now().subtract(const Duration(days: 150)),
        monthlyRewardPoint: 70000,
        totalRewardPoint: 320000,
      ),
      UserModel(
        userId: '4',
        username: 'Jacob Jones',
        email: 'alma.lawson@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=4',
        joinDate: DateTime.now().subtract(const Duration(days: 120)),
        monthlyRewardPoint: 60000,
        totalRewardPoint: 280000,
      ),
      UserModel(
        userId: '5',
        username: 'Floyd Miles',
        email: 'tim.jennings@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=5',
        joinDate: DateTime.now().subtract(const Duration(days: 100)),
        monthlyRewardPoint: 50000,
        totalRewardPoint: 240000,
      ),
      UserModel(
        userId: '6',
        username: 'Jenny Wilson',
        email: 'kenzi.lawson@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=6',
        joinDate: DateTime.now().subtract(const Duration(days: 90)),
        monthlyRewardPoint: 40000,
        totalRewardPoint: 200000,
      ),
      UserModel(
        userId: '7',
        username: 'Cody Fisher',
        email: 'michelle.rivera@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=7',
        joinDate: DateTime.now().subtract(const Duration(days: 80)),
        monthlyRewardPoint: 30000,
        totalRewardPoint: 180000,
      ),
      UserModel(
        userId: '8',
        username: 'John Smith',
        email: 'johnsmith@gmail.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=8',
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        monthlyRewardPoint: 1000,
        totalRewardPoint: 5000,
      ),
      // Additional users to fill up to 20
      ...List.generate(12, (index) {
        return UserModel(
          userId: '${9 + index}',
          username: 'User ${9 + index}',
          email: 'user${9 + index}@example.com',
          role: 'user',
          isVerified: true,
          isActive: true,
          loginAttemptCount: 0,
          profileImage: 'https://i.pravatar.cc/150?img=${9 + index}',
          joinDate: DateTime.now().subtract(Duration(days: 30 + index)),
          monthlyRewardPoint: 900 - (index * 50),
          totalRewardPoint: 4500 - (index * 250),
        );
      }),
    ];
  }

  // Mock data for all-time leaderboard
  List<UserModel> _getAllTimeMockData() {
    return [
      UserModel(
        userId: '1',
        username: 'B.Simmons',
        email: 'b.simmons@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=1',
        joinDate: DateTime.now().subtract(const Duration(days: 180)),
        monthlyRewardPoint: 90000,
        totalRewardPoint: 450000,
      ),
      UserModel(
        userId: '2',
        username: 'W.Warren',
        email: 'w.warren@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=2',
        joinDate: DateTime.now().subtract(const Duration(days: 200)),
        monthlyRewardPoint: 80000,
        totalRewardPoint: 380000,
      ),
      UserModel(
        userId: '3',
        username: 'J.Cooper',
        email: 'j.cooper@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=3',
        joinDate: DateTime.now().subtract(const Duration(days: 150)),
        monthlyRewardPoint: 70000,
        totalRewardPoint: 320000,
      ),
      UserModel(
        userId: '4',
        username: 'Jacob Jones',
        email: 'alma.lawson@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=4',
        joinDate: DateTime.now().subtract(const Duration(days: 120)),
        monthlyRewardPoint: 60000,
        totalRewardPoint: 280000,
      ),
      UserModel(
        userId: '5',
        username: 'Floyd Miles',
        email: 'tim.jennings@example.com',
        role: 'user',
        isVerified: true,
        isActive: true,
        loginAttemptCount: 0,
        profileImage: 'https://i.pravatar.cc/150?img=5',
        joinDate: DateTime.now().subtract(const Duration(days: 100)),
        monthlyRewardPoint: 50000,
        totalRewardPoint: 240000,
      ),
      // Add more users as needed for all-time leaderboard
      ...List.generate(15, (index) {
        return UserModel(
          userId: '${6 + index}',
          username: 'AllTime User ${6 + index}',
          email: 'alltime${6 + index}@example.com',
          role: 'user',
          isVerified: true,
          isActive: true,
          loginAttemptCount: 0,
          profileImage: 'https://i.pravatar.cc/150?img=${6 + index}',
          joinDate: DateTime.now().subtract(Duration(days: 100 + index)),
          monthlyRewardPoint: 1000 + (index * 100),
          totalRewardPoint: 200000 - (index * 5000),
        );
      }),
    ];
  }

/// TODO: Replace mock data with Firestore queries
///
/// Future<void> loadMonthlyLeaderboard() async {
///   try {
///     isLoading.value = true;
///     final snapshot = await FirebaseFirestore.instance
///         .collection('users')
///         .where('Role', isEqualTo: 'user')
///         .orderBy('MonthlyRewardPoint', descending: true)
///         .limit(50)
///         .get();
///
///     monthlyTopUsers.value = snapshot.docs
///         .map((doc) => UserModel.fromSnapshot(doc))
///         .toList();
///   } catch (e) {
///     FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load leaderboard');
///   } finally {
///     isLoading.value = false;
///   }
/// }
///
/// Future<void> loadAllTimeLeaderboard() async {
///   try {
///     isLoading.value = true;
///     final snapshot = await FirebaseFirestore.instance
///         .collection('users')
///         .where('Role', isEqualTo: 'user')
///         .orderBy('TotalRewardPoint', descending: true)
///         .limit(50)
///         .get();
///
///     allTimeTopUsers.value = snapshot.docs
///         .map((doc) => UserModel.fromSnapshot(doc))
///         .toList();
///   } catch (e) {
///     FLoaders.errorSnackBar(title: 'Error', message: 'Failed to load leaderboard');
///   } finally {
///     isLoading.value = false;
///   }
/// }
///
/// Future<void> loadCurrentUser() async {
///   try {
///     // Get current user from authentication service
///     final userId = AuthenticationRepository.instance.authUser?.uid;
///     if (userId == null) return;
///
///     final snapshot = await FirebaseFirestore.instance
///         .collection('users')
///         .doc(userId)
///         .get();
///
///     currentUser.value = UserModel.fromSnapshot(snapshot);
///   } catch (e) {
///     print('Error loading current user: $e');
///   }
/// }
}