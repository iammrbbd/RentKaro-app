import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

// ============================================================
// AUTH SERVICE PROVIDER
// ============================================================

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ============================================================
// CURRENT AUTH USER
// ============================================================

final authUserProvider =
StateProvider<AuthUser?>((ref) {
  return null;
});

// ============================================================
// AUTH LOADING STATE
// ============================================================

final authLoadingProvider =
StateProvider<bool>((ref) {
  return false;
});

// ============================================================
// AUTH NOTIFIER
// ============================================================

class AuthNotifier
    extends StateNotifier<AuthUser?> {
  AuthNotifier(this._ref) : super(null);

  final Ref _ref;

  AuthService get _authService =>
      _ref.read(authServiceProvider);

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<AuthUser?> login({
    required String phone,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final user =
      await _authService.login(
        phone: phone.trim(),
        password: password,
      );

      state = user;

      _ref.read(
        authUserProvider.notifier,
      ).state = user;

      return user;
    } catch (error) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // SIGNUP
  //
  // Signup now only sends the OTP.
  // The user is NOT created until OTP verification succeeds.
  // ==========================================================

  Future<SignupOtpResponse> signup({
    required String name,
    required String phone,
    String? email,
    required String password,
    String role = 'customer',
  }) async {
    _setLoading(true);

    try {
      final normalizedRole =
      role.trim().toLowerCase();

      final response =
      await _authService.signup(
        name: name.trim(),
        phone: phone.trim(),
        email: email?.trim().isEmpty == true
            ? null
            : email?.trim(),
        password: password,
        role: normalizedRole,
      );

      return response;
    } catch (error) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // VERIFY SIGNUP OTP
  //
  // This is where the actual account is created and the
  // authentication token is saved.
  // ==========================================================

  Future<AuthUser> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);

    try {
      final user =
      await _authService.verifySignupOtp(
        email: email.trim(),
        otp: otp.trim(),
      );

      state = user;

      _ref.read(
        authUserProvider.notifier,
      ).state = user;

      return user;
    } catch (error) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // LOAD CURRENT USER
  // ==========================================================

  Future<AuthUser?> loadCurrentUser() async {
    try {
      final isLoggedIn =
      await _authService.isLoggedIn();

      if (!isLoggedIn) {
        state = null;

        _ref.read(
          authUserProvider.notifier,
        ).state = null;

        return null;
      }

      final user =
      await _authService.getCurrentUser();

      state = user;

      _ref.read(
        authUserProvider.notifier,
      ).state = user;

      return user;
    } catch (error) {
      state = null;

      _ref.read(
        authUserProvider.notifier,
      ).state = null;

      rethrow;
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();

      state = null;

      _ref.read(
        authUserProvider.notifier,
      ).state = null;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<AuthUser?> updateProfile({
    required String name,
    required String phone,
    String? email,
  }) async {
    _setLoading(true);

    try {
      final user =
      await _authService.updateProfile(
        name: name.trim(),
        phone: phone.trim(),
        email: email?.trim().isEmpty == true
            ? null
            : email?.trim(),
      );

      state = user;

      _ref.read(
        authUserProvider.notifier,
      ).state = user;

      return user;
    } catch (error) {
      rethrow;
    } finally {
      _setLoading(false);
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
    _setLoading(true);

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (error) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================
  // TOKEN
  // ==========================================================

  Future<String?> getToken() async {
    return _authService.getToken();
  }

  // ==========================================================
  // LOGIN STATUS
  // ==========================================================

  Future<bool> isLoggedIn() async {
    return _authService.isLoggedIn();
  }

  // ==========================================================
  // SET LOADING
  // ==========================================================

  void _setLoading(bool value) {
    _ref.read(
      authLoadingProvider.notifier,
    ).state = value;
  }
}

// ============================================================
// AUTH NOTIFIER PROVIDER
// ============================================================

final authNotifierProvider =
StateNotifierProvider<
    AuthNotifier,
    AuthUser?>(
      (ref) {
    return AuthNotifier(ref);
  },
);