import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../home/models/vehicle.dart';
import '../../../home/providers/home_provider.dart';
import '../../../vehicles/screens/vehicle_details_screen.dart';

class NearbyVehiclesMapScreen extends ConsumerStatefulWidget {
  const NearbyVehiclesMapScreen({
    super.key,
  });

  @override
  ConsumerState<NearbyVehiclesMapScreen> createState() =>
      _NearbyVehiclesMapScreenState();
}

class _NearbyVehiclesMapScreenState
    extends ConsumerState<NearbyVehiclesMapScreen> {
  final MapController _mapController = MapController();

  /// IMPORTANT:
  /// This is the customer's selected location.
  ///
  /// It will remain NULL until the customer explicitly
  /// chooses a location or uses GPS.
  LatLng? _customerLocation;

  bool _locationLoading = false;
  bool _locationSet = false;

  Vehicle? _selectedVehicle;

  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Car',
    'Bike',
    'SUV',
  ];

  /// This is ONLY used as the initial map camera position.
  ///
  /// It is NEVER used as customer's location
  /// and NEVER used for distance calculation.
  static const LatLng _mapDefaultLocation = LatLng(
    22.3072,
    73.1812,
  );

  @override
  void initState() {
    super.initState();
  }

  void _closeMapScreen() {
    Navigator.of(context).pop();
  }

  // ===========================================================================
  // LOCATION SELECTION
  // ===========================================================================

  Future<void> _openLocationSelection() async {
    final LatLng? selectedLocation =
    await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LocationPickerSheet(
          initialLocation: _customerLocation,
        );
      },
    );

    if (!mounted || selectedLocation == null) {
      return;
    }

    setState(() {
      _customerLocation = selectedLocation;
      _locationSet = true;
      _selectedVehicle = null;
    });

    _moveMapTo(
      selectedLocation,
      zoom: 14.5,
    );
  }

  // ===========================================================================
  // CURRENT GPS LOCATION
  // ===========================================================================

  Future<void> _useCurrentGpsLocation() async {
    setState(() {
      _locationLoading = true;
    });

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _locationLoading = false;
        });

        await _showMessage(
          'Location service is disabled. Please enable GPS.',
        );

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _locationLoading = false;
        });

        await _showMessage(
          'Location permission was not granted.',
        );

        return;
      }

      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _customerLocation = location;
        _locationSet = true;
        _locationLoading = false;
        _selectedVehicle = null;
      });

      _moveMapTo(
        location,
        zoom: 14.5,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _locationLoading = false;
      });

      await _showMessage(
        'Unable to get your current location.',
      );
    }
  }

  Future<void> _showMessage(
      String message,
      ) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===========================================================================
  // MAP MOVE
  // ===========================================================================

  void _moveMapTo(
      LatLng location, {
        double zoom = 14,
      }) {
    try {
      _mapController.move(
        location,
        zoom,
      );
    } catch (_) {
      // Map may not be ready yet.
    }
  }

  // ===========================================================================
  // VEHICLE FILTER
  // ===========================================================================

  List<Vehicle> _filterVehicles(
      List<Vehicle> vehicles,
      ) {
    final List<Vehicle> filtered =
    vehicles.where((vehicle) {
      /// Only available vehicles.
      if (!vehicle.isAvailable) {
        return false;
      }

      /// Only admin-approved vehicles.
      if (!vehicle.isVerified) {
        return false;
      }

      /// Vehicle must have coordinates.
      if (vehicle.latitude == null ||
          vehicle.longitude == null) {
        return false;
      }

      /// Category filter.
      if (_selectedCategory == 'All') {
        return true;
      }

      final String category =
      vehicle.category.toLowerCase();

      final String vehicleType =
      vehicle.vehicleType.toLowerCase();

      final String selected =
      _selectedCategory.toLowerCase();

      return category == selected ||
          vehicleType == selected;
    }).toList();

    /// IMPORTANT:
    /// All vehicles remain in the list.
    ///
    /// If customer location is selected,
    /// nearest vehicles are displayed first.
    if (_customerLocation != null) {
      filtered.sort(
            (a, b) {
          final double distanceA =
          _distanceToVehicle(a);

          final double distanceB =
          _distanceToVehicle(b);

          return distanceA.compareTo(
            distanceB,
          );
        },
      );
    }

    return filtered;
  }

  // ===========================================================================
  // DISTANCE
  // ===========================================================================

  double _distanceToVehicle(
      Vehicle vehicle,
      ) {
    final LatLng? customerLocation =
        _customerLocation;

    /// VERY IMPORTANT:
    /// Never calculate distance if customer
    /// has not selected a location.
    if (customerLocation == null) {
      return double.infinity;
    }

    if (vehicle.latitude == null ||
        vehicle.longitude == null) {
      return double.infinity;
    }

    return Geolocator.distanceBetween(
      customerLocation.latitude,
      customerLocation.longitude,
      vehicle.latitude!,
      vehicle.longitude!,
    );
  }

  String _formatDistance(
      Vehicle vehicle,
      ) {
    if (_customerLocation == null) {
      return 'Set location';
    }

    final double distance =
    _distanceToVehicle(vehicle);

    if (distance == double.infinity) {
      return 'Distance unavailable';
    }

    if (distance < 1000) {
      return '${distance.round()} m away';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km away';
  }

  // ===========================================================================
  // VEHICLE DETAILS
  // ===========================================================================

  void _openVehicleDetails(
      Vehicle vehicle,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return VehicleDetailsScreen(
            vehicle: vehicle,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // VEHICLE MARKER TAP
  // ===========================================================================

  void _onVehicleMarkerTap(
      Vehicle vehicle,
      ) {
    setState(() {
      _selectedVehicle = vehicle;
    });

    if (vehicle.latitude != null &&
        vehicle.longitude != null) {
      _moveMapTo(
        LatLng(
          vehicle.latitude!,
          vehicle.longitude!,
        ),
        zoom: 16,
      );
    }

    _showVehicleBottomSheet(
      vehicle,
    );
  }

  // ===========================================================================
  // VEHICLE BOTTOM SHEET
  // ===========================================================================

  void _showVehicleBottomSheet(
      Vehicle vehicle,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VehicleBottomSheet(
          vehicle: vehicle,
          distanceText:
          _formatDistance(vehicle),
          locationSelected:
          _locationSet,
          onViewDetails: () {
            Navigator.of(context).pop();

            Future.delayed(
              const Duration(
                milliseconds: 150,
              ),
                  () {
                if (!mounted) return;

                _openVehicleDetails(
                  vehicle,
                );
              },
            );
          },
          onViewOnMap: () {
            Navigator.of(context).pop();

            Future.delayed(
              const Duration(
                milliseconds: 150,
              ),
                  () {
                if (!mounted) return;

                if (vehicle.latitude != null &&
                    vehicle.longitude != null) {
                  _moveMapTo(
                    LatLng(
                      vehicle.latitude!,
                      vehicle.longitude!,
                    ),
                    zoom: 17,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // INITIAL MAP LOCATION
  // ===========================================================================

  LatLng _getInitialMapLocation(
      List<Vehicle> vehicles,
      ) {
    /// If customer selected location,
    /// use that location.
    if (_customerLocation != null) {
      return _customerLocation!;
    }

    /// Otherwise just use first vehicle
    /// as map camera location if available.
    ///
    /// IMPORTANT:
    /// This is ONLY camera location.
    /// It is NOT customer location.
    for (final vehicle in vehicles) {
      if (vehicle.latitude != null &&
          vehicle.longitude != null) {
        return LatLng(
          vehicle.latitude!,
          vehicle.longitude!,
        );
      }
    }

    /// Final fallback only for map camera.
    return _mapDefaultLocation;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final vehiclesAsync =
    ref.watch(homeVehiclesProvider);

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),
      body: vehiclesAsync.when(
        loading: () {
          return const _LoadingView();
        },
        error: (
            error,
            stackTrace,
            ) {
          return _ErrorView(
            onRetry: () {
              ref.invalidate(
                homeVehiclesProvider,
              );
            },
          );
        },
        data: (vehicles) {
          final List<Vehicle> filteredVehicles =
          _filterVehicles(
            vehicles,
          );

          final LatLng initialLocation =
          _getInitialMapLocation(
            filteredVehicles,
          );

          return Stack(
            children: [
              // ===============================================================
              // MAP
              // ===============================================================

              FlutterMap(
                mapController:
                _mapController,
                options: MapOptions(
                  initialCenter:
                  initialLocation,
                  initialZoom: 13.5,
                  minZoom: 4,
                  maxZoom: 19,
                  onTap: (
                      tapPosition,
                      point,
                      ) {
                    setState(() {
                      _selectedVehicle = null;
                    });
                  },
                ),
                children: [
                  // ===========================================================
                  // OPEN STREET MAP
                  // ===========================================================

                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                    'com.rentkaro.app',
                  ),

                  // ===========================================================
                  // VEHICLE MARKERS
                  // ===========================================================

                  MarkerLayer(
                    markers:
                    filteredVehicles.map(
                          (vehicle) {
                        return Marker(
                          point: LatLng(
                            vehicle.latitude!,
                            vehicle.longitude!,
                          ),
                          width: 62,
                          height: 62,
                          child:
                          GestureDetector(
                            behavior:
                            HitTestBehavior
                                .opaque,
                            onTap: () {
                              _onVehicleMarkerTap(
                                vehicle,
                              );
                            },
                            child:
                            _VehicleMapMarker(
                              vehicle:
                              vehicle,
                              selected:
                              _selectedVehicle
                                  ?.id ==
                                  vehicle.id,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),

                  // ===========================================================
                  // CUSTOMER SELECTED LOCATION
                  // ===========================================================

                  if (_customerLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point:
                          _customerLocation!,
                          width: 46,
                          height: 46,
                          child:
                          const _CustomerLocationMarker(),
                        ),
                      ],
                    ),
                ],
              ),

              // ===============================================================
              // TOP HEADER
              // ===============================================================

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      0,
                    ),
                    child:
                    _TopHeader(
                      vehicleCount:
                      filteredVehicles.length,
                      locationSet:
                      _locationSet,
                      onSetLocation:
                      _openLocationSelection,
                      onUseGps:
                      _useCurrentGpsLocation,
                      loading:
                      _locationLoading,
                      onClose:
                      _closeMapScreen,
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // CATEGORY FILTER
              // ===============================================================

              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 46,
                  child:
                  ListView.separated(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                    ),
                    scrollDirection:
                    Axis.horizontal,
                    itemCount:
                    _categories.length,
                    separatorBuilder:
                        (_, __) {
                      return const SizedBox(
                        width: 8,
                      );
                    },
                    itemBuilder:
                        (context, index) {
                      final String category =
                      _categories[index];

                      final bool selected =
                          _selectedCategory ==
                              category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory =
                                category;
                            _selectedVehicle =
                            null;
                          });
                        },
                        child:
                        AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds: 180,
                          ),
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 18,
                          ),
                          alignment:
                          Alignment.center,
                          decoration:
                          BoxDecoration(
                            color: selected
                                ? const Color(
                              0xFF1565C0,
                            )
                                : Colors.white,
                            borderRadius:
                            BorderRadius
                                .circular(
                              22,
                            ),
                            border:
                            Border.all(
                              color: selected
                                  ? const Color(
                                0xFF1565C0,
                              )
                                  : const Color(
                                0xFFE5E7EB,
                              ),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 8,
                                offset:
                                Offset(0, 3),
                                color:
                                Color(
                                  0x18000000,
                                ),
                              ),
                            ],
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(
                                0xFF374151,
                              ),
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ===============================================================
              // LOCATION NOT SET MESSAGE
              // ===============================================================

              if (!_locationSet)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 110,
                  child:
                  _SetLocationCard(
                    onSetLocation:
                    _openLocationSelection,
                    onUseGps:
                    _useCurrentGpsLocation,
                    loading:
                    _locationLoading,
                  ),
                ),

              // ===============================================================
              // NO VEHICLES
              // ===============================================================

              if (_locationSet &&
                  filteredVehicles.isEmpty)
                const Positioned(
                  left: 24,
                  right: 24,
                  bottom: 110,
                  child:
                  _NoVehiclesCard(),
                ),

              // ===============================================================
              // LOCATION BUTTON
              // ===============================================================

              Positioned(
                right: 16,
                bottom: 34,
                child: SafeArea(
                  child: Material(
                    color: Colors.white,
                    elevation: 6,
                    shape:
                    const CircleBorder(),
                    child: InkWell(
                      customBorder:
                      const CircleBorder(),
                      onTap:
                      _openLocationSelection,
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: _locationLoading
                            ? const Padding(
                          padding:
                          EdgeInsets.all(
                            15,
                          ),
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:
                            Color(
                              0xFF1565C0,
                            ),
                          ),
                        )
                            : const Icon(
                          Icons
                              .location_on_rounded,
                          color:
                          Color(
                            0xFF1565C0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // NEAREST VEHICLE PREVIEW
              // ===============================================================

              if (_locationSet &&
                  filteredVehicles.isNotEmpty &&
                  _selectedVehicle == null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child:
                    _NearbyPreviewCard(
                      vehicle:
                      filteredVehicles.first,
                      distanceText:
                      _formatDistance(
                        filteredVehicles.first,
                      ),
                      vehicleCount:
                      filteredVehicles.length,
                      onTap: () {
                        _showAllVehiclesBottomSheet(
                          filteredVehicles,
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // ALL VEHICLES LIST
  // ===========================================================================

  void _showAllVehiclesBottomSheet(
      List<Vehicle> vehicles,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AllVehiclesSheet(
          vehicles: vehicles,
          distanceBuilder:
          _formatDistance,
          onVehicleTap: (vehicle) {
            Navigator.of(context).pop();

            Future.delayed(
              const Duration(
                milliseconds: 150,
              ),
                  () {
                if (!mounted) return;

                _showVehicleBottomSheet(
                  vehicle,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// LOCATION PICKER SHEET
// ============================================================================

class _LocationPickerSheet
    extends StatefulWidget {
  final LatLng? initialLocation;

  const _LocationPickerSheet({
    required this.initialLocation,
  });

  @override
  State<_LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState
    extends State<_LocationPickerSheet> {
  final MapController _mapController =
  MapController();

  static const LatLng _defaultLocation =
  LatLng(
    22.3072,
    73.1812,
  );

  LatLng? _selectedLocation;

  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();

    _selectedLocation =
        widget.initialLocation;
  }

  Future<void> _useGps() async {
    setState(() {
      _loadingGps = true;
    });

    try {
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _loadingGps = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Please enable GPS/location service.',
            ),
          ),
        );

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _loadingGps = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied.',
            ),
          ),
        );

        return;
      }

      final Position position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation =
            location;
        _loadingGps = false;
      });

      _mapController.move(
        location,
        16,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingGps = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not get current location.',
          ),
        ),
      );
    }
  }

  void _confirmLocation() {
    final LatLng? location =
        _selectedLocation;

    if (location == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Tap on the map to select your location.',
          ),
        ),
      );

      return;
    }

    Navigator.of(context).pop(
      location,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final LatLng mapCenter =
        _selectedLocation ??
            _defaultLocation;

    return SafeArea(
      child: Container(
        height:
        MediaQuery.of(context)
            .size
            .height *
            0.82,
        decoration:
        const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // ===============================================================
            // HEADER
            // ===============================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                10,
              ),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFD1D5DB,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              'Set your location',
                              style:
                              TextStyle(
                                fontSize: 19,
                                fontWeight:
                                FontWeight
                                    .w800,
                                color:
                                Color(
                                  0xFF111827,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Tap anywhere on the map where you are',
                              style:
                              TextStyle(
                                fontSize: 12,
                                color:
                                Color(
                                  0xFF6B7280,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop();
                        },
                        icon:
                        const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===============================================================
            // MAP
            // ===============================================================

            Expanded(
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  0,
                ),
                child: FlutterMap(
                  mapController:
                  _mapController,
                  options: MapOptions(
                    initialCenter:
                    mapCenter,
                    initialZoom: 14,
                    minZoom: 4,
                    maxZoom: 19,
                    onTap: (
                        tapPosition,
                        point,
                        ) {
                      setState(() {
                        _selectedLocation =
                            point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                      'com.rentkaro.app',
                    ),

                    if (_selectedLocation !=
                        null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point:
                            _selectedLocation!,
                            width: 54,
                            height: 64,
                            child:
                            const _SelectedLocationMarker(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // ===============================================================
            // LOCATION INFO
            // ===============================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16,
              ),
              child: Column(
                children: [
                  if (_selectedLocation !=
                      null)
                    Container(
                      width:
                      double.infinity,
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF3F4F6,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_rounded,
                            size: 18,
                            color:
                            Color(
                              0xFF1565C0,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                                  '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                              style:
                              const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                FontWeight
                                    .w600,
                                color:
                                Color(
                                  0xFF374151,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        OutlinedButton.icon(
                          onPressed:
                          _loadingGps
                              ? null
                              : _useGps,
                          icon: _loadingGps
                              ? const SizedBox(
                            width: 17,
                            height: 17,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                            ),
                          )
                              : const Icon(
                            Icons
                                .my_location_rounded,
                          ),
                          label:
                          const Text(
                            'Use GPS',
                          ),
                          style:
                          OutlinedButton
                              .styleFrom(
                            foregroundColor:
                            const Color(
                              0xFF1565C0,
                            ),
                            side:
                            const BorderSide(
                              color:
                              Color(
                                0xFF1565C0,
                              ),
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child:
                        ElevatedButton(
                          onPressed:
                          _confirmLocation,
                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                              0xFF1565C0,
                            ),
                            foregroundColor:
                            Colors.white,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                12,
                              ),
                            ),
                          ),
                          child:
                          const Text(
                            'Confirm Location',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TOP HEADER
// ============================================================================

class _TopHeader extends StatelessWidget {
  final int vehicleCount;
  final bool locationSet;
  final VoidCallback onSetLocation;
  final VoidCallback onUseGps;
  final bool loading;
  final VoidCallback onClose;

  const _TopHeader({
    required this.vehicleCount,
    required this.locationSet,
    required this.onSetLocation,
    required this.onUseGps,
    required this.loading,
    required this.onClose,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color:
            Color(0x18000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            const BoxDecoration(
              color:
              Color(0xFF111827),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.map_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  locationSet
                      ? '$vehicleCount vehicles nearby'
                      : 'Find vehicles near you',
                  style:
                  const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    Color(0xFF111827),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  locationSet
                      ? 'Distances are calculated from your location'
                      : 'First select where you are',
                  style:
                  const TextStyle(
                    fontSize: 10,
                    color:
                    Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (!locationSet)
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed:
                loading
                    ? null
                    : onSetLocation,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF1565C0,
                  ),
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 12,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),
                ),
                child:
                const Text(
                  'Set Location',
                  style:
                  TextStyle(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed:
              onSetLocation,
              icon:
              const Icon(
                Icons.edit_location_alt_rounded,
                color:
                Color(0xFF1565C0),
              ),
            ),
          const SizedBox(
            width: 2,
          ),
          Material(
            color: const Color(0xFFF3F4F6),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onClose,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.close_rounded,
                  size: 21,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SET LOCATION CARD
// ============================================================================

class _SetLocationCard
    extends StatelessWidget {
  final VoidCallback onSetLocation;
  final VoidCallback onUseGps;
  final bool loading;

  const _SetLocationCard({
    required this.onSetLocation,
    required this.onUseGps,
    required this.loading,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            offset: Offset(0, 5),
            color:
            Color(0x25000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
            const BoxDecoration(
              color:
              Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color:
              Color(0xFF1565C0),
              size: 28,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Where are you?',
            style:
            TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
              color:
              Color(0xFF111827),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'Select your location first. Then RentKaro will show all available vehicles and their distance from you.',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              fontSize: 11,
              height: 1.4,
              color:
              Color(0xFF6B7280),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            children: [
              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed:
                  onSetLocation,
                  icon:
                  const Icon(
                    Icons.map_rounded,
                    size: 18,
                  ),
                  label:
                  const Text(
                    'Choose on Map',
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    const Color(
                      0xFF1565C0,
                    ),
                    side:
                    const BorderSide(
                      color:
                      Color(
                        0xFF1565C0,
                      ),
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
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child:
                ElevatedButton.icon(
                  onPressed:
                  loading
                      ? null
                      : onUseGps,
                  icon: loading
                      ? const SizedBox(
                    width: 17,
                    height: 17,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons
                        .my_location_rounded,
                    size: 18,
                  ),
                  label:
                  const Text(
                    'Use GPS',
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xFF1565C0,
                    ),
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VEHICLE MAP MARKER
// ============================================================================

class _VehicleMapMarker
    extends StatelessWidget {
  final Vehicle vehicle;
  final bool selected;

  const _VehicleMapMarker({
    required this.vehicle,
    required this.selected,
  });

  IconData _vehicleIcon() {
    final String type =
    '${vehicle.category} ${vehicle.vehicleType}'
        .toLowerCase();

    if (type.contains('bike') ||
        type.contains('scooter')) {
      return Icons.two_wheeler_rounded;
    }

    return Icons.directions_car_filled_rounded;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 180,
          ),
          width:
          selected ? 52 : 46,
          height:
          selected ? 52 : 46,
          decoration:
          BoxDecoration(
            color: selected
                ? const Color(
              0xFF1565C0,
            )
                : const Color(
              0xFF111827,
            ),
            shape:
            BoxShape.circle,
            border:
            Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset:
                Offset(0, 3),
                color:
                Color(0x45000000),
              ),
            ],
          ),
          child: Icon(
            _vehicleIcon(),
            color:
            Colors.white,
            size:
            selected ? 25 : 22,
          ),
        ),
        CustomPaint(
          size:
          const Size(10, 6),
          painter:
          _MarkerTrianglePainter(
            selected:
            selected,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// VEHICLE MARKER TRIANGLE
// ============================================================================

class _MarkerTrianglePainter
    extends CustomPainter {
  final bool selected;

  const _MarkerTrianglePainter({
    required this.selected,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint paint =
    Paint()
      ..color = selected
          ? const Color(
        0xFF1565C0,
      )
          : const Color(
        0xFF111827,
      )
      ..style =
          PaintingStyle.fill;

    final ui.Path path =
    ui.Path();

    path.moveTo(
      0,
      0,
    );

    path.lineTo(
      size.width,
      0,
    );

    path.lineTo(
      size.width / 2,
      size.height,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _MarkerTrianglePainter
      oldDelegate,
      ) {
    return oldDelegate.selected !=
        selected;
  }
}

// ============================================================================
// CUSTOMER LOCATION MARKER
// ============================================================================

class _CustomerLocationMarker
    extends StatelessWidget {
  const _CustomerLocationMarker();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFF1565C0,
            ),
            shape:
            BoxShape.circle,
            border:
            Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 9,
                color:
                Color(0x55000000),
              ),
            ],
          ),
          child:
          const Icon(
            Icons.person_pin_circle_rounded,
            color:
            Colors.white,
            size: 23,
          ),
        ),
        CustomPaint(
          size:
          const Size(12, 7),
          painter:
          _CustomerMarkerTrianglePainter(),
        ),
      ],
    );
  }
}

class _SelectedLocationMarker
    extends StatelessWidget {
  const _SelectedLocationMarker();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFF1565C0,
            ),
            shape:
            BoxShape.circle,
            border:
            Border.all(
              color:
              Colors.white,
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color:
                Color(0x55000000),
              ),
            ],
          ),
          child:
          const Icon(
            Icons.location_on_rounded,
            color:
            Colors.white,
            size: 25,
          ),
        ),
        CustomPaint(
          size:
          const Size(12, 7),
          painter:
          _CustomerMarkerTrianglePainter(),
        ),
      ],
    );
  }
}

class _CustomerMarkerTrianglePainter
    extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint paint =
    Paint()
      ..color =
      const Color(
        0xFF1565C0,
      )
      ..style =
          PaintingStyle.fill;

    final ui.Path path =
    ui.Path();

    path.moveTo(
      0,
      0,
    );

    path.lineTo(
      size.width,
      0,
    );

    path.lineTo(
      size.width / 2,
      size.height,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter
      oldDelegate,
      ) {
    return false;
  }
}

// ============================================================================
// NEAREST PREVIEW
// ============================================================================

class _NearbyPreviewCard
    extends StatelessWidget {
  final Vehicle vehicle;
  final String distanceText;
  final int vehicleCount;
  final VoidCallback onTap;

  const _NearbyPreviewCard({
    required this.vehicle,
    required this.distanceText,
    required this.vehicleCount,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius:
      BorderRadius.circular(20),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFF3F4F6,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .directions_car_filled_rounded,
                  color:
                  Color(0xFF111827),
                  size: 25,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      vehicle.name.isNotEmpty
                          ? vehicle.name
                          : 'Vehicle',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(
                          0xFF111827,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      distanceText,
                      style:
                      const TextStyle(
                        fontSize: 12,
                        color:
                        Color(
                          0xFF1565C0,
                        ),
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .end,
                children: [
                  Text(
                    '$vehicleCount',
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w800,
                      color:
                      Color(
                        0xFF111827,
                      ),
                    ),
                  ),
                  const Text(
                    'vehicles',
                    style:
                    TextStyle(
                      fontSize: 9,
                      color:
                      Color(
                        0xFF6B7280,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 8,
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ALL VEHICLES SHEET
// ============================================================================

class _AllVehiclesSheet
    extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String Function(Vehicle)
  distanceBuilder;
  final void Function(Vehicle)
  onVehicleTap;

  const _AllVehiclesSheet({
    required this.vehicles,
    required this.distanceBuilder,
    required this.onVehicleTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return SafeArea(
      child: Container(
        height:
        MediaQuery.of(context)
            .size
            .height *
            0.72,
        decoration:
        const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 44,
              height: 5,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFD1D5DB,
                ),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nearby Vehicles',
                      style:
                      TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(
                          0xFF111827,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Nearest first',
                    style:
                    TextStyle(
                      fontSize: 11,
                      color:
                      Color(
                        0xFF6B7280,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child:
              ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  20,
                ),
                itemCount:
                vehicles.length,
                separatorBuilder:
                    (_, __) {
                  return const SizedBox(
                    height: 8,
                  );
                },
                itemBuilder:
                    (context, index) {
                  final Vehicle vehicle =
                  vehicles[index];

                  return _VehicleListTile(
                    vehicle:
                    vehicle,
                    distanceText:
                    distanceBuilder(
                      vehicle,
                    ),
                    rank:
                    index + 1,
                    onTap: () {
                      onVehicleTap(
                        vehicle,
                      );
                    },
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

// ============================================================================
// VEHICLE LIST TILE
// ============================================================================

class _VehicleListTile
    extends StatelessWidget {
  final Vehicle vehicle;
  final String distanceText;
  final int rank;
  final VoidCallback onTap;

  const _VehicleListTile({
    required this.vehicle,
    required this.distanceText,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      const Color(0xFFF9FAFB),
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment:
                Alignment.center,
                decoration:
                const BoxDecoration(
                  color:
                  Color(0xFF111827),
                  shape:
                  BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                width: 52,
                height: 52,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEFF1F4,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .directions_car_filled_rounded,
                  color:
                  Color(0xFF111827),
                ),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      vehicle.name.isNotEmpty
                          ? vehicle.name
                          : 'Vehicle',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(
                          0xFF111827,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      vehicle.area.isNotEmpty
                          ? vehicle.area
                          : 'Location available',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontSize: 10,
                        color:
                        Color(
                          0xFF6B7280,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      distanceText,
                      style:
                      const TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Color(
                          0xFF1565C0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// VEHICLE BOTTOM SHEET
// ============================================================================

class _VehicleBottomSheet
    extends StatelessWidget {
  final Vehicle vehicle;
  final String distanceText;
  final bool locationSelected;
  final VoidCallback onViewDetails;
  final VoidCallback onViewOnMap;

  const _VehicleBottomSheet({
    required this.vehicle,
    required this.distanceText,
    required this.locationSelected,
    required this.onViewDetails,
    required this.onViewOnMap,
  });

  String _formatPrice(
      double value,
      ) {
    if (value ==
        value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return SafeArea(
      top: false,
      child: Container(
        margin:
        const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          12,
        ),
        padding:
        const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16,
        ),
        decoration:
        const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(28),
            bottom: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFD1D5DB,
                ),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF3F4F6,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                  child:
                  const Icon(
                    Icons
                        .directions_car_filled_rounded,
                    color:
                    Color(0xFF111827),
                    size: 27,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        vehicle.name.isNotEmpty
                            ? vehicle.name
                            : 'Vehicle',
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight
                              .w800,
                          color:
                          Color(
                            0xFF111827,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        vehicle.category.isNotEmpty
                            ? vehicle.category
                            : vehicle.vehicleType,
                        style:
                        const TextStyle(
                          fontSize: 12,
                          color:
                          Color(
                            0xFF6B7280,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFEFF6FF,
                ),
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .near_me_rounded,
                    size: 18,
                    color:
                    Color(
                      0xFF1565C0,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      locationSelected
                          ? distanceText
                          : 'Select your location first',
                      style:
                      const TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight
                            .w700,
                        color:
                        Color(
                          0xFF1565C0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Expanded(
                  child:
                  _InfoBox(
                    icon:
                    Icons
                        .event_seat_rounded,
                    title:
                    'Seats',
                    value:
                    '${vehicle.seats}',
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                  _InfoBox(
                    icon:
                    Icons
                        .local_gas_station_rounded,
                    title:
                    'Fuel',
                    value:
                    vehicle.fuelType
                        .isNotEmpty
                        ? vehicle
                        .fuelType
                        : '-',
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                  _InfoBox(
                    icon:
                    Icons
                        .settings_rounded,
                    title:
                    'Gear',
                    value:
                    vehicle.transmission
                        .isNotEmpty
                        ? vehicle
                        .transmission
                        : '-',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFF222222,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Text(
                '₹${_formatPrice(vehicle.pricePerHour)}/hour',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width:
              double.infinity,
              height: 49,
              child:
              ElevatedButton(
                onPressed:
                onViewDetails,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF1565C0,
                  ),
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child:
                const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Icon(
                      Icons
                          .directions_car_rounded,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'View Vehicle Details',
                      style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            SizedBox(
              width:
              double.infinity,
              height: 45,
              child:
              OutlinedButton(
                onPressed:
                onViewOnMap,
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(
                    0xFF1565C0,
                  ),
                  side:
                  const BorderSide(
                    color:
                    Color(
                      0xFFE5E7EB,
                    ),
                  ),
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
                  'View on Map',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w600,
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

// ============================================================================
// INFO BOX
// ============================================================================

class _InfoBox
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 68,
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFF5F5F5),
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color:
            const Color(
              0xFF111827,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            title,
            style:
            const TextStyle(
              fontSize: 9,
              color:
              Color(
                0xFF6B7280,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
              color:
              Color(
                0xFF111827,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NO VEHICLES
// ============================================================================

class _NoVehiclesCard
    extends StatelessWidget {
  const _NoVehiclesCard();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset:
            Offset(0, 4),
            color:
            Color(0x22000000),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons
                .location_searching_rounded,
            size: 34,
            color:
            Color(0xFF9CA3AF),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'No vehicles found',
            style:
            TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w700,
              color:
              Color(0xFF111827),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            'Try another vehicle category.',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              fontSize: 12,
              color:
              Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _LoadingView
    extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Center(
      child:
      CircularProgressIndicator(
        color:
        Color(0xFF1565C0),
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorView
    extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,
              size: 55,
              color:
              Color(0xFF9CA3AF),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Unable to load vehicles',
              style:
              TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed:
              onRetry,
              child:
              const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
