import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/owner_vehicle.dart';

class OwnerVehicleService {
  OwnerVehicleService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  // ==========================================================
  // BACKEND BASE URL
  // ==========================================================
  //
  // Android Emulator -> Windows localhost
  //
  // 127.0.0.1 = Android Emulator itself
  // 10.0.2.2   = Windows host machine
  //
  static const String _baseUrl =
      'https://rentkaro.up.railway.app';

  // ==========================================================
  // HEADERS
  // ==========================================================

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ==========================================================
  // GET MY VEHICLES
  // ==========================================================

  Future<List<OwnerVehicle>> getMyVehicles() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/owner/vehicles',
        options: Options(
          headers: await _headers(),
        ),
      );

      final data = response.data;

      if (data is! List) {
        throw Exception(
          'Invalid vehicle list response from server.',
        );
      }

      return data
          .map(
            (item) => OwnerVehicle.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        ),
      )
          .toList();
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // GET SINGLE VEHICLE
  // ==========================================================

  Future<OwnerVehicle> getVehicle(
      int vehicleId,
      ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/owner/vehicles/$vehicleId',
        options: Options(
          headers: await _headers(),
        ),
      );

      return OwnerVehicle.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // ADD VEHICLE
  // ==========================================================

  Future<OwnerVehicle> addVehicle({
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
    try {
      final headers = await _headers();

      final requestData = {
        'brand': brand,
        'model': model,
        'vehicle_type': vehicleType,
        'category': category,
        'registration_number': registrationNumber,
        'description': description,
        'hourly_price': hourlyPrice,
        'twelve_hour_price': twelveHourPrice,
        'daily_price': dailyPrice,
        'security_deposit': securityDeposit,
        'city': city,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
        'images': images ?? [],
        'seats': seats,
        'fuel_type': fuelType,
        'transmission': transmission,
      };

      // ========================================================
      // DEBUG LOG
      // ========================================================

      print(
        'ADD VEHICLE URL: '
            '$_baseUrl/api/owner/vehicles',
      );

      print(
        'ADD VEHICLE REQUEST: $requestData',
      );

      final response = await _dio.post(
        '$_baseUrl/api/owner/vehicles',
        data: requestData,
        options: Options(
          headers: headers,
        ),
      );

      print(
        'ADD VEHICLE STATUS: '
            '${response.statusCode}',
      );

      print(
        'ADD VEHICLE RESPONSE: '
            '${response.data}',
      );

      return OwnerVehicle.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      print('ADD VEHICLE ERROR');
      print('TYPE: ${error.type}');
      print('MESSAGE: ${error.message}');
      print('URL: ${error.requestOptions.uri}');
      print('STATUS: ${error.response?.statusCode}');
      print('RESPONSE: ${error.response?.data}');

      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // UPDATE VEHICLE
  // ==========================================================

  Future<OwnerVehicle> updateVehicle({
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
    try {
      final response = await _dio.put(
        '$_baseUrl/api/owner/vehicles/$vehicleId',
        data: {
          'brand': brand,
          'model': model,
          'vehicle_type': vehicleType,
          'category': category,
          'registration_number': registrationNumber,
          'description': description,
          'hourly_price': hourlyPrice,
          'twelve_hour_price': twelveHourPrice,
          'daily_price': dailyPrice,
          'security_deposit': securityDeposit,
          'city': city,
          'area': area,
          'latitude': latitude,
          'longitude': longitude,
          'images': images ?? [],
          'seats': seats,
          'fuel_type': fuelType,
          'transmission': transmission,
        },
        options: Options(
          headers: await _headers(),
        ),
      );

      return OwnerVehicle.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // UPDATE VEHICLE AVAILABILITY
  // ==========================================================

  Future<OwnerVehicle> updateAvailability({
    required int vehicleId,
    required bool isAvailable,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/owner/vehicles/'
            '$vehicleId/availability',
        data: {
          'is_available': isAvailable,
        },
        options: Options(
          headers: await _headers(),
        ),
      );

      return OwnerVehicle.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // DELETE VEHICLE
  // ==========================================================

  Future<void> deleteVehicle(
      int vehicleId,
      ) async {
    try {
      await _dio.delete(
        '$_baseUrl/api/owner/vehicles/$vehicleId',
        options: Options(
          headers: await _headers(),
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  String _errorMessage(
      DioException error,
      ) {
    final statusCode =
        error.response?.statusCode;

    final responseData =
        error.response?.data;

    // ========================================================
    // BACKEND DETAIL MESSAGE
    // ========================================================

    if (responseData is Map &&
        responseData['detail'] != null) {
      return responseData['detail'].toString();
    }

    // ========================================================
    // HTTP STATUS
    // ========================================================

    if (statusCode == 400) {
      return 'Invalid vehicle information.';
    }

    if (statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    if (statusCode == 403) {
      return 'You are not authorized to manage vehicles.';
    }

    if (statusCode == 404) {
      return 'Vehicle endpoint or vehicle not found.';
    }

    if (statusCode == 409) {
      return 'This vehicle registration number already exists.';
    }

    if (statusCode != null &&
        statusCode >= 500) {
      return 'Server error. Please check the backend.';
    }

    // ========================================================
    // CONNECTION ERRORS
    // ========================================================

    if (error.type ==
        DioExceptionType.connectionTimeout) {
      return 'Could not connect to the server. Connection timed out.';
    }

    if (error.type ==
        DioExceptionType.receiveTimeout) {
      return 'Server response timed out.';
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Cannot connect to RentKaro server. '
          'Make sure the FastAPI backend is running.';
    }

    if (error.type ==
        DioExceptionType.badCertificate) {
      return 'Secure connection error.';
    }

    return error.message ??
        'Something went wrong. Please try again.';
  }
}