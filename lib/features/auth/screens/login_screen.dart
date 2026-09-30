import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CUSTOMER LOGIN
  // ==========================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      final user = await authService.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      ref.read(authUserProvider.notifier).state = user;

      if (!mounted) {
        return;
      }

      final role = user.role.toLowerCase().trim();

      // --------------------------------------------------------
      // ADMIN
      // --------------------------------------------------------

      if (role == 'admin') {
        context.go('/admin/vehicles');
        return;
      }

      // --------------------------------------------------------
      // HOST / OWNER
      // --------------------------------------------------------

      if (role == 'host' || role == 'owner') {
        context.go('/host');
        return;
      }

      // --------------------------------------------------------
      // CUSTOMER
      // --------------------------------------------------------

      context.go('/home');
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorMessage(error),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  String _errorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final detail = responseData['detail'];

      if (detail != null && detail.toString().isNotEmpty) {
        return detail.toString();
      }

      final message = responseData['message'];

      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to RentKaro server.';
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out. Please try again.';
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server response timed out.';
    }

    if (error.response?.statusCode == 401) {
      return 'Invalid phone number or password.';
    }

    if (error.response?.statusCode == 422) {
      return 'Invalid login data.';
    }

    return 'Unable to login. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==================================================
                  // APP ICON
                  // ==================================================

                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 34,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'Welcome to RentKaro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Login to continue your journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // PHONE
                  // ==================================================

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                      ),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? '';

                      if (phone.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      if (!RegExp(
                        r'^[0-9]{10}$',
                      ).hasMatch(phone)) {
                        return 'Enter a valid 10-digit phone number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================================
                  // LOGIN BUTTON
                  // ==================================================

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // REGISTER
                  // ==================================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // IMPORTANT:
                          // Open role selection before signup.
                          context.push('/register-role');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // HOST LOGIN
                  // ==================================================

                  TextButton.icon(
                    onPressed: () {
                      context.go('/host/login');
                    },
                    icon: const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    label: const Text(
                      'Host Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),

                  // ==================================================
                  // ADMIN LOGIN
                  // ==================================================

                  TextButton.icon(
                    onPressed: () {
                      context.go('/admin/login');
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 18,
                      color: Color(0xFFEA580C),
                    ),
                    label: const Text(
                      'Admin Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}