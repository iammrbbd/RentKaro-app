import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AdminDashboardStats {
  final int users;
  final int vehicles;
  final int pendingHostKyc;
  final int bookings;

  const AdminDashboardStats({
    required this.users,
    required this.vehicles,
    required this.pendingHostKyc,
    required this.bookings,
  });

  factory AdminDashboardStats.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminDashboardStats(
      users: _toInt(json['users']),
      vehicles: _toInt(json['vehicles']),
      pendingHostKyc: _toInt(
        json['pending_host_kyc'],
      ),
      bookings: _toInt(
        json['bookings'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}

class AdminDashboardService {
  // ==========================================================
  // ANDROID EMULATOR
  // 10.0.2.2 points to the host Windows machine.
  // ==========================================================

  static const String baseUrl =
      'https://rentkaro.up.railway.app';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  // ==========================================================
  // AUTH HEADERS
  // ==========================================================

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(
      key: 'access_token',
    );

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

  // ==========================================================
  // GET DASHBOARD STATS
  // ==========================================================

  Future<AdminDashboardStats> fetchStats() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/admin/dashboard/stats',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid dashboard response.',
        );
      }

      return AdminDashboardStats.fromJson(
        decoded,
      );
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Authentication expired. Please login again.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Admin access required.',
      );
    }

    String message =
        'Failed to load dashboard statistics.';

    try {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail != null &&
            detail.toString().trim().isNotEmpty) {
          message = detail.toString();
        }
      }
    } catch (_) {
      // Keep default message.
    }

    throw Exception(
      '$message (${response.statusCode})',
    );
  }
}