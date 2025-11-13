import 'dart:io';
import 'package:fyp/features/personalization/models/recycle_activity_model.dart';

/// Helper class to pair activity with its image file
class ActivityWithImage {
  final RecyclingActivity activity;
  final File? imageFile;

  ActivityWithImage({
    required this.activity,
    this.imageFile,
  });

  bool get hasImage => imageFile != null;
}