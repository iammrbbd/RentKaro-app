import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingService {
  BookingService()
      : _dio = Dio(
    BaseOptions(
      // Android Emulator -> Windows PC localhost
      baseUrl: 'https://rentkaro.up.railway.app',

      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final Dio _dio;

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  // ==========================================================
  // GET AUTH TOKEN
  // ==========================================================

  Future<String> _getToken() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    print(
      'BOOKING TOKEN EXISTS: ${token != null}',
    );

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    return token;
  }

  // ==========================================================
  // CHECK VEHICLE AVAILABILITY
  // ==========================================================

  Future<Map<String, dynamic>> checkAvailability({
    required int vehicleId,
    required DateTime startTime,
    DateTime? endTime,
    double? durationHours,
  }) async {
    try {
      if (vehicleId <= 0) {
        throw Exception(
          'Invalid vehicle ID.',
        );
      }

      double finalDurationHours;

      if (durationHours != null) {
        finalDurationHours = durationHours;
      } else if (endTime != null) {
        if (!endTime.isAfter(startTime)) {
          throw Exception(
            'Return time must be after pickup time.',
          );
        }

        finalDurationHours =
            endTime.difference(startTime).inMinutes /
                60.0;
      } else {
        throw Exception(
          'Rental duration is required.',
        );
      }

      if (finalDurationHours <= 0) {
        throw Exception(
          'Rental duration must be greater than 0.',
        );
      }

      final token = await _getToken();

      print('====================================');
      print('CHECKING VEHICLE AVAILABILITY');
      print(
        'URL: ${_dio.options.baseUrl}/api/bookings/vehicles/$vehicleId/availability',
      );
      print('Vehicle ID: $vehicleId');
      print('Start Time: $startTime');
      print(
        'Duration: $finalDurationHours',
      );
      print('====================================');

      final response = await _dio.get(
        '/api/bookings/vehicles/'
            '$vehicleId/availability',
        queryParameters: {
          'start_time':
          startTime.toIso8601String(),
          'duration_hours':
          finalDurationHours,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(
        'AVAILABILITY STATUS: '
            '${response.statusCode}',
      );

      print(
        'AVAILABILITY RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid availability response from server.',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      print('====================================');
      print('AVAILABILITY CHECK ERROR');
      print(
        'URL: ${error.requestOptions.uri}',
      );
      print(
        'Type: ${error.type}',
      );
      print(
        'Status Code: '
            '${error.response?.statusCode}',
      );
      print(
        'Response: '
            '${error.response?.data}',
      );
      print(
        'Message: '
            '${error.message}',
      );
      print('====================================');

      final responseData =
          error.response?.data;

      String message =
          'Unable to check vehicle availability.';

      if (responseData is Map) {
        if (responseData['detail'] != null) {
          message =
              responseData['detail'].toString();
        } else if (
        responseData['message'] != null) {
          message =
              responseData['message'].toString();
        }
      }

      if (error.response?.statusCode == 401) {
        message =
        'Your session has expired. Please login again.';
      } else if (error.response?.statusCode == 404) {
        message =
        'Vehicle or availability service not found.';
      } else if (
      error.response?.statusCode == 409) {
        message =
        'Vehicle is not available for the selected time.';
      } else if (
      error.type ==
          DioExceptionType.connectionError) {
        message =
        'Cannot connect to RentKaro server.\n'
            'Make sure the FastAPI server is running.';
      } else if (
      error.type ==
          DioExceptionType.connectionTimeout ||
          error.type ==
              DioExceptionType.receiveTimeout) {
        message =
        'RentKaro server connection timed out.';
      }

      throw Exception(message);
    } catch (error) {
      print(
        'AVAILABILITY UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // CREATE BOOKING
  // POST /api/bookings
  // ==========================================================

  Future<Map<String, dynamic>> createBooking({
    required int vehicleId,
    required DateTime startTime,
    required double durationHours,
  }) async {
    try {
      if (vehicleId <= 0) {
        throw Exception(
          'Invalid vehicle ID.',
        );
      }

      if (durationHours <= 0) {
        throw Exception(
          'Rental duration must be greater than 0.',
        );
      }

      final token = await _getToken();

      print('====================================');
      print('CREATE BOOKING REQUEST');
      print(
        'URL: ${_dio.options.baseUrl}/api/bookings',
      );
      print('Vehicle ID: $vehicleId');
      print('Start Time: $startTime');
      print('Duration: $durationHours');
      print('====================================');

      final response = await _dio.post(
        '/api/bookings',
        data: {
          'vehicle_id': vehicleId,
          'start_time':
          startTime.toIso8601String(),
          'duration_hours': durationHours,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(
        'CREATE BOOKING STATUS: '
            '${response.statusCode}',
      );

      print(
        'CREATE BOOKING RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid booking response from server.',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      print('====================================');
      print('CREATE BOOKING ERROR');
      print(
        'URL: ${error.requestOptions.uri}',
      );
      print(
        'Type: ${error.type}',
      );
      print(
        'Status Code: '
            '${error.response?.statusCode}',
      );
      print(
        'Response: '
            '${error.response?.data}',
      );
      print(
        'Message: '
            '${error.message}',
      );
      print('====================================');

      final responseData =
          error.response?.data;

      String message =
          'Failed to create booking.';

      if (responseData is Map) {
        if (responseData['detail'] != null) {
          message =
              responseData['detail'].toString();
        } else if (
        responseData['message'] != null) {
          message =
              responseData['message'].toString();
        }
      }

      if (error.response?.statusCode == 401) {
        message =
        'Your session has expired.\n'
            'Please login again.';
      } else if (
      error.response?.statusCode == 409) {
        message =
        'Vehicle is already booked for the selected time.';
      } else if (
      error.response?.statusCode == 400) {
        message =
        responseData is Map &&
            responseData['detail'] != null
            ? responseData['detail'].toString()
            : 'Invalid booking details.';
      } else if (
      error.type ==
          DioExceptionType.connectionError) {
        message =
        'Cannot connect to RentKaro server.\n'
            'Make sure the FastAPI server is running.';
      } else if (
      error.type ==
          DioExceptionType.connectionTimeout ||
          error.type ==
              DioExceptionType.receiveTimeout) {
        message =
        'RentKaro server connection timed out.';
      }

      throw Exception(message);
    } catch (error) {
      print(
        'CREATE BOOKING UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // GET MY BOOKINGS
  // GET /api/bookings
  // ==========================================================

  Future<List<Map<String, dynamic>>>
  getMyBookings() async {
    try {
      final token = await _getToken();

      print('====================================');
      print('GET MY BOOKINGS');
      print(
        'URL: ${_dio.options.baseUrl}/api/bookings',
      );
      print('====================================');

      final response = await _dio.get(
        '/api/bookings',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(
        'MY BOOKINGS STATUS: '
            '${response.statusCode}',
      );

      print(
        'MY BOOKINGS RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid bookings response.',
        );
      }

      final responseData =
      Map<String, dynamic>.from(
        response.data,
      );

      final bookings =
      responseData['bookings'];

      if (bookings == null) {
        return [];
      }

      if (bookings is! List) {
        return [];
      }

      return bookings
          .whereType<Map>()
          .map<Map<String, dynamic>>(
            (booking) =>
        Map<String, dynamic>.from(
          booking,
        ),
      )
          .toList();
    } on DioException catch (error) {
      print('====================================');
      print('GET MY BOOKINGS ERROR');
      print(
        'URL: ${error.requestOptions.uri}',
      );
      print(
        'Type: ${error.type}',
      );
      print(
        'Status Code: '
            '${error.response?.statusCode}',
      );
      print(
        'Response: '
            '${error.response?.data}',
      );
      print(
        'Message: '
            '${error.message}',
      );
      print('====================================');

      final responseData =
          error.response?.data;

      String message =
          'Failed to load bookings.';

      if (responseData is Map &&
          responseData['detail'] != null) {
        message =
            responseData['detail'].toString();
      }

      if (error.response?.statusCode == 401) {
        message =
        'Your session has expired.\n'
            'Please login again.';
      } else if (
      error.type ==
          DioExceptionType.connectionError) {
        message =
        'Cannot connect to RentKaro server.\n'
            'Make sure the FastAPI server is running.';
      } else if (
      error.type ==
          DioExceptionType.connectionTimeout ||
          error.type ==
              DioExceptionType.receiveTimeout) {
        message =
        'RentKaro server connection timed out.';
      }

      throw Exception(message);
    } catch (error) {
      print(
        'GET MY BOOKINGS UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // GET SINGLE BOOKING
  // GET /api/bookings/{booking_id}
  // ==========================================================

  Future<Map<String, dynamic>> getBooking(
      int bookingId,
      ) async {
    try {
      if (bookingId <= 0) {
        throw Exception(
          'Invalid booking ID.',
        );
      }

      final token = await _getToken();

      print('====================================');
      print('GET SINGLE BOOKING');
      print(
        'URL: ${_dio.options.baseUrl}/api/bookings/$bookingId',
      );
      print('Booking ID: $bookingId');
      print('====================================');

      final response = await _dio.get(
        '/api/bookings/$bookingId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(
        'GET BOOKING STATUS: '
            '${response.statusCode}',
      );

      print(
        'GET BOOKING RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid booking response.',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      print('====================================');
      print('GET BOOKING ERROR');
      print(
        'URL: ${error.requestOptions.uri}',
      );
      print(
        'Type: ${error.type}',
      );
      print(
        'Status Code: '
            '${error.response?.statusCode}',
      );
      print(
        'Response: '
            '${error.response?.data}',
      );
      print(
        'Message: '
            '${error.message}',
      );
      print('====================================');

      final responseData =
          error.response?.data;

      String message =
          'Failed to load booking.';

      if (responseData is Map &&
          responseData['detail'] != null) {
        message =
            responseData['detail'].toString();
      }

      if (error.response?.statusCode == 401) {
        message =
        'Your session has expired.\n'
            'Please login again.';
      } else if (
      error.response?.statusCode == 404) {
        message =
        'Booking not found.';
      } else if (
      error.type ==
          DioExceptionType.connectionError) {
        message =
        'Cannot connect to RentKaro server.\n'
            'Make sure the FastAPI server is running.';
      }

      throw Exception(message);
    } catch (error) {
      print(
        'GET BOOKING UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // CANCEL BOOKING
  // POST /api/cancellations/{booking_id}
  // ==========================================================

  Future<Map<String, dynamic>> cancelBooking(
      int bookingId, {
        String? reason,
      }) async {
    try {
      if (bookingId <= 0) {
        throw Exception(
          'Invalid booking ID.',
        );
      }

      final token = await _getToken();

      print('====================================');
      print('CANCEL BOOKING REQUEST');
      print(
        'URL: ${_dio.options.baseUrl}/api/cancellations/$bookingId',
      );
      print('Booking ID: $bookingId');
      print('Reason: $reason');
      print('====================================');

      final Map<String, dynamic> data = {};

      if (reason != null &&
          reason.trim().isNotEmpty) {
        data['reason'] = reason.trim();
      }

      final response = await _dio.post(
        '/api/cancellations/$bookingId',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(
        'CANCEL BOOKING STATUS: '
            '${response.statusCode}',
      );

      print(
        'CANCEL BOOKING RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid cancel booking response.',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      print('====================================');
      print('CANCEL BOOKING ERROR');
      print(
        'URL: ${error.requestOptions.uri}',
      );
      print(
        'Type: ${error.type}',
      );
      print(
        'Status Code: '
            '${error.response?.statusCode}',
      );
      print(
        'Response: '
            '${error.response?.data}',
      );
      print(
        'Message: '
            '${error.message}',
      );
      print('====================================');

      final responseData =
          error.response?.data;

      String message =
          'Failed to cancel booking.';

      if (responseData is Map) {
        if (responseData['detail'] != null) {
          message =
              responseData['detail'].toString();
        } else if (
        responseData['message'] != null) {
          message =
              responseData['message'].toString();
        }
      }

      if (error.response?.statusCode == 401) {
        message =
        'Your session has expired.\n'
            'Please login again.';
      } else if (
      error.response?.statusCode == 404) {
        message =
        'Booking not found.';
      } else if (
      error.response?.statusCode == 409) {
        message =
        'Booking cannot be cancelled at this stage.';
      } else if (
      error.type ==
          DioExceptionType.connectionError) {
        message =
        'Cannot connect to RentKaro server.\n'
            'Make sure the FastAPI server is running.';
      } else if (
      error.type ==
          DioExceptionType.connectionTimeout ||
          error.type ==
              DioExceptionType.receiveTimeout) {
        message =
        'RentKaro server connection timed out.';
      }

      throw Exception(message);
    } catch (error) {
      print(
        'CANCEL BOOKING UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }

  // ==========================================================
  // GET CANCELLATION DETAILS
  // GET /api/cancellations/{booking_id}
  // ==========================================================

  Future<Map<String, dynamic>>
  getCancellation(
      int bookingId,
      ) async {
    try {
      if (bookingId <= 0) {
        throw Exception(
          'Invalid booking ID.',
        );
      }

      final token = await _getToken();

      print('====================================');
      print('GET CANCELLATION DETAILS');
      print(
        'URL: ${_dio.options.baseUrl}/api/cancellations/$bookingId',
      );
      print('Booking ID: $bookingId');
      print('====================================');

      final response = await _dio.get(
        '/api/cancellations/$bookingId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(
        'CANCELLATION STATUS: '
            '${response.statusCode}',
      );

      print(
        'CANCELLATION RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid cancellation response.',
        );
      }

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      print('====================================');
      print('GET CANCELLATION ERROR');
      print(
        'URL: ${error.requestOptions.uri}',
      );
      print(
        'Type: ${error.type}',
      );
      print(
        'Status Code: '
            '${error.response?.statusCode}',
      );
      print(
        'Response: '
            '${error.response?.data}',
      );
      print(
        'Message: '
            '${error.message}',
      );
      print('====================================');

      final responseData =
          error.response?.data;

      String message =
          'Failed to load cancellation details.';

      if (responseData is Map &&
          responseData['detail'] != null) {
        message =
            responseData['detail'].toString();
      }

      if (error.response?.statusCode == 401) {
        message =
        'Your session has expired.\n'
            'Please login again.';
      } else if (
      error.response?.statusCode == 404) {
        message =
        'Cancellation details not found.';
      } else if (
      error.type ==
          DioExceptionType.connectionError) {
        message =
        'Cannot connect to RentKaro server.\n'
            'Make sure the FastAPI server is running.';
      } else if (
      error.type ==
          DioExceptionType.connectionTimeout ||
          error.type ==
              DioExceptionType.receiveTimeout) {
        message =
        'RentKaro server connection timed out.';
      }

      throw Exception(message);
    } catch (error) {
      print(
        'GET CANCELLATION UNKNOWN ERROR: '
            '$error',
      );

      throw Exception(
        error.toString(),
      );
    }
  }
}