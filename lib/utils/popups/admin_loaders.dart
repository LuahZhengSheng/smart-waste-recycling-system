import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class FAdminLoaders {
  static hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _isDark()
                ? FColors.adminDarkSurface
                : FColors.adminLightSurface,
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color:
                    _isDark() ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static successSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor:
          _isDark() ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.check, color: Colors.white),
    );
  }

  static warningSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor:
          _isDark() ? FColors.adminDarkWarning : FColors.adminLightWarning,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.warning_2, color: Colors.white),
    );
  }

  static errorSnackBar({required title, message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor:
          _isDark() ? FColors.adminDarkError : FColors.adminLightError,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Iconsax.danger, color: Colors.white),
    );
  }

  /// Show loading dialog
  static void loadingDialog() {
    final dark = _isDark();

    Get.dialog(
      PopScope(
        canPop: false, // 防止用户按返回键关闭
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show loading dialog with custom message
  static void loadingDialogWithMessage(String message) {
    final dark = _isDark();

    Get.dialog(
      PopScope(
        canPop: false,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(FSizes.lg),
              decoration: BoxDecoration(
                color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
                borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  ),
                  const SizedBox(height: FSizes.md),
                  Text(
                    message,
                    style: TextStyle(
                      color: dark ? FColors.adminDarkText : FColors.adminLightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Close loading dialog
  static void closeLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// 显示更新确认对话框
  ///
  /// [title] - 对话框标题
  /// [message] - 对话框描述信息
  /// [changedFields] - 已更改的字段列表
  /// [onConfirm] - 确认回调函数
  /// [confirmButtonText] - 确认按钮文本，默认为 'Update'
  /// [cancelButtonText] - 取消按钮文本，默认为 'Cancel'
  /// [icon] - 自定义图标，默认为编辑图标
  static void showUpdateConfirmationDialog({
    required String title,
    required String message,
    required List<String> changedFields,
    required VoidCallback onConfirm,
    String confirmButtonText = 'Update',
    String cancelButtonText = 'Cancel',
    IconData icon = Iconsax.edit,
  }) {
    final dark = _isDark();

    Get.dialog(
      Dialog(
        backgroundColor:
            dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 400, // 适合 Web 的最小宽度
            maxWidth: 600, // 适合 Web 的最大宽度
            minHeight: 300, // 适合 Web 的最小高度
            maxHeight: 700, // 适合 Web 的最大高度
          ),
          child: Padding(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: dark
                        ? FColors.adminDarkPrimary
                        : FColors.adminLightPrimary,
                  ),
                ),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FSizes.sm),

                // Message
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: dark
                            ? FColors.adminDarkTextSecondary
                            : FColors.adminLightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: FSizes.spaceBtwItems),

                // Changed fields summary (only show if there are changes)
                if (changedFields.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark
                          ? FColors.adminDarkSurfaceVariant
                          : FColors.adminLightSurfaceVariant,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Changes detected:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: dark
                                ? FColors.adminDarkText
                                : FColors.adminLightText,
                          ),
                        ),
                        const SizedBox(height: FSizes.sm),
                        ...changedFields.map((field) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.tick_circle,
                                    size: 16,
                                    color: dark
                                        ? FColors.adminDarkSuccess
                                        : FColors.adminLightSuccess,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      field,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: dark
                                            ? FColors.adminDarkTextSecondary
                                            : FColors.adminLightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                ],

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: dark
                                ? FColors.adminDarkBorder
                                : FColors.adminLightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: FSizes.md),
                        ),
                        child: Text(
                          cancelButtonText,
                          style: TextStyle(
                            color: dark
                                ? FColors.adminDarkTextSecondary
                                : FColors.adminLightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dark
                              ? FColors.adminDarkPrimary
                              : FColors.adminLightPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(FSizes.cardRadiusMd),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: FSizes.md),
                        ),
                        child: Text(
                          confirmButtonText,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showRewardUpdateDialog({
    required List<String> changedFields,
    required VoidCallback onConfirm,
  }) {
    showUpdateConfirmationDialog(
      title: 'Update Reward?',
      message:
      'Are you sure you want to save the changes to this reward? This action will update all reward information.',
      changedFields: changedFields,
      onConfirm: onConfirm,
      confirmButtonText: 'Update',
      cancelButtonText: 'Cancel',
      icon: Iconsax.edit,
    );
  }

  /// 专门用于回收中心更新的确认对话框
  static void showRecyclingCenterUpdateDialog({
    required List<String> changedFields,
    required VoidCallback onConfirm,
  }) {
    showUpdateConfirmationDialog(
      title: 'Update Recycling Center?',
      message:
          'Are you sure you want to save the changes to this recycling center? This action will update all center information.',
      changedFields: changedFields,
      onConfirm: onConfirm,
      confirmButtonText: 'Update',
      cancelButtonText: 'Cancel',
      icon: Iconsax.edit,
    );
  }

  /// 通用删除确认对话框
  static void showDeleteConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String itemName = '',
  }) {
    showUpdateConfirmationDialog(
      title: title,
      message: message,
      changedFields: const [], // 删除操作不需要显示更改字段
      onConfirm: onConfirm,
      confirmButtonText: 'Delete',
      cancelButtonText: 'Cancel',
      icon: Iconsax.trash,
    );
  }

  /// 通用保存确认对话框
  static void showSaveConfirmationDialog({
    required List<String> changedFields,
    required VoidCallback onConfirm,
    String itemType = 'item',
  }) {
    showUpdateConfirmationDialog(
      title: 'Save Changes?',
      message: 'Are you sure you want to save the changes to this $itemType?',
      changedFields: changedFields,
      onConfirm: onConfirm,
      confirmButtonText: 'Save',
      cancelButtonText: 'Cancel',
      icon: Iconsax.save_2,
    );
  }

  /// 显示禁用/恢复确认对话框（社区帖子样式）
  ///
  /// [title] - 对话框标题
  /// [message] - 对话框描述信息
  /// [confirmButtonText] - 确认按钮文本
  /// [onConfirm] - 确认回调函数
  /// [isDisableAction] - 是否为禁用操作（true=禁用，false=恢复）
  /// [itemName] - 项目名称（用于个性化消息）
  static void showDisableRecoverConfirmationDialog({
    required String title,
    required String message,
    required String confirmButtonText,
    required VoidCallback onConfirm,
    required bool isDisableAction,
    String itemName = '',
  }) {
    final dark = _isDark();

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          title,
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisableAction
                  ? (dark ? FColors.adminDarkError : FColors.adminLightError)
                  : (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess),
            ),
            child: Text(
              confirmButtonText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 专门用于回收中心禁用/恢复的确认对话框
  static void showRecyclingCenterDisableRecoverDialog({
    required String centerName,
    required bool isDisabled,
    required VoidCallback onConfirm,
  }) {
    final isDisableAction = !isDisabled;

    showDisableRecoverConfirmationDialog(
      title: isDisableAction ? 'Disable Center' : 'Recover Center',
      message: isDisableAction
          ? 'Are you sure you want to disable "$centerName"? This will ban all associated staff members.'
          : 'Are you sure you want to recover "$centerName"? The center will be reactivated but staff accounts will remain banned.',
      confirmButtonText: isDisableAction ? 'Disable' : 'Recover',
      onConfirm: onConfirm,
      isDisableAction: isDisableAction,
      itemName: centerName,
    );
  }

  /// 专门用于社区帖子禁用/恢复的确认对话框
  static void showPostDisableRecoverDialog({
    required String postContent,
    required bool isDisabled,
    required VoidCallback onConfirm,
  }) {
    final isDisableAction = !isDisabled;

    showDisableRecoverConfirmationDialog(
      title: isDisableAction ? 'Disable Post' : 'Recover Post',
      message: isDisableAction
          ? 'Are you sure you want to disable this post? Users will no longer be able to see or interact with it.'
          : 'Are you sure you want to recover this post? Users will be able to see and interact with it again.',
      confirmButtonText: isDisableAction ? 'Disable' : 'Recover',
      onConfirm: onConfirm,
      isDisableAction: isDisableAction,
      itemName: postContent,
    );
  }

  /// 显示状态切换确认对话框（激活/停用）
  ///
  /// [title] - 对话框标题
  /// [message] - 对话框描述信息
  /// [confirmButtonText] - 确认按钮文本
  /// [onConfirm] - 确认回调函数
  /// [isActivating] - 是否为激活操作（true=激活，false=停用）
  /// [itemName] - 项目名称（用于个性化消息）
  static void showStatusToggleConfirmationDialog({
    required String title,
    required String message,
    required String confirmButtonText,
    required VoidCallback onConfirm,
    required bool isActivating,
    String itemName = '',
  }) {
    // 复用禁用/恢复对话框，因为功能和样式相同
    showDisableRecoverConfirmationDialog(
      title: title,
      message: message,
      confirmButtonText: confirmButtonText,
      onConfirm: onConfirm,
      isDisableAction: !isActivating, // 激活对应恢复，停用对应禁用
      itemName: itemName,
    );
  }

  /// 专门用于成就激活/停用的确认对话框
  static void showAchievementStatusToggleDialog({
    required String achievementTitle,
    required bool isActivating,
    required VoidCallback onConfirm,
  }) {
    showStatusToggleConfirmationDialog(
      title: isActivating ? 'Activate Achievement' : 'Deactivate Achievement',
      message: isActivating
          ? 'Are you sure you want to activate "$achievementTitle"? Users will be able to see and unlock this achievement.'
          : 'Are you sure you want to deactivate "$achievementTitle"? Users will no longer see this achievement, but their progress will be preserved.',
      confirmButtonText: isActivating ? 'Activate' : 'Deactivate',
      onConfirm: onConfirm,
      isActivating: isActivating,
      itemName: achievementTitle,
    );
  }

  /// 专门用于成就更新的确认对话框
  static void showAchievementUpdateDialog({
    required List<String> changedFields,
    required VoidCallback onConfirm,
  }) {
    showUpdateConfirmationDialog(
      title: 'Update Achievement?',
      message: 'Are you sure you want to save the changes to this achievement? This action will update all achievement levels and criteria.',
      changedFields: changedFields,
      onConfirm: onConfirm,
      confirmButtonText: 'Update',
      cancelButtonText: 'Cancel',
      icon: Iconsax.award,
    );
  }

  /// Show cancel event confirmation dialog
  static Future<bool> cancelEventDialog({
    required String eventTitle,
  }) async {
    final dark = Get.isDarkMode;

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Event',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel "$eventTitle"?',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              'Cancel all active registrations',
              dark,
            ),
            _buildBulletPoint(
              'Delete all event reminders',
              dark,
            ),
            _buildBulletPoint(
              'Send cancellation notifications to all registered users',
              dark,
            ),
            _buildBulletPoint(
              'Hide the event from users',
              dark,
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'No, Keep Event',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            child: const Text(
              'Yes, Cancel Event',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Helper method to build bullet points
  static Widget _buildBulletPoint(String text, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static bool _isDark() {
    return Get.isDarkMode;
  }
}
