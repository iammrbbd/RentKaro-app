import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      // Android Emulator -> host PC
      baseUrl: 'https://rentkaro.up.railway.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static Future<List<Map<String, dynamic>>> getVehicles({
    String? city,
    String? category,
  }) async {
    try {
      final response = await dio.get(
        '/api/vehicles',
        queryParameters: {
          if (city != null && city.isNotEmpty) 'city': city,
          if (category != null && category.isNotEmpty)
            'category': category,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid vehicle API response');
      }

      if (data['success'] != true) {
        throw Exception('Vehicle API request failed');
      }

      final vehicles = data['vehicles'];

      if (vehicles is! List) {
        return [];
      }

      return vehicles
          .whereType<Map>()
          .map(
            (vehicle) => Map<String, dynamic>.from(vehicle),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(
        'Unable to connect to RentKaro server: '
        '${error.message ?? 'Unknown network error'}',
      );
    } catch (error) {
      throw Exception(
        'Failed to load vehicles: $error',
      );
    }
  }

  static Future<Map<String, dynamic>> getVehicle(
    int vehicleId,
  ) async {
    try {
      final response = await dio.get(
        '/api/vehicles/$vehicleId',
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid vehicle response');
      }

      if (data['success'] != true) {
        throw Exception('Vehicle request failed');
      }

      final vehicle = data['vehicle'];

      if (vehicle is! Map) {
        throw Exception('Vehicle data not found');
      }

      return Map<String, dynamic>.from(vehicle);
    } on DioException catch (error) {
      throw Exception(
        'Unable to connect to RentKaro server: '
        '${error.message ?? 'Unknown network error'}',
      );
    } catch (error) {
      throw Exception(
        'Failed to load vehicle: $error',
      );
    }
  }
}
