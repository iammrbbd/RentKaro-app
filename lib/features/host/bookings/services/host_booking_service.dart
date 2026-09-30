import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/host_booking.dart';

class HostBookingService {
  // Android Emulator -> Windows localhost
  static const String baseUrl = 'https://rentkaro.up.railway.app';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  // ============================================================
  // AUTH HEADERS
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final token =
    await _storage.read(key: 'access_token');

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // GET ALL HOST BOOKINGS
  // ============================================================

  Future<List<HostBooking>> getBookings() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/bookings/owner',
      ),
      headers: headers,
    );

    return _parseBookingListResponse(
      response,
    );
  }

  // ============================================================
  // GET PENDING HOST BOOKINGS
  // ============================================================

  Future<List<HostBooking>> getPendingBookings() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/bookings/owner/pending',
      ),
      headers: headers,
    );

    return _parseBookingListResponse(
      response,
    );
  }

  // ============================================================
  // GET SINGLE HOST BOOKING
  // ============================================================

  Future<HostBooking> getBooking(
      int bookingId,
      ) async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/bookings/owner/$bookingId',
      ),
      headers: headers,
    );

    _throwIfFailed(response);

    final data = _decodeJson(response);

    final booking = data['booking'];

    if (booking is Map) {
      return HostBooking.fromJson(
        Map<String, dynamic>.from(
          booking,
        ),
      );
    }

    throw Exception(
      'Booking data not found.',
    );
  }

  // ============================================================
  // CONFIRM BOOKING
  // ============================================================

  Future<HostBooking> confirmBooking(
      int bookingId,
      ) async {
    final headers = await _headers();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/bookings/owner/$bookingId/confirm',
      ),
      headers: headers,
    );

    _throwIfFailed(response);

    return _parseSingleBookingResponse(
      response,
      fallbackMessage:
      'Booking confirmed successfully.',
    );
  }

  // ============================================================
  // REJECT BOOKING
  // ============================================================

  Future<HostBooking> rejectBooking(
      int bookingId, {
        String? reason,
      }) async {
    final headers = await _headers();

    final body = <String, dynamic>{};

    if (reason != null &&
        reason.trim().isNotEmpty) {
      body['reason'] = reason.trim();
    }

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/bookings/owner/$bookingId/reject',
      ),
      headers: headers,
      body: jsonEncode(body),
    );

    _throwIfFailed(response);

    return _parseSingleBookingResponse(
      response,
      fallbackMessage:
      'Booking rejected successfully.',
    );
  }

  // ============================================================
  // COMPLETE RENTAL
  // ============================================================

  Future<HostBooking> completeBooking(
      int bookingId,
      ) async {
    final headers = await _headers();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/api/bookings/owner/$bookingId/complete',
      ),
      headers: headers,
    );

    _throwIfFailed(response);

    return _parseSingleBookingResponse(
      response,
      fallbackMessage:
      'Rental completed successfully.',
    );
  }

  // ============================================================
  // PARSE BOOKING LIST
  // ============================================================

  List<HostBooking> _parseBookingListResponse(
      http.Response response,
      ) {
    _throwIfFailed(response);

    final data = _decodeJson(response);

    dynamic bookings;

    if (data['bookings'] is List) {
      bookings = data['bookings'];
    } else if (data['data'] is Map &&
        data['data']['bookings'] is List) {
      bookings = data['data']['bookings'];
    } else if (data['data'] is List) {
      bookings = data['data'];
    } else if (data['items'] is List) {
      bookings = data['items'];
    }

    if (bookings is! List) {
      return [];
    }

    return bookings
        .whereType<Map>()
        .map(
          (booking) => HostBooking.fromJson(
        Map<String, dynamic>.from(
          booking,
        ),
      ),
    )
        .toList();
  }

  // ============================================================
  // PARSE SINGLE BOOKING
  // ============================================================

  HostBooking _parseSingleBookingResponse(
      http.Response response, {
        required String fallbackMessage,
      }) {
    final data = _decodeJson(response);

    dynamic booking = data['booking'];

    if (booking == null &&
        data['data'] is Map) {
      booking = data['data']['booking'];
    }

    if (booking is Map) {
      return HostBooking.fromJson(
        Map<String, dynamic>.from(
          booking,
        ),
      );
    }

    throw Exception(
      data['message']?.toString() ??
          fallbackMessage,
    );
  }

  // ============================================================
  // JSON DECODE
  // ============================================================

  Map<String, dynamic> _decodeJson(
      http.Response response,
      ) {
    try {
      final decoded =
      jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }

      throw Exception(
        'Invalid server response.',
      );
    } catch (_) {
      throw Exception(
        'Invalid server response.',
      );
    }
  }

  // ============================================================
  // HTTP ERROR HANDLER
  // ============================================================

  void _throwIfFailed(
      http.Response response,
      ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message =
        'Request failed (${response.statusCode}).';

    try {
      final decoded =
      jsonDecode(response.body);

      if (decoded is Map &&
          decoded['detail'] != null) {
        message =
            decoded['detail'].toString();
      } else if (decoded is Map &&
          decoded['message'] != null) {
        message =
            decoded['message'].toString();
      }
    } catch (_) {
      // Keep default message.
    }

    throw Exception(message);
  }
}