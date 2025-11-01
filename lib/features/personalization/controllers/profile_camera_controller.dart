import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileCameraController extends GetxController with WidgetsBindingObserver {
  final _availableCameras = <CameraDescription>[].obs;
  final _cameraController = Rxn<CameraController>();
  final _isRearCamera = true.obs;
  final _isInitialized = false.obs;
  final _isCapturing = false.obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;
  final _flashMode = FlashMode.off.obs;
  final _errorMessage = ''.obs;

  // Zoom variables
  final _currentZoom = 1.0.obs;
  final _minZoom = 1.0.obs;
  final _maxZoom = 1.0.obs;
  double _baseScale = 1.0;

  List<CameraDescription> get cameras => _availableCameras;
  CameraController? get controller => _cameraController.value;
  bool get isRearCamera => _isRearCamera.value;
  bool get isInitialized => _isInitialized.value;
  bool get isCapturing => _isCapturing.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  FlashMode get flashMode => _flashMode.value;
  String get errorMessage => _errorMessage.value;
  RxDouble get currentZoom => _currentZoom;
  RxDouble get minZoom => _minZoom;
  RxDouble get maxZoom => _maxZoom;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _disposeController() {
    _cameraController.value?.dispose();
    _cameraController.value = null;
    _isInitialized.value = false;
  }

  Future<bool> _checkPermissions() async {
    try {
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      if (!cameraStatus.isGranted) {
        _errorMessage.value = 'Camera permission is required';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage.value = 'Permission check failed: $e';
      return false;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;
      _errorMessage.value = '';

      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _hasError.value = true;
        _isLoading.value = false;
        return;
      }

      _availableCameras.value = await availableCameras();

      if (_availableCameras.isEmpty) {
        _hasError.value = true;
        _errorMessage.value = 'No cameras available';
        _isLoading.value = false;
        return;
      }

      CameraDescription selectedCamera = _isRearCamera.value
          ? _availableCameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _availableCameras.first,
      )
          : _availableCameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _availableCameras.first,
      );

      _disposeController();

      _cameraController.value = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.value!.initialize();

      // Initialize zoom levels
      _minZoom.value = await _cameraController.value!.getMinZoomLevel();
      _maxZoom.value = await _cameraController.value!.getMaxZoomLevel();
      _currentZoom.value = _minZoom.value;

      if (_isRearCamera.value) {
        await _setFlashMode(_flashMode.value);
      }

      _isInitialized.value = true;
      _isLoading.value = false;
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Failed to initialize camera: $e';
      _isLoading.value = false;
    }
  }

  Future<void> _setFlashMode(FlashMode mode) async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    try {
      await currentController.setFlashMode(mode);
      _flashMode.value = mode;
    } on CameraException catch (e) {
      print('Failed to set flash mode: ${e.description}');
    }
  }

  void _handleCameraError(CameraException e) {
    String errorMessage;
    switch (e.code) {
      case 'CameraAccessDenied':
        errorMessage = 'Camera access denied. Please grant permission.';
        break;
      default:
        errorMessage = 'Camera error: ${e.description ?? e.code}';
        break;
    }

    _hasError.value = true;
    _errorMessage.value = errorMessage;
    _isLoading.value = false;
  }

  // Zoom handlers
  void onScaleStart(ScaleStartDetails details) {
    _baseScale = _currentZoom.value;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final scale = (_baseScale * details.scale).clamp(_minZoom.value, _maxZoom.value);
    setZoomLevel(scale);
  }

  Future<void> setZoomLevel(double zoom) async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;

    try {
      await currentController.setZoomLevel(zoom);
      _currentZoom.value = zoom;
    } catch (e) {
      print('Failed to set zoom level: $e');
    }
  }

  Future<void> capturePhoto() async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized || _isCapturing.value) {
      return;
    }

    try {
      _isCapturing.value = true;
      final XFile image = await currentController.takePicture();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/profile_camera_$timestamp.jpg';
      final imageFile = File(image.path);
      final savedFile = await imageFile.copy(imagePath);
      _isCapturing.value = false;
      Get.back(result: savedFile);
    } on CameraException catch (e) {
      _isCapturing.value = false;
      Get.snackbar('Error', 'Failed to capture photo: ${e.description ?? e.code}');
    }
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) return;

    _isInitialized.value = false;
    _isRearCamera.value = !_isRearCamera.value;
    _disposeController();
    await _initializeCamera();
  }

  Future<void> toggleFlash() async {
    if (!_isRearCamera.value) return;

    FlashMode newMode;
    switch (_flashMode.value) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    await _setFlashMode(newMode);
  }

  Future<void> retryInitialize() async {
    await _initializeCamera();
  }

  IconData get flashIcon {
    switch (_flashMode.value) {
      case FlashMode.off:
        return Iconsax.flash_slash;
      case FlashMode.auto:
        return Iconsax.flash;
      case FlashMode.always:
        return Iconsax.flash_1;
      default:
        return Iconsax.flash_slash;
    }
  }

  String get flashTooltip {
    switch (_flashMode.value) {
      case FlashMode.off:
        return 'Flash Off';
      case FlashMode.auto:
        return 'Flash Auto';
      case FlashMode.always:
        return 'Flash On';
      default:
        return 'Flash Off';
    }
  }

  bool get isFlashSupported => _isRearCamera.value;
}