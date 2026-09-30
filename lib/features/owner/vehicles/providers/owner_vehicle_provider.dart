import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/owner_vehicle_service.dart';
import '../models/owner_vehicle.dart';

// ==========================================================
// SERVICE PROVIDER
// ==========================================================

final ownerVehicleServiceProvider =
Provider<OwnerVehicleService>(
      (ref) {
    return OwnerVehicleService();
  },
);

// ==========================================================
// VEHICLES PROVIDER
// ==========================================================

final ownerVehiclesProvider =
AsyncNotifierProvider<
    OwnerVehiclesNotifier,
    List<OwnerVehicle>>(
  OwnerVehiclesNotifier.new,
);

// ==========================================================
// VEHICLES NOTIFIER
// ==========================================================

class OwnerVehiclesNotifier
    extends AsyncNotifier<List<OwnerVehicle>> {

  late final OwnerVehicleService _service;

  @override
  Future<List<OwnerVehicle>> build() async {
    _service = ref.read(
      ownerVehicleServiceProvider,
    );

    return _service.getMyVehicles();
  }

  // ==========================================================
  // REFRESH VEHICLES
  // ==========================================================

  Future<void> refreshVehicles() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => _service.getMyVehicles(),
    );
  }

  // ==========================================================
  // ADD VEHICLE
  // ==========================================================

  Future<OwnerVehicle?> addVehicle({
    required String brand,
    required String model,
    required String vehicleType,
    required String category,
    required String registrationNumber,
    String? description,
    required double hourlyPrice,
    double? twelveHourPrice,
    required double dailyPrice,
    required double securityDeposit,
    required String city,
    required String area,
    double? latitude,
    double? longitude,
    List<String>? images,
    int? seats,
    String? fuelType,
    String? transmission,
  }) async {
    final previousState = state;

    try {
      final vehicle =
      await _service.addVehicle(
        brand: brand,
        model: model,
        vehicleType: vehicleType,
        category: category,
        registrationNumber:
        registrationNumber,
        description: description,
        hourlyPrice: hourlyPrice,
        twelveHourPrice:
        twelveHourPrice,
        dailyPrice: dailyPrice,
        securityDeposit:
        securityDeposit,
        city: city,
        area: area,
        latitude: latitude,
        longitude: longitude,
        images: images,
        seats: seats,
        fuelType: fuelType,
        transmission: transmission,
      );

      final currentVehicles =
          previousState.valueOrNull ?? [];

      state = AsyncData(
        [
          vehicle,
          ...currentVehicles,
        ],
      );

      return vehicle;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // UPDATE VEHICLE
  // ==========================================================

  Future<OwnerVehicle?> updateVehicle({
    required int vehicleId,
    required String brand,
    required String model,
    required String vehicleType,
    required String category,
    required String registrationNumber,
    String? description,
    required double hourlyPrice,
    double? twelveHourPrice,
    required double dailyPrice,
    required double securityDeposit,
    required String city,
    required String area,
    double? latitude,
    double? longitude,
    List<String>? images,
    int? seats,
    String? fuelType,
    String? transmission,
  }) async {
    final previousState = state;

    try {
      final updatedVehicle =
      await _service.updateVehicle(
        vehicleId: vehicleId,
        brand: brand,
        model: model,
        vehicleType: vehicleType,
        category: category,
        registrationNumber:
        registrationNumber,
        description: description,
        hourlyPrice: hourlyPrice,
        twelveHourPrice:
        twelveHourPrice,
        dailyPrice: dailyPrice,
        securityDeposit:
        securityDeposit,
        city: city,
        area: area,
        latitude: latitude,
        longitude: longitude,
        images: images,
        seats: seats,
        fuelType: fuelType,
        transmission: transmission,
      );

      final currentVehicles =
          previousState.valueOrNull ?? [];

      final updatedVehicles =
      currentVehicles.map(
            (vehicle) {
          if (vehicle.id ==
              vehicleId) {
            return updatedVehicle;
          }

          return vehicle;
        },
      ).toList();

      state = AsyncData(
        updatedVehicles,
      );

      return updatedVehicle;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return null;
    }
  }

  // ==========================================================
  // UPDATE VEHICLE AVAILABILITY
  // ==========================================================

  Future<OwnerVehicle?> updateAvailability({
    required int vehicleId,
    required bool isAvailable,
  }) async {
    final previousState = state;

    try {
      final updatedVehicle =
      await _service.updateAvailability(
        vehicleId: vehicleId,
        isAvailable: isAvailable,
      );

      final currentVehicles =
          previousState.valueOrNull ?? [];

      final updatedVehicles =
      currentVehicles.map(
            (vehicle) {
          if (vehicle.id ==
              vehicleId) {
            return updatedVehicle;
          }

          return vehicle;
        },
      ).toList();

      state = AsyncData(
        updatedVehicles,
      );

      return updatedVehicle;
    } catch (error, stackTrace) {
      // Keep existing vehicle list instead of
      // replacing the entire screen with an error.
      state = previousState;

      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // DELETE VEHICLE
  // ==========================================================

  Future<bool> deleteVehicle(
      int vehicleId,
      ) async {
    try {
      await _service.deleteVehicle(
        vehicleId,
      );

      final currentVehicles =
          state.valueOrNull ?? [];

      state = AsyncData(
        currentVehicles
            .where(
              (vehicle) =>
          vehicle.id != vehicleId,
        )
            .toList(),
      );

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return false;
    }
  }

  // ==========================================================
  // GET SINGLE VEHICLE
  // ==========================================================

  Future<OwnerVehicle?> getVehicle(
      int vehicleId,
      ) async {
    try {
      return await _service.getVehicle(
        vehicleId,
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return null;
    }
  }
}