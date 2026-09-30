import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/admin_vehicle_model.dart';

class AdminVehicleService {
  AdminVehicleService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  // ==========================================================
  // API BASE URL
  //
  // Android Emulator -> Windows localhost
  //
  // 10.0.2.2 points to the host machine from Android Emulator.
  // ==========================================================

  static const String _baseUrl =
      'https://rentkaro.up.railway.app';

  // ==========================================================
  // GET AUTH TOKEN
  // ==========================================================

  Future<String> _getToken() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return token.trim();
  }

  // ==========================================================
  // AUTH OPTIONS
  // ==========================================================

  Future<Options> _authOptions() async {
    final token = await _getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  // ==========================================================
  // GET ALL VEHICLES
  // ==========================================================

  Future<List<AdminVehicle>> getVehicles() async {
    try {
      print('========================================');
      print('ADMIN GET VEHICLES');
      print('URL: $_baseUrl/api/admin/vehicles');
      print('========================================');

      final response = await _dio.get(
        '/api/admin/vehicles',
        options: await _authOptions(),
      );

      print(
        'ADMIN VEHICLES STATUS: ${response.statusCode}',
      );

      print(
        'ADMIN VEHICLES RESPONSE: ${response.data}',
      );

      return _parseVehicleList(
        response.data,
      );
    } on DioException catch (error) {
      _logDioError(
        'ADMIN GET VEHICLES ERROR',
        error,
      );

      throw Exception(
        _dioErrorMessage(error),
      );
    } catch (error) {
      print(
        'ADMIN GET VEHICLES UNKNOWN ERROR: $error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // GET PENDING VEHICLES
  // ==========================================================

  Future<List<AdminVehicle>> getPendingVehicles() async {
    try {
      print('========================================');
      print('ADMIN GET PENDING VEHICLES');
      print(
        'URL: $_baseUrl/api/admin/vehicles/pending',
      );
      print('========================================');

      final response = await _dio.get(
        '/api/admin/vehicles/pending',
        options: await _authOptions(),
      );

      print(
        'ADMIN PENDING VEHICLES STATUS: '
            '${response.statusCode}',
      );

      print(
        'ADMIN PENDING VEHICLES RESPONSE: '
            '${response.data}',
      );

      return _parseVehicleList(
        response.data,
      );
    } on DioException catch (error) {
      _logDioError(
        'ADMIN GET PENDING VEHICLES ERROR',
        error,
      );

      throw Exception(
        _dioErrorMessage(error),
      );
    } catch (error) {
      print(
        'ADMIN GET PENDING VEHICLES UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // GET SINGLE VEHICLE
  // ==========================================================

  Future<AdminVehicle> getVehicle(
      int vehicleId,
      ) async {
    if (vehicleId <= 0) {
      throw Exception(
        'Invalid vehicle ID.',
      );
    }

    try {
      print('========================================');
      print('ADMIN GET VEHICLE');
      print('Vehicle ID: $vehicleId');
      print(
        'URL: $_baseUrl/api/admin/vehicles/$vehicleId',
      );
      print('========================================');

      final response = await _dio.get(
        '/api/admin/vehicles/$vehicleId',
        options: await _authOptions(),
      );

      print(
        'ADMIN VEHICLE STATUS: '
            '${response.statusCode}',
      );

      print(
        'ADMIN VEHICLE RESPONSE: '
            '${response.data}',
      );

      final data = response.data;

      if (data is Map) {
        final mapData =
        Map<String, dynamic>.from(data);

        final vehicleData =
        mapData['vehicle'];

        if (vehicleData is Map) {
          return AdminVehicle.fromJson(
            Map<String, dynamic>.from(
              vehicleData,
            ),
          );
        }

        return AdminVehicle.fromJson(
          mapData,
        );
      }

      throw Exception(
        'Invalid vehicle response from server.',
      );
    } on DioException catch (error) {
      _logDioError(
        'ADMIN GET VEHICLE ERROR',
        error,
      );

      throw Exception(
        _dioErrorMessage(error),
      );
    } catch (error) {
      print(
        'ADMIN GET VEHICLE UNKNOWN ERROR: $error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // APPROVE VEHICLE
  // ==========================================================

  Future<void> approveVehicle(
      int vehicleId,
      ) async {
    if (vehicleId <= 0) {
      throw Exception(
        'Invalid vehicle ID.',
      );
    }

    try {
      print('========================================');
      print('ADMIN APPROVE VEHICLE');
      print('Vehicle ID: $vehicleId');
      print(
        'URL: '
            '$_baseUrl/api/admin/vehicles/'
            '$vehicleId/approve',
      );
      print('========================================');

      final response = await _dio.put(
        '/api/admin/vehicles/'
            '$vehicleId/approve',
        options: await _authOptions(),
      );

      print(
        'ADMIN APPROVE STATUS: '
            '${response.statusCode}',
      );

      print(
        'ADMIN APPROVE RESPONSE: '
            '${response.data}',
      );
    } on DioException catch (error) {
      _logDioError(
        'ADMIN APPROVE VEHICLE ERROR',
        error,
      );

      throw Exception(
        _dioErrorMessage(error),
      );
    } catch (error) {
      print(
        'ADMIN APPROVE VEHICLE UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // REJECT VEHICLE
  // ==========================================================

  Future<void> rejectVehicle(
      int vehicleId, {
        String? reason,
      }) async {
    if (vehicleId <= 0) {
      throw Exception(
        'Invalid vehicle ID.',
      );
    }

    try {
      final data = <String, dynamic>{};

      if (reason != null &&
          reason.trim().isNotEmpty) {
        data['reason'] = reason.trim();
      }

      print('========================================');
      print('ADMIN REJECT VEHICLE');
      print('Vehicle ID: $vehicleId');
      print(
        'URL: '
            '$_baseUrl/api/admin/vehicles/'
            '$vehicleId/reject',
      );
      print('Reason: ${data['reason'] ?? 'none'}');
      print('========================================');

      final response = await _dio.put(
        '/api/admin/vehicles/'
            '$vehicleId/reject',
        data: data.isEmpty ? null : data,
        options: await _authOptions(),
      );

      print(
        'ADMIN REJECT STATUS: '
            '${response.statusCode}',
      );

      print(
        'ADMIN REJECT RESPONSE: '
            '${response.data}',
      );
    } on DioException catch (error) {
      _logDioError(
        'ADMIN REJECT VEHICLE ERROR',
        error,
      );

      throw Exception(
        _dioErrorMessage(error),
      );
    } catch (error) {
      print(
        'ADMIN REJECT VEHICLE UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // PARSE VEHICLE LIST
  // ==========================================================

  List<AdminVehicle> _parseVehicleList(
      dynamic data,
      ) {
    dynamic vehiclesData = data;

    if (data is Map) {
      final mapData =
      Map<String, dynamic>.from(data);

      vehiclesData =
          mapData['vehicles'] ??
              mapData['data'] ??
              mapData['items'] ??
              [];
    }

    if (vehiclesData is! List) {
      throw Exception(
        'Invalid vehicle list response from server.',
      );
    }

    return vehiclesData
        .whereType<Map>()
        .map(
          (vehicle) {
        return AdminVehicle.fromJson(
          Map<String, dynamic>.from(
            vehicle,
          ),
        );
      },
    )
        .toList();
  }

  // ==========================================================
  // DIO ERROR LOGGER
  // ==========================================================

  void _logDioError(
      String title,
      DioException error,
      ) {
    print('========================================');
    print(title);
    print('Type: ${error.type}');
    print('Message: ${error.message}');
    print('URL: ${error.requestOptions.uri}');
    print(
      'Status Code: '
          '${error.response?.statusCode}',
    );
    print(
      'Response: '
          '${error.response?.data}',
    );
    print('========================================');
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  String _dioErrorMessage(
      DioException error,
      ) {
    final response = error.response;

    // --------------------------------------------------------
    // SERVER RESPONSE ERROR
    // --------------------------------------------------------

    if (response != null) {
      final data = response.data;

      if (data is Map) {
        final mapData =
        Map<String, dynamic>.from(data);

        final detail =
        mapData['detail'];

        if (detail != null &&
            detail.toString().trim().isNotEmpty) {
          return detail.toString();
        }

        final message =
        mapData['message'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        final errorMessage =
        mapData['error'];

        if (errorMessage != null &&
            errorMessage
                .toString()
                .trim()
                .isNotEmpty) {
          return errorMessage.toString();
        }
      }

      switch (response.statusCode) {
        case 400:
          return 'Invalid request.';

        case 401:
          return 'Admin session expired. Please login again.';

        case 403:
          return 'You are not authorized to manage vehicle approvals.';

        case 404:
          return 'Vehicle approval API was not found.';

        case 409:
          return 'Vehicle cannot be modified in its current state.';

        case 422:
          return 'Invalid vehicle data.';

        case 500:
          return 'RentKaro server error. Please check the backend.';

        default:
          return 'Request failed with status '
              '${response.statusCode}.';
      }
    }

    // --------------------------------------------------------
    // CONNECTION ERROR
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Unable to connect to RentKaro server.';
    }

    // --------------------------------------------------------
    // CONNECTION TIMEOUT
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.connectionTimeout) {
      return 'Connection timed out. Please make sure the RentKaro server is running.';
    }

    // --------------------------------------------------------
    // RECEIVE TIMEOUT
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.receiveTimeout) {
      return 'Server response timed out. Please try again.';
    }

    // --------------------------------------------------------
    // SEND TIMEOUT
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.sendTimeout) {
      return 'Request timed out while sending data.';
    }

    return error.message ??
        'Something went wrong. Please try again.';
  }
}