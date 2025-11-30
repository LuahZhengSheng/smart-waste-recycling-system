import 'package:get/get.dart';

import '../../../data/repositories/personalization/recycling_activity_repository.dart';
import '../../../data/repositories/recycling_center/recycling_center_repository.dart';
import '../../../data/repositories/recycling_center/waste_category_repository.dart';
import '../../../data/repositories/reward_redemption/redemption_repository.dart';
import '../../../data/repositories/reward_redemption/reward_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../recycling_center/models/recycle_activity_model.dart';
import '../../recycling_center/models/partner_recycling_center_model.dart';
import '../../recycling_center/models/recycling_center_staff_model.dart';
import '../../waste_classification/models/waste_category_model.dart';
import '../models/redemption_model.dart';
import '../models/reward_model.dart';

class TransactionDetailsController extends GetxController {
  static TransactionDetailsController get instance => Get.find();

  // Repositories
  final activityRepository = Get.put(RecyclingActivityRepository());
  final redemptionRepository = Get.put(RedemptionRepository());
  final rewardRepository = Get.put(RewardRepository());
  final centerRepository = Get.put(RecyclingCenterRepository());
  final userRepository = Get.put(UserRepository());
  final wasteCategoryRepository = Get.put(WasteCategoryRepository());

  // Observable variables
  final isLoading = false.obs;
  final transactionType = ''.obs;

  // Earning transaction data
  final Rx<RecyclingActivity?> activity = Rx<RecyclingActivity?>(null);
  final Rx<PartnerRecyclingCenter?> recyclingCenter = Rx<PartnerRecyclingCenter?>(null);
  final Rx<RecyclingCenterStaff?> staff = Rx<RecyclingCenterStaff?>(null);
  final Rx<WasteCategory?> wasteCategory = Rx<WasteCategory?>(null);

  // Spending transaction data
  final Rx<RedemptionModel?> redemption = Rx<RedemptionModel?>(null);
  final Rx<RewardModel?> reward = Rx<RewardModel?>(null);

  /// Load transaction details
  Future<void> loadTransactionDetails({
    required String transactionId,
    required String type,
  }) async {
    try {
      isLoading(true);
      transactionType.value = type;

      if (type == 'earning') {
        await _loadEarningTransactionDetails(transactionId);
      } else {
        await _loadSpendingTransactionDetails(transactionId);
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load transaction details: $e',
      );
    } finally {
      isLoading(false);
    }
  }

  /// Load earning transaction details
  Future<void> _loadEarningTransactionDetails(String activityId) async {
    try {
      // Get activity stream
      activityRepository.getActivityStream(activityId).listen((activityData) async {
        activity.value = activityData;

        if (activityData.activityId.isNotEmpty) {
          // Load waste category
          final category = await wasteCategoryRepository.getCategoryById(activityData.wasteCategoryId);
          wasteCategory.value = category;

          // Load recycling center
          final center = await centerRepository.getCenterByStaffId(activityData.centerStaffId);
          recyclingCenter.value = center;

          // Load staff details
          final staffDoc = await userRepository.fetchOtherUserDetails(activityData.centerStaffId);
          if (staffDoc.role == 'center_staff') {
            staff.value = RecyclingCenterStaff(
              userId: staffDoc.userId,
              username: staffDoc.username,
              email: staffDoc.email,
              role: staffDoc.role,
              isVerified: staffDoc.isVerified,
              isActive: staffDoc.isActive,
              isBanned: false,
              phoneNo: staffDoc.phoneNo,
              profileImg: staffDoc.profileImg,
              centerId: center?.centerId ?? '',
              joinDate: DateTime.now(),
            );
          }
        }
      });
    } catch (e) {
      throw 'Failed to load earning transaction: $e';
    }
  }

  /// Load spending transaction details
  Future<void> _loadSpendingTransactionDetails(String redemptionId) async {
    try {
      // Get redemption stream
      redemptionRepository.getRedemptionStream(redemptionId).listen((redemptionData) async {
        redemption.value = redemptionData;

        if (redemptionData.redemptionId.isNotEmpty) {
          // Get reward stream
          rewardRepository.getRewardStream(redemptionData.rewardId).listen((rewardData) {
            reward.value = rewardData;
          });
        }
      });
    } catch (e) {
      throw 'Failed to load spending transaction: $e';
    }
  }

  @override
  void onClose() {
    activity.value = null;
    redemption.value = null;
    reward.value = null;
    recyclingCenter.value = null;
    staff.value = null;
    wasteCategory.value = null;
    super.onClose();
  }
}