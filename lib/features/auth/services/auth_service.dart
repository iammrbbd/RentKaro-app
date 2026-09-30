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
  );

  final Dio _dio;

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _tokenKey =
      'access_token';

  // ==========================================================
  // SIGNUP
  // ==========================================================

  Future<SignupOtpResponse> signup({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String role,
  }) async {
    try {
      final response =
      await _dio.post(
        '/api/auth/signup',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.data is! Map) {
        throw Exception(
          'Invalid signup response from server.',
        );
      }

      final data =
      Map<String, dynamic>.from(
        response.data,
      );

      return SignupOtpResponse.fromJson(
        data,
      );
    } on DioException catch (error) {
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

  Future<AuthUser> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response =
      await _dio.post(
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
      data['access_token']
          ?.toString();

      if (token == null ||
          token.trim().isEmpty) {
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

  Future<SignupOtpResponse>
  resendSignupOtp({
    required String email,
  }) async {
    try {
      final response =
      await _dio.post(
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

      return SignupOtpResponse.fromJson(
        data,
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
      final response =
      await _dio.post(
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
      data['access_token']
          ?.toString();

      if (token == null ||
          token.trim().isEmpty) {
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

      final response =
      await _dio.get(
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
              return message
                  .toString();
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

    if (responseData is String &&
        responseData.trim().isNotEmpty) {
      return responseData;
    }

    if (error.type ==
        DioExceptionType.connectionTimeout) {
      return 'Connection timed out. Please check your internet connection.';
    }

    if (error.type ==
        DioExceptionType.receiveTimeout) {
      return 'Server response timed out. Please try again.';
    }

    if (error.type ==
        DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Unable to connect to RentKaro server.';
    }

    return fallback;
  }
}