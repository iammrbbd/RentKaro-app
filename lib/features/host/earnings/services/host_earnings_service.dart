import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/host_earnings.dart';

class HostEarningsService {
  static const String baseUrl =
      'http://127.0.0.1:8000';

  static const FlutterSecureStorage storage =
  FlutterSecureStorage();

  Future<HostEarnings> getEarnings() async {
    final token =
    await storage.read(key: 'access_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/owner/earnings',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      String message =
          'Failed to load earnings.';

      try {
        final data =
        jsonDecode(response.body);

        if (data is Map &&
            data['detail'] != null) {
          message =
              data['detail'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data =
    jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Invalid earnings response.',
      );
    }

    return HostEarnings.fromJson(data);
  }
}