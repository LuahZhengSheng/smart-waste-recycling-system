import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/services/google_places/google_maps_service.dart';
import '../../../features/event/models/address_model.dart';
import '../../../features/event/models/geopoint_model.dart';
import '../../../features/event/models/location_model.dart';
import '../../../utils/popups/admin_loaders.dart';

class LocationInputController extends GetxController {
  final GoogleMapsService _mapsService = GoogleMapsService();

  // Text controllers
  late TextEditingController venueNameController;
  late TextEditingController unitNoController;
  late TextEditingController areaController;
  late TextEditingController postcodeController;
  late TextEditingController cityController;
  late TextEditingController stateController;

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool showMap = false.obs;
  final RxBool isValidLocation = false.obs;
  final RxnString errorMessage = RxnString();

  // 编辑状态管理
  final RxBool isEditingMode = false.obs;
  final RxBool hasChanges = false.obs;
  final RxBool _isInitialLoadComplete = false.obs; // 新增：初始加载完成标志

  String _originalVenueName = '';
  String _originalUnitNo = '';
  String _originalArea = '';
  String _originalPostcode = '';
  String _originalCity = '';
  String _originalState = '';
  LatLng? _originalMarkerPosition;

  // Map related
  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  set mapController(GoogleMapController? controller) {
    _mapController = controller;
  }

  final Rx<LatLng?> currentMarkerPosition = Rx<LatLng?>(null);
  final Rx<LatLng?> originalMarkerPosition = Rx<LatLng?>(null);
  final RxString placeId = ''.obs;
  final RxString validatedAddress = ''.obs;

  // 搜索位置和距离限制
  final Rx<LatLng?> _searchCenter = Rx<LatLng?>(null);
  static const double _maxDistanceKm = 0.5; // 0.5公里限制

  Timer? _debounce;
  final Location? initialLocation;

  LocationInputController({this.initialLocation});

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupAddressListeners();

    // Load initial location if provided
    if (initialLocation != null) {
      _loadInitialLocation();
    } else {
      // 新增：如果不是编辑模式，设置初始加载完成
      _isInitialLoadComplete.value = true;
    }
  }

  void _initializeControllers() {
    venueNameController = TextEditingController();
    unitNoController = TextEditingController();
    areaController = TextEditingController();
    postcodeController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
  }

  void _loadInitialLocation() {
    final address = initialLocation!.address;
    venueNameController.text = initialLocation!.venueName;
    unitNoController.text = address.unitNo;
    areaController.text = address.area;
    postcodeController.text = address.postcode;
    cityController.text = address.city;
    stateController.text = address.state;

    if (_isAddressComplete()) {
      final geoPoint = initialLocation!.geoPoint;
      currentMarkerPosition.value = LatLng(geoPoint.latitude, geoPoint.longitude);
      originalMarkerPosition.value = LatLng(geoPoint.latitude, geoPoint.longitude);
      _searchCenter.value = LatLng(geoPoint.latitude, geoPoint.longitude);
      placeId.value = address.placeId ?? '';
      validatedAddress.value = address.formattedAddress;
      showMap.value = true;
      isValidLocation.value = true;

      // 设置编辑模式和原始地址
      isEditingMode.value = true;
      _saveOriginalAddress();
      _originalMarkerPosition = LatLng(geoPoint.latitude, geoPoint.longitude);

      // 新增：初始加载完成
      _isInitialLoadComplete.value = true;
    } else {
      // 新增：即使地址不完整也标记初始加载完成
      _isInitialLoadComplete.value = true;
    }
  }

  void _setupAddressListeners() {
    // 为所有地址字段添加监听器
    unitNoController.addListener(_onAddressFieldChanged);
    areaController.addListener(_onAddressFieldChanged);
    postcodeController.addListener(_onAddressFieldChanged);
    cityController.addListener(_onAddressFieldChanged);
    stateController.addListener(_onAddressFieldChanged);
  }

  void _onAddressFieldChanged() {
    // 检查是否有变化
    _checkForChanges();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 关键修改：只有在初始加载完成后才触发搜索
    if (!_isInitialLoadComplete.value) {
      return;
    }

    // 如果是在编辑模式且没有变化，不触发搜索
    if (isEditingMode.value && !hasChanges.value) {
      return;
    }

    // 检查所有字段是否都已填写
    if (!_isAddressComplete()) {
      showMap.value = false;
      isValidLocation.value = false;
      currentMarkerPosition.value = null;
      originalMarkerPosition.value = null;
      _searchCenter.value = null;
      return;
    }

    _debounce = Timer(const Duration(seconds: 5), () {
      // 再次检查条件，确保在计时器触发时条件仍然满足
      if (_isAddressComplete() &&
          (hasChanges.value || !isEditingMode.value) &&
          _isInitialLoadComplete.value) {
        _searchLocation();
      }
    });
  }

  bool _isAddressComplete() {
    return unitNoController.text.trim().isNotEmpty &&
        areaController.text.trim().isNotEmpty &&
        postcodeController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        stateController.text.trim().isNotEmpty;
  }

  String get _formattedAddress {
    return '${unitNoController.text.trim()}, ${areaController.text.trim()}, ${postcodeController.text.trim()} ${cityController.text.trim()}, ${stateController.text.trim()}';
  }

  // ==================== 变化检测核心方法 ====================
  void _checkForChanges() {
    if (isEditingMode.value) {
      // 编辑模式：检查实际变化
      final hasVenueNameChanged = venueNameController.text.trim() != _originalVenueName;
      final hasUnitNoChanged = unitNoController.text.trim() != _originalUnitNo;
      final hasAreaChanged = areaController.text.trim() != _originalArea;
      final hasPostcodeChanged = postcodeController.text.trim() != _originalPostcode;
      final hasCityChanged = cityController.text.trim() != _originalCity;
      final hasStateChanged = stateController.text.trim() != _originalState;

      // 检查标记位置变化
      bool hasMarkerMoved = false;
      if (currentMarkerPosition.value != null && _originalMarkerPosition != null) {
        hasMarkerMoved = currentMarkerPosition.value!.latitude != _originalMarkerPosition!.latitude ||
            currentMarkerPosition.value!.longitude != _originalMarkerPosition!.longitude;
      } else {
        hasMarkerMoved = currentMarkerPosition.value != _originalMarkerPosition;
      }

      hasChanges.value = hasUnitNoChanged || hasAreaChanged || hasPostcodeChanged ||
          hasCityChanged || hasStateChanged || hasMarkerMoved;

      print('🔄 Change Detection - Editing Mode:');
      print('   📝 UnitNo Changed: $hasUnitNoChanged');
      print('   📝 Area Changed: $hasAreaChanged');
      print('   📝 Postcode Changed: $hasPostcodeChanged');
      print('   📝 City Changed: $hasCityChanged');
      print('   📝 State Changed: $hasStateChanged');
      print('   📍 Marker Moved: $hasMarkerMoved');
      print('   ✅ Has Changes: ${hasChanges.value}');
    } else {
      // 新建模式：只要有完整地址就认为有变化
      hasChanges.value = _isAddressComplete();

      print('🔄 Change Detection - New Mode:');
      print('   📝 Address Complete: ${_isAddressComplete()}');
      print('   ✅ Has Changes: ${hasChanges.value}');
    }
  }

  void _saveOriginalAddress() {
    _originalVenueName = venueNameController.text.trim();
    _originalUnitNo = unitNoController.text.trim();
    _originalArea = areaController.text.trim();
    _originalPostcode = postcodeController.text.trim();
    _originalCity = cityController.text.trim();
    _originalState = stateController.text.trim();
    _originalMarkerPosition = currentMarkerPosition.value;

    print('💾 Saved Original Address:');
    print('   📝 UnitNo: "$_originalUnitNo"');
    print('   📝 Area: "$_originalArea"');
    print('   📝 Postcode: "$_originalPostcode"');
    print('   📝 City: "$_originalCity"');
    print('   📝 State: "$_originalState"');
    print('   📍 Marker: $_originalMarkerPosition');
  }

  // 重置变化状态（当用户保存后调用）
  void resetChangeDetection() {
    if (isEditingMode.value) {
      _saveOriginalAddress();
      hasChanges.value = false;
      print('🔄 Change detection reset');
    }
  }

  // 检查是否可以保存（用于启用/禁用保存按钮）
  bool get canSaveChanges {
    if (!isValidLocation.value) return false;
    if (!isEditingMode.value) return true; // 新建模式只要有有效位置就可以保存
    return hasChanges.value; // 编辑模式需要有变化
  }

  // 获取变化摘要（用于显示给用户）
  List<String> getChangedFields() {
    final List<String> changes = [];

    if (!isEditingMode.value) return ['New Location'];

    if (unitNoController.text.trim() != _originalUnitNo) {
      changes.add('Unit Number');
    }
    if (areaController.text.trim() != _originalArea) {
      changes.add('Area');
    }
    if (postcodeController.text.trim() != _originalPostcode) {
      changes.add('Postcode');
    }
    if (cityController.text.trim() != _originalCity) {
      changes.add('City');
    }
    if (stateController.text.trim() != _originalState) {
      changes.add('State');
    }
    if (currentMarkerPosition.value != _originalMarkerPosition) {
      changes.add('Location Marker');
    }

    return changes;
  }
  // ==================== 变化检测核心方法结束 ====================

  // 地图创建回调方法
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // 如果已经有位置，安全地移动相机
    if (currentMarkerPosition.value != null) {
      _safeMoveCamera(currentMarkerPosition.value!);
    }
  }

  void _safeMoveCamera(LatLng position) {
    try {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    } catch (e) {
      print('Safe camera move error: $e');
    }
  }

  Future<void> _searchLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final address = _formattedAddress;
      final result = await _mapsService.searchLocation(address);

      if (result == null) {
        errorMessage.value = 'Location not found in Malaysia. Please enter a valid Malaysian address.';
        showMap.value = false;
        isValidLocation.value = false;
        currentMarkerPosition.value = null;
        originalMarkerPosition.value = null;
        _searchCenter.value = null;
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Location',
          message: 'Location not found or outside Malaysia',
        );
      } else {
        placeId.value = result['placeId'];
        validatedAddress.value = result['formattedAddress'];
        final latLng = LatLng(result['latitude'], result['longitude']);
        currentMarkerPosition.value = latLng;
        originalMarkerPosition.value = latLng;
        _searchCenter.value = latLng; // 设置搜索中心点
        showMap.value = true;
        isValidLocation.value = true;
        errorMessage.value = null;

        // 更新原始地址（如果是编辑模式）
        if (isEditingMode.value) {
          _saveOriginalAddress();
          hasChanges.value = false;
        }

        // 安全地移动相机
        _safeMoveCamera(latLng);
      }
    } catch (e) {
      errorMessage.value = 'Error searching location: ${e.toString()}';
      FAdminLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to search location',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 计算两点之间的距离（公里）
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371.0; // 地球半径（公里）

    final double lat1 = start.latitude * (pi / 180.0);
    final double lon1 = start.longitude * (pi / 180.0);
    final double lat2 = end.latitude * (pi / 180.0);
    final double lon2 = end.longitude * (pi / 180.0);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // 检查是否在海上（简单的水域检测）
  bool _isInWater(LatLng position) {
    // 马来西亚主要水域的边界框（简化版本）
    final malaysiaWaterAreas = [
      // 马六甲海峡
      LatLng(1.0, 100.0), // 西北角
      LatLng(4.0, 102.0), // 东南角

      // 南中国海
      LatLng(1.0, 104.0), // 西南角
      LatLng(6.0, 110.0), // 东北角

      // 苏禄海
      LatLng(4.0, 115.0), // 西南角
      LatLng(7.0, 120.0), // 东北角
    ];

    // 简化检查：如果坐标在这些水域边界框内，认为是海上
    for (int i = 0; i < malaysiaWaterAreas.length; i += 2) {
      final northwest = malaysiaWaterAreas[i];
      final southeast = malaysiaWaterAreas[i + 1];

      if (position.latitude >= northwest.latitude &&
          position.latitude <= southeast.latitude &&
          position.longitude >= northwest.longitude &&
          position.longitude <= southeast.longitude) {
        return true;
      }
    }

    return false;
  }

  Future<void> onMarkerDragEnd(LatLng newPosition) async {
    try {
      isLoading.value = true;

      // 1. 检查是否在马来西亚境内
      final isInMalaysia = await _mapsService.isWithinMalaysia(
        newPosition.latitude,
        newPosition.longitude,
      );

      if (!isInMalaysia) {
        errorMessage.value = 'Location must be within Malaysia';
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Location',
          message: 'You cannot place the marker outside Malaysia',
        );
        // Reset to original position
        currentMarkerPosition.value = originalMarkerPosition.value;
        isLoading.value = false;
        return;
      }

      // 2. 检查是否在海上
      if (_isInWater(newPosition)) {
        errorMessage.value = 'Marker cannot be placed in water areas';
        FAdminLoaders.errorSnackBar(
          title: 'Invalid Location',
          message: 'Please place the marker on land',
        );
        // Reset to original position
        currentMarkerPosition.value = originalMarkerPosition.value;
        isLoading.value = false;
        return;
      }

      // 3. 检查是否在5公里范围内
      if (_searchCenter.value != null) {
        final distance = _calculateDistance(_searchCenter.value!, newPosition);
        if (distance > _maxDistanceKm) {
          FAdminLoaders.errorSnackBar(
            title: 'Out of Range',
            message: 'Please keep the marker within 500m of the original location',
          );
          // Reset to original position
          currentMarkerPosition.value = originalMarkerPosition.value;
          isLoading.value = false;
          return;
        }
      }

      // 4. 获取新位置的地址信息
      final newPlaceInfo = await _mapsService.searchLocationByCoordinates(
        newPosition.latitude,
        newPosition.longitude,
      );

      if (newPlaceInfo != null) {
        // 更新位置和placeId，但保持地址字段不变
        currentMarkerPosition.value = newPosition;
        placeId.value = newPlaceInfo['placeId'];
        validatedAddress.value = newPlaceInfo['formattedAddress'];
        errorMessage.value = null;

        // 标记有变化
        if (isEditingMode.value) {
          hasChanges.value = true;
        }

        print('📍 Marker moved to new location:');
        print('   📍 New Coordinates: (${newPosition.latitude}, ${newPosition.longitude})');
        print('   📍 New Place ID: ${newPlaceInfo['placeId']}');
        print('   📍 New Address: ${newPlaceInfo['formattedAddress']}');
        print('   🔄 Has Changes: ${hasChanges.value}');
      } else {
        errorMessage.value = 'Unable to get address information for new location';
        currentMarkerPosition.value = originalMarkerPosition.value;
      }
    } catch (e) {
      errorMessage.value = 'Error validating location: $e';
      currentMarkerPosition.value = originalMarkerPosition.value;
    } finally {
      isLoading.value = false;
    }
  }

  void resetMarkerToOriginal() {
    if (originalMarkerPosition.value != null) {
      currentMarkerPosition.value = originalMarkerPosition.value;
      _safeMoveCamera(originalMarkerPosition.value!);
      // 标记有变化
      if (isEditingMode.value) {
        hasChanges.value = true;
      }
      print('🔄 Marker reset to original position');
      print('   🔄 Has Changes: ${hasChanges.value}');
    }
  }

  Location? getLocation() {
    if (!isValidLocation.value || currentMarkerPosition.value == null) {
      print('❌ Cannot get location: isValidLocation = ${isValidLocation.value}, currentMarkerPosition = ${currentMarkerPosition.value}');
      return null;
    }

    final address = Address(
      unitNo: unitNoController.text.trim(),
      area: areaController.text.trim(),
      postcode: postcodeController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      fullAddress: _formattedAddress,
      placeId: placeId.value,
    );

    final geoPoint = GeoPointModel(
      latitude: currentMarkerPosition.value!.latitude,
      longitude: currentMarkerPosition.value!.longitude,
    );

    // 打印保存的地址信息
    print('📍 Saving Location:');
    print('   📍 Venue Name: ${venueNameController.text.trim()}'); // 🆕
    print('   📍 Unit No: ${address.unitNo}');
    print('   📍 Area: ${address.area}');
    print('   📍 Postcode: ${address.postcode}');
    print('   📍 City: ${address.city}');
    print('   📍 State: ${address.state}');
    print('   📍 Full Address: ${address.fullAddress}');
    print('   📍 Place ID: ${address.placeId}');
    print('   📍 Coordinates: (${geoPoint.latitude}, ${geoPoint.longitude})');
    print('   📍 Formatted Address: ${address.formattedAddress}');
    print('   📍 Has Place ID: ${address.hasPlaceId}');

    return Location(venueName: venueNameController.text.trim(), address: address, geoPoint: geoPoint);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    venueNameController.dispose();
    unitNoController.dispose();
    areaController.dispose();
    postcodeController.dispose();
    cityController.dispose();
    stateController.dispose();

    // 安全地处理 mapController
    _safeDisposeMapController();

    super.onClose();
  }

  void _safeDisposeMapController() {
    try {
      if (_mapController != null) {
        // 延迟 dispose 以避免在 build 过程中调用
        Future.delayed(Duration.zero, () {
          _mapController?.dispose();
          _mapController = null;
        });
      }
    } catch (e) {
      print('Safe dispose error: $e');
    }
  }
}