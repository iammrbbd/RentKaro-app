import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentService {
  PaymentService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  final Dio _dio;

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

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

  Future<Map<String, dynamic>> createOrder({
    required int bookingId,
  }) async {
    final token = await _getToken();

    try {
      final response = await _dio.post(
        '/api/payments/create-order',
        queryParameters: {
          'booking_id': bookingId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(error),
      );
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required int bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final token = await _getToken();

    try {
      final response = await _dio.post(
        '/api/payments/verify',
        data: {
          'booking_id': bookingId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(error),
      );
    }
  }

  Future<Map<String, dynamic>> getPayment({
    required int bookingId,
  }) async {
    final token = await _getToken();

    try {
      final response = await _dio.get(
        '/api/payments/$bookingId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Map<String, dynamic>.from(
        response.data,
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(error),
      );
    }
  }

  String _extractErrorMessage(
      DioException error,
      ) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      final message = responseData['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (error.message != null &&
        error.message!.isNotEmpty) {
      return error.message!;
    }

    return 'Payment request failed. Please try again.';
  }
}