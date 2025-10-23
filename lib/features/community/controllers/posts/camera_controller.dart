import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCameraController extends GetxController with WidgetsBindingObserver {
  // Camera state
  final _availableCameras = <CameraDescription>[].obs;
  final _cameraController = Rxn<CameraController>();
  final _isRearCamera = true.obs;
  final _isInitialized = false.obs;
  final _isCapturing = false.obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;
  final _flashMode = FlashMode.off.obs;
  final _errorMessage = ''.obs;

  // Video recording state
  final _isRecording = false.obs;
  final _isVideoMode = false.obs;
  final _isRecordingPaused = false.obs;
  final _recordedVideoPath = ''.obs;
  final _recordingDuration = Duration.zero.obs;
  final _recordingTimerDisplay = '00:00'.obs;

  // Timer
  Timer? _recordingTimer;

  // Getters
  List<CameraDescription> get cameras => _availableCameras;
  CameraController? get controller => _cameraController.value;
  bool get isRearCamera => _isRearCamera.value;
  bool get isInitialized => _isInitialized.value;
  bool get isCapturing => _isCapturing.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  FlashMode get flashMode => _flashMode.value;
  String get errorMessage => _errorMessage.value;
  bool get isRecording => _isRecording.value;
  bool get isVideoMode => _isVideoMode.value;
  bool get isRecordingPaused => _isRecordingPaused.value;
  String get recordedVideoPath => _recordedVideoPath.value;
  String get recordingTimer => _recordingTimerDisplay.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecordingTimer();
    _disposeController();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (_isRecording.value) {
        _stopVideoRecording();
      }
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

  // 开始录制计时器
  void _startRecordingTimer() {
    _recordingDuration.value = Duration.zero;
    _recordingTimerDisplay.value = '00:00';

    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRecording.value && !_isRecordingPaused.value) {
        _recordingDuration.value += Duration(seconds: 1);
        _updateTimerDisplay();
      }
    });
  }

  // 停止录制计时器
  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingDuration.value = Duration.zero;
    _recordingTimerDisplay.value = '00:00';
  }

  // 更新计时器显示
  void _updateTimerDisplay() {
    final minutes = _recordingDuration.value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _recordingDuration.value.inSeconds.remainder(60).toString().padLeft(2, '0');
    _recordingTimerDisplay.value = '$minutes:$seconds';
  }

  // 暂停录制
  Future<void> pauseVideoRecording() async {
    if (!_isRecording.value || _isRecordingPaused.value) return;

    try {
      await _cameraController.value?.pauseVideoRecording();
      _isRecordingPaused.value = true;
    } on CameraException catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pause video recording: ${e.description ?? e.code}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 继续录制
  Future<void> resumeVideoRecording() async {
    if (!_isRecording.value || !_isRecordingPaused.value) return;

    try {
      await _cameraController.value?.resumeVideoRecording();
      _isRecordingPaused.value = false;
    } on CameraException catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resume video recording: ${e.description ?? e.code}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 切换暂停/继续
  Future<void> toggleRecordingPause() async {
    if (_isRecordingPaused.value) {
      await resumeVideoRecording();
    } else {
      await pauseVideoRecording();
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      // 检查相机权限
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      if (!cameraStatus.isGranted) {
        _errorMessage.value = 'Camera permission is required to use this feature';
        return false;
      }

      // 如果是录像模式，检查麦克风权限
      if (_isVideoMode.value) {
        PermissionStatus microphoneStatus = await Permission.microphone.status;
        if (!microphoneStatus.isGranted) {
          microphoneStatus = await Permission.microphone.request();
        }
        if (!microphoneStatus.isGranted) {
          _errorMessage.value = 'Microphone permission is required for video recording';
          return false;
        }
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

      try {
        _availableCameras.value = await availableCameras();
      } catch (e) {
        _hasError.value = true;
        _errorMessage.value = 'Failed to access camera: $e';
        _isLoading.value = false;
        return;
      }

      if (_availableCameras.isEmpty) {
        _hasError.value = true;
        _errorMessage.value = 'No cameras available on this device';
        _isLoading.value = false;
        return;
      }

      CameraDescription selectedCamera;
      try {
        selectedCamera = _isRearCamera.value
            ? _availableCameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
        )
            : _availableCameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        selectedCamera = _availableCameras.first;
      }

      _disposeController();

      _cameraController.value = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: _isVideoMode.value,
      );

      await _cameraController.value!.initialize();

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
        errorMessage = 'Camera access was denied. Please grant camera permission.';
        break;
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        errorMessage = 'Camera access is restricted on this device.';
        break;
      case 'AudioAccessDenied':
        errorMessage = 'Audio access was denied.';
        break;
      case 'AudioAccessDeniedWithoutPrompt':
      case 'AudioAccessRestricted':
        errorMessage = 'Audio access is restricted on this device.';
        break;
      default:
        errorMessage = 'Camera error: ${e.description ?? e.code}';
        break;
    }

    _hasError.value = true;
    _errorMessage.value = errorMessage;
    _isLoading.value = false;
  }

  // 拍照
  Future<File?> capturePhoto() async {
    final currentController = _cameraController.value;
    if (currentController == null ||
        !currentController.value.isInitialized ||
        _isCapturing.value) {
      return null;
    }

    try {
      _isCapturing.value = true;
      final XFile image = await currentController.takePicture();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/camera_$timestamp.jpg';
      final imageFile = File(image.path);
      final savedFile = await imageFile.copy(imagePath);
      _isCapturing.value = false;
      return savedFile;
    } on CameraException catch (e) {
      _isCapturing.value = false;
      Get.snackbar(
        'Error',
        'Failed to capture photo: ${e.description ?? e.code}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      _isCapturing.value = false;
      Get.snackbar(
        'Error',
        'Failed to capture photo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // 开始录制视频
  Future<void> startVideoRecording() async {
    final currentController = _cameraController.value;
    if (currentController == null ||
        !currentController.value.isInitialized ||
        _isRecording.value) {
      return;
    }

    try {
      await currentController.startVideoRecording();
      _isRecording.value = true;
      _isRecordingPaused.value = false;
      _startRecordingTimer();
    } on CameraException catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start video recording: ${e.description ?? e.code}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 停止录制视频
  Future<File?> stopVideoRecording() async {
    if (!_isRecording.value) return null;

    try {
      final XFile videoFile = await _cameraController.value!.stopVideoRecording();
      _isRecording.value = false;
      _isRecordingPaused.value = false;
      _stopRecordingTimer();

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoPath = '${directory.path}/video_$timestamp.mp4';

      final originalFile = File(videoFile.path);
      final savedFile = await originalFile.copy(videoPath);

      _recordedVideoPath.value = savedFile.path;
      return savedFile;
    } on CameraException catch (e) {
      _isRecording.value = false;
      _isRecordingPaused.value = false;
      _stopRecordingTimer();
      Get.snackbar(
        'Error',
        'Failed to stop video recording: ${e.description ?? e.code}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // 切换拍照/录像模式
  Future<void> toggleCameraMode() async {
    if (_isRecording.value) {
      await _stopVideoRecording();
    }

    _isVideoMode.value = !_isVideoMode.value;
    await _reinitializeCamera();
  }

  Future<void> _stopVideoRecording() async {
    if (_isRecording.value) {
      await stopVideoRecording();
    }
  }

  Future<void> _reinitializeCamera() async {
    _isInitialized.value = false;
    _disposeController();
    await _initializeCamera();
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) return;

    if (_isRecording.value) {
      await _stopVideoRecording();
    }

    _isInitialized.value = false;
    _isRearCamera.value = !_isRearCamera.value;
    _disposeController();
    await _initializeCamera();
  }

  Future<void> toggleFlash() async {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return;
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

  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Cannot open settings: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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

  bool get isFlashSupported {
    final currentController = _cameraController.value;
    if (currentController == null || !currentController.value.isInitialized) return false;
    return _isRearCamera.value;
  }

  // 获取暂停/继续图标
  IconData get pauseResumeIcon {
    return _isRecordingPaused.value ? Iconsax.play : Iconsax.pause;
  }

  // 获取暂停/继续提示
  String get pauseResumeTooltip {
    return _isRecordingPaused.value ? 'Resume Recording' : 'Pause Recording';
  }

  // 获取录制按钮颜色
  Color get recordButtonColor {
    if (_isVideoMode.value) {
      return _isRecording.value ? Colors.red : Colors.white;
    }
    return Colors.white;
  }

  // 获取录制按钮内部颜色
  Color get recordButtonInnerColor {
    if (_isVideoMode.value) {
      return _isRecording.value ? Colors.red : Colors.white;
    }
    return Colors.white;
  }
}

