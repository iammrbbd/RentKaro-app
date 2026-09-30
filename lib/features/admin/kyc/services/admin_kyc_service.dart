import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/admin_kyc_model.dart';

class AdminKycService {
  static const String baseUrl = 'https://rentkaro.up.railway.app';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  AdminKycService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout:
          const Duration(seconds: 15),
          receiveTimeout:
          const Duration(seconds: 30),
        ),
      ),
        _storage =
            storage ??
                const FlutterSecureStorage();

  // ============================================================
  // AUTH OPTIONS
  // ============================================================

  Future<Options> _authOptions() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null ||
        token.trim().isEmpty) {
      throw Exception(
        'Please login again.',
      );
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ============================================================
  // GET HOST KYC LIST
  // ============================================================

  Future<List<AdminKycModel>> getKycList({
    String? status,
  }) async {
    try {
      final endpoint =
      status == 'pending'
          ? '/api/admin/host-kyc/pending'
          : '/api/admin/host-kyc';

      final response = await _dio.get(
        endpoint,
        options: await _authOptions(),
      );

      debugPrint(
        '================================================',
      );

      debugPrint(
        'ADMIN HOST KYC RESPONSE',
      );

      debugPrint(
        'STATUS: ${response.statusCode}',
      );

      debugPrint(
        'DATA TYPE: ${response.data.runtimeType}',
      );

      debugPrint(
        'DATA: ${response.data}',
      );

      debugPrint(
        '================================================',
      );

      final data = response.data;

      // ========================================================
      // RESPONSE MUST BE A LIST
      // ========================================================

      if (data is! List) {
        throw Exception(
          'Host KYC API returned ${data.runtimeType} '
              'instead of List.\n'
              'Response: $data',
        );
      }

      final List<AdminKycModel> items = [];

      // ========================================================
      // PARSE EACH RECORD SEPARATELY
      // ========================================================

      for (int index = 0;
      index < data.length;
      index++) {
        try {
          final item = data[index];

          if (item is! Map) {
            throw Exception(
              'Record is not a JSON object. '
                  'Received: ${item.runtimeType}',
            );
          }

          final json =
          Map<String, dynamic>.from(
            item,
          );

          debugPrint(
            'HOST KYC RECORD [$index]: $json',
          );

          final kyc =
          AdminKycModel.fromJson(
            json,
          );

          items.add(kyc);
        } catch (error, stackTrace) {
          debugPrint(
            '================================================',
          );

          debugPrint(
            'HOST KYC PARSING ERROR',
          );

          debugPrint(
            'INDEX: $index',
          );

          debugPrint(
            'RECORD: ${data[index]}',
          );

          debugPrint(
            'ERROR: $error',
          );

          debugPrint(
            'STACK TRACE: $stackTrace',
          );

          debugPrint(
            '================================================',
          );

          throw Exception(
            'Unable to parse Host KYC record #${index + 1}.\n'
                'Error: $error',
          );
        }
      }

      // ========================================================
      // APPROVED / REJECTED FILTER
      // ========================================================

      if (status == 'approved' ||
          status == 'rejected') {
        return items
            .where(
              (item) =>
          item.verificationStatus
              .trim()
              .toLowerCase() ==
              status,
        )
            .toList();
      }

      return items;
    } on DioException catch (error) {
      debugPrint(
        '================================================',
      );

      debugPrint(
        'ADMIN HOST KYC DIO ERROR',
      );

      debugPrint(
        'URL: ${error.requestOptions.uri}',
      );

      debugPrint(
        'STATUS: ${error.response?.statusCode}',
      );

      debugPrint(
        'RESPONSE: ${error.response?.data}',
      );

      debugPrint(
        'ERROR: ${error.message}',
      );

      debugPrint(
        '================================================',
      );

      throw Exception(
        _extractError(error),
      );
    } catch (error) {
      debugPrint(
        'ADMIN HOST KYC ERROR: $error',
      );

      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to load Host KYC records.',
      );
    }
  }

  // ============================================================
  // GET HOST KYC DETAIL
  // ============================================================

  Future<AdminKycModel> getKycDetail(
      int kycId,
      ) async {
    try {
      final response = await _dio.get(
        '/api/admin/host-kyc/$kycId',
        options: await _authOptions(),
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid Host KYC detail response.',
        );
      }

      return AdminKycModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractError(error),
      );
    }
  }

  // ============================================================
  // APPROVE HOST KYC
  // ============================================================

  Future<AdminKycModel> approveKyc(
      int kycId,
      ) async {
    try {
      final response = await _dio.put(
        '/api/admin/host-kyc/$kycId/approve',
        options: await _authOptions(),
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid approval response from server.',
        );
      }

      return AdminKycModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractError(error),
      );
    }
  }

  // ============================================================
  // REJECT HOST KYC
  // ============================================================

  Future<AdminKycModel> rejectKyc({
    required int kycId,
    required String reason,
  }) async {
    final rejectionReason =
    reason.trim();

    if (rejectionReason.isEmpty) {
      throw Exception(
        'Rejection reason is required.',
      );
    }

    if (rejectionReason.length > 500) {
      throw Exception(
        'Rejection reason must not exceed 500 characters.',
      );
    }

    try {
      final response = await _dio.put(
        '/api/admin/host-kyc/$kycId/reject',
        data: {
          'rejection_reason':
          rejectionReason,
        },
        options: await _authOptions(),
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid rejection response from server.',
        );
      }

      return AdminKycModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractError(error),
      );
    }
  }

  // ============================================================
  // GET HOST KYC DOCUMENT
  // ============================================================

  Future<Uint8List> getDocument({
    required int kycId,
    required String documentType,
  }) async {
    try {
      final authOptions =
      await _authOptions();

      final response =
      await _dio.get<List<int>>(
        '/api/admin/host-kyc/'
            '$kycId/document/'
            '$documentType',
        options: Options(
          headers:
          authOptions.headers,
          responseType:
          ResponseType.bytes,
        ),
      );

      return Uint8List.fromList(
        response.data ?? [],
      );
    } on DioException catch (error) {
      throw Exception(
        _extractError(error),
      );
    }
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  String _extractError(
      DioException error,
      ) {
    final data =
        error.response?.data;

    if (data is Map &&
        data['detail'] != null) {
      return data['detail'].toString();
    }

    if (error.response?.statusCode ==
        401) {
      return 'Session expired. Please login again.';
    }

    if (error.response?.statusCode ==
        403) {
      return 'Admin access required.';
    }

    if (error.response?.statusCode ==
        404) {
      return 'Host KYC record not found.';
    }

    if (error.response?.statusCode ==
        409) {
      return data is Map &&
          data['detail'] != null
          ? data['detail'].toString()
          : 'This Host KYC action cannot be performed.';
    }

    if (error.response?.statusCode ==
        422) {
      return data is Map &&
          data['detail'] != null
          ? data['detail'].toString()
          : 'Invalid Host KYC request.';
    }

    if (error.response?.statusCode !=
        null) {
      return 'Server error: '
          '${error.response!.statusCode}';
    }

    return 'Unable to connect to the server.';
  }
}