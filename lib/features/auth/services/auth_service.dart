import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_user.dart';

// ============================================================
// SIGNUP OTP RESPONSE
// ============================================================

class SignupOtpResponse {
  final String message;
  final String email;

  const SignupOtpResponse({
    required this.message,
    required this.email,
  });

  factory SignupOtpResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return SignupOtpResponse(
      message:
      json['message']?.toString() ??
          'Verification OTP sent to your email.',
      email:
      json['email']?.toString() ??
          '',
    );
  }
}

// ============================================================
// AUTH SERVICE
// ============================================================

class AuthService {
  AuthService()
      : _dio = Dio(
    BaseOptions(
      baseUrl:
      'https://rentkaro.up.railway.app',
      connectTimeout:
      const Duration(seconds: 15),
      receiveTimeout:
      const Duration(seconds: 15),
      sendTimeout:
      const Duration(seconds: 15),
      headers: {
        'Content-Type':
        'application/json',
        'Accept':
        'application/json',
      },
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('AUTH DIO REQUEST');
        print('URL: ${options.uri}');
        print('CONNECT TIMEOUT: ${options.connectTimeout}');
        print('RECEIVE TIMEOUT: ${options.receiveTimeout}');
        print('SEND TIMEOUT: ${options.sendTimeout}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('AUTH DIO RESPONSE');
        print('URL: ${response.requestOptions.uri}');
        print('STATUS: ${response.statusCode}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('AUTH DIO ERROR');
        print('URL: ${error.requestOptions.uri}');
        print('TYPE: ${error.type}');
        print('CONNECT TIMEOUT: ${error.requestOptions.connectTimeout}');
        print('RECEIVE TIMEOUT: ${error.requestOptions.receiveTimeout}');
        print('SEND TIMEOUT: ${error.requestOptions.sendTimeout}');
        print('MESSAGE: ${error.message}');
        handler.next(error);
      },
    ),
  );

  final Dio _dio;

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _tokenKey =
      'access_token';

  // ==========================================================
  // SIGNUP
  // ==========================================================
  //
  // IMPORTANT:
  // Signup ONLY starts the OTP verification process.
  //
  // The backend does NOT return an authentication token here.
  //
  // Token is received ONLY after:
  //
  // /api/auth/signup/verify-otp
  //
  // ==========================================================

  Future<SignupOtpResponse> signup({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String role,
  }) async {
    try {
      print('SIGNUP REQUEST START');
      print('SIGNUP DIO RECEIVE TIMEOUT: ${_dio.options.receiveTimeout}');
      print('SIGNUP DIO CONNECT TIMEOUT: ${_dio.options.connectTimeout}');
      print('SIGNUP DIO SEND TIMEOUT: ${_dio.options.sendTimeout}');

      final response = await _dio.post(
        '/api/auth/signup',
        data: {
          'name': name.trim(),
          'phone': phone.trim(),
          'email': email?.trim(),
          'password': password,
          'role': role.trim().toLowerCase(),
        },
      );

      print('SIGNUP REQUEST SUCCESS');
      print('SIGNUP STATUS: ${response.statusCode}');
      print('SIGNUP RESPONSE DATA: ${response.data}');

      if (response.data is! Map) {
        throw Exception(
          'Invalid signup response from server.',
        );
      }

      final data =
      Map<String, dynamic>.from(
        response.data,
      );

      final serverEmail =
          data['email']?.toString().trim() ?? '';

      final responseEmail =
      serverEmail.isNotEmpty
          ? serverEmail
          : (email?.trim() ?? '');

      return SignupOtpResponse(
        message:
        data['message']?.toString() ??
            'Verification OTP sent to your email.',
        email: responseEmail,
      );
    } on DioException catch (error) {
      print('SIGNUP REQUEST ERROR');
      print('SIGNUP ERROR TYPE: ${error.type}');
      print('SIGNUP ERROR URL: ${error.requestOptions.uri}');
      print('SIGNUP ERROR RECEIVE TIMEOUT: ${error.requestOptions.receiveTimeout}');
      print('SIGNUP ERROR MESSAGE: ${error.message}');
      print('SIGNUP ERROR STATUS: ${error.response?.statusCode}');

      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to start registration. Please try again.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // VERIFY SIGNUP OTP
  // ==========================================================
  //
  // Authentication token is expected HERE.
  //
  // Backend response:
  //
  // {
  //   "access_token": "...",
  //   "token_type": "bearer",
  //   "user": {...}
  // }
  //
  // ==========================================================

  Future<AuthUser> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/signup/verify-otp',
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid OTP verification response from server.',
        );
      }

      final data =
      Map<String, dynamic>.from(
        response.data,
      );

      // ------------------------------------------------------
      // TOKEN
      // ------------------------------------------------------

      final token =
      data['access_token']?.toString().trim();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Account was created but authentication token was not received.',
        );
      }

      // ------------------------------------------------------
      // USER
      // ------------------------------------------------------

      final userData =
      data['user'];

      if (userData is! Map) {
        throw Exception(
          'Account was created but user data was not received.',
        );
      }

      final user =
      AuthUser.fromJson(
        Map<String, dynamic>.from(
          userData,
        ),
      );

      // ------------------------------------------------------
      // SAVE TOKEN
      // ------------------------------------------------------

      await _storage.write(
        key: _tokenKey,
        value: token,
      );

      return user;
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to verify OTP. Please try again.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // RESEND SIGNUP OTP
  // ==========================================================

  Future<SignupOtpResponse> resendSignupOtp({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/signup/resend-otp',
        queryParameters: {
          'email': email.trim(),
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid resend OTP response from server.',
        );
      }

      final data =
      Map<String, dynamic>.from(
        response.data,
      );

      final serverEmail =
          data['email']?.toString().trim() ?? '';

      return SignupOtpResponse(
        message:
        data['message']?.toString() ??
            'Verification OTP sent to your email.',
        email: serverEmail.isNotEmpty
            ? serverEmail
            : email.trim(),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to resend OTP. Please try again.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'phone': phone.trim(),
          'password': password,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid login response from server.',
        );
      }

      final data =
      Map<String, dynamic>.from(
        response.data,
      );

      final token =
      data['access_token']?.toString().trim();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login succeeded but authentication token was not received.',
        );
      }

      final userData =
      data['user'];

      if (userData is! Map) {
        throw Exception(
          'Login succeeded but user data was not received.',
        );
      }

      final user =
      AuthUser.fromJson(
        Map<String, dynamic>.from(
          userData,
        ),
      );

      await _storage.write(
        key: _tokenKey,
        value: token,
      );

      return user;
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to login. Please check your credentials.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // GET CURRENT USER
  // ==========================================================

  Future<AuthUser> getCurrentUser() async {
    try {
      final token =
      await getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Authentication token not found. Please login again.',
        );
      }

      final response = await _dio.get(
        '/api/auth/me',
        options: Options(
          headers: {
            'Authorization':
            'Bearer $token',
            'Accept':
            'application/json',
          },
        ),
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid current user response from server.',
        );
      }

      return AuthUser.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to load your account.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<AuthUser> updateProfile({
    required String name,
    required String phone,
    String? email,
  }) async {
    try {
      final token =
      await getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Authentication token not found. Please login again.',
        );
      }

      final response =
      await _dio.patch(
        '/api/auth/profile',
        data: {
          'name': name.trim(),
          'phone': phone.trim(),
          'email':
          email?.trim().isEmpty == true
              ? null
              : email?.trim(),
        },
        options: Options(
          headers: {
            'Authorization':
            'Bearer $token',
            'Content-Type':
            'application/json',
            'Accept':
            'application/json',
          },
        ),
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid profile response from server.',
        );
      }

      return AuthUser.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to update profile.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token =
      await getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Authentication token not found. Please login again.',
        );
      }

      await _dio.post(
        '/api/auth/change-password',
        data: {
          'current_password':
          currentPassword,
          'new_password':
          newPassword,
          'confirm_password':
          confirmPassword,
        },
        options: Options(
          headers: {
            'Authorization':
            'Bearer $token',
            'Content-Type':
            'application/json',
            'Accept':
            'application/json',
          },
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(
          error,
          fallback:
          'Unable to change password.',
        ),
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // ==========================================================
  // GET TOKEN
  // ==========================================================

  Future<String?> getToken() async {
    return _storage.read(
      key: _tokenKey,
    );
  }

  // ==========================================================
  // LOGGED IN
  // ==========================================================

  Future<bool> isLoggedIn() async {
    final token =
    await getToken();

    return token != null &&
        token.trim().isNotEmpty;
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    await _storage.delete(
      key: _tokenKey,
    );
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  String _extractErrorMessage(
      DioException error, {
        required String fallback,
      }) {
    final responseData =
        error.response?.data;

    // --------------------------------------------------------
    // FastAPI:
    // {"detail": "..."}
    // --------------------------------------------------------

    if (responseData is Map) {
      final detail =
      responseData['detail'];

      if (detail != null) {
        if (detail is String &&
            detail.trim().isNotEmpty) {
          return detail;
        }

        if (detail is List &&
            detail.isNotEmpty) {
          final first =
              detail.first;

          if (first is Map) {
            final message =
            first['msg'];

            if (message != null) {
              return message.toString();
            }
          }
        }
      }

      final message =
      responseData['message'];

      if (message != null &&
          message
              .toString()
              .trim()
              .isNotEmpty) {
        return message.toString();
      }
    }

    // --------------------------------------------------------
    // Plain text response
    // --------------------------------------------------------

    if (responseData is String &&
        responseData.trim().isNotEmpty) {
      return responseData;
    }

    // --------------------------------------------------------
    // TIMEOUTS
    // --------------------------------------------------------

    if (error.type ==
        DioExceptionType.connectionTimeout) {
      return
        'Connection timed out. Please check your internet connection.';
    }

    if (error.type ==
        DioExceptionType.receiveTimeout) {
      return
        'Server response timed out. Please try again.';
    }

    if (error.type ==
        DioExceptionType.sendTimeout) {
      return
        'Request timed out. Please try again.';
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return
        'Unable to connect to RentKaro server.';
    }

    return fallback;
  }
}