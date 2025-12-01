import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import '../../../features/event/models/location_model.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';
import 'location_input_controller.dart';

class LocationInputDialog extends StatelessWidget {
  final bool dark;
  final Location? initialLocation;
  final Function(Location) onLocationSelected;

  const LocationInputDialog({
    super.key,
    required this.dark,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 使用固定的 tag 避免每次都创建新的
    final controllerTag =
        'location_input_${initialLocation?.hashCode ?? 'new'}';

    return GetBuilder<LocationInputController>(
      init: LocationInputController(initialLocation: initialLocation),
      tag: controllerTag,
      builder: (controller) {
        return Dialog(
          backgroundColor:
              dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxHeight: 800, maxWidth: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(controller),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(FSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map Preview
                        Obx(() => _buildMapPreview(controller)),

                        const SizedBox(height: FSizes.spaceBtwSections),

                        // Address Form
                        _buildAddressForm(controller),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                _buildActionButtons(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(LocationInputController controller) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.location,
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
          const SizedBox(width: FSizes.sm),
          Text(
            'Event Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Iconsax.close_circle,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(LocationInputController controller) {
    if (!controller.showMap.value) {
      return _buildMapPlaceholder();
    }

    if (controller.isLoading.value) {
      return _buildLoadingWidget();
    }

    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            border: Border.all(
              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            child: _buildSafeGoogleMap(controller),
          ),
        ),
        const SizedBox(height: FSizes.sm),
        _buildMapControls(controller),
        // if (controller.errorMessage.value != null) ...[
        //   const SizedBox(height: FSizes.sm),
        //   _buildErrorMessage(controller),
        // ],
      ],
    );
  }

  Widget _buildSafeGoogleMap(LocationInputController controller) {
    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: controller.currentMarkerPosition.value ??
              const LatLng(3.1390, 101.6869),
          zoom: 15,
        ),
        onMapCreated: controller.onMapCreated,
        markers: controller.currentMarkerPosition.value != null
            ? {
                Marker(
                  markerId: const MarkerId('event_location'),
                  position: controller.currentMarkerPosition.value!,
                  draggable: true,
                  onDragEnd: controller.onMarkerDragEnd,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              }
            : {},
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        onCameraMove: (position) {
          // 添加空回调防止 disposed view 错误
        },
      );
    } catch (e) {
      print('GoogleMap widget error: $e');
      return _buildMapErrorWidget();
    }
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.map,
            size: 64,
            color:
                dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Map will appear here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FSizes.xl),
            child: Text(
              'Fill in all address fields below and wait 5 seconds to see the location on the map',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Searching location...',
            style: TextStyle(
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapErrorWidget() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 48,
            color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Map Error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: 12,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls(LocationInputController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(FSizes.sm),
                decoration: BoxDecoration(
                  color: (dark ? FColors.adminDarkInfo : FColors.adminLightInfo)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                  border: Border.all(
                    color:
                        dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 16,
                      color:
                          dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
                    ),
                    const SizedBox(width: FSizes.xs),
                    Expanded(
                      child: Text(
                        'You can drag the red marker to adjust the exact location (within 500m)',
                        style: TextStyle(
                          fontSize: 11,
                          color: dark
                              ? FColors.adminDarkText
                              : FColors.adminLightText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: FSizes.sm),
            IconButton(
              onPressed: controller.resetMarkerToOriginal,
              icon: Icon(
                Iconsax.refresh,
                color:
                    dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
              tooltip: 'Reset to original position',
            ),
          ],
        ),
        // const SizedBox(height: FSizes.xs),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: FSizes.sm, vertical: FSizes.xs),
        //   decoration: BoxDecoration(
        //     color: (dark ? FColors.adminDarkWarning : FColors.adminLightWarning).withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
        //     border: Border.all(
        //       color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
        //     ),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Icon(
        //         Iconsax.warning_2,
        //         size: 12,
        //         color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
        //       ),
        //       const SizedBox(width: FSizes.xs),
        //       Expanded(
        //         child: Text(
        //           'Marker must stay within 500m, on land, and within Malaysia',
        //           textAlign: TextAlign.left,
        //           style: TextStyle(
        //             fontSize: 10,
        //             color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  // Widget _buildErrorMessage(LocationInputController controller) {
  //   return Container(
  //     padding: const EdgeInsets.all(FSizes.sm),
  //     decoration: BoxDecoration(
  //       color: (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
  //       border: Border.all(
  //         color: dark ? FColors.adminDarkError : FColors.adminLightError,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Iconsax.danger,
  //           size: 16,
  //           color: dark ? FColors.adminDarkError : FColors.adminLightError,
  //         ),
  //         const SizedBox(width: FSizes.xs),
  //         Expanded(
  //           child: Text(
  //             controller.errorMessage.value!,
  //             style: TextStyle(
  //               fontSize: 11,
  //               color: dark ? FColors.adminDarkError : FColors.adminLightError,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAddressForm(LocationInputController controller) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // 🆕 Venue Name (Optional)
          TextFormField(
            controller: controller.venueNameController,
            decoration: _inputDecoration('Venue Name (Optional)', Iconsax.building),
            style: _inputTextStyle(),
            // 🆕 不添加 validator，表示非必填
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // Unit Number
          TextFormField(
            controller: controller.unitNoController,
            decoration:
            _inputDecoration('Unit/Building Number *', Iconsax.home_2),
            style: _inputTextStyle(),
            validator: (value) =>
                FValidator.validateEmptyText('Unit number', value),
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // Area/Street
          TextFormField(
            controller: controller.areaController,
            decoration: _inputDecoration('Area/Street *', Iconsax.map),
            style: _inputTextStyle(),
            validator: (value) =>
                FValidator.validateEmptyText('Area/Street', value),
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // Postcode and City Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: controller.postcodeController,
                  decoration: _inputDecoration('Postcode *', Iconsax.location),
                  style: _inputTextStyle(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (value.trim().length < 5) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: controller.cityController,
                  decoration: _inputDecoration('City *', Iconsax.building),
                  style: _inputTextStyle(),
                  validator: (value) =>
                      FValidator.validateEmptyText('City', value),
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwInputFields),

          // State
          DropdownButtonFormField<String>(
            value: controller.stateController.text.isEmpty
                ? null
                : controller.stateController.text,
            decoration: _inputDecoration('State *', Iconsax.global),
            style: _inputTextStyle(),
            dropdownColor:
            dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
            items: _malaysianStates.map((String state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(state, style: _inputTextStyle()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.stateController.text = newValue;
              }
            },
            validator: (value) => value == null ? 'Please select state' : null,
          ),
          const SizedBox(height: FSizes.xs),
          Obx(() => Text(
            controller.isEditingMode.value
                ? controller.hasChanges.value
                ? 'Address changed. Fill all fields and wait 5 seconds to update map'
                : 'Edit the address fields to update map location'
                : 'Fill in all address fields and wait 5 seconds for automatic map validation',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LocationInputController controller) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color:
                      dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                ),
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Obx(() => ElevatedButton(
              onPressed: controller.isValidLocation.value
                  ? () {
                final location = controller.getLocation();
                if (location != null) {
                  // 立即关闭对话框
                  if (Get.isDialogOpen == true) {
                    Get.back();
                  }

                  // 然后在下一帧执行回调
                  Future.delayed(Duration.zero, () {
                    controller.resetChangeDetection();
                    onLocationSelected(location);
                  });
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: dark
                    ? FColors.adminDarkPrimary
                    : FColors.adminLightPrimary,
                disabledBackgroundColor: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
                padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
              ),
              child: const Text(
                'Save Location',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: dark
            ? FColors.adminDarkTextSecondary
            : FColors.adminLightTextSecondary,
      ),
      prefixIcon: Icon(
        icon,
        color: dark
            ? FColors.adminDarkTextSecondary
            : FColors.adminLightTextSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkError : FColors.adminLightError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        borderSide: BorderSide(
          color: dark ? FColors.adminDarkError : FColors.adminLightError,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: dark
          ? FColors.adminDarkSurfaceVariant
          : FColors.adminLightSurfaceVariant,
    );
  }

  TextStyle _inputTextStyle() {
    return TextStyle(
      color: dark ? FColors.adminDarkText : FColors.adminLightText,
    );
  }

  static const List<String> _malaysianStates = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Kuala Lumpur',
    'Labuan',
    'Malacca',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Putrajaya',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
  ];
}
