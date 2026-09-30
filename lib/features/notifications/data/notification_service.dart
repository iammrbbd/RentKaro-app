import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  static const String baseUrl =
      'https://rentkaro.up.railway.app';

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  late final Dio _dio;

  NotificationService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
        const Duration(seconds: 10),
        receiveTimeout:
        const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<Map<String, String>>
  _headers() async {
    final token =
    await _storage.read(
      key: 'access_token',
    );

    if (token == null ||
        token.trim().isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // ==========================================================
  // USER — GET NOTIFICATIONS
  // ==========================================================

  Future<Map<String, dynamic>>
  getNotifications() async {
    final response =
    await _dio.get(
      '/api/notifications',
      options: Options(
        headers: await _headers(),
      ),
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // ==========================================================
  // USER — MARK READ
  // ==========================================================

  Future<void> markAsRead(
      int notificationId,
      ) async {
    await _dio.patch(
      '/api/notifications/$notificationId/read',
      options: Options(
        headers: await _headers(),
      ),
    );
  }

  // ==========================================================
  // USER — MARK ALL READ
  // ==========================================================

  Future<void> markAllAsRead() async {
    await _dio.patch(
      '/api/notifications/read-all',
      options: Options(
        headers: await _headers(),
      ),
    );
  }

  // ==========================================================
  // USER — DELETE
  // ==========================================================

  Future<void> deleteNotification(
      int notificationId,
      ) async {
    await _dio.delete(
      '/api/notifications/$notificationId',
      options: Options(
        headers: await _headers(),
      ),
    );
  }

  // ==========================================================
  // ADMIN — SEND TO USER
  // ==========================================================

  Future<void> sendNotification({
    required int userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _dio.post(
      '/api/admin/notifications',
      data: {
        'user_id': userId,
        'title': title,
        'message': message,
        'notification_type': type,
      },
      options: Options(
        headers: await _headers(),
      ),
    );
  }

  // ==========================================================
  // ADMIN — BROADCAST
  // ==========================================================

  Future<int> sendToAllUsers({
    required String title,
    required String message,
    required String type,
  }) async {
    final response =
    await _dio.post(
      '/api/admin/notifications/broadcast',
      data: {
        'title': title,
        'message': message,
        'notification_type': type,
      },
      options: Options(
        headers: await _headers(),
      ),
    );

    final data =
    Map<String, dynamic>.from(
      response.data as Map,
    );

    return _toInt(
      data['count'],
    );
  }

  // ==========================================================
  // ADMIN — HISTORY
  // ==========================================================

  Future<List<Map<String, dynamic>>>
  getAdminNotifications() async {
    final response =
    await _dio.get(
      '/api/admin/notifications',
      options: Options(
        headers: await _headers(),
      ),
    );

    final data =
    Map<String, dynamic>.from(
      response.data as Map,
    );

    final raw =
    data['notifications'];

    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  // ==========================================================
  // ADMIN — DELETE
  // ==========================================================

  Future<void> adminDeleteNotification(
      int notificationId,
      ) async {
    await _dio.delete(
      '/api/admin/notifications/$notificationId',
      options: Options(
        headers: await _headers(),
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}