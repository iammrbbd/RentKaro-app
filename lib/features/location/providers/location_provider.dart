import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../data/location_service.dart';

final locationServiceProvider =
Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider =
FutureProvider<Position>((ref) async {
  final service =
  ref.read(locationServiceProvider);

  return service.getCurrentPosition();
});