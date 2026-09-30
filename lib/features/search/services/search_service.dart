import 'package:dio/dio.dart';

import '../../home/models/vehicle.dart';

class SearchService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://rentkaro.up.railway.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<Vehicle>> searchVehicles({
    String? search,
    String? category,
    String? city,
    String? area,
    String? vehicleType,
    double? minPrice,
    double? maxPrice,
    int? seats,
    String? fuelType,
    String? transmission,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (category != null && category.trim().isNotEmpty) {
      queryParameters['category'] = category.trim();
    }

    if (city != null && city.trim().isNotEmpty) {
      queryParameters['city'] = city.trim();
    }

    if (area != null && area.trim().isNotEmpty) {
      queryParameters['area'] = area.trim();
    }

    if (vehicleType != null &&
        vehicleType.trim().isNotEmpty) {
      queryParameters['vehicle_type'] =
          vehicleType.trim();
    }

    if (minPrice != null) {
      queryParameters['min_price'] = minPrice;
    }

    if (maxPrice != null) {
      queryParameters['max_price'] = maxPrice;
    }

    if (seats != null) {
      queryParameters['seats'] = seats;
    }

    if (fuelType != null &&
        fuelType.trim().isNotEmpty) {
      queryParameters['fuel_type'] =
          fuelType.trim();
    }

    if (transmission != null &&
        transmission.trim().isNotEmpty) {
      queryParameters['transmission'] =
          transmission.trim();
    }

    final response = await _dio.get(
      '/api/vehicles',
      queryParameters: queryParameters,
    );

    final data =
    Map<String, dynamic>.from(
      response.data as Map,
    );

    final vehiclesData =
        data['vehicles'] as List<dynamic>? ?? [];

    return vehiclesData
        .map(
          (item) => Vehicle.fromJson(
        Map<String, dynamic>.from(
          item as Map,
        ),
      ),
    )
        .toList();
  }
}