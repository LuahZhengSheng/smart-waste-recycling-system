import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';

import '../../../utils/popups/loaders.dart';
import '../../../utils/helpers/image_compressor.dart';
import '../models/waste_category_model.dart';

class AddActivityFormController extends GetxController {
  final bool isEditing;
  final RecyclingActivity? existingActivity;
  final List<WasteCategory> wasteCategories;

  AddActivityFormController({
    required this.isEditing,
    this.existingActivity,
    required this.wasteCategories,
  });

  // Form key and controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController wasteObjectController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Observables
  final Rx<WasteCategory?> selectedCategory = Rx<WasteCategory?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString uploadedImageFileName = ''.obs;
  final RxInt calculatedPoints = 0.obs;
  final RxBool isLoading = false.obs;

  // Computed property to check if there's an existing image
  RxBool get hasExistingImage => RxBool(uploadedImageFileName.value.isNotEmpty && !uploadedImageFileName.value.startsWith('temp_'));

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Image validation constants
  static const int maxImageSizeInBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp', 'heic'];

  @override
  void onInit() {
    super.onInit();
    if (isEditing && existingActivity != null) {
      _populateFields();
    }
  }

  @override
  void onClose() {
    wasteObjectController.dispose();
    weightController.dispose();
    super.onClose();
  }

  void _populateFields() {
    if (existingActivity != null) {
      wasteObjectController.text = existingActivity!.wasteObject;
      weightController.text = existingActivity!.weight.toString();

      // Debug existing activity data
      print('Existing activity supportImage: ${existingActivity!.supportImage}');
      print('Existing activity wasteObject: ${existingActivity!.wasteObject}');
      print('Existing activity weight: ${existingActivity!.weight}');

      // Set the uploaded image filename - this is crucial for edit mode
      // Only set if it's not a temporary filename
      if (existingActivity!.supportImage.isNotEmpty && !existingActivity!.supportImage.startsWith('temp_')) {
        uploadedImageFileName.value = existingActivity!.supportImage;
        print('Set uploadedImageFileName to: ${uploadedImageFileName.value}');
      } else {
        print('Existing image is temporary, ignoring: ${existingActivity!.supportImage}');
        uploadedImageFileName.value = '';
      }

      calculatedPoints.value = existingActivity!.pointsEarned;

      final category = wasteCategories.firstWhereOrNull(
            (cat) => cat.categoryId == existingActivity!.wasteCategoryId,
      );
      if (category != null) {
        selectedCategory.value = category;
        print('Set category to: ${category.name}');
      }
    }
  }

  void selectCategory(WasteCategory category) {
    selectedCategory.value = category;
    calculatePoints();
  }

  void calculatePoints() {
    final weight = double.tryParse(weightController.text) ?? 0.0;

    if (weight <= 0 || selectedCategory.value == null) {
      calculatedPoints.value = 0;
      return;
    }

    final basePoints = selectedCategory.value!.basePoints;
    final totalPoints = (weight * basePoints).round();
    calculatedPoints.value = totalPoints;
  }

  void pickImage() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _validateAndSetImage(File(image.path));
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to capture photo: $e',
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _validateAndSetImage(File(image.path));
      }
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to select image: $e',
      );
    }
  }

  Future<void> _validateAndSetImage(File imageFile) async {
    // Validate format
    if (!ImageCompressor.isValidImageFormat(imageFile)) {
      FLoaders.errorSnackBar(
        title: 'Invalid Format',
        message: 'Please select a valid image format (JPG, PNG, WEBP, HEIC)',
      );
      return;
    }

    // Validate size
    final fileSize = await imageFile.length();
    if (fileSize > maxImageSizeInBytes) {
      FLoaders.errorSnackBar(
        title: 'File Too Large',
        message: 'Image size must be less than 10MB',
      );
      return;
    }

    // Check if already has image (limit to 1)
    if (selectedImage.value != null || uploadedImageFileName.value.isNotEmpty) {
      FLoaders.warningSnackBar(
        title: 'Replace Image',
        message: 'Replacing existing image',
      );
    }

    selectedImage.value = imageFile;
    uploadedImageFileName.value = ''; // Clear old filename when selecting new one

    FLoaders.customToast(message: 'Image selected successfully!');
  }

  void removeImage() {
    selectedImage.value = null;
    uploadedImageFileName.value = '';

    FLoaders.warningSnackBar(
      title: 'Image Removed',
      message: 'Please select a new image',
    );
  }

  String? validateWasteObject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe the waste item';
    }
    if (value.trim().length < 3) {
      return 'Description must be at least 3 characters';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter weight';
    }

    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }

    if (weight > 1000) {
      return 'Weight cannot exceed 1000 kg';
    }

    return null;
  }

  bool validateForm() {
    bool isValid = true;
    String errorMessage = '';

    if (!formKey.currentState!.validate()) {
      isValid = false;
    }

    if (selectedCategory.value == null) {
      isValid = false;
      errorMessage = 'Please select a waste category';
    }

    if (selectedImage.value == null && uploadedImageFileName.value.isEmpty) {
      isValid = false;
      errorMessage = 'Please upload a support image';
    }

    if (!isValid && errorMessage.isNotEmpty) {
      FLoaders.errorSnackBar(
        title: 'Validation Error',
        message: errorMessage,
      );
    }

    return isValid;
  }

  /// Create recycling activity (image will be uploaded later during submission)
  RecyclingActivity createActivity(String userId, String centerStaffId) {
    // In edit mode, preserve the existing image filename if no new image is selected
    String supportImage;

    if (isEditing && existingActivity != null) {
      // If we have a new image selected, we'll upload it later
      // If no new image is selected, keep the existing image filename
      if (selectedImage.value != null) {
        // New image selected - use temporary identifier
        supportImage = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // No new image - preserve the existing image filename
        supportImage = existingActivity!.supportImage;
        print('Preserving existing image: $supportImage');
      }
    } else {
      // New activity - use temporary identifier
      supportImage = uploadedImageFileName.value.isNotEmpty && !uploadedImageFileName.value.startsWith('temp_')
          ? uploadedImageFileName.value
          : 'temp_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Create activity
    final activity = RecyclingActivity.createNew(
      userId: userId,
      centerStaffId: centerStaffId,
      wasteObject: wasteObjectController.text.trim(),
      wasteCategoryId: selectedCategory.value!.categoryId,
      weight: double.parse(weightController.text.trim()),
      supportImage: supportImage,
      customPoints: calculatedPoints.value,
    );

    print('Created activity with supportImage: $supportImage');
    return activity;
  }

  /// Get the selected image file (for upload during submission)
  File? getImageFile() {
    return selectedImage.value;
  }

  /// Get the URL for existing image in edit mode
  String getExistingImageUrl(String userId) {
    if (uploadedImageFileName.value.isEmpty) {
      print('uploadedImageFileName is empty');
      return '';
    }

    // Don't try to generate URL for temporary files
    if (uploadedImageFileName.value.startsWith('temp_')) {
      print('Skipping temporary image: ${uploadedImageFileName.value}');
      return '';
    }

    // Construct the Firebase Storage URL
    final imageUrl = 'https://firebasestorage.googleapis.com/v0/b/fir-82ffd.appspot.com/o/recycling_activities%2F$userId%2F${Uri.encodeComponent(uploadedImageFileName.value)}?alt=media';

    print('Generated image URL: $imageUrl');
    print('User ID: $userId');
    print('Filename: ${uploadedImageFileName.value}');

    return imageUrl;
  }

  void resetForm() {
    formKey.currentState?.reset();
    wasteObjectController.clear();
    weightController.clear();
    selectedCategory.value = null;
    selectedImage.value = null;
    uploadedImageFileName.value = '';
    calculatedPoints.value = 0;
  }

  bool get hasUnsavedChanges {
    if (isEditing && existingActivity != null) {
      return wasteObjectController.text != existingActivity!.wasteObject ||
          weightController.text != existingActivity!.weight.toString() ||
          selectedCategory.value?.categoryId !=
              existingActivity!.wasteCategoryId ||
          selectedImage.value != null;
    } else {
      return wasteObjectController.text.isNotEmpty ||
          weightController.text.isNotEmpty ||
          selectedCategory.value != null ||
          selectedImage.value != null;
    }
  }

  String getCategoryDisplayName() {
    if (selectedCategory.value == null) return 'Select Category';
    return selectedCategory.value!.name;
  }

  String getRecyclingTips() {
    if (selectedCategory.value == null) return '';
    return selectedCategory.value!.disposalMethodWithEmoji;
  }
}