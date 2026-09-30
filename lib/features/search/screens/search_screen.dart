import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/models/vehicle.dart';
import '../../home/widgets/vehicle_card.dart';
import '../../vehicles/screens/vehicle_details_screen.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  Timer? _debounce;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Recommended';

  String? _selectedCity;
  double? _minPrice;
  double? _maxPrice;
  int? _selectedSeats;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedVehicleType;

  final List<String> _categories = [
    'All',
    'Cars',
    'SUV',
    'Bikes',
    'Premium',
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _performSearch();
    });

    _searchController.addListener(() {
      _searchQuery =
          _searchController.text.trim();

      _debounce?.cancel();

      _debounce = Timer(
        const Duration(milliseconds: 500),
            () {
          _performSearch();
        },
      );

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SEARCH VEHICLES
  // ==========================================================

  Future<void> _performSearch() async {
    String? category;

    if (_selectedCategory != 'All') {
      category = _selectedCategory;
    }

    await ref
        .read(searchProvider.notifier)
        .searchVehicles(
      search: _searchQuery.isEmpty
          ? null
          : _searchQuery,
      category: category,
      city: _selectedCity,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      seats: _selectedSeats,
      fuelType: _selectedFuelType,
      transmission: _selectedTransmission,
      vehicleType: _selectedVehicleType,
    );
  }

  // ==========================================================
  // SORT VEHICLES
  // ==========================================================

  List<Vehicle> _sortVehicles(
      List<Vehicle> vehicles,
      ) {
    final sorted =
    List<Vehicle>.from(vehicles);

    if (_selectedSort ==
        'Price: Low to High') {
      sorted.sort(
            (a, b) =>
            a.price24Hours.compareTo(
              b.price24Hours,
            ),
      );
    }

    if (_selectedSort ==
        'Price: High to Low') {
      sorted.sort(
            (a, b) =>
            b.price24Hours.compareTo(
              a.price24Hours,
            ),
      );
    }

    if (_selectedSort == 'Rating') {
      sorted.sort(
            (a, b) =>
            b.rating.compareTo(
              a.rating,
            ),
      );
    }

    return sorted;
  }

  // ==========================================================
  // SORT BOTTOM SHEET
  // ==========================================================

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final options = [
          'Recommended',
          'Price: Low to High',
          'Price: High to Low',
          'Rating',
        ];

        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort Vehicles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                ...options.map(
                      (option) {
                    return ListTile(
                      title: Text(option),

                      trailing:
                      _selectedSort == option
                          ? const Icon(
                        Icons.check_circle,
                        color:
                        Color(
                          0xFF2563EB,
                        ),
                      )
                          : null,

                      onTap: () {
                        setState(() {
                          _selectedSort =
                              option;
                        });

                        Navigator.pop(
                          context,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // FILTER BOTTOM SHEET
  // ==========================================================

  void _showFilterSheet() {
    final minPriceController =
    TextEditingController(
      text: _minPrice?.toString() ?? '',
    );

    final maxPriceController =
    TextEditingController(
      text: _maxPrice?.toString() ?? '',
    );

    final cities = [
      'Vadodara',
      'Ahmedabad',
      'Surat',
      'Mumbai',
    ];

    final vehicleTypes = [
      'Car',
      'Bike',
      'SUV',
    ];

    final seatOptions = [
      2,
      4,
      5,
      7,
    ];

    final fuelTypes = [
      'Petrol',
      'Diesel',
      'Electric',
      'CNG',
    ];

    final transmissions = [
      'Manual',
      'Automatic',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
              context,
              setModalState,
              ) {
            return SafeArea(
              child: Padding(
                padding:
                EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom:
                  MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                      20,
                ),
                child:
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // TITLE

                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // CITY

                      const Text(
                        'City',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      DropdownButton<String>(
                        isExpanded: true,
                        value:
                        _selectedCity,
                        hint: const Text(
                          'Select city',
                        ),
                        items: cities.map(
                              (city) {
                            return DropdownMenuItem(
                              value: city,
                              child:
                              Text(city),
                            );
                          },
                        ).toList(),
                        onChanged: (
                            value,
                            ) {
                          setModalState(() {
                            _selectedCity =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // VEHICLE TYPE

                      const Text(
                        'Vehicle Type',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      DropdownButton<String>(
                        isExpanded: true,
                        value:
                        _selectedVehicleType,
                        hint: const Text(
                          'Select vehicle type',
                        ),
                        items:
                        vehicleTypes.map(
                              (type) {
                            return DropdownMenuItem(
                              value: type,
                              child:
                              Text(type),
                            );
                          },
                        ).toList(),
                        onChanged: (
                            value,
                            ) {
                          setModalState(() {
                            _selectedVehicleType =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // PRICE

                      const Text(
                        'Daily Price Range',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                            TextField(
                              controller:
                              minPriceController,
                              keyboardType:
                              TextInputType
                                  .number,
                              decoration:
                              const InputDecoration(
                                labelText:
                                'Min price',
                                border:
                                OutlineInputBorder(),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                            TextField(
                              controller:
                              maxPriceController,
                              keyboardType:
                              TextInputType
                                  .number,
                              decoration:
                              const InputDecoration(
                                labelText:
                                'Max price',
                                border:
                                OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // SEATS

                      const Text(
                        'Minimum Seats',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      DropdownButton<int>(
                        isExpanded: true,
                        value:
                        _selectedSeats,
                        hint: const Text(
                          'Select seats',
                        ),
                        items:
                        seatOptions.map(
                              (seats) {
                            return DropdownMenuItem(
                              value: seats,
                              child: Text(
                                '$seats seats',
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (
                            value,
                            ) {
                          setModalState(() {
                            _selectedSeats =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // FUEL TYPE

                      const Text(
                        'Fuel Type',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      DropdownButton<String>(
                        isExpanded: true,
                        value:
                        _selectedFuelType,
                        hint: const Text(
                          'Select fuel type',
                        ),
                        items:
                        fuelTypes.map(
                              (fuel) {
                            return DropdownMenuItem(
                              value: fuel,
                              child:
                              Text(fuel),
                            );
                          },
                        ).toList(),
                        onChanged: (
                            value,
                            ) {
                          setModalState(() {
                            _selectedFuelType =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // TRANSMISSION

                      const Text(
                        'Transmission',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      DropdownButton<String>(
                        isExpanded: true,
                        value:
                        _selectedTransmission,
                        hint: const Text(
                          'Select transmission',
                        ),
                        items:
                        transmissions.map(
                              (transmission) {
                            return DropdownMenuItem(
                              value:
                              transmission,
                              child: Text(
                                transmission,
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (
                            value,
                            ) {
                          setModalState(() {
                            _selectedTransmission =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // BUTTONS

                      Row(
                        children: [

                          // CLEAR

                          Expanded(
                            child:
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCity =
                                  null;

                                  _selectedVehicleType =
                                  null;

                                  _selectedSeats =
                                  null;

                                  _selectedFuelType =
                                  null;

                                  _selectedTransmission =
                                  null;

                                  _minPrice =
                                  null;

                                  _maxPrice =
                                  null;
                                });

                                Navigator.pop(
                                  context,
                                );

                                _performSearch();
                              },

                              child:
                              const Text(
                                'Clear',
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          // APPLY

                          Expanded(
                            child:
                            ElevatedButton(
                              onPressed: () {
                                final minPrice =
                                double.tryParse(
                                  minPriceController
                                      .text
                                      .trim(),
                                );

                                final maxPrice =
                                double.tryParse(
                                  maxPriceController
                                      .text
                                      .trim(),
                                );

                                setState(() {
                                  _minPrice =
                                      minPrice;

                                  _maxPrice =
                                      maxPrice;
                                });

                                Navigator.pop(
                                  context,
                                );

                                _performSearch();
                              },

                              child:
                              const Text(
                                'Apply Filters',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final searchState =
    ref.watch(searchProvider);

    final vehicles =
    _sortVehicles(
      searchState.vehicles,
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Search Vehicles',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    'Find the perfect ride for your journey',
                    style: TextStyle(
                      color:
                      Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // SEARCH BAR

                  TextField(
                    controller:
                    _searchController,

                    decoration:
                    InputDecoration(
                      hintText:
                      'Search cars, bikes or location',

                      prefixIcon:
                      const Icon(
                        Icons.search,
                      ),

                      suffixIcon:
                      _searchQuery
                          .isNotEmpty
                          ? IconButton(
                        icon:
                        const Icon(
                          Icons.clear,
                        ),
                        onPressed:
                            () {
                          _searchController
                              .clear();

                          setState(() {
                            _searchQuery =
                            '';
                          });

                          _performSearch();
                        },
                      )
                          : null,

                      filled: true,

                      fillColor:
                      Colors.white,

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                        borderSide:
                        BorderSide.none,
                      ),

                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                        borderSide:
                        const BorderSide(
                          color:
                          Color(
                            0xFFE5E7EB,
                          ),
                        ),
                      ),

                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                        borderSide:
                        const BorderSide(
                          color:
                          Color(
                            0xFF2563EB,
                          ),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CATEGORY FILTER
            // ==================================================

            SizedBox(
              height: 48,

              child:
              ListView.separated(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                scrollDirection:
                Axis.horizontal,

                itemCount:
                _categories.length,

                separatorBuilder:
                    (_, index) =>
                const SizedBox(
                  width: 10,
                ),

                itemBuilder:
                    (context, index) {
                  final category =
                  _categories[index];

                  final selected =
                      _selectedCategory ==
                          category;

                  return ChoiceChip(
                    label:
                    Text(category),

                    selected:
                    selected,

                    onSelected: (_) {
                      setState(() {
                        _selectedCategory =
                            category;
                      });

                      _performSearch();
                    },

                    selectedColor:
                    const Color(
                      0xFF2563EB,
                    ),

                    labelStyle:
                    TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(
                        0xFF374151,
                      ),
                      fontWeight:
                      FontWeight.w600,
                    ),

                    backgroundColor:
                    Colors.white,

                    side:
                    BorderSide(
                      color: selected
                          ? const Color(
                        0xFF2563EB,
                      )
                          : const Color(
                        0xFFE5E7EB,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // RESULTS HEADER
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      searchState.isLoading
                          ? 'Searching...'
                          : '${vehicles.length} vehicles found',

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                        color:
                        Color(
                          0xFF374151,
                        ),
                      ),
                    ),
                  ),

                  // FILTER BUTTON

                  OutlinedButton.icon(
                    onPressed:
                    _showFilterSheet,

                    icon: const Icon(
                      Icons.tune,
                      size: 18,
                    ),

                    label:
                    const Text(
                      'Filter',
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // SORT BUTTON

                  OutlinedButton.icon(
                    onPressed:
                    _showSortSheet,

                    icon: const Icon(
                      Icons.sort,
                      size: 18,
                    ),

                    label:
                    const Text(
                      'Sort',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // VEHICLE LIST
            // ==================================================

            Expanded(
              child: Builder(
                builder: (context) {

                  // LOADING

                  if (searchState.isLoading &&
                      vehicles.isEmpty) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  // ERROR

                  if (searchState.error !=
                      null) {
                    return Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          24,
                        ),
                        child: Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [

                            const Icon(
                              Icons.error_outline,
                              size: 50,
                              color:
                              Colors.red,
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            const Text(
                              'Unable to search vehicles',
                              style:
                              TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              searchState.error!,
                              textAlign:
                              TextAlign.center,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            ElevatedButton(
                              onPressed:
                              _performSearch,
                              child:
                              const Text(
                                'Try Again',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // EMPTY

                  if (vehicles.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [

                          Icon(
                            Icons.search_off,
                            size: 64,
                            color:
                            Color(
                              0xFF9CA3AF,
                            ),
                          ),

                          SizedBox(
                            height: 16,
                          ),

                          Text(
                            'No vehicles found',
                            style:
                            TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),

                          Text(
                            'Try changing your search or filters',
                            style:
                            TextStyle(
                              color:
                              Color(
                                0xFF6B7280,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // RESULTS

                  return RefreshIndicator(
                    onRefresh:
                    _performSearch,

                    child:
                    ListView.builder(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        30,
                      ),

                      itemCount:
                      vehicles.length,

                      itemBuilder:
                          (
                          context,
                          index,
                          ) {
                        final vehicle =
                        vehicles[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 16,
                          ),

                          child:
                          SizedBox(
                            width:
                            double.infinity,

                            child:
                            VehicleCard(
                              vehicle:
                              vehicle,

                              onTap: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                        VehicleDetailsScreen(
                                          vehicle:
                                          vehicle,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}