import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../data/repositories/event/event_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/helpers/image_compressor.dart';
import '../../../../utils/popups/admin_loaders.dart';
import '../../../event/models/event_model.dart';
import '../../../event/models/location_model.dart';
import 'event_management_controller.dart';

class EditEventController extends GetxController {
  static EditEventController get instance => Get.find();

  final EventRepository _eventRepository = Get.find();
  final _uuid = const Uuid();

  // Original event
  late Event originalEvent;

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
  final Rxn<Uint8List> selectedPosterBytes = Rxn<Uint8List>();
  final RxnString selectedPosterName = RxnString();
  final RxBool posterChanged = false.obs;

  // Track if dates have been modified
  final RxBool startDateModified = false.obs;
  final RxBool startTimeModified = false.obs;
  final RxBool endDateModified = false.obs;
  final RxBool endTimeModified = false.obs;
  final RxBool registrationDeadlineDateModified = false.obs;
  final RxBool registrationDeadlineTimeModified = false.obs;

  // Track text field changes
  final RxBool titleChanged = false.obs;
  final RxBool descriptionChanged = false.obs;
  final RxBool maxParticipantsChanged = false.obs;
  final RxBool contactEmailChanged = false.obs;
  final RxBool contactPhoneChanged = false.obs;
  final RxBool locationChanged = false.obs;

  // Image compression settings
  static const int imageQuality = 85;
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  void initializeWithEvent(Event event) {
    originalEvent = event;
    _initializeControllers();
    _loadEventData();
    _setupTextListeners();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    maxParticipantsController = TextEditingController();
    contactEmailController = TextEditingController();
    contactPhoneController = TextEditingController();
  }

  void _setupTextListeners() {
    // 监听文本字段变化
    titleController.addListener(() {
      titleChanged.value = titleController.text.trim() != originalEvent.title;
    });

    descriptionController.addListener(() {
      descriptionChanged.value = descriptionController.text.trim() != originalEvent.description;
    });

    maxParticipantsController.addListener(() {
      final currentValue = int.tryParse(maxParticipantsController.text.trim());
      maxParticipantsChanged.value = currentValue != null && currentValue != originalEvent.maxParticipants;
    });

    contactEmailController.addListener(() {
      contactEmailChanged.value = contactEmailController.text.trim() != originalEvent.contactEmail;
    });

    contactPhoneController.addListener(() {
      contactPhoneChanged.value = contactPhoneController.text.trim() != originalEvent.contactPhoneNo;
    });

    // 监听位置变化
    ever(selectedLocation, (Location? location) {
      if (location != null) {
        locationChanged.value = _isLocationChanged(location, originalEvent.location);
      } else {
        locationChanged.value = false;
      }
    });
  }

  bool _isLocationChanged(Location newLocation, Location oldLocation) {
    return newLocation.fullAddress != oldLocation.fullAddress ||
        newLocation.geoPoint.latitude != oldLocation.geoPoint.latitude ||
        newLocation.geoPoint.longitude != oldLocation.geoPoint.longitude;
  }

  void _loadEventData() {
    // Load text fields
    titleController.text = originalEvent.title;
    descriptionController.text = originalEvent.description;
    maxParticipantsController.text = originalEvent.maxParticipants.toString();
    contactEmailController.text = originalEvent.contactEmail;
    contactPhoneController.text = originalEvent.contactPhoneNo;

    // Load dates and times
    selectedStartDate.value = originalEvent.startDateTime;
    selectedStartTime.value = TimeOfDay.fromDateTime(originalEvent.startDateTime);
    selectedEndDate.value = originalEvent.endDateTime;
    selectedEndTime.value = TimeOfDay.fromDateTime(originalEvent.endDateTime);
    selectedRegistrationDeadlineDate.value = originalEvent.registrationDeadline;
    selectedRegistrationDeadlineTime.value = TimeOfDay.fromDateTime(originalEvent.registrationDeadline);

    // Load location
    selectedLocation.value = originalEvent.location;

    // Load poster - 修复这部分
    if (originalEvent.poster.isNotEmpty) {
      String posterName = originalEvent.poster;

      // 如果海报字段是完整的URL，需要提取文件名
      if (originalEvent.poster.startsWith('http')) {
        try {
          final uri = Uri.parse(originalEvent.poster);
          final pathSegments = uri.pathSegments;
          // 查找包含文件名的segment
          for (final segment in pathSegments) {
            if (segment.contains('.webp') ||
                segment.contains('.jpg') ||
                segment.contains('.png') ||
                segment.contains('.jpeg')) {
              posterName = segment;
              break;
            }
          }
          // 如果没找到合适的文件名，使用最后一个segment
          if (posterName == originalEvent.poster && pathSegments.isNotEmpty) {
            posterName = pathSegments.last;
          }
        } catch (e) {
          print('Error parsing poster URL: $e');
          // 如果解析失败，使用原始值
          posterName = originalEvent.poster;
        }
      }

      // 确保不包含重复的路径前缀
      if (posterName.startsWith('events/')) {
        posterName = posterName.substring(7); // 移除'events/'前缀
      }

      print('📁 Setting existing poster name: $posterName');
      selectedPosterName.value = posterName;
    } else {
      selectedPosterName.value = null;
    }

    // Reset modification flags
    _resetModificationFlags();
  }

  void _resetModificationFlags() {
    startDateModified.value = false;
    startTimeModified.value = false;
    endDateModified.value = false;
    endTimeModified.value = false;
    registrationDeadlineDateModified.value = false;
    registrationDeadlineTimeModified.value = false;
    titleChanged.value = false;
    descriptionChanged.value = false;
    maxParticipantsChanged.value = false;
    contactEmailChanged.value = false;
    contactPhoneChanged.value = false;
    locationChanged.value = false;
    posterChanged.value = false;
  }

  // 检查是否有任何改动
  bool get hasChanges {
    return titleChanged.value ||
        descriptionChanged.value ||
        maxParticipantsChanged.value ||
        contactEmailChanged.value ||
        contactPhoneChanged.value ||
        locationChanged.value ||
        posterChanged.value ||
        startDateModified.value ||
        startTimeModified.value ||
        endDateModified.value ||
        endTimeModified.value ||
        registrationDeadlineDateModified.value ||
        registrationDeadlineTimeModified.value;
  }

  // 检查是否有重要更改需要通知用户
  bool _hasImportantChanges() {
    return startDateModified.value ||
        startTimeModified.value ||
        endDateModified.value ||
        endTimeModified.value ||
        locationChanged.value ||
        descriptionChanged.value;
  }

  // 获取重要更改的详细信息
  List<String> _getImportantChangeDetails() {
    final changes = <String>[];

    if (startDateModified.value || startTimeModified.value) {
      changes.add('Event start time changed');
    }
    if (endDateModified.value || endTimeModified.value) {
      changes.add('Event end time changed');
    }
    if (locationChanged.value) {
      changes.add('Event location changed');
    }
    if (descriptionChanged.value) {
      changes.add('Event description changed');
    }

    return changes;
  }

  // Date and Time Selection Methods (保持不变)
  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedStartDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
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
      // 检查是否真的修改了日期
      final originalStartDate = DateTime(
        originalEvent.startDateTime.year,
        originalEvent.startDateTime.month,
        originalEvent.startDateTime.day,
      );
      final pickedDate = DateTime(picked.year, picked.month, picked.day);

      startDateModified.value = !pickedDate.isAtSameMomentAs(originalStartDate);

      selectedStartDate.value = picked;

      // 实时验证：如果结束日期在开始日期之前，重置结束日期
      if (selectedEndDate.value != null && selectedEndDate.value!.isBefore(picked)) {
        selectedEndDate.value = picked;
        selectedEndTime.value = null;
      }

      // 新增：验证注册截止时间
      _validateRegistrationDeadline();

      // 新增：验证事件时长
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
      // 检查是否真的修改了时间
      final originalStartTime = TimeOfDay.fromDateTime(originalEvent.startDateTime);
      startTimeModified.value = picked.hour != originalStartTime.hour ||
          picked.minute != originalStartTime.minute;

      selectedStartTime.value = picked;

      // 新增：验证注册截止时间
      _validateRegistrationDeadline();

      // 新增：验证事件时长
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
      firstDate: selectedStartDate.value ?? DateTime.now(),
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
      // 检查是否真的修改了日期
      final originalEndDate = DateTime(
        originalEvent.endDateTime.year,
        originalEvent.endDateTime.month,
        originalEvent.endDateTime.day,
      );
      final pickedDate = DateTime(picked.year, picked.month, picked.day);

      endDateModified.value = !pickedDate.isAtSameMomentAs(originalEndDate);

      // 实时验证：结束日期不能在开始日期之前
      if (selectedStartDate.value != null && picked.isBefore(selectedStartDate.value!)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'End date cannot be before start date',
        );
        return;
      }

      selectedEndDate.value = picked;

      // 新增：验证事件时长
      _validateEventDuration();
    }
  }

  Future<void> selectEndTime() async {
    // 必须先选择开始日期和时间
    if (selectedStartDate.value == null || selectedStartTime.value == null) {
      FAdminLoaders.warningSnackBar(
        title: 'Select Start Time First',
        message: 'Please select start date and time first',
      );
      return;
    }

    // 必须先选择结束日期
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
      // 默认比开始时间晚2小时
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
      // 检查是否真的修改了时间
      final originalEndTime = TimeOfDay.fromDateTime(originalEvent.endDateTime);
      endTimeModified.value = picked.hour != originalEndTime.hour ||
          picked.minute != originalEndTime.minute;

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

      // 实时验证：结束时间必须在开始时间之后
      if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Time',
          message: 'End time must be after start time',
        );
        return;
      }

      // 实时验证：至少1小时间隔
      final duration = endDateTime.difference(startDateTime);
      if (duration.inHours < 1) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Time',
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
      // 检查是否真的修改了日期
      final originalDeadlineDate = DateTime(
        originalEvent.registrationDeadline.year,
        originalEvent.registrationDeadline.month,
        originalEvent.registrationDeadline.day,
      );
      final pickedDate = DateTime(picked.year, picked.month, picked.day);

      registrationDeadlineDateModified.value = !pickedDate.isAtSameMomentAs(originalDeadlineDate);

      // 实时验证：如果已选择开始日期，注册截止日期不能晚于开始日期
      if (selectedStartDate.value != null && picked.isAfter(selectedStartDate.value!)) {
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Date',
          message: 'Registration deadline must be on or before event start date',
        );
        return;
      }

      // 实时验证：注册截止日期不能是过去（考虑时间）- 只有在修改时才验证
      if (registrationDeadlineDateModified.value) {
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
      // 检查是否真的修改了时间
      final originalDeadlineTime = TimeOfDay.fromDateTime(originalEvent.registrationDeadline);
      registrationDeadlineTimeModified.value = picked.hour != originalDeadlineTime.hour ||
          picked.minute != originalDeadlineTime.minute;

      final registrationDeadline = DateTime(
        selectedRegistrationDeadlineDate.value!.year,
        selectedRegistrationDeadlineDate.value!.month,
        selectedRegistrationDeadlineDate.value!.day,
        picked.hour,
        picked.minute,
      );

      // 实时验证：注册截止时间不能是过去 - 只有在修改时才验证
      if (registrationDeadlineTimeModified.value && registrationDeadline.isBefore(DateTime.now())) {
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
        registrationDeadlineDateModified.value = false;
        registrationDeadlineTimeModified.value = false;
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
        endTimeModified.value = false;
      }
    }
  }

  // Poster Selection and Upload - 简化的版本
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

      // 存储字节数据
      selectedPosterBytes.value = compressedBytes;
      selectedPosterName.value = '${_uuid.v4()}.webp';

      // 设置posterChanged标志
      posterChanged.value = true;

      FAdminLoaders.successSnackBar(
        title: 'Poster Selected',
        message: 'New event poster has been selected and will be updated when you save changes',
      );
    } catch (e) {
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select poster: ${e.toString()}',
      );
    }
  }

  Future<Uint8List> _processAndCompressImage(PlatformFile file) async {
    try {
      isCompressing.value = true;

      // 先拿到 File
      late File imageFile;
      if (file.path != null && file.path!.isNotEmpty) {
        imageFile = File(file.path!);
      } else if (file.bytes != null) {
        // 只有 bytes 的情况：写入临时文件再压缩
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/${file.name}';
        imageFile = await File(tempPath).writeAsBytes(file.bytes!);
      } else {
        throw 'No file data available';
      }

      // 用 ImageCompressor 压缩并转 WebP，带 UUID 文件名
      final compressedFile = await ImageCompressor.compressAndConvertToWebP(imageFile);

      // 读回 Uint8List 给 UI / 上传用
      final compressedBytes = await compressedFile.readAsBytes();

      isCompressing.value = false;
      return compressedBytes;
    } catch (e) {
      isCompressing.value = false;
      print('Image compression failed: $e');

      // 失败就回退用原始 bytes，保证功能不断
      if (file.bytes != null) {
        return file.bytes!;
      } else if (file.path != null && file.path!.isNotEmpty) {
        final originalFile = File(file.path!);
        return await originalFile.readAsBytes();
      } else {
        throw 'No file data available';
      }
    }
  }

  void removePoster() {
    // 设置posterChanged为true
    posterChanged.value = true;

    selectedPosterName.value = null;
    selectedPosterBytes.value = null;

    FAdminLoaders.successSnackBar(
      title: 'Poster Removed',
      message: 'Event poster will be removed when you save changes',
    );
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

  // Validation methods (保持不变)
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

    // 只有在修改了注册截止时间时才检查过去时间
    if ((registrationDeadlineDateModified.value || registrationDeadlineTimeModified.value) &&
        registrationDeadline.isBefore(DateTime.now())) {
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

    // Cannot be less than registered count
    if (maxParticipants < originalEvent.registeredCount) {
      FAdminLoaders.errorSnackBar(
        title: 'Invalid Max Participants',
        message: 'Cannot be less than current registered count (${originalEvent.registeredCount})',
      );
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

  // 验证海报
  bool _validatePoster() {
    // 如果没有原始图片且没有选择新图片，显示错误
    if ((selectedPosterName.value == null || selectedPosterName.value!.isEmpty) &&
        selectedPosterBytes.value == null) {
      FAdminLoaders.errorSnackBar(title: 'Error', message: 'Please add event poster');
      return false;
    }
    return true;
  }

  // 显示通知确认对话框
  Future<bool?> _showNotificationConfirmationDialog() async {
    final dark = FHelperFunctions.isDarkMode(Get.context!);
    final changeDetails = _getImportantChangeDetails();

    return await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send Update Notification?',
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Get.back(result: null), // 取消操作
              icon: Icon(
                Icons.close,
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Important changes were detected:',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...changeDetails.map((change) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $change',
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  fontSize: 14,
                ),
              ),
            )).toList(),
            const SizedBox(height: 16),
            Text(
              'Do you want to send push notifications to all registered users about these changes?',
              style: TextStyle(
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), // 不发送通知
            child: Text(
              'Update Only',
              style: TextStyle(
                color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true), // 发送通知
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Update & Notify',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 执行事件更新
  Future<void> _performEventUpdate({required bool sendNotification}) async {
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

    String posterFileName = originalEvent.poster;

    // Handle poster changes
    if (posterChanged.value) {
      // 如果有新选择的poster
      if (selectedPosterBytes.value != null && selectedPosterName.value != null) {
        // 删除旧的poster（如果存在）
        if (originalEvent.poster.isNotEmpty) {
          try {
            // 清理要删除的文件名
            String deleteFileName = originalEvent.poster;
            if (deleteFileName.startsWith('http')) {
              // 如果是URL，提取文件名
              try {
                final uri = Uri.parse(deleteFileName);
                final pathSegments = uri.pathSegments;
                for (final segment in pathSegments) {
                  if (segment.contains('.webp') || segment.contains('.jpg') ||
                      segment.contains('.png') || segment.contains('.jpeg')) {
                    deleteFileName = segment;
                    break;
                  }
                }
                if (deleteFileName == originalEvent.poster && pathSegments.isNotEmpty) {
                  deleteFileName = pathSegments.last;
                }
              } catch (e) {
                print('Error parsing poster URL for deletion: $e');
              }
            }

            // 确保路径格式正确
            if (!deleteFileName.startsWith('events/')) {
              deleteFileName = 'events/$deleteFileName';
            }

            await _eventRepository.deleteEventPoster(deleteFileName);
            print('🗑️ Deleted old poster: $deleteFileName');
          } catch (e) {
            print('⚠️ Failed to delete old poster: $e');
            // 继续上传新poster，不抛出异常
          }
        }

        // 上传新poster
        try {
          print('📤 Uploading new poster: ${selectedPosterName.value}');
          // 确保上传路径正确
          String uploadFileName = selectedPosterName.value!;
          if (!uploadFileName.startsWith('events/')) {
            uploadFileName = 'events/$uploadFileName';
          }

          posterFileName = await _eventRepository.uploadEventPoster(
            selectedPosterBytes.value!,
            uploadFileName,
          );
          print('✅ New poster uploaded: $posterFileName');
        } catch (e) {
          print('❌ Failed to upload new poster: $e');
          throw 'Failed to upload new poster: $e';
        }
      }
      // 如果用户移除了poster
      else if (selectedPosterBytes.value == null && selectedPosterName.value == null) {
        // 删除旧的poster（如果存在）
        if (originalEvent.poster.isNotEmpty) {
          try {
            String deleteFileName = originalEvent.poster;
            if (deleteFileName.startsWith('http')) {
              // 如果是URL，提取文件名
              try {
                final uri = Uri.parse(deleteFileName);
                final pathSegments = uri.pathSegments;
                for (final segment in pathSegments) {
                  if (segment.contains('.webp') || segment.contains('.jpg') ||
                      segment.contains('.png') || segment.contains('.jpeg')) {
                    deleteFileName = segment;
                    break;
                  }
                }
                if (deleteFileName == originalEvent.poster && pathSegments.isNotEmpty) {
                  deleteFileName = pathSegments.last;
                }
              } catch (e) {
                print('Error parsing poster URL for deletion: $e');
              }
            }

            // 确保路径格式正确
            if (!deleteFileName.startsWith('events/')) {
              deleteFileName = 'events/$deleteFileName';
            }

            await _eventRepository.deleteEventPoster(deleteFileName);
            print('🗑️ Deleted poster as requested: $deleteFileName');
          } catch (e) {
            print('⚠️ Failed to delete poster: $e');
            // 继续更新事件，不抛出异常
          }
        }
        posterFileName = ''; // 设置为空字符串
      }
      // 其他情况保持原有poster
    }

    final updatedEvent = originalEvent.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      contactEmail: contactEmailController.text.trim(),
      contactPhoneNo: contactPhoneController.text.trim(),
      location: selectedLocation.value!,
      poster: posterFileName,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      registrationDeadline: registrationDeadline,
      maxParticipants: int.parse(maxParticipantsController.text.trim()),
    );

    // 保存原始事件数据用于比较
    final Event oldEvent = originalEvent;

    await _eventRepository.updateEvent(updatedEvent);

    // 只有在用户确认时才发送通知
    if (sendNotification) {
      try {
        final eventManagementController = Get.put(EventManagementController());
        await eventManagementController.sendEventUpdateNotifications(oldEvent, updatedEvent);
        print('📢 Update notifications sent to registered users');
      } catch (e) {
        print('❌ Failed to send update notifications: $e');
        // 不抛出异常，避免影响主要业务逻辑
      }
    }

    isLoading.value = false;

    FAdminLoaders.successSnackBar(
      title: 'Event Updated',
      message: sendNotification
          ? 'Event updated and notifications sent to registered users'
          : 'Event updated successfully',
    );

    Navigator.of(Get.context!).pop();
  }

  // Update Event Method
  Future<void> updateEvent() async {
    try {
      // 检查是否有改动
      if (!hasChanges) {
        FAdminLoaders.warningSnackBar(
          title: 'No Changes',
          message: 'No changes detected. Please make some changes before updating.',
        );
        return;
      }

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

      if (!_validatePoster()) {
        return;
      }

      // 检查是否有重要更改需要通知用户
      final bool hasImportantChanges = _hasImportantChanges();

      if (hasImportantChanges) {
        // 显示确认对话框询问是否发送通知
        final bool? sendNotification = await _showNotificationConfirmationDialog();

        if (sendNotification == null) {
          return; // 用户取消了操作
        }

        // 用户选择是否发送通知
        await _performEventUpdate(sendNotification: sendNotification);
      } else {
        // 没有重要更改，直接更新不发送通知
        await _performEventUpdate(sendNotification: false);
      }

    } catch (e) {
      isLoading.value = false;
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update event: ${e.toString()}',
      );
    }
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