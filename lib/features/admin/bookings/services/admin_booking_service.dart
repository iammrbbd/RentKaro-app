import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/admin_booking_model.dart';

class AdminBookingService {
  static const String baseUrl = 'https://rentkaro.up.railway.app';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'access_token');

    if (token == null || token.trim().isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  Future<List<AdminBooking>> getBookings({String? status}) async {
    final headers = await _headers();
    final query = status == null || status == 'all'
        ? ''
        : '?status=${Uri.encodeQueryComponent(status)}';

    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/bookings$query'),
      headers: headers,
    );

    _throwIfFailed(response);
    final data = _decode(response);
    final bookings = data['bookings'];

    if (bookings is! List) {
      throw Exception('Invalid bookings response from server.');
    }

    return bookings
        .whereType<Map>()
        .map((item) => AdminBooking.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<AdminBooking> getBooking(int bookingId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/bookings/$bookingId'),
      headers: headers,
    );

    _throwIfFailed(response);
    final data = _decode(response);
    final booking = data['booking'];

    if (booking is Map) {
      return AdminBooking.fromJson(
        Map<String, dynamic>.from(booking),
      );
    }

    throw Exception('Booking data not found.');
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Invalid server response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['detail'] != null) {
        throw Exception(data['detail'].toString());
      }
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
    }

    throw Exception(
      'Request failed with status ${response.statusCode}.',
    );
  }
}
