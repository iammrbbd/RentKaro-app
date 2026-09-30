import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/kyc_model.dart';

class KycService {
  KycService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout:
          const Duration(seconds: 15),
          receiveTimeout:
          const Duration(seconds: 30),
          sendTimeout:
          const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
          },
        ),
      ),
        _storage =
            storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const String _baseUrl =
      'https://rentkaro.up.railway.app';

  // ============================================================
  // GET TOKEN
  // ============================================================

  Future<String> _getToken() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null ||
        token.trim().isEmpty) {
      throw Exception(
        'Authentication token not found. Please login again.',
      );
    }

    return token.trim();
  }

  // ============================================================
  // AUTH OPTIONS
  // ============================================================

  Future<Options> _authOptions() async {
    final token = await _getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ============================================================
  // GET MY KYC
  // ============================================================

  Future<KycModel?> getMyKyc() async {
    try {
      print('==========================================');
      print('CUSTOMER KYC - GET MY KYC');
      print('URL: $_baseUrl/api/kyc/me');
      print('==========================================');

      final response = await _dio.get(
        '/api/kyc/me',
        options: await _authOptions(),
      );

      print(
        'KYC GET STATUS: ${response.statusCode}',
      );

      print(
        'KYC GET RESPONSE: ${response.data}',
      );

      if (response.data == null) {
        return null;
      }

      if (response.data is! Map) {
        throw Exception(
          'Invalid KYC response received from server.',
        );
      }

      final json =
      Map<String, dynamic>.from(
        response.data as Map,
      );

      return KycModel.fromJson(json);
    } on DioException catch (error) {
      print('==========================================');
      print('CUSTOMER KYC GET ERROR');
      print('TYPE: ${error.type}');
      print(
        'STATUS: ${error.response?.statusCode}',
      );
      print(
        'DATA: ${error.response?.data}',
      );
      print(
        'MESSAGE: ${error.message}',
      );
      print('==========================================');

      throw Exception(
        _extractDioError(error),
      );
    } catch (error) {
      print(
        'CUSTOMER KYC GET UNKNOWN ERROR: $error',
      );

      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to process KYC request.',
      );
    }
  }

  // ============================================================
  // SUBMIT KYC
  // ============================================================

  Future<KycModel> submitKyc({
    required String fullName,
    required DateTime dateOfBirth,
    required String address,
    required String aadhaarLast4,
    required String drivingLicenseNumber,
    required DateTime drivingLicenseExpiry,
    required XFile aadhaarDocument,
    required XFile drivingLicenseDocument,
  }) async {
    try {
      print('==========================================');
      print('CUSTOMER KYC - SUBMIT');
      print('URL: $_baseUrl/api/kyc/submit');
      print('==========================================');

      final token = await _getToken();

      // ========================================================
      // VALIDATION
      // ========================================================

      if (fullName.trim().isEmpty) {
        throw Exception(
          'Full name is required.',
        );
      }

      if (address.trim().isEmpty) {
        throw Exception(
          'Address is required.',
        );
      }

      if (!RegExp(r'^\d{4}$')
          .hasMatch(aadhaarLast4.trim())) {
        throw Exception(
          'Aadhaar last 4 digits must contain exactly 4 digits.',
        );
      }

      if (drivingLicenseNumber
          .trim()
          .isEmpty) {
        throw Exception(
          'Driving licence number is required.',
        );
      }

      // ========================================================
      // MULTIPART FORM DATA
      // ========================================================

      final formData = FormData.fromMap({
        'full_name':
        fullName.trim(),

        'date_of_birth':
        _formatDateForApi(
          dateOfBirth,
        ),

        'address':
        address.trim(),

        'aadhaar_last4':
        aadhaarLast4.trim(),

        'driving_license_number':
        drivingLicenseNumber
            .trim()
            .toUpperCase(),

        'driving_license_expiry':
        _formatDateForApi(
          drivingLicenseExpiry,
        ),

        'aadhaar_document':
        await MultipartFile.fromFile(
          aadhaarDocument.path,
          filename:
          aadhaarDocument.name,
        ),

        'driving_license_document':
        await MultipartFile.fromFile(
          drivingLicenseDocument.path,
          filename:
          drivingLicenseDocument.name,
        ),
      });

      print(
        'KYC FULL NAME: ${fullName.trim()}',
      );

      print(
        'KYC DOB: ${_formatDateForApi(dateOfBirth)}',
      );

      print(
        'KYC ADDRESS: ${address.trim()}',
      );

      print(
        'KYC AADHAAR LAST4: ${aadhaarLast4.trim()}',
      );

      print(
        'KYC LICENSE: '
            '${drivingLicenseNumber.trim().toUpperCase()}',
      );

      print(
        'KYC LICENSE EXPIRY: '
            '${_formatDateForApi(drivingLicenseExpiry)}',
      );

      print(
        'AADHAAR FILE: ${aadhaarDocument.name}',
      );

      print(
        'LICENSE FILE: '
            '${drivingLicenseDocument.name}',
      );

      // ========================================================
      // API REQUEST
      // ========================================================

      final response = await _dio.post(
        '/api/kyc/submit',
        data: formData,
        options: Options(
          headers: {
            'Authorization':
            'Bearer $token',
            'Accept':
            'application/json',
          },
        ),
      );

      print(
        'KYC SUBMIT STATUS: '
            '${response.statusCode}',
      );

      print(
        'KYC SUBMIT RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid KYC submission response from server.',
        );
      }

      final json =
      Map<String, dynamic>.from(
        response.data as Map,
      );

      return KycModel.fromJson(json);
    } on DioException catch (error) {
      print('==========================================');
      print('CUSTOMER KYC SUBMIT ERROR');
      print('TYPE: ${error.type}');
      print(
        'STATUS: ${error.response?.statusCode}',
      );
      print(
        'DATA: ${error.response?.data}',
      );
      print(
        'MESSAGE: ${error.message}',
      );
      print('==========================================');

      throw Exception(
        _extractDioError(error),
      );
    } catch (error) {
      print(
        'CUSTOMER KYC SUBMIT UNKNOWN ERROR: $error',
      );

      if (error is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to submit KYC.',
      );
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateForApi(
      DateTime date,
      ) {
    final year =
    date.year.toString().padLeft(
      4,
      '0',
    );

    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    return '$year-$month-$day';
  }

  // ============================================================
  // DIO ERROR
  // ============================================================

  String _extractDioError(
      DioException error,
      ) {
    final response =
        error.response;

    // ========================================================
    // BACKEND RESPONSE
    // ========================================================

    if (response != null) {
      final data =
          response.data;

      if (data is Map) {
        final detail =
        data['detail'];

        if (detail != null) {
          if (detail is String &&
              detail.trim().isNotEmpty) {
            return detail.trim();
          }

          if (detail is List &&
              detail.isNotEmpty) {
            final messages =
            detail.map((item) {
              if (item is Map) {
                final message =
                item['msg'];

                if (message != null) {
                  return message.toString();
                }
              }

              return item.toString();
            }).join(', ');

            if (messages
                .trim()
                .isNotEmpty) {
              return messages;
            }
          }
        }

        final message =
        data['message'];

        if (message != null &&
            message
                .toString()
                .trim()
                .isNotEmpty) {
          return message
              .toString()
              .trim();
        }

        final errorMessage =
        data['error'];

        if (errorMessage != null &&
            errorMessage
                .toString()
                .trim()
                .isNotEmpty) {
          return errorMessage
              .toString()
              .trim();
        }
      }

      // ======================================================
      // HTTP STATUS
      // ======================================================

      final statusCode =
          response.statusCode;

      if (statusCode == 400) {
        return 'Invalid KYC information. Please check your details.';
      }

      if (statusCode == 401) {
        return 'Your session has expired. Please login again.';
      }

      if (statusCode == 403) {
        return 'You are not authorized to perform this KYC action.';
      }

      if (statusCode == 404) {
        return 'KYC service endpoint was not found.';
      }

      if (statusCode == 409) {
        return 'KYC is already submitted or under review.';
      }

      if (statusCode == 413) {
        return 'Uploaded document is too large.';
      }

      if (statusCode != null &&
          statusCode >= 500) {
        return 'Server error while processing KYC. Please try again.';
      }
    }

    // ========================================================
    // NETWORK / DIO ERRORS
    // ========================================================

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your network.';

      case DioExceptionType.sendTimeout:
        return 'Uploading KYC documents timed out. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again.';

      case DioExceptionType.transformTimeout:
        return 'Processing the server response timed out. Please try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to RentKaro server. Make sure the backend is running.';

      case DioExceptionType.badCertificate:
        return 'Secure connection with the server failed.';

      case DioExceptionType.cancel:
        return 'KYC request was cancelled.';

      case DioExceptionType.badResponse:
        return 'Server returned an invalid response.';

      case DioExceptionType.unknown:
        return 'Unable to connect to RentKaro server.';
    }
  }
}