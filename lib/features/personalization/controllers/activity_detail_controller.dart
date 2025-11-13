import 'package:get/get.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/recycling_center/models/waste_category_model.dart';
import 'package:fyp/features/recycling_center/models/partner_recycling_center_model.dart';
import 'package:fyp/data/repositories/recycling_center/recycling_center_repository.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../data/repositories/personalization/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/repositories/recycling_center/recycling_center_staff_repository.dart';
import '../../recycling_center/models/recycling_center_staff_model.dart';

class ActivityDetailController extends GetxController {
  final Rx<RecyclingActivity?> activity = Rx<RecyclingActivity?>(null);
  final Rx<WasteCategory?> wasteCategory = Rx<WasteCategory?>(null);
  final Rx<PartnerRecyclingCenter?> recyclingCenter = Rx<PartnerRecyclingCenter?>(null);
  final Rx<RecyclingCenterStaff?> staffUser = Rx<RecyclingCenterStaff?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isDeleting = false.obs;

  // Repositories
  final _activityRepo = Get.put(RecyclingActivityRepository());
  final _categoryRepo = Get.put(WasteCategoryRepository());
  final _centerRepo = Get.put(RecyclingCenterRepository());
  final _userRepo = Get.put(UserRepository());
  final _staffRepo = Get.put(RecyclingCenterStaffRepository());

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as RecyclingActivity?;
    if (args != null) {
      activity.value = args;
      _loadActivityData();
    } else {
      isLoading.value = false;
    }
  }

  /// Load all activity related data
  Future<void> _loadActivityData() async {
    if (activity.value == null) return;

    try {
      isLoading.value = true;

      // Load all data in parallel for better performance
      await Future.wait([
        _loadWasteCategory(),
        _loadRecyclingCenter(),
        _loadStaffUser(),
      ]);

      // 检查数据是否成功加载
      print('=== Activity Data Load Status ===');
      print('Waste Category: ${wasteCategory.value != null ? "Loaded" : "Failed"}');
      print('Recycling Center: ${recyclingCenter.value != null ? "Loaded" : "Failed"}');
      print('Staff User: ${staffUser.value != null ? "Loaded" : "Failed"}');
      print('Activity ID: ${activity.value?.activityId}');
      print('Center Staff ID: ${activity.value?.centerStaffId}');
      print('Waste Category ID: ${activity.value?.wasteCategoryId}');
      print('center image: ${recyclingCenter.value?.image}');

    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load activity data: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load waste category
  Future<void> _loadWasteCategory() async {
    if (activity.value == null) return;

    try {
      final category = await _categoryRepo.getCategoryById(activity.value!.wasteCategoryId);
      wasteCategory.value = category;
      print('✅ Waste category loaded: ${category?.name}');
    } catch (e) {
      print('❌ Failed to load waste category: $e');
      wasteCategory.value = null;
    }
  }

  /// Load recycling center
  Future<void> _loadRecyclingCenter() async {
    if (activity.value == null) return;

    try {
      final center = await _centerRepo.getCenterByStaffId(activity.value!.centerStaffId);
      recyclingCenter.value = center;
      print('✅ Recycling center loaded: ${center?.name}');
    } catch (e) {
      print('❌ Failed to load recycling center: $e');
      recyclingCenter.value = null;
    }
  }

  /// Load staff user information using RecyclingCenterStaffRepository
  Future<void> _loadStaffUser() async {
    if (activity.value == null) return;

    try {
      print('🔄 Loading staff user with ID: ${activity.value!.centerStaffId}');

      // 使用 RecyclingCenterStaffRepository 获取员工数据
      final staff = await _staffRepo.getStaffById(activity.value!.centerStaffId);

      if (staff != null && staff.userId.isNotEmpty) {
        staffUser.value = staff;
        print('✅ Staff user loaded successfully: ${staff.username}');
        print('Staff details - Email: ${staff.email}, Center ID: ${staff.centerId}');
      } else {
        print('❌ Staff user data is empty or invalid');
        staffUser.value = null;

        // 如果无法获取员工数据，尝试使用普通用户数据作为备选
        await _loadStaffUserFallback();
      }
    } catch (e) {
      print('❌ Failed to load staff user: $e');
      staffUser.value = null;

      // 如果主要方法失败，尝试备选方法
      await _loadStaffUserFallback();
    }
  }

  /// Fallback method to load staff user using UserRepository
  Future<void> _loadStaffUserFallback() async {
    try {
      print('🔄 Trying fallback method to load staff user...');
      final user = await _userRepo.fetchOtherUserDetails(activity.value!.centerStaffId);

      if (user.userId.isNotEmpty) {
        // 创建基本的 RecyclingCenterStaff 使用用户数据
        staffUser.value = RecyclingCenterStaff(
          userId: user.userId,
          username: user.username,
          email: user.email,
          phoneNo: user.phoneNo ?? '',
          profileImg: user.profileImg ?? '',
          loginAttemptCount: user.loginAttemptCount ?? 0,
          role: user.role,
          isVerified: user.isVerified ?? false,
          isActive: user.isActive ?? true,
          lastFailedLogin: user.lastFailedLogin,
          centerId: '', // 无法从用户数据获取
          joinDate: user.joinDate ?? DateTime.now(),
        );
        print('✅ Fallback staff user loaded: ${user.username}');
      } else {
        print('❌ Fallback method also failed - user data is empty');
      }
    } catch (e) {
      print('❌ Fallback method failed: $e');
    }
  }

  /// Get waste category
  WasteCategory? getWasteCategory() {
    return wasteCategory.value;
  }

  /// Get activity age text
  String get activityAgeText {
    if (activity.value == null) return '';

    final age = activity.value!.ageInHours;
    if (age < 1) {
      return 'Less than an hour ago';
    } else if (age < 24) {
      return '$age hour${age > 1 ? 's' : ''} ago';
    } else {
      final days = (age / 24).floor();
      return '$days day${days > 1 ? 's' : ''} ago';
    }
  }

  /// Delete activity
  Future<void> deleteActivity() async {
    if (activity.value == null || !activity.value!.canDelete) return;

    try {
      isDeleting.value = true;

      await _activityRepo.deleteActivity(activity.value!.activityId);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Activity deleted successfully',
      );

      Get.back(result: true);
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity: ${e.toString()}',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  /// Check if all data is loaded
  bool get isDataLoaded {
    return wasteCategory.value != null &&
        recyclingCenter.value != null &&
        staffUser.value != null;
  }

  /// Get loading status for debugging
  void printLoadingStatus() {
    print('=== Current Loading Status ===');
    print('isLoading: ${isLoading.value}');
    print('Activity: ${activity.value != null ? "Loaded" : "Null"}');
    print('Waste Category: ${wasteCategory.value != null ? "Loaded" : "Null"}');
    print('Recycling Center: ${recyclingCenter.value != null ? "Loaded" : "Null"}');
    print('Staff User: ${staffUser.value != null ? "Loaded" : "Null"}');
    print('center image: ${recyclingCenter.value?.image}');
    print('==============================');
  }
}