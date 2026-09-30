import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  return VehicleService();
});

final homeVehiclesProvider =
FutureProvider<List<Vehicle>>((ref) async {
  final service = ref.read(vehicleServiceProvider);

  return service.getVehicles();
});

final selectedCategoryProvider =
StateProvider<String>((ref) {
  return 'All';
});
