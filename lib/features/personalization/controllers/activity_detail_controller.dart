import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';
import 'package:fyp/features/recycling_center/models/waste_category.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ActivityDetailController extends GetxController {
  final Rx<RecyclingActivity?> activity = Rx<RecyclingActivity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString selectedTab = 'details'.obs;

  // Mock recycling center data
  final RxString recyclingCenterName = 'Green Earth Recycling Center'.obs;
  final RxString recyclingCenterAddress = '123 Eco Street, Green City'.obs;
  final RxString recyclingCenterPhone = '+1 234 567 8900'.obs;
  final RxDouble recyclingCenterRating = 4.5.obs;

  // Timeline data
  final RxList<ActivityTimelineItem> timeline = <ActivityTimelineItem>[].obs;

  // Mock waste categories - in real app, this would come from repository
  final List<WasteCategory> _wasteCategories = [
    WasteCategory(
      categoryId: '1',
      name: 'Plastic',
      description: 'Plastic bottles, containers, bags and other plastic items',
      disposalMethod: 'Clean and sort by type for recycling',
      icon: Iconsax.box,
      color: const Color(0xFF2196F3),
      basePoints: 10.0,
      examples: ['Plastic bottles', 'Food containers', 'Plastic bags'],
      isRecyclable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WasteCategory(
      categoryId: '2',
      name: 'Paper',
      description: 'Newspapers, cardboard, magazines and paper products',
      disposalMethod: 'Keep dry and separate from other materials',
      icon: Iconsax.document,
      color: const Color(0xFF8BC34A),
      basePoints: 8.0,
      examples: ['Newspapers', 'Cardboard boxes', 'Magazines'],
      isRecyclable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WasteCategory(
      categoryId: '3',
      name: 'Glass',
      description: 'Bottles, jars and glass containers',
      disposalMethod: 'Clean and sort by color',
      icon: Iconsax.glass,
      color: const Color(0xFF00BCD4),
      basePoints: 12.0,
      examples: ['Glass bottles', 'Jars', 'Glass containers'],
      isRecyclable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WasteCategory(
      categoryId: '4',
      name: 'Metal',
      description: 'Aluminum cans, steel containers and metal items',
      disposalMethod: 'Clean and separate ferrous from non-ferrous',
      icon: Iconsax.cpu,
      color: const Color(0xFF607D8B),
      basePoints: 15.0,
      examples: ['Aluminum cans', 'Steel containers', 'Metal scraps'],
      isRecyclable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WasteCategory(
      categoryId: '5',
      name: 'Electronics',
      description: 'Old phones, computers, batteries and electronic devices',
      disposalMethod: 'Special handling required for electronic components',
      icon: Iconsax.mobile,
      color: const Color(0xFF9C27B0),
      basePoints: 20.0,
      examples: ['Old phones', 'Computers', 'Batteries'],
      isRecyclable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as RecyclingActivity?;
    if (args != null) {
      activity.value = args;
      _generateTimeline();
    }
  }

  void _generateTimeline() {
    if (activity.value == null) return;

    final act = activity.value!;
    timeline.clear();

    // Always add submission
    timeline.add(ActivityTimelineItem(
      title: 'Activity Submitted',
      description: 'Your recycling activity was submitted for review',
      timestamp: act.createdAt,
      status: TimelineStatus.completed,
      icon: 'upload',
    ));

    // Add review if not pending
    if (!act.isPending) {
      timeline.add(ActivityTimelineItem(
        title: 'Under Review',
        description: 'Our team is verifying your submission',
        timestamp: act.createdAt.add(const Duration(hours: 2)),
        status: TimelineStatus.completed,
        icon: 'eye',
      ));

      // Add approval/rejection based on status
      if (act.isApproved) {
        timeline.add(ActivityTimelineItem(
          title: 'Activity Approved',
          description: 'Great! Your activity has been verified and points awarded',
          timestamp: act.createdAt.add(const Duration(hours: 24)),
          status: TimelineStatus.completed,
          icon: 'check_circle',
        ));
      } else if (act.isRejected) {
        timeline.add(ActivityTimelineItem(
          title: 'Activity Rejected',
          description: 'Unfortunately, your submission did not meet our criteria',
          timestamp: act.createdAt.add(const Duration(hours: 24)),
          status: TimelineStatus.rejected,
          icon: 'close_circle',
        ));
      } else if (act.isCompleted) {
        timeline.add(ActivityTimelineItem(
          title: 'Activity Completed',
          description: 'Your recycling activity has been processed successfully',
          timestamp: act.createdAt.add(const Duration(hours: 48)),
          status: TimelineStatus.completed,
          icon: 'check_circle',
        ));
      }
    } else {
      // Add pending review
      timeline.add(ActivityTimelineItem(
        title: 'Pending Review',
        description: 'Waiting for verification by our team',
        timestamp: DateTime.now(),
        status: TimelineStatus.pending,
        icon: 'clock',
      ));
    }

    // Sort by timestamp
    timeline.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  Future<void> deleteActivity() async {
    if (activity.value == null || !activity.value!.canDelete) return;

    try {
      isDeleting.value = true;

      // Simulate API call - in real app, call repository method
      await Future.delayed(const Duration(seconds: 1));

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Activity deleted successfully',
      );

      Get.back(result: true); // Return true to indicate deletion
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete activity',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> resubmitActivity() async {
    if (activity.value == null) return;

    try {
      isLoading.value = true;

      // Simulate API call - in real app, call repository method
      await Future.delayed(const Duration(seconds: 1));

      // Update activity status using model's method
      final updatedActivity = activity.value!.copyWith(status: 'pending');
      activity.value = updatedActivity;
      _generateTimeline();

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Activity resubmitted for review',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to resubmit activity',
      );
    } finally {
      isLoading.value = false;
    }
  }

  WasteCategory? getWasteCategory() {
    if (activity.value == null) return null;

    try {
      return _wasteCategories.firstWhere(
            (cat) => cat.categoryId == activity.value!.wasteCategoryId,
      );
    } catch (e) {
      // Return first category as fallback if not found
      return _wasteCategories.isNotEmpty ? _wasteCategories.first : null;
    }
  }

  // Environmental impact calculations based on activity weight
  double get carbonFootprintReduced {
    if (activity.value == null) return 0.0;
    return activity.value!.weight * 0.5; // Mock calculation: 0.5kg CO2 per kg waste
  }

  double get energySaved {
    if (activity.value == null) return 0.0;
    return activity.value!.weight * 2.1; // Mock calculation: 2.1 kWh per kg
  }

  double get waterSaved {
    if (activity.value == null) return 0.0;
    return activity.value!.weight * 3.7; // Mock calculation: 3.7L per kg
  }

  String get activityAgeText {
    if (activity.value == null) return '';

    final age = activity.value!.ageInHours;
    if (age < 1) {
      return 'Less than an hour ago';
    } else if (age < 24) {
      return '$age hours ago';
    } else {
      final days = (age / 24).floor();
      return '$days day${days > 1 ? 's' : ''} ago';
    }
  }
}

class ActivityTimelineItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final TimelineStatus status;
  final String icon;

  ActivityTimelineItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    required this.icon,
  });
}

enum TimelineStatus { completed, pending, rejected, inProgress }