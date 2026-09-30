import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/host_kyc.dart';

class HostKycService {
  HostKycService()
      : _dio = Dio(
    BaseOptions(
      // Android Emulator -> Windows PC localhost
      baseUrl: 'https://rentkaro.up.railway.app',

      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),

      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  final Dio _dio;

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  // ==========================================================
  // GET AUTH TOKEN
  // ==========================================================

  Future<String> _getToken() async {
    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    return token;
  }

  // ==========================================================
  // AUTH OPTIONS
  // ==========================================================

  Future<Options> _authOptions() async {
    final token = await _getToken();

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ==========================================================
  // GET MY HOST KYC
  // ==========================================================

  Future<HostKyc?> getMyKyc() async {
    try {
      print(
        'HOST KYC GET: ${_dio.options.baseUrl}/api/host-kyc/me',
      );

      final response = await _dio.get(
        '/api/host-kyc/me',
        options: await _authOptions(),
      );

      print(
        'HOST KYC GET STATUS: ${response.statusCode}',
      );

      print(
        'HOST KYC GET RESPONSE: ${response.data}',
      );

      if (response.data == null) {
        return null;
      }

      if (response.data is! Map) {
        throw Exception(
          'Invalid Host KYC response from server.',
        );
      }

      return HostKyc.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      print('HOST KYC GET ERROR');
      print('TYPE: ${error.type}');
      print('URL: ${error.requestOptions.uri}');
      print('MESSAGE: ${error.message}');
      print('STATUS: ${error.response?.statusCode}');
      print('RESPONSE: ${error.response?.data}');

      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to load Host KYC information.',
        ),
      );
    }
  }

  // ==========================================================
  // SUBMIT / RESUBMIT HOST KYC
  // ==========================================================

  Future<HostKyc> submitKyc({
    required String aadhaarNumber,
    required String panNumber,
    required String drivingLicenseNumber,
    required XFile aadhaarDocument,
    required XFile panDocument,
    required XFile drivingLicenseDocument,
  }) async {
    try {
      // XFile.readAsBytes() works on Android, iOS, Web and Desktop.
      // MultipartFile.fromFile() depends on dart:io and therefore fails
      // on Flutter Web.
      final aadhaarBytes = await aadhaarDocument.readAsBytes();
      final panBytes = await panDocument.readAsBytes();
      final drivingLicenseBytes =
      await drivingLicenseDocument.readAsBytes();

      final formData = FormData.fromMap({
        'aadhaar_number': aadhaarNumber.trim(),

        'pan_number':
        panNumber.trim().toUpperCase(),

        'driving_license_number':
        drivingLicenseNumber.trim().toUpperCase(),

        'aadhaar_document':
        MultipartFile.fromBytes(
          aadhaarBytes,
          filename: aadhaarDocument.name,
        ),

        'pan_document':
        MultipartFile.fromBytes(
          panBytes,
          filename: panDocument.name,
        ),

        'driving_license_document':
        MultipartFile.fromBytes(
          drivingLicenseBytes,
          filename: drivingLicenseDocument.name,
        ),
      });

      print(
        'HOST KYC SUBMIT: '
            '${_dio.options.baseUrl}/api/host-kyc/submit',
      );

      final response = await _dio.post(
        '/api/host-kyc/submit',
        data: formData,
        options: await _authOptions(),
      );

      print(
        'HOST KYC SUBMIT STATUS: '
            '${response.statusCode}',
      );

      print(
        'HOST KYC SUBMIT RESPONSE: '
            '${response.data}',
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid Host KYC response from server.',
        );
      }

      return HostKyc.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      print('HOST KYC SUBMIT ERROR');
      print('TYPE: ${error.type}');
      print('URL: ${error.requestOptions.uri}');
      print('MESSAGE: ${error.message}');
      print('STATUS: ${error.response?.statusCode}');
      print('RESPONSE: ${error.response?.data}');

      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to submit Host KYC.',
        ),
      );
    }
  }

  // ==========================================================
  // ERROR HANDLER
  // ==========================================================

  String _extractErrorMessage(
      DioException error, {
        required String fallback,
      }) {
    final data = error.response?.data;

    // --------------------------------------------------------
    // BACKEND DETAIL
    // --------------------------------------------------------

    if (data is Map) {
      final detail = data['detail'];

      if (detail != null &&
          detail.toString().trim().isNotEmpty) {
        return detail.toString();
      }
    }

    // --------------------------------------------------------
    // AUTH
    // --------------------------------------------------------

    if (error.response?.statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    // --------------------------------------------------------
    // FORBIDDEN
    // --------------------------------------------------------

    if (error.response?.statusCode == 403) {
      return 'You are not authorized to perform this action.';
    }

    // --------------------------------------------------------
    // CONFLICT
    // --------------------------------------------------------

    if (error.response?.statusCode == 409) {
      return 'Host KYC is already submitted or approved.';
    }

    // --------------------------------------------------------
    // FILE TOO LARGE
    // --------------------------------------------------------

    if (error.response?.statusCode == 413) {
      return 'Document size is too large. Maximum size is 5 MB.';
    }

    // --------------------------------------------------------
    // CONNECTION ERROR
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Unable to connect to the RentKaro server.';
    }

    // --------------------------------------------------------
    // CONNECTION TIMEOUT
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.connectionTimeout ||
        error.type ==
            DioExceptionType.receiveTimeout) {
      return 'Server connection timed out.';
    }

    // --------------------------------------------------------
    // SERVER ERROR
    // --------------------------------------------------------

    if (error.response?.statusCode != null) {
      return 'Server error: ${error.response?.statusCode}';
    }

    return fallback;
  }
}