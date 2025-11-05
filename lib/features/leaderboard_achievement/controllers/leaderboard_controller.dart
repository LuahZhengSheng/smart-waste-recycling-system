import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/models/user_model.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';

class LeaderboardController extends GetxController {
  static LeaderboardController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _authRepo = AuthenticationRepository.instance;

  // Observable variables
  final RxBool isLoading = true.obs;
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
    _initializeLeaderboard();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Initialize leaderboard with real-time updates
  void _initializeLeaderboard() {
    // Listen to monthly leaderboard
    _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .where('monthlyRewardPoint', isGreaterThan: 0)
        .orderBy('monthlyRewardPoint', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      monthlyTopUsers.value = snapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();

      if (isLoading.value) {
        isLoading.value = false;
      }
    });

    // Listen to all-time leaderboard
    _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .where('totalRewardPoint', isGreaterThan: 0)
        .orderBy('totalRewardPoint', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      allTimeTopUsers.value = snapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();
    });

    // Listen to current user
    final userId = _authRepo.authUser?.uid;
    if (userId != null) {
      _db
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          currentUser.value = UserModel.fromSnapshot(snapshot);
        }
      });
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
    return currentLeaderboard;
  }

  /// Get top 3 users for podium display
  List<UserModel> get topThree {
    final users = currentLeaderboard;
    if (users.length < 3) return [];
    return [users[1], users[0], users[2]]; // 2nd, 1st, 3rd for display order
  }

  /// Get current user rank
  int get currentUserRank {
    final users = currentLeaderboard;
    final index = users.indexWhere((user) => user.userId == currentUser.value.userId);
    return index >= 0 ? index + 1 : 0; // Return 0 if not in top 20
  }

  /// Get points for user based on current tab
  int getPoints(UserModel user) {
    return selectedTab.value == 'monthly'
        ? user.monthlyRewardPoint
        : user.totalRewardPoint;
  }

  /// Check if leaderboard has data
  bool get hasData {
    return currentLeaderboard.isNotEmpty;
  }

  /// Check if user is in top 20
  bool get isUserInTop20 {
    return currentUserRank > 0 && currentUserRank <= 20;
  }
}