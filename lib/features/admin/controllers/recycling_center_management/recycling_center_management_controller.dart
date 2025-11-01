import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../event/models/location_model.dart';
import '../../../event/models/address_model.dart';
import '../../../event/models/geopoint_model.dart';
import '../../../recycling_center/models/partner_recycling_center_model.dart';
import '../../screens/recycling_center_management/add_recycling_center/add_recycling_center.dart';
import '../../screens/recycling_center_management/recycling_center_detail/Recycling_center_detail.dart';
import '../../screens/recycling_center_management/recycling_center_management.dart';

class PartnerCenterManagementController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Observables
  final RxList<PartnerRecyclingCenter> allCenters = <PartnerRecyclingCenter>[].obs;
  final RxList<PartnerRecyclingCenter> filteredCenters = <PartnerRecyclingCenter>[].obs;
  final RxList<String> selectedCenterIds = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 25.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxBool isSelectAllChecked = false.obs;
  final RxMap<String, dynamic> activeFilters = <String, dynamic>{
    'status': null,
    'staffRange': null,
    'city': null,
    'state': null,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadCenters();

    // Listen to search changes
    debounce(searchQuery, (_) => applyFiltersAndSearch(), time: const Duration(milliseconds: 500));

    // Listen to filter changes
    ever(activeFilters, (_) => applyFiltersAndSearch());

    // Listen to selection changes
    ever(selectedCenterIds, (_) => updateSelectAllState());
  }

  void loadCenters() {
    // Mock data - replace with actual API call
    allCenters.value = _generateMockCenters();
    filteredCenters.value = List.from(allCenters);
  }

  List<PartnerRecyclingCenter> _generateMockCenters() {
    final now = DateTime.now();
    return [
      PartnerRecyclingCenter(
        centerId: '1',
        name: 'EcoCenter KL',
        email: 'contact@ecocenter-kl.com',
        phoneNo: '0123456789',
        website: 'https://ecocenter-kl.com',
        centerLocation: Location(
          address: const Address(
            unitNo: 'Block A, Lot 123',
            area: 'Taman Eco',
            postcode: '50100',
            city: 'Kuala Lumpur',
            state: 'Selangor',
          ),
          geoPoint: const GeoPointModel(latitude: 3.1390, longitude: 101.6869),
        ),
        image: 'https://example.com/ecocenter-kl.jpg',
        openingHours: {
          'periods': [
            {
              'open': {'day': 0, 'time': '0900'}, // Sunday
              'close': {'day': 0, 'time': '1500'},
            },
            {
              'open': {'day': 1, 'time': '0800'}, // Monday
              'close': {'day': 1, 'time': '1800'},
            },
            {
              'open': {'day': 2, 'time': '0800'}, // Tuesday
              'close': {'day': 2, 'time': '1800'},
            },
            {
              'open': {'day': 3, 'time': '0800'}, // Wednesday
              'close': {'day': 3, 'time': '1800'},
            },
            {
              'open': {'day': 4, 'time': '0800'}, // Thursday
              'close': {'day': 4, 'time': '1800'},
            },
            {
              'open': {'day': 5, 'time': '0800'}, // Friday
              'close': {'day': 5, 'time': '1800'},
            },
            {
              'open': {'day': 6, 'time': '0900'}, // Saturday
              'close': {'day': 6, 'time': '1500'},
            },
          ],
          'weekday_text': [
            'Monday: 8:00 AM – 6:00 PM',
            'Tuesday: 8:00 AM – 6:00 PM',
            'Wednesday: 8:00 AM – 6:00 PM',
            'Thursday: 8:00 AM – 6:00 PM',
            'Friday: 8:00 AM – 6:00 PM',
            'Saturday: 9:00 AM – 3:00 PM',
            'Sunday: 9:00 AM – 3:00 PM',
          ],
        },
        acceptedMaterials: ['plastic', 'paper', 'glass', 'metal', 'electronics'],
        numberOfStaff: 15,
        createdAt: now.subtract(const Duration(days: 120)),
        status: 'active',
        rating: 4.5,
        userRatingsTotal: 128,
        placeId: 'ChIJP5jIRfdizTERr2dFDD2K9No',
      ),
      PartnerRecyclingCenter(
        centerId: '2',
        name: 'GreenHub Johor',
        email: 'info@greenhub-johor.com',
        phoneNo: '0187654321',
        website: 'https://greenhub-johor.com',
        centerLocation: Location(
          address: const Address(
            unitNo: '45, Jalan Hijau',
            area: 'Taman Hijau',
            postcode: '81100',
            city: 'Johor Bahru',
            state: 'Johor',
          ),
          geoPoint: const GeoPointModel(latitude: 1.4927, longitude: 103.7414),
        ),
        image: 'https://example.com/greenhub-johor.jpg',
        openingHours: {
          'periods': [
            {
              'open': {'day': 1, 'time': '0900'}, // Monday
              'close': {'day': 1, 'time': '1700'},
            },
            {
              'open': {'day': 2, 'time': '0900'}, // Tuesday
              'close': {'day': 2, 'time': '1700'},
            },
            {
              'open': {'day': 3, 'time': '0900'}, // Wednesday
              'close': {'day': 3, 'time': '1700'},
            },
            {
              'open': {'day': 4, 'time': '0900'}, // Thursday
              'close': {'day': 4, 'time': '1700'},
            },
            {
              'open': {'day': 5, 'time': '0900'}, // Friday
              'close': {'day': 5, 'time': '1700'},
            },
            {
              'open': {'day': 6, 'time': '1000'}, // Saturday
              'close': {'day': 6, 'time': '1400'},
            },
          ],
          'weekday_text': [
            'Monday: 9:00 AM – 5:00 PM',
            'Tuesday: 9:00 AM – 5:00 PM',
            'Wednesday: 9:00 AM – 5:00 PM',
            'Thursday: 9:00 AM – 5:00 PM',
            'Friday: 9:00 AM – 5:00 PM',
            'Saturday: 10:00 AM – 2:00 PM',
            'Sunday: Closed',
          ],
        },
        acceptedMaterials: ['plastic', 'paper', 'glass'],
        numberOfStaff: 8,
        createdAt: now.subtract(const Duration(days: 90)),
        status: 'active',
        rating: 4.2,
        userRatingsTotal: 89,
        placeId: 'ChIJy2W5xY5ZzDER4FpDZ6wM7YQ',
      ),
      PartnerRecyclingCenter(
        centerId: '3',
        name: 'RecyclePro Penang',
        email: 'hello@recyclepro-penang.com',
        phoneNo: '0198765432',
        website: 'https://recyclepro-penang.com',
        centerLocation: Location(
          address: const Address(
            unitNo: '88, Lebuh Recycling',
            area: 'Georgetown',
            postcode: '10200',
            city: 'George Town',
            state: 'Penang',
          ),
          geoPoint: const GeoPointModel(latitude: 5.4141, longitude: 100.3288),
        ),
        image: 'https://example.com/recyclepro-penang.jpg',
        openingHours: {
          'periods': [
            {
              'open': {'day': 1, 'time': '0830'}, // Monday
              'close': {'day': 1, 'time': '1730'},
            },
            {
              'open': {'day': 2, 'time': '0830'}, // Tuesday
              'close': {'day': 2, 'time': '1730'},
            },
            {
              'open': {'day': 3, 'time': '0830'}, // Wednesday
              'close': {'day': 3, 'time': '1730'},
            },
            {
              'open': {'day': 4, 'time': '0830'}, // Thursday
              'close': {'day': 4, 'time': '1730'},
            },
            {
              'open': {'day': 5, 'time': '0830'}, // Friday
              'close': {'day': 5, 'time': '1730'},
            },
            {
              'open': {'day': 6, 'time': '0900'}, // Saturday
              'close': {'day': 6, 'time': '1600'},
            },
          ],
          'weekday_text': [
            'Monday: 8:30 AM – 5:30 PM',
            'Tuesday: 8:30 AM – 5:30 PM',
            'Wednesday: 8:30 AM – 5:30 PM',
            'Thursday: 8:30 AM – 5:30 PM',
            'Friday: 8:30 AM – 5:30 PM',
            'Saturday: 9:00 AM – 4:00 PM',
            'Sunday: Closed',
          ],
        },
        acceptedMaterials: ['plastic', 'paper', 'glass', 'metal', 'electronics', 'textiles'],
        numberOfStaff: 25,
        createdAt: now.subtract(const Duration(days: 200)),
        status: 'active',
        rating: 4.7,
        userRatingsTotal: 156,
        placeId: 'ChIJy2W5xY5ZzDER4FpDZ6wM7YQ',
      ),
      PartnerRecyclingCenter(
        centerId: '4',
        name: 'EcoStation Melaka',
        email: 'support@ecostation-melaka.com',
        phoneNo: '0167891234',
        website: 'https://ecostation-melaka.com',
        centerLocation: Location(
          address: const Address(
            unitNo: '22A, Jalan Aman',
            area: 'Bandar Hilir',
            postcode: '75000',
            city: 'Melaka',
            state: 'Melaka',
          ),
          geoPoint: const GeoPointModel(latitude: 2.2055, longitude: 102.2501),
        ),
        image: 'https://example.com/ecostation-melaka.jpg',
        openingHours: {
          'periods': [
            {
              'open': {'day': 1, 'time': '0900'}, // Monday
              'close': {'day': 1, 'time': '1800'},
            },
            {
              'open': {'day': 2, 'time': '0900'}, // Tuesday
              'close': {'day': 2, 'time': '1800'},
            },
            {
              'open': {'day': 3, 'time': '0900'}, // Wednesday
              'close': {'day': 3, 'time': '1800'},
            },
            {
              'open': {'day': 4, 'time': '0900'}, // Thursday
              'close': {'day': 4, 'time': '1800'},
            },
            {
              'open': {'day': 5, 'time': '0900'}, // Friday
              'close': {'day': 5, 'time': '1800'},
            },
          ],
          'weekday_text': [
            'Monday: 9:00 AM – 6:00 PM',
            'Tuesday: 9:00 AM – 6:00 PM',
            'Wednesday: 9:00 AM – 6:00 PM',
            'Thursday: 9:00 AM – 6:00 PM',
            'Friday: 9:00 AM – 6:00 PM',
            'Saturday: Closed',
            'Sunday: Closed',
          ],
        },
        acceptedMaterials: ['plastic', 'paper'],
        numberOfStaff: 3,
        createdAt: now.subtract(const Duration(days: 45)),
        status: 'inactive',
        rating: 3.8,
        userRatingsTotal: 42,
        placeId: 'ChIJy2W5xY5ZzDER4FpDZ6wM7YQ',
      ),
      PartnerRecyclingCenter(
        centerId: '5',
        name: 'WasteWise Selangor',
        email: 'admin@wastewise-selangor.com',
        phoneNo: '0156781234',
        website: 'https://wastewise-selangor.com',
        centerLocation: Location(
          address: const Address(
            unitNo: '15, Jalan Sustainable',
            area: 'Shah Alam',
            postcode: '40000',
            city: 'Shah Alam',
            state: 'Selangor',
          ),
          geoPoint: const GeoPointModel(latitude: 3.0733, longitude: 101.5185),
        ),
        image: 'https://example.com/wastewise-selangor.jpg',
        openingHours: {
          'periods': [
            {
              'open': {'day': 0, 'time': '0900'}, // Sunday
              'close': {'day': 0, 'time': '1500'},
            },
            {
              'open': {'day': 1, 'time': '0730'}, // Monday
              'close': {'day': 1, 'time': '1900'},
            },
            {
              'open': {'day': 2, 'time': '0730'}, // Tuesday
              'close': {'day': 2, 'time': '1900'},
            },
            {
              'open': {'day': 3, 'time': '0730'}, // Wednesday
              'close': {'day': 3, 'time': '1900'},
            },
            {
              'open': {'day': 4, 'time': '0730'}, // Thursday
              'close': {'day': 4, 'time': '1900'},
            },
            {
              'open': {'day': 5, 'time': '0730'}, // Friday
              'close': {'day': 5, 'time': '1900'},
            },
            {
              'open': {'day': 6, 'time': '0800'}, // Saturday
              'close': {'day': 6, 'time': '1700'},
            },
          ],
          'weekday_text': [
            'Monday: 7:30 AM – 7:00 PM',
            'Tuesday: 7:30 AM – 7:00 PM',
            'Wednesday: 7:30 AM – 7:00 PM',
            'Thursday: 7:30 AM – 7:00 PM',
            'Friday: 7:30 AM – 7:00 PM',
            'Saturday: 8:00 AM – 5:00 PM',
            'Sunday: 9:00 AM – 3:00 PM',
          ],
        },
        acceptedMaterials: ['plastic', 'paper', 'glass', 'metal', 'electronics', 'textiles', 'batteries'],
        numberOfStaff: 42,
        createdAt: now.subtract(const Duration(days: 300)),
        status: 'active',
        rating: 4.9,
        userRatingsTotal: 234,
        placeId: 'ChIJy2W5xY5ZzDER4FpDZ6wM7YQ',
      ),
    ];
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void applyFiltersAndSearch() {
    List<PartnerRecyclingCenter> result = List.from(allCenters);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((center) {
        return center.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            center.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            center.phoneNo.contains(searchQuery.value) ||
            center.centerLocation.address.city.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            center.centerLocation.address.state.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply filters
    if (activeFilters['status'] != null) {
      result = result.where((center) => center.status == activeFilters['status']).toList();
    }

    if (activeFilters['staffRange'] != null) {
      result = result.where((center) {
        switch (activeFilters['staffRange']) {
          case 'small':
            return center.numberOfStaff <= 10;
          case 'medium':
            return center.numberOfStaff > 10 && center.numberOfStaff <= 30;
          case 'large':
            return center.numberOfStaff > 30;
          default:
            return true;
        }
      }).toList();
    }

    if (activeFilters['city'] != null) {
      result = result.where((center) =>
      center.centerLocation.address.city.toLowerCase() == activeFilters['city'].toString().toLowerCase()
      ).toList();
    }

    if (activeFilters['state'] != null) {
      result = result.where((center) =>
      center.centerLocation.address.state.toLowerCase() == activeFilters['state'].toString().toLowerCase()
      ).toList();
    }

    filteredCenters.value = result;
    currentPage.value = 1; // Reset to first page after filtering
    selectedCenterIds.clear(); // Clear selections when filtering
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return activeFilters['status'] != null ||
        activeFilters['staffRange'] != null ||
        activeFilters['city'] != null ||
        activeFilters['state'] != null;
  }

  // Sorting functionality
  void sortCenters(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;

    filteredCenters.sort((a, b) {
      dynamic aValue, bValue;

      switch (columnIndex) {
        case 0: // Name
          aValue = a.name;
          bValue = b.name;
          break;
        case 1: // Email
          aValue = a.email;
          bValue = b.email;
          break;
        case 2: // Phone
          aValue = a.phoneNo;
          bValue = b.phoneNo;
          break;
        case 3: // City
          aValue = a.centerLocation.address.city;
          bValue = b.centerLocation.address.city;
          break;
        case 4: // State
          aValue = a.centerLocation.address.state;
          bValue = b.centerLocation.address.state;
          break;
        case 5: // Staff Count
          aValue = a.numberOfStaff;
          bValue = b.numberOfStaff;
          break;
        case 6: // Created Date
          aValue = a.createdAt;
          bValue = b.createdAt;
          break;
        case 7: // Status
          aValue = a.status;
          bValue = b.status;
          break;
        default:
          return 0;
      }

      int result;
      if (aValue is String && bValue is String) {
        result = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else {
        result = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? result : -result;
    });
  }

  // Selection functionality
  void toggleCenterSelection(String centerId) {
    if (selectedCenterIds.contains(centerId)) {
      selectedCenterIds.remove(centerId);
    } else {
      selectedCenterIds.add(centerId);
    }
  }

  void toggleSelectAll() {
    if (isSelectAllChecked.value) {
      selectedCenterIds.clear();
    } else {
      selectedCenterIds.value = paginatedCenters.map((c) => c.centerId).toList();
    }
  }

  void updateSelectAllState() {
    final currentPageIds = paginatedCenters.map((c) => c.centerId).toSet();
    final selectedOnCurrentPage = selectedCenterIds.where((id) => currentPageIds.contains(id)).length;

    if (selectedOnCurrentPage == 0) {
      isSelectAllChecked.value = false;
    } else if (selectedOnCurrentPage == currentPageIds.length) {
      isSelectAllChecked.value = true;
    } else {
      isSelectAllChecked.value = false;
    }
  }

  // Center actions
  void toggleCenterStatus(PartnerRecyclingCenter center) {
    if (center.status == 'active') {
      _deactivateCenter(center);
    } else {
      _activateCenter(center);
    }
  }

  void _activateCenter(PartnerRecyclingCenter center) {
    final centerIndex = allCenters.indexWhere((c) => c.centerId == center.centerId);
    if (centerIndex != -1) {
      allCenters[centerIndex] = center.copyWith(status: 'active');
      applyFiltersAndSearch();
      FHelperFunctions.showSnackBar('Partner center activated successfully');
    }
  }

  void _deactivateCenter(PartnerRecyclingCenter center) {
    final centerIndex = allCenters.indexWhere((c) => c.centerId == center.centerId);
    if (centerIndex != -1) {
      allCenters[centerIndex] = center.copyWith(status: 'inactive');
      applyFiltersAndSearch();
      FHelperFunctions.showSnackBar('Partner center deactivated successfully');
    }
  }

  void deleteCenter(PartnerRecyclingCenter center) {
    allCenters.removeWhere((c) => c.centerId == center.centerId);
    selectedCenterIds.remove(center.centerId);
    applyFiltersAndSearch();
    FHelperFunctions.showSnackBar('Partner center deleted successfully. All associated staff have been deactivated.');
  }

  void batchDeleteCenters() {
    if (selectedCenterIds.isEmpty) return;

    final centersToDelete = allCenters.where((c) => selectedCenterIds.contains(c.centerId)).toList();

    for (final center in centersToDelete) {
      allCenters.removeWhere((c) => c.centerId == center.centerId);
    }

    selectedCenterIds.clear();
    applyFiltersAndSearch();
    FHelperFunctions.showSnackBar('${centersToDelete.length} partner centers deleted successfully. All associated staff have been deactivated.');
  }

  void addCenter() {
    // Navigate to add center screen
    Get.to(() => AddPartnerCenterScreen());

    print('Navigate to add center screen');
  }

  void viewCenter(PartnerRecyclingCenter center) {
    // Navigate to view center detail screen
    Get.to(() => RecyclingCenterDetailsScreen(centerId: center.centerId,));

    print('View center: ${center.name}');
  }

  void editCenter(PartnerRecyclingCenter center) {
    // Navigate to edit center screen
    print('Edit center: ${center.name}');
  }

  // Pagination functionality
  List<PartnerRecyclingCenter> get paginatedCenters {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = (startIndex + itemsPerPage.value).clamp(0, filteredCenters.length);

    if (startIndex >= filteredCenters.length) {
      return [];
    }

    return filteredCenters.sublist(startIndex, endIndex);
  }

  int get totalCenters => filteredCenters.length;
  int get totalPages => (totalCenters / itemsPerPage.value).ceil();
  int get startIndex => (currentPage.value - 1) * itemsPerPage.value;
  int get endIndex => (startIndex + itemsPerPage.value).clamp(0, totalCenters);

  bool get canGoPreviousPage => currentPage.value > 1;
  bool get canGoNextPage => currentPage.value < totalPages;

  void previousPage() {
    if (canGoPreviousPage) {
      currentPage.value--;
    }
  }

  void nextPage() {
    if (canGoNextPage) {
      currentPage.value++;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void changeItemsPerPage(int? newValue) {
    if (newValue != null) {
      itemsPerPage.value = newValue;
      currentPage.value = 1; // Reset to first page
      selectedCenterIds.clear(); // Clear selections
    }
  }

  void showFilters() {
    final dark = FHelperFunctions.isDarkMode(Get.context!);

    Get.dialog(
      PartnerCenterFilterDialog(
        dark: dark,
        currentFilters: Map.from(activeFilters),
        availableCities: _getAvailableCities(),
        availableStates: _getAvailableStates(),
        onApplyFilters: (newFilters) {
          activeFilters.assignAll(newFilters);
        },
      ),
      barrierDismissible: false,
    );
  }

  List<String> _getAvailableCities() {
    return allCenters.map((c) => c.centerLocation.address.city).toSet().toList()..sort();
  }

  List<String> _getAvailableStates() {
    return allCenters.map((c) => c.centerLocation.address.state).toSet().toList()..sort();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}