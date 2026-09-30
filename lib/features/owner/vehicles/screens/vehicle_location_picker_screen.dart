import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class VehicleLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const VehicleLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<VehicleLocationPickerScreen> createState() =>
      _VehicleLocationPickerScreenState();
}

class _VehicleLocationPickerScreenState
    extends State<VehicleLocationPickerScreen> {
  static const LatLng _defaultLocation = LatLng(
    22.3072,
    73.1812,
  );

  final MapController _mapController = MapController();

  LatLng? _selectedLocation;

  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();

    if (_isValidCoordinate(
      widget.initialLatitude,
      widget.initialLongitude,
    )) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
    } else {
      _selectedLocation = _defaultLocation;
    }
  }

  bool _isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Future<void> _useCurrentLocation() async {
    if (_isGettingLocation) {
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          await _showMessage(
            'Location service is disabled. Please enable GPS.',
          );
        }
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          await _showMessage(
            'Location permission was denied.',
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          await _showPermissionSettingsDialog();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedLocation = location;
      });

      _mapController.move(
        location,
        16,
      );
    } catch (e) {
      if (mounted) {
        await _showMessage(
          'Unable to get your current location.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _showMessage(String message) async {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _showPermissionSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Location Permission Required',
          ),
          content: const Text(
            'Location permission is permanently denied. '
                'Please enable it from app settings to use '
                'your current location.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onMapTap(
      TapPosition tapPosition,
      LatLng location,
      ) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onMarkerDragEnd(
      LatLng location,
      ) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _confirmLocation() {
    final location = _selectedLocation;

    if (location == null) {
      _showMessage(
        'Please select a pickup location first.',
      );
      return;
    }

    Navigator.of(context).pop(
      <String, double>{
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = _selectedLocation ?? _defaultLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Select Vehicle Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Use current location',
            onPressed: _useCurrentLocation,
            icon: const Icon(
              Icons.my_location_rounded,
              size: 21,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: location,
                initialZoom: 14.5,
                minZoom: 3,
                maxZoom: 19,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                  'com.rentkaro.app',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 60,
                      height: 75,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onLongPress: () {},
                        child: Draggable(
                          feedback: const Icon(
                            Icons.location_on,
                            size: 52,
                            color: Color(0xFF1976D2),
                          ),
                          childWhenDragging: const Icon(
                            Icons.location_on,
                            size: 52,
                            color: Colors.black26,
                          ),
                          onDragEnd: (details) {
                            final camera =
                                _mapController.camera;

                            final mapPoint =
                            camera.screenOffsetToLatLng(
                              details.offset,
                            );

                            _onMarkerDragEnd(
                              mapPoint,
                            );
                          },
                          child: const Icon(
                            Icons.location_on,
                            size: 52,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top instruction card
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _instructionCard(),
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _bottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _instructionCard() {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF1976D2),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose pickup location',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tap anywhere on the map or drag the marker '
                        'to select the exact vehicle pickup location.',
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.35,
                      color: Color(0xFF607D9B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomPanel() {
    final location = _selectedLocation;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, -4),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            _coordinatesCard(location),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation
                    ? null
                    : _useCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.my_location_rounded,
                  size: 18,
                ),
                label: Text(
                  _isGettingLocation
                      ? 'Getting Location...'
                      : 'Use My Current Location',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(0xFF1565C0),
                  side: const BorderSide(
                    color: Color(0xFFB0BEC5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed:
                location == null ? null : _confirmLocation,
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 19,
                ),
                label: const Text(
                  'Confirm Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  Colors.grey.shade300,
                  disabledForegroundColor:
                  Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coordinatesCard(LatLng? location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.gps_fixed_rounded,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Coordinates',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location == null
                      ? 'No location selected'
                      : 'Lat: ${location.latitude.toStringAsFixed(6)}'
                      '  Lng: ${location.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF263238),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}