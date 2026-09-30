import 'package:dio/dio.dart';
import '../models/review.dart';

class ReviewService {
  ReviewService({
    Dio? dio,
  }) : _dio = dio ??
      Dio(
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

  // ==========================================================
  // CREATE REVIEW
  // ==========================================================

  Future<Review> createReview({
    required String token,
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reviews',
        data: {
          'booking_id': bookingId,
          'rating': rating,
          'comment': comment?.trim().isEmpty == true
              ? null
              : comment?.trim(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid review response.',
        );
      }

      return Review.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // GET VEHICLE REVIEWS
  // ==========================================================

  Future<VehicleReviews> getVehicleReviews(
      int vehicleId,
      ) async {
    try {
      final response = await _dio.get(
        '/api/reviews/vehicle/$vehicleId',
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception(
          'Invalid vehicle reviews response.',
        );
      }

      return VehicleReviews.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (error) {
      throw Exception(
        _errorMessage(error),
      );
    }
  }

  // ==========================================================
  // GET MY REVIEWS
  // ==========================================================

  Future<List<Review>> getMyReviews({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/reviews/my',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      if (data is! List) {
        throw Exception(
          'Invalid reviews response.',
        );
      }

      return data
          .map(
            (item) => Review.fromJson(
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
  // ERROR MESSAGE
  // ==========================================================

  String _errorMessage(
      DioException error,
      ) {
    final responseData = error.response?.data;

    if (responseData is Map &&
        responseData['detail'] != null) {
      return responseData['detail'].toString();
    }

    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid review request.';

      case 401:
        return 'Session expired. Please login again.';

      case 403:
        return 'You are not authorized to submit this review.';

      case 404:
        return 'Booking or vehicle not found.';

      case 409:
        return 'You have already reviewed this booking.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}