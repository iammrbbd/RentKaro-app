import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoriteService {
  FavoriteService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://rentkaro.up.railway.app',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

  final Dio _dio;

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();


  // ============================================================
  // GET TOKEN
  // ============================================================

  Future<String> _getToken() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null || token.isEmpty) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    return token;
  }


  // ============================================================
  // ADD FAVORITE
  // ============================================================

  Future<Map<String, dynamic>> addFavorite(
    int vehicleId,
  ) async {
    final token = await _getToken();

    final response = await _dio.post(
      '/api/favorites/$vehicleId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }


  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<Map<String, dynamic>> removeFavorite(
    int vehicleId,
  ) async {
    final token = await _getToken();

    final response = await _dio.delete(
      '/api/favorites/$vehicleId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return Map<String, dynamic>.from(
      response.data,
    );
  }


  // ============================================================
  // GET MY FAVORITES
  // ============================================================

  Future<List<Map<String, dynamic>>> getMyFavorites() async {
    final token = await _getToken();

    final response = await _dio.get(
      '/api/favorites',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    final favorites =
        responseData['favorites'];

    if (favorites is! List) {
      return [];
    }

    return favorites
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }


  // ============================================================
  // CHECK FAVORITE STATUS
  // ============================================================

  Future<bool> isFavorite(
    int vehicleId,
  ) async {
    final token = await _getToken();

    final response = await _dio.get(
      '/api/favorites/$vehicleId/status',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final responseData =
        Map<String, dynamic>.from(
      response.data,
    );

    return responseData['is_favorite'] == true;
  }
}