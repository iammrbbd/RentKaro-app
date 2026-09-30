import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../location/presentation/screens/nearby_vehicles_map_screen.dart';
import '../../vehicles/screens/vehicle_details_screen.dart';
import '../models/vehicle.dart';
import '../providers/home_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/vehicle_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  int _vehicleImageCacheVersion =
      DateTime.now().millisecondsSinceEpoch;

  Future<void> _refreshVehicles() async {
    setState(() {
      _vehicleImageCacheVersion =
          DateTime.now().millisecondsSinceEpoch;
    });

    ref.invalidate(homeVehiclesProvider);

    await ref.read(homeVehiclesProvider.future);
  }

  bool _availableOnly = false;

  double? _maxHourlyPrice;

  final List<Map<String, dynamic>> categories =
  const [
    {
      'title': 'All',
      'icon': Icons.apps_rounded,
    },
    {
      'title': 'Cars',
      'icon': Icons.directions_car_outlined,
    },
    {
      'title': 'Bikes',
      'icon': Icons.two_wheeler_outlined,
    },
    {
      'title': 'SUV',
      'icon': Icons.directions_car,
    },
    {
      'title': 'Premium',
      'icon': Icons.star_outline_rounded,
    },
  ];

  // ============================================================
  // SEARCH + FILTER
  // ============================================================

  List<Vehicle> _filterVehicles(
      List<Vehicle> vehicles,
      String selectedCategory,
      ) {
    final query =
    _searchQuery.trim().toLowerCase();

    return vehicles.where((vehicle) {
      // ========================================================
      // CATEGORY FILTER
      // ========================================================

      bool categoryMatches = true;

      final category =
      vehicle.category.toLowerCase().trim();

      final vehicleType =
      vehicle.vehicleType.toLowerCase().trim();

      if (selectedCategory == 'Premium') {
        categoryMatches =
            vehicle.isPremium;
      } else if (selectedCategory == 'Bikes') {
        categoryMatches =
            category == 'bike' ||
                category == 'bikes' ||
                vehicleType == 'bike' ||
                vehicleType == 'bikes' ||
                category.contains('bike') ||
                vehicleType.contains('bike');
      } else if (selectedCategory == 'Cars') {
        categoryMatches =
            !category.contains('bike') &&
                !vehicleType.contains('bike');
      } else if (selectedCategory == 'SUV') {
        categoryMatches =
            category == 'suv' ||
                vehicleType == 'suv' ||
                category.contains('suv') ||
                vehicleType.contains('suv');
      }

      if (!categoryMatches) {
        return false;
      }

      // ========================================================
      // AVAILABLE ONLY
      // ========================================================

      if (_availableOnly &&
          !vehicle.isAvailable) {
        return false;
      }

      // ========================================================
      // MAX HOURLY PRICE
      // ========================================================

      if (_maxHourlyPrice != null &&
          vehicle.pricePerHour >
              _maxHourlyPrice!) {
        return false;
      }

      // ========================================================
      // SEARCH
      // ========================================================

      if (query.isEmpty) {
        return true;
      }

      final searchableText = [
        vehicle.name,
        vehicle.brand,
        vehicle.model,
        vehicle.category,
        vehicle.vehicleType,
        vehicle.location,
        vehicle.city,
        vehicle.area,
        vehicle.fuelType,
        vehicle.transmission,
        vehicle.registrationNumber,
        vehicle.description,
      ]
          .join(' ')
          .toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // ============================================================
  // ACTIVE FILTER COUNT
  // ============================================================

  int _activeFilterCount(
      String selectedCategory,
      ) {
    int count = 0;

    if (selectedCategory != 'All') {
      count++;
    }

    if (_availableOnly) {
      count++;
    }

    if (_maxHourlyPrice != null) {
      count++;
    }

    return count;
  }

  // ============================================================
  // NEARBY MAP
  // ============================================================

  void _openNearbyMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const NearbyVehiclesMapScreen(),
      ),
    );
  }

  // ============================================================
  // FILTER SHEET
  // ============================================================

  Future<void> _openFilterSheet(
      List<Vehicle> vehicles,
      ) async {
    final selectedCategory =
    ref.read(
      selectedCategoryProvider,
    );

    double maximumVehiclePrice = 500;

    if (vehicles.isNotEmpty) {
      for (final vehicle in vehicles) {
        if (vehicle.pricePerHour >
            maximumVehiclePrice) {
          maximumVehiclePrice =
              vehicle.pricePerHour;
        }
      }
    }

    if (maximumVehiclePrice <= 0) {
      maximumVehiclePrice = 500;
    }

    final safeMax =
        maximumVehiclePrice;

    double temporaryMaxPrice =
        _maxHourlyPrice ?? safeMax;

    bool temporaryAvailableOnly =
        _availableOnly;

    String temporaryCategory =
        selectedCategory;

    if (temporaryMaxPrice > safeMax) {
      temporaryMaxPrice = safeMax;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
              context,
              setSheetState,
              ) {
            final priceFilterActive =
                temporaryMaxPrice <
                    safeMax - 0.01;

            return SafeArea(
              child: Container(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20,
                ),
                decoration:
                const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HANDLE
                    // ==================================================

                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFD1D5DB,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.w800,
                              color:
                              Color(0xFF111827),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              temporaryCategory =
                              'All';

                              temporaryAvailableOnly =
                              false;

                              temporaryMaxPrice =
                                  safeMax;
                            });
                          },
                          child:
                          const Text(
                            'Reset',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==================================================
                    // VEHICLE TYPE
                    // ==================================================

                    const Text(
                      'Vehicle type',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      height: 46,
                      child:
                      ListView.separated(
                        scrollDirection:
                        Axis.horizontal,
                        itemCount:
                        categories.length,
                        separatorBuilder:
                            (_, __) =>
                        const SizedBox(
                          width: 8,
                        ),
                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          final item =
                          categories[
                          index];

                          final title =
                          item['title']
                          as String;

                          final icon =
                          item['icon']
                          as IconData;

                          return CategoryChip(
                            title: title,
                            icon: icon,
                            selected:
                            temporaryCategory ==
                                title,
                            onTap: () {
                              setSheetState(() {
                                temporaryCategory =
                                    title;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // AVAILABILITY
                    // ==================================================

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 14,
                        vertical: 3,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF8FAFC,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        border: Border.all(
                          color:
                          const Color(
                            0xFFE5E7EB,
                          ),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding:
                        EdgeInsets.zero,
                        title:
                        const Text(
                          'Available vehicles only',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle:
                        const Text(
                          'Show only vehicles available for booking',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                            Color(0xFF6B7280),
                          ),
                        ),
                        value:
                        temporaryAvailableOnly,
                        activeColor:
                        const Color(
                          0xFF1565C0,
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            temporaryAvailableOnly =
                                value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // PRICE
                    // ==================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Maximum hourly price',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w800,
                              color:
                              Color(0xFF111827),
                            ),
                          ),
                        ),
                        Text(
                          priceFilterActive
                              ? '₹${temporaryMaxPrice.round()}/hr'
                              : 'Any price',
                          style:
                          const TextStyle(
                            color:
                            Color(0xFF1565C0),
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      min: 0,
                      max: safeMax,
                      value:
                      temporaryMaxPrice
                          .clamp(
                        0.0,
                        safeMax,
                      ),
                      activeColor:
                      const Color(
                        0xFF1565C0,
                      ),
                      inactiveColor:
                      const Color(
                        0xFFE5E7EB,
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          temporaryMaxPrice =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // APPLY
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child:
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(
                            selectedCategoryProvider
                                .notifier,
                          )
                              .state =
                              temporaryCategory;

                          setState(() {
                            _availableOnly =
                                temporaryAvailableOnly;

                            _maxHourlyPrice =
                            priceFilterActive
                                ? temporaryMaxPrice
                                : null;
                          });

                          Navigator.of(
                            sheetContext,
                          ).pop();
                        },
                        style:
                        FilledButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF1565C0,
                          ),
                          foregroundColor:
                          Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync =
    ref.watch(
      homeVehiclesProvider,
    );

    final selectedCategory =
    ref.watch(
      selectedCategoryProvider,
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),
      body: SafeArea(
        child: vehiclesAsync.when(
          loading: () =>
          const _HomeLoadingView(),

          error: (
              error,
              stackTrace,
              ) =>
              _HomeErrorView(
                onRetry: () {
                  ref.invalidate(
                    homeVehiclesProvider,
                  );
                },
              ),

          data: (vehicles) {
            final filteredVehicles =
            _filterVehicles(
              vehicles,
              selectedCategory,
            );

            final activeFilters =
            _activeFilterCount(
              selectedCategory,
            );

            return RefreshIndicator(
              onRefresh: _refreshVehicles,
              color: const Color(0xFF1565C0),
              child: CustomScrollView(
                physics:
                const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // =====================================================
                  // HEADER
                  // =====================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        18,
                        20,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // =================================================
                          // LOCATION
                          // =================================================

                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap:
                                  _openNearbyMap,
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      vertical: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        const Text(
                                          'Your location',
                                          style:
                                          TextStyle(
                                            color:
                                            Color(
                                              0xFF6B7280,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .location_on,
                                              size: 19,
                                              color:
                                              Color(
                                                0xFF1565C0,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            const Flexible(
                                              child:
                                              Text(
                                                'Vadodara, Gujarat',
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                                style:
                                                TextStyle(
                                                  color:
                                                  Color(
                                                    0xFF111827,
                                                  ),
                                                  fontSize:
                                                  16,
                                                  fontWeight:
                                                  FontWeight
                                                      .w700,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons
                                                  .keyboard_arrow_down,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              // MAP
                              Container(
                                height: 44,
                                width: 44,
                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.white,
                                  shape:
                                  BoxShape.circle,
                                  border:
                                  Border.all(
                                    color:
                                    const Color(
                                      0xFFE5E7EB,
                                    ),
                                  ),
                                ),
                                child:
                                IconButton(
                                  onPressed:
                                  _openNearbyMap,
                                  icon:
                                  const Icon(
                                    Icons
                                        .map_outlined,
                                    color:
                                    Color(
                                      0xFF1565C0,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              // NOTIFICATION
                              Container(
                                height: 44,
                                width: 44,
                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.white,
                                  shape:
                                  BoxShape.circle,
                                  border:
                                  Border.all(
                                    color:
                                    const Color(
                                      0xFFE5E7EB,
                                    ),
                                  ),
                                ),
                                child:
                                IconButton(
                                  onPressed: () {},
                                  icon:
                                  const Icon(
                                    Icons
                                        .notifications_none_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          // =================================================
                          // TITLE
                          // =================================================

                          const Text(
                            'Find your perfect ride',
                            style: TextStyle(
                              color:
                              Color(0xFF111827),
                              fontSize: 28,
                              fontWeight:
                              FontWeight.w800,
                              height: 1.15,
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          const Text(
                            'Rent cars and bikes around Vadodara.',
                            style: TextStyle(
                              color:
                              Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // =================================================
                          // SEARCH BAR
                          // =================================================

                          HomeSearchBar(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery =
                                    value;
                              });
                            },
                            onTap: () {},
                            onFilterTap: () {
                              _openFilterSheet(
                                vehicles,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // =================================================
                          // EXPLORE
                          // =================================================

                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Explore',
                                  style:
                                  TextStyle(
                                    color:
                                    Color(
                                      0xFF111827,
                                    ),
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (activeFilters >
                                  0)
                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                      0xFFE3F2FD,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child:
                                  Text(
                                    '$activeFilters filter${activeFilters == 1 ? '' : 's'}',
                                    style:
                                    const TextStyle(
                                      color:
                                      Color(
                                        0xFF1565C0,
                                      ),
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // =================================================
                          // CATEGORIES
                          // =================================================

                          SizedBox(
                            height: 48,
                            child:
                            ListView.separated(
                              scrollDirection:
                              Axis.horizontal,
                              physics:
                              const BouncingScrollPhysics(),
                              itemCount:
                              categories.length,
                              separatorBuilder:
                                  (
                                  context,
                                  index,
                                  ) =>
                              const SizedBox(
                                width: 10,
                              ),
                              itemBuilder:
                                  (
                                  context,
                                  index,
                                  ) {
                                final category =
                                categories[
                                index];

                                final title =
                                category[
                                'title'] as String;

                                final icon =
                                category[
                                'icon'] as IconData;

                                return CategoryChip(
                                  title: title,
                                  icon: icon,
                                  selected:
                                  selectedCategory ==
                                      title,
                                  onTap: () {
                                    ref
                                        .read(
                                      selectedCategoryProvider
                                          .notifier,
                                    )
                                        .state =
                                        title;
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // =================================================
                          // POPULAR
                          // =================================================

                          SectionHeader(
                            title:
                            'Popular near you',
                            onSeeAll:
                            _openNearbyMap,
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          // SEARCH RESULT COUNT
                          if (_searchQuery
                              .trim()
                              .isNotEmpty ||
                              activeFilters >
                                  0)
                            Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                top: 4,
                                bottom: 8,
                              ),
                              child: Text(
                                '${filteredVehicles.length} vehicle${filteredVehicles.length == 1 ? '' : 's'} found',
                                style:
                                const TextStyle(
                                  color:
                                  Color(
                                    0xFF6B7280,
                                  ),
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // =========================================================
                  // VEHICLES
                  // =========================================================

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 365,
                      child:
                      filteredVehicles.isEmpty
                          ? _NoVehiclesView(
                        searchQuery:
                        _searchQuery,
                      )
                          : ListView
                          .separated(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 20,
                        ),
                        scrollDirection:
                        Axis.horizontal,
                        physics:
                        const BouncingScrollPhysics(),
                        itemCount:
                        filteredVehicles
                            .length,
                        separatorBuilder:
                            (
                            context,
                            index,
                            ) =>
                        const SizedBox(
                          width: 14,
                        ),
                        itemBuilder:
                            (
                            context,
                            index,
                            ) {
                          final vehicle =
                          filteredVehicles[
                          index];

                          return VehicleCard(
                            key: ValueKey(
                              '${vehicle.id}-$_vehicleImageCacheVersion',
                            ),
                            vehicle:
                            vehicle,
                            imageCacheVersion:
                            _vehicleImageCacheVersion,
                            onTap: () async {
                              await Navigator.of(
                                context,
                              ).push(
                                MaterialPageRoute(
                                  builder:
                                      (
                                      context,
                                      ) {
                                    return VehicleDetailsScreen(
                                      vehicle:
                                      vehicle,
                                    );
                                  },
                                ),
                              );

                              if (mounted) {
                                try {
                                  await _refreshVehicles();
                                } catch (_) {
                                  // Keep the current Home data if refresh fails.
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // =========================================================
                  // CTA
                  // =========================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        28,
                        20,
                        30,
                      ),
                      child: InkWell(
                        onTap:
                        _openNearbyMap,
                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                        child: Container(
                          padding:
                          const EdgeInsets.all(
                            20,
                          ),
                          decoration:
                          BoxDecoration(
                            gradient:
                            const LinearGradient(
                              begin:
                              Alignment.topLeft,
                              end: Alignment
                                  .bottomRight,
                              colors: [
                                Color(
                                  0xFF1565C0,
                                ),
                                Color(
                                  0xFF1976D2,
                                ),
                              ],
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                          ),
                          child:
                          const Row(
                            children: [
                              Expanded(
                                child:
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Need a ride today?',
                                      style:
                                      TextStyle(
                                        color:
                                        Colors.white,
                                        fontSize:
                                        20,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                      7,
                                    ),
                                    Text(
                                      'Compare nearby vehicles and book in minutes.',
                                      style:
                                      TextStyle(
                                        color:
                                        Colors.white70,
                                        fontSize:
                                        13,
                                        height:
                                        1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                                color:
                                Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ======================================================================
// LOADING
// ======================================================================

class _HomeLoadingView
    extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 42,
            width: 42,
            child:
            CircularProgressIndicator(
              strokeWidth: 3,
              color:
              Color(0xFF1565C0),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          Text(
            'Finding vehicles near you...',
            style: TextStyle(
              color:
              Color(0xFF6B7280),
              fontSize: 14,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// ERROR
// ======================================================================

class _HomeErrorView
    extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration:
              const BoxDecoration(
                color:
                Color(0xFFFFF1F2),
                shape:
                BoxShape.circle,
              ),
              child:
              const Icon(
                Icons
                    .cloud_off_rounded,
                size: 36,
                color:
                Color(0xFFDC2626),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'Unable to load vehicles',
              style: TextStyle(
                color:
                Color(0xFF111827),
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Please check your connection and try again.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:
              const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
              const Text(
                'Try Again',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFF1565C0,
                ),
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// NO VEHICLES
// ======================================================================

class _NoVehiclesView
    extends StatelessWidget {
  final String searchQuery;

  const _NoVehiclesView({
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final hasSearch =
        searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 54,
              color:
              Color(0xFF9CA3AF),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              hasSearch
                  ? 'No vehicles found'
                  : 'No vehicles available',
              style:
              const TextStyle(
                color:
                Color(0xFF6B7280),
                fontSize: 15,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              hasSearch
                  ? 'Try another search or change your filters.'
                  : 'Try another category or filter.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                color:
                Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}