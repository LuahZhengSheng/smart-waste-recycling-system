import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';

import '../../../../utils/popups/loaders.dart';
import '../../../event/models/location_model.dart';
import '../../../recycling_center/models/partner_recycling_center_model.dart';

class AddPartnerCenterController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;
  final formProgress = 0.0.obs;

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController staffCountController;

  // Selected values
  final selectedLocation = Rxn<Location>();
  final selectedImage = RxnString();
  final selectedStatus = 'active'.obs;

  // Opening hours map - changed to Google Places format
  final RxMap<String, dynamic> openingHours = <String, dynamic>{}.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Days of the week
  final List<String> daysOfWeek = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _initializeOpeningHours();
    _setupFormProgressListener();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    websiteController = TextEditingController();
    staffCountController = TextEditingController();
  }

  void _initializeOpeningHours() {
    // Initialize with Google Places format structure
    openingHours.value = {
      'periods': [],
      'weekday_text': [],
      'open_now': false,
    };
  }

  void _setupFormProgressListener() {
    // Listen to all form fields and update progress
    nameController.addListener(_updateFormProgress);
    emailController.addListener(_updateFormProgress);
    phoneController.addListener(_updateFormProgress);
    websiteController.addListener(_updateFormProgress);
    staffCountController.addListener(_updateFormProgress);

    // Listen to reactive variables
    ever(selectedLocation, (_) => _updateFormProgress());
    ever(selectedImage, (_) => _updateFormProgress());
    ever(selectedStatus, (_) => _updateFormProgress());
  }

  void _updateFormProgress() {
    double progress = 0.0;
    int totalFields = 8; // Total required fields

    // Basic information (4 fields)
    if (nameController.text.isNotEmpty) progress += 1;
    if (emailController.text.isNotEmpty) progress += 1;
    if (phoneController.text.isNotEmpty) progress += 1;
    if (websiteController.text.isNotEmpty) progress += 1;

    // Location
    if (selectedLocation.value != null) progress += 1;

    // Image
    if (selectedImage.value != null) progress += 1;

    // Staff count
    if (staffCountController.text.isNotEmpty) progress += 1;

    // Opening hours (check if at least one day is set)
    bool hasOpeningHours = _hasValidOpeningHours();
    if (hasOpeningHours) progress += 1;

    formProgress.value = progress / totalFields;
  }

  bool _hasValidOpeningHours() {
    final periods = openingHours['periods'] as List<dynamic>?;
    return periods != null && periods.isNotEmpty;
  }

  // Add formatTime method here
  String formatTime(String timeString) {
    if (timeString.length != 4) return timeString;

    final hour = int.parse(timeString.substring(0, 2));
    final minute = timeString.substring(2, 4);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;

    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Center name is required';
    }
    if (value.trim().length < 3) {
      return 'Center name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove all non-digit characters for validation
    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Website is required';
    }
    if (!GetUtils.isURL(value.trim())) {
      return 'Please enter a valid website URL';
    }
    return null;
  }

  String? validateStaffCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Staff count is required';
    }
    final count = int.tryParse(value.trim());
    if (count == null || count < 1) {
      return 'Please enter a valid staff count';
    }
    return null;
  }

  String? validateStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Status is required';
    }
    return null;
  }

  // Location methods
  void setLocation(Location location) {
    selectedLocation.value = location;
    FLoaders.successSnackBar(
      title: 'Location Set',
      message: 'Center location has been saved successfully',
    );
  }

  void clearLocation() {
    selectedLocation.value = null;
    FLoaders.customToast(message: 'Location cleared');
  }

  // Image methods
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = image.path;
        FLoaders.successSnackBar(
          title: 'Image Selected',
          message: 'Center image has been added successfully',
        );
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  void clearImage() {
    selectedImage.value = null;
    FLoaders.customToast(message: 'Image removed');
  }

  // Opening hours methods - updated for Google Places format
  Future<void> selectTime(String day, String timeType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final isDark = FHelperFunctions.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark().copyWith(
              primary: Color(0xFF7B8CFF), // adminDarkPrimary
            )
                : const ColorScheme.light().copyWith(
              primary: Color(0xFF5E72E4), // adminLightPrimary
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}${picked.minute.toString().padLeft(2, '0')}';
      final dayIndex = daysOfWeek.indexOf(day); // 0=monday, 6=sunday
      final googleDayIndex = (dayIndex + 1) % 7; // Convert to Google format: 0=Sunday, 6=Saturday

      // Get current periods
      final List<dynamic> periods = List.from(openingHours['periods'] ?? []);

      // Find existing period for this day
      int existingIndex = periods.indexWhere((period) =>
      period['open'] != null && period['open']['day'] == googleDayIndex);

      if (existingIndex == -1) {
        // Create new period
        periods.add({
          'open': {
            'day': googleDayIndex,
            'time': timeString,
          },
          'close': {
            'day': googleDayIndex,
            'time': '',
          }
        });
        existingIndex = periods.length - 1;
      }

      // Update the time
      if (timeType == 'open') {
        periods[existingIndex]['open']['time'] = timeString;
      } else {
        periods[existingIndex]['close']['time'] = timeString;
      }

      // Validate time logic
      final openTime = periods[existingIndex]['open']['time'];
      final closeTime = periods[existingIndex]['close']['time'];

      if (openTime.isNotEmpty && closeTime.isNotEmpty) {
        if (closeTime.compareTo(openTime) <= 0) {
          FLoaders.warningSnackBar(
            title: 'Invalid Time',
            message: 'Close time must be after open time',
          );
          // Reset the close time
          periods[existingIndex]['close']['time'] = '';
        }
      }

      // Update weekday_text
      final weekdayText = _generateWeekdayText(periods);

      openingHours.value = {
        'periods': periods,
        'weekday_text': weekdayText,
        'open_now': _calculateOpenNow(periods),
      };

      _updateFormProgress();
    }
  }

  List<String> _generateWeekdayText(List<dynamic> periods) {
    final List<String> result = [];
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (int i = 0; i < 7; i++) {
      final googleDayIndex = i; // Google: 0=Sunday, 6=Saturday
      final period = periods.firstWhere(
            (p) => p['open'] != null && p['open']['day'] == googleDayIndex,
        orElse: () => null,
      );

      if (period != null &&
          period['open']['time'].isNotEmpty &&
          period['close']['time'].isNotEmpty) {
        final openTime = _formatTimeString(period['open']['time']);
        final closeTime = _formatTimeString(period['close']['time']);
        result.add('${dayNames[i]}: $openTime - $closeTime');
      } else {
        result.add('${dayNames[i]}: Closed');
      }
    }

    return result;
  }

  String _formatTimeString(String timeString) {
    if (timeString.length != 4) return timeString;

    final hour = int.parse(timeString.substring(0, 2));
    final minute = timeString.substring(2, 4);

    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;

    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  bool _calculateOpenNow(List<dynamic> periods) {
    final now = DateTime.now();
    final currentDay = now.weekday - 1; // Convert to Google format: 0=Sunday, 6=Saturday
    final currentTime = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    for (var period in periods) {
      if (period['open'] != null &&
          period['open']['day'] == currentDay &&
          period['open']['time'].isNotEmpty &&
          period['close']['time'].isNotEmpty) {

        final openTime = period['open']['time'];
        final closeTime = period['close']['time'];

        if (currentTime.compareTo(openTime) >= 0 && currentTime.compareTo(closeTime) < 0) {
          return true;
        }
      }
    }

    return false;
  }

  String getTimeDisplay(String day, String timeType) {
    final periods = openingHours['periods'] as List<dynamic>?;
    if (periods == null) return 'Not set';

    final dayIndex = daysOfWeek.indexOf(day);
    final googleDayIndex = (dayIndex + 1) % 7;

    final period = periods.firstWhere(
          (p) => p['open'] != null && p['open']['day'] == googleDayIndex,
      orElse: () => null,
    );

    if (period != null) {
      final timeString = period[timeType]?['time'] ?? '';
      if (timeString.isNotEmpty) {
        return _formatTimeString(timeString);
      }
    }

    return 'Not set';
  }

  // Save draft functionality
  void saveDraft() {
    // In real implementation, save to local storage or database
    FLoaders.successSnackBar(
      title: 'Draft Saved',
      message: 'Your progress has been saved as draft',
    );
  }

  // Create center method
  Future<void> createCenter() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Create PartnerRecyclingCenter object
      final center = PartnerRecyclingCenter(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNo: phoneController.text.trim(),
        website: websiteController.text.trim(),
        centerLocation: selectedLocation.value!,
        image: selectedImage.value ?? '', // In real app, upload image first
        openingHours: openingHours.value.isNotEmpty ? openingHours.value : null,
        numberOfStaff: int.parse(staffCountController.text.trim()),
        status: selectedStatus.value,
        centerId: '',
        createdAt: DateTime.now(),
      );

      // In real implementation, save to database
      await _saveCenterToDatabase(center);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Partner recycling center created successfully',
      );

      // Clear form and go back
      _resetForm();
      Get.back(result: true); // Return true to indicate success

    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to create center: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    // Basic form validation
    if (!formKey.currentState!.validate()) {
      FLoaders.errorSnackBar(
        title: 'Form Error',
        message: 'Please fix all form errors before proceeding',
      );
      return false;
    }

    // Location validation
    if (selectedLocation.value == null) {
      FLoaders.errorSnackBar(
        title: 'Location Required',
        message: 'Please set the center location',
      );
      return false;
    }

    // Image validation (optional but recommended)
    if (selectedImage.value == null) {
      FLoaders.warningSnackBar(
        title: 'No Image',
        message: 'Consider adding a center image for better visibility',
      );
    }

    // Opening hours validation
    if (!_hasValidOpeningHours()) {
      FLoaders.errorSnackBar(
        title: 'Opening Hours Required',
        message: 'Please set opening hours for at least one day',
      );
      return false;
    }

    return true;
  }

  Future<void> _saveCenterToDatabase(PartnerRecyclingCenter center) async {
    // Simulate database save
    // In real implementation, use Firebase or other backend service
    await Future.delayed(const Duration(milliseconds: 500));

    // Here you would typically:
    // 1. Upload the image to storage and get URL
    // 2. Save center data to Firestore
    // 3. Handle any errors

    print('Saving center: ${center.toJson()}');
  }

  void _resetForm() {
    // Clear all controllers
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    websiteController.clear();
    staffCountController.clear();

    // Reset reactive variables
    selectedLocation.value = null;
    selectedImage.value = null;
    selectedStatus.value = 'active';

    // Reset opening hours
    _initializeOpeningHours();

    // Reset progress
    formProgress.value = 0.0;
  }

  // Lifecycle methods
  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    staffCountController.dispose();
    super.onClose();
  }

  // Helper method to check if form has unsaved changes
  bool get hasUnsavedChanges {
    return nameController.text.isNotEmpty ||
        emailController.text.isNotEmpty ||
        phoneController.text.isNotEmpty ||
        websiteController.text.isNotEmpty ||
        staffCountController.text.isNotEmpty ||
        selectedLocation.value != null ||
        selectedImage.value != null ||
        _hasValidOpeningHours();
  }

  // Method to handle back navigation with confirmation
  Future<bool> onWillPop() async {
    if (!hasUnsavedChanges) return true;

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: FHelperFunctions.isDarkMode(Get.context!)
            ? Color(0xFF111B2B) // adminDarkSurface
            : Colors.white,
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            color: FHelperFunctions.isDarkMode(Get.context!)
                ? Color(0xFFE2E8F0) // adminDarkText
                : Color(0xFF32325D), // adminLightText
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: TextStyle(
            color: FHelperFunctions.isDarkMode(Get.context!)
                ? Color(0xFF94A3B8) // adminDarkTextSecondary
                : Color(0xFF8898AA), // adminLightTextSecondary
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: FHelperFunctions.isDarkMode(Get.context!)
                    ? Color(0xFF94A3B8) // adminDarkTextSecondary
                    : Color(0xFF8898AA), // adminLightTextSecondary
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Discard',
              style: TextStyle(
                color: FHelperFunctions.isDarkMode(Get.context!)
                    ? Color(0xFFFC7C8A) // adminDarkError
                    : Color(0xFFF5365C), // adminLightError
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

