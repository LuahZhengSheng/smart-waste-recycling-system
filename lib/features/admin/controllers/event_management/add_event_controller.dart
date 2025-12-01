import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/repositories/event/event_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/admin_loaders.dart';
import '../../../event/models/event_model.dart';
import '../../../event/models/location_model.dart';

class AddEventController extends GetxController {
  static AddEventController get instance => Get.find();

  final EventRepository _eventRepository = Get.find();
  final _uuid = const Uuid();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController maxParticipantsController;
  late TextEditingController contactEmailController;
  late TextEditingController contactPhoneController;

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isCompressing = false.obs;
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedStartTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedEndTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> selectedRegistrationDeadlineDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedRegistrationDeadlineTime = Rx<TimeOfDay?>(null);
  final Rx<Location?> selectedLocation = Rx<Location?>(null);
  final RxnString selectedPosterPath = RxnString();
  final RxnString selectedPosterName = RxnString();
  final Rxn<Uint8List> selectedPosterBytes = Rxn<Uint8List>();

  // Image compression settings
  static const int imageQuality = 85;
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    maxParticipantsController = TextEditingController();
    contactEmailController = TextEditingController();
    contactPhoneController = TextEditingController();
  }

  // Date and Time Selection Methods
  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedStartDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(), // ✅ 已经限制了，但还需要额外检查
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 🆕 检查是否选择了今天之前的日期（额外安全检查）
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(picked.year, picked.month, picked.day);

      if (selectedDay.isBefore(today)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'Event start date cannot be in the past',
        );
        return;
      }

      selectedStartDate.value = picked;

      if (selectedEndDate.value != null &&
          selectedEndDate.value!.isBefore(picked)) {
        selectedEndDate.value = picked;
        selectedEndTime.value = null;
      }

      _validateRegistrationDeadline();
      _validateEventDuration();
    }
  }

  Future<void> selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedStartTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 🆕 如果选择的是今天，检查时间是否在过去
      if (selectedStartDate.value != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final selectedDay = DateTime(
          selectedStartDate.value!.year,
          selectedStartDate.value!.month,
          selectedStartDate.value!.day,
        );

        // 如果选择的是今天
        if (selectedDay.isAtSameMomentAs(today)) {
          final selectedDateTime = DateTime(
            selectedStartDate.value!.year,
            selectedStartDate.value!.month,
            selectedStartDate.value!.day,
            picked.hour,
            picked.minute,
          );

          // 检查是否在过去
          if (selectedDateTime.isBefore(now)) {
            FAdminLoaders.errorSnackBar(
              title: 'Invalid Time',
              message: 'Event start time cannot be in the past',
            );
            return;
          }
        }
      }

      selectedStartTime.value = picked;
      _validateRegistrationDeadline();
      _validateEventDuration();
    }
  }

  Future<void> selectEndDate() async {
    DateTime initialDate;

    if (selectedEndDate.value != null) {
      initialDate = selectedEndDate.value!;
    } else if (selectedStartDate.value != null) {
      initialDate = selectedStartDate.value!;
    } else {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: selectedStartDate.value ?? DateTime.now(), // ✅ 限制最早日期
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 🆕 额外检查：确保不早于今天
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(picked.year, picked.month, picked.day);

      if (selectedDay.isBefore(today)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'Event end date cannot be in the past',
        );
        return;
      }

      // 检查是否早于开始日期
      if (selectedStartDate.value != null &&
          picked.isBefore(selectedStartDate.value!)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'End date cannot be before start date',
        );
        return;
      }

      selectedEndDate.value = picked;
      _validateEventDuration();
    }
  }

  Future<void> selectEndTime() async {
    if (selectedStartDate.value == null || selectedStartTime.value == null) {
      FAdminLoaders.warningSnackBar(
        title: 'Select Start Time First',
        message: 'Please select start date and time first',
      );
      return;
    }

    if (selectedEndDate.value == null) {
      FAdminLoaders.warningSnackBar(
        title: 'Select End Date First',
        message: 'Please select end date first',
      );
      return;
    }

    TimeOfDay initialTime;
    if (selectedEndTime.value != null) {
      initialTime = selectedEndTime.value!;
    } else {
      // 默认为开始时间 + 2小时
      initialTime = TimeOfDay(
        hour: (selectedStartTime.value!.hour + 2) % 24,
        minute: selectedStartTime.value!.minute,
      );
    }

    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final startDateTime = DateTime(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
        selectedStartTime.value!.hour,
        selectedStartTime.value!.minute,
      );

      final endDateTime = DateTime(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
        picked.hour,
        picked.minute,
      );

      // 🆕 如果结束日期是今天，检查时间是否在过去
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
      );

      if (selectedDay.isAtSameMomentAs(today)) {
        if (endDateTime.isBefore(now)) {
          FAdminLoaders.errorSnackBar(
            title: 'Invalid Time',
            message: 'Event end time cannot be in the past',
          );
          return;
        }
      }

      // 检查结束时间是否早于或等于开始时间
      if (endDateTime.isBefore(startDateTime) ||
          endDateTime.isAtSameMomentAs(startDateTime)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Time',
          message: 'End time must be after start time',
        );
        return;
      }

      // 🆕 检查活动时长是否至少1小时
      final duration = endDateTime.difference(startDateTime);
      if (duration.inHours < 1) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Duration',
          message: 'Event must last at least 1 hour',
        );
        return;
      }

      selectedEndTime.value = picked;
    }
  }

  Future<void> selectRegistrationDeadlineDate() async {
    // 计算合适的初始日期
    DateTime initialDate;
    if (selectedRegistrationDeadlineDate.value != null) {
      initialDate = selectedRegistrationDeadlineDate.value!;
    } else if (selectedStartDate.value != null) {
      // 默认设置为开始日期前3天
      initialDate = selectedStartDate.value!.subtract(const Duration(days: 3));
      // 确保不早于今天
      if (initialDate.isBefore(DateTime.now())) {
        initialDate = DateTime.now();
      }
    } else {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    // 计算合适的最后日期
    DateTime lastDate;
    if (selectedStartDate.value != null) {
      // 注册截止日期可以是开始日期当天（只要时间在开始时间之前）
      lastDate = selectedStartDate.value!;
    } else {
      lastDate = DateTime.now().add(const Duration(days: 365));
    }

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime.now(), // 从今天开始
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // 实时验证：如果已选择开始日期，注册截止日期不能晚于开始日期
      if (selectedStartDate.value != null && picked.isAfter(selectedStartDate.value!)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'Registration deadline must be on or before event start date',
        );
        return;
      }

      // 实时验证：注册截止日期不能是过去（考虑时间）
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(picked.year, picked.month, picked.day);

      if (selectedDay.isBefore(today)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'Registration deadline cannot be in the past',
        );
        return;
      }

      selectedRegistrationDeadlineDate.value = picked;

      // 如果选择了同一天作为开始日期，需要验证时间
      if (selectedStartDate.value != null &&
          selectedStartDate.value!.isAtSameMomentAs(picked) &&
          selectedStartTime.value != null &&
          selectedRegistrationDeadlineTime.value != null) {

        final registrationDeadline = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedRegistrationDeadlineTime.value!.hour,
          selectedRegistrationDeadlineTime.value!.minute,
        );

        final startDateTime = DateTime(
          selectedStartDate.value!.year,
          selectedStartDate.value!.month,
          selectedStartDate.value!.day,
          selectedStartTime.value!.hour,
          selectedStartTime.value!.minute,
        );

        // 如果注册截止时间不满足在开始时间之前，重置时间
        if (!registrationDeadline.isBefore(startDateTime)) {
          selectedRegistrationDeadlineTime.value = null;
          FAdminLoaders.warningSnackBar(
            title: 'Time Reset',
            message: 'Please select a registration deadline time before start time',
          );
        }
      }
    }
  }

  Future<void> selectRegistrationDeadlineTime() async {
    // 必须先选择注册截止日期
    if (selectedRegistrationDeadlineDate.value == null) {
      FAdminLoaders.warningSnackBar(
        title: 'Select Date First',
        message: 'Please select registration deadline date first',
      );
      return;
    }

    TimeOfDay initialTime;
    if (selectedRegistrationDeadlineTime.value != null) {
      initialTime = selectedRegistrationDeadlineTime.value!;
    } else if (selectedStartDate.value != null &&
        selectedStartTime.value != null &&
        selectedRegistrationDeadlineDate.value!.isAtSameMomentAs(selectedStartDate.value!)) {
      // 如果是同一天，默认设置为开始时间前1小时
      initialTime = TimeOfDay(
        hour: (selectedStartTime.value!.hour - 1) % 24,
        minute: selectedStartTime.value!.minute,
      );
    } else {
      initialTime = const TimeOfDay(hour: 23, minute: 59);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: FHelperFunctions.isDarkMode(context)
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final registrationDeadline = DateTime(
        selectedRegistrationDeadlineDate.value!.year,
        selectedRegistrationDeadlineDate.value!.month,
        selectedRegistrationDeadlineDate.value!.day,
        picked.hour,
        picked.minute,
      );

      // 实时验证：注册截止时间不能是过去
      if (registrationDeadline.isBefore(DateTime.now())) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Time',
          message: 'Registration deadline cannot be in the past',
        );
        return;
      }

      // 如果已选择开始时间，检查注册截止时间是否在开始时间之前
      if (selectedStartDate.value != null && selectedStartTime.value != null) {
        final startDateTime = DateTime(
          selectedStartDate.value!.year,
          selectedStartDate.value!.month,
          selectedStartDate.value!.day,
          selectedStartTime.value!.hour,
          selectedStartTime.value!.minute,
        );

        // 注册截止时间必须在开始时间之前
        if (!registrationDeadline.isBefore(startDateTime)) {
          FAdminLoaders.errorSnackBar(
            title: 'Invalid Time',
            message: 'Registration deadline must be before event start time',
          );
          return;
        }
      }

      selectedRegistrationDeadlineTime.value = picked;
    }
  }

  // 添加验证方法用于UI显示
  bool isEndTimeValid() {
    if (selectedStartDate.value == null ||
        selectedStartTime.value == null ||
        selectedEndDate.value == null ||
        selectedEndTime.value == null) {
      return true;
    }

    final startDateTime = DateTime(
      selectedStartDate.value!.year,
      selectedStartDate.value!.month,
      selectedStartDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    final endDateTime = DateTime(
      selectedEndDate.value!.year,
      selectedEndDate.value!.month,
      selectedEndDate.value!.day,
      selectedEndTime.value!.hour,
      selectedEndTime.value!.minute,
    );

    return endDateTime.isAfter(startDateTime) &&
        endDateTime.difference(startDateTime).inHours >= 1;
  }

  bool isRegistrationDeadlineValid() {
    if (selectedRegistrationDeadlineDate.value == null ||
        selectedRegistrationDeadlineTime.value == null ||
        selectedStartDate.value == null ||
        selectedStartTime.value != null) {
      return true;
    }

    final registrationDeadline = DateTime(
      selectedRegistrationDeadlineDate.value!.year,
      selectedRegistrationDeadlineDate.value!.month,
      selectedRegistrationDeadlineDate.value!.day,
      selectedRegistrationDeadlineTime.value!.hour,
      selectedRegistrationDeadlineTime.value!.minute,
    );

    final startDateTime = DateTime(
      selectedStartDate.value!.year,
      selectedStartDate.value!.month,
      selectedStartDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    return registrationDeadline.isBefore(startDateTime) &&
        !registrationDeadline.isBefore(DateTime.now());
  }

  void _validateRegistrationDeadline() {
    if (selectedRegistrationDeadlineDate.value != null &&
        selectedRegistrationDeadlineTime.value != null &&
        selectedStartDate.value != null &&
        selectedStartTime.value != null) {

      final registrationDeadline = DateTime(
        selectedRegistrationDeadlineDate.value!.year,
        selectedRegistrationDeadlineDate.value!.month,
        selectedRegistrationDeadlineDate.value!.day,
        selectedRegistrationDeadlineTime.value!.hour,
        selectedRegistrationDeadlineTime.value!.minute,
      );

      final startDateTime = DateTime(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
        selectedStartTime.value!.hour,
        selectedStartTime.value!.minute,
      );

      // 如果注册截止时间在开始时间之后，显示错误并重置注册截止时间
      if (registrationDeadline.isAfter(startDateTime) ||
          registrationDeadline.isAtSameMomentAs(startDateTime)) {
        FAdminLoaders.errorSnackBar(
          title: 'Time Conflict',
          message: 'Registration deadline must be before start time. Please adjust registration deadline.',
        );

        // 重置注册截止时间
        selectedRegistrationDeadlineDate.value = null;
        selectedRegistrationDeadlineTime.value = null;
      }
    }
  }

  void _validateEventDuration() {
    if (selectedStartDate.value != null &&
        selectedStartTime.value != null &&
        selectedEndDate.value != null &&
        selectedEndTime.value != null) {

      final startDateTime = DateTime(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
        selectedStartTime.value!.hour,
        selectedStartTime.value!.minute,
      );

      final endDateTime = DateTime(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
        selectedEndTime.value!.hour,
        selectedEndTime.value!.minute,
      );

      // 如果结束时间不满足至少1小时间隔，重置结束时间
      if (endDateTime.difference(startDateTime).inHours < 1) {
        FAdminLoaders.errorSnackBar(
          title: 'Duration Too Short',
          message: 'Event must last at least 1 hour. Please adjust end time.',
        );

        selectedEndTime.value = null;
      }
    }
  }

  // Poster Selection and Upload
  Future<void> selectPoster() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      PlatformFile file = result.files.first;

      // Check file size
      if (file.size > maxImageSizeBytes) {
        FAdminLoaders.errorSnackBar(
          title: 'File Too Large',
          message: 'Image size must be less than ${maxImageSizeMB}MB',
        );
        return;
      }

      // Check file type
      final extension = file.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Format',
          message: 'Only JPG, PNG, and WebP formats are supported',
        );
        return;
      }

      // Process and compress image
      final compressedBytes = await _processAndCompressImage(file);

      // 只存储字节数据，文件名在创建事件时生成
      selectedPosterBytes.value = compressedBytes;
      // 移除这行: selectedPosterName.value = '${_uuid.v4()}.webp';

      FAdminLoaders.successSnackBar(
        title: 'Poster Selected',
        message: 'Event poster has been selected successfully',
      );
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select poster: ${e.toString()}',
      );
      print('Error selecting poster: ${e.toString()}');
    }
  }

  // 处理并压缩图片 - 返回字节数据而不是文件
  Future<Uint8List> _processAndCompressImage(PlatformFile file) async {
    try {
      isCompressing.value = true;

      // 处理文件数据
      Uint8List imageBytes;
      if (file.bytes != null) {
        // Web 环境或已有字节数据
        imageBytes = file.bytes!;
      } else if (file.path != null) {
        // 移动端环境，从文件路径读取
        final originalFile = File(file.path!);
        imageBytes = await originalFile.readAsBytes();
      } else {
        throw 'No file data available';
      }

      // 压缩图片
      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        format: CompressFormat.webp,
        quality: imageQuality,
        minWidth: 1080,
        minHeight: 1080,
        autoCorrectionAngle: true,
      );

      isCompressing.value = false;
      return result;
    } catch (e) {
      isCompressing.value = false;
      print('Image compression failed: $e');

      // 如果压缩失败，返回原始字节
      if (file.bytes != null) {
        return file.bytes!;
      } else if (file.path != null) {
        final originalFile = File(file.path!);
        return await originalFile.readAsBytes();
      } else {
        throw 'No file data available';
      }
    }
  }

  void removePoster() {
    selectedPosterPath.value = null;
    selectedPosterName.value = null; // 可以保留或移除
    selectedPosterBytes.value = null;
  }

  // Format helper methods
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Validation methods
  bool _validateDates() {
    if (selectedStartDate.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please select start date');
      return false;
    }

    if (selectedStartTime.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please select start time');
      return false;
    }

    if (selectedEndDate.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please select end date');
      return false;
    }

    if (selectedEndTime.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please select end time');
      return false;
    }

    if (selectedRegistrationDeadlineDate.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please select registration deadline date');
      return false;
    }

    if (selectedRegistrationDeadlineTime.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please select registration deadline time');
      return false;
    }

    final startDateTime = DateTime(
      selectedStartDate.value!.year,
      selectedStartDate.value!.month,
      selectedStartDate.value!.day,
      selectedStartTime.value!.hour,
      selectedStartTime.value!.minute,
    );

    final endDateTime = DateTime(
      selectedEndDate.value!.year,
      selectedEndDate.value!.month,
      selectedEndDate.value!.day,
      selectedEndTime.value!.hour,
      selectedEndTime.value!.minute,
    );

    final registrationDeadline = DateTime(
      selectedRegistrationDeadlineDate.value!.year,
      selectedRegistrationDeadlineDate.value!.month,
      selectedRegistrationDeadlineDate.value!.day,
      selectedRegistrationDeadlineTime.value!.hour,
      selectedRegistrationDeadlineTime.value!.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      FAdminLoaders.errorSnackBar(
        title: 'Invalid Date/Time',
        message: 'End date/time must be after start date/time',
      );
      return false;
    }

    if (registrationDeadline.isAfter(startDateTime) || registrationDeadline.isAtSameMomentAs(startDateTime)) {
      FAdminLoaders.errorSnackBar(
        title: 'Invalid Registration Deadline',
        message: 'Registration deadline must be before event start time',
      );
      return false;
    }

    if (registrationDeadline.isBefore(DateTime.now())) {
      FAdminLoaders.errorSnackBar(
        title: 'Invalid Registration Deadline',
        message: 'Registration deadline cannot be in the past',
      );
      return false;
    }

    return true;
  }

  bool _validateLocation() {
    if (selectedLocation.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please add event location');
      return false;
    }
    return true;
  }

  bool _validateMaxParticipants() {
    final maxParticipants = int.tryParse(maxParticipantsController.text.trim());
    if (maxParticipants == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Invalid max participants value');
      return false;
    }
    if (maxParticipants > 1000) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Maximum participants cannot exceed 1000',
      );
      return false;
    }
    return true;
  }

  // Create Event Method
  Future<void> createEvent() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      if (!_validateDates()) {
        return;
      }

      if (!_validateLocation()) {
        return;
      }

      if (!_validateMaxParticipants()) {
        return;
      }

      if (selectedPosterBytes.value == null) {
        FAdminLoaders.errorSnackBar(
          title: 'Poster Required',
          message: 'Please upload an event poster',
        );
        return;
      }

      isLoading.value = true;

      final startDateTime = DateTime(
        selectedStartDate.value!.year,
        selectedStartDate.value!.month,
        selectedStartDate.value!.day,
        selectedStartTime.value!.hour,
        selectedStartTime.value!.minute,
      );

      final endDateTime = DateTime(
        selectedEndDate.value!.year,
        selectedEndDate.value!.month,
        selectedEndDate.value!.day,
        selectedEndTime.value!.hour,
        selectedEndTime.value!.minute,
      );

      final registrationDeadline = DateTime(
        selectedRegistrationDeadlineDate.value!.year,
        selectedRegistrationDeadlineDate.value!.month,
        selectedRegistrationDeadlineDate.value!.day,
        selectedRegistrationDeadlineTime.value!.hour,
        selectedRegistrationDeadlineTime.value!.minute,
      );

      // 使用 UUID 作为 poster 文件名
      final posterFileName = '${_uuid.v4()}.webp';
      print('Using poster file name: $posterFileName');

      // Upload poster
      String uploadedFileName = '';
      try {
        print('Uploading poster...');
        uploadedFileName = await _eventRepository.uploadEventPoster(
          selectedPosterBytes.value!,
          posterFileName, // 使用新的 UUID 文件名
        );
        print('Poster uploaded successfully: $uploadedFileName');
      } catch (e) {
        print('Poster upload failed: $e');
        rethrow;
      }

      final event = Event(
        eventId: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        contactEmail: contactEmailController.text.trim(),
        contactPhoneNo: contactPhoneController.text.trim(),
        location: selectedLocation.value!,
        poster: uploadedFileName, // 使用实际上传的文件名
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        registrationDeadline: registrationDeadline,
        maxParticipants: int.parse(maxParticipantsController.text.trim()),
        registeredCount: 0,
        createdAt: DateTime.now(),
        isPublish: true,
        status: 'active',
        eventRegistrations: [],
      );

      print('Creating event in Firestore...');
      await _eventRepository.createEvent(event);
      print('Event created successfully');

      isLoading.value = false;

      FAdminLoaders.successSnackBar(
        title: 'Event Created',
        message: 'Event created and published successfully',
      );

      Navigator.of(Get.context!).pop();
    } catch (e) {
      isLoading.value = false;
      print('=== EVENT CREATION ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=== END ERROR ===');

      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create event: ${e.toString()}',
      );
    }
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    maxParticipantsController.clear();
    contactEmailController.clear();
    contactPhoneController.clear();
    selectedStartDate.value = null;
    selectedStartTime.value = null;
    selectedEndDate.value = null;
    selectedEndTime.value = null;
    selectedRegistrationDeadlineDate.value = null;
    selectedRegistrationDeadlineTime.value = null;
    selectedLocation.value = null;
    selectedPosterPath.value = null;
    selectedPosterName.value = null;
    selectedPosterBytes.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    maxParticipantsController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    super.onClose();
  }
}