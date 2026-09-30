import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // ADMIN LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final authService =
      ref.read(authServiceProvider);

      final user = await authService.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      // ========================================================
      // VERIFY ADMIN ROLE
      // ========================================================

      if (user.role.toLowerCase().trim() != 'admin') {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This account does not have admin access.',
            ),
          ),
        );

        return;
      }

      // ========================================================
      // UPDATE AUTH STATE
      // ========================================================

      ref.read(authUserProvider.notifier).state = user;

      if (!mounted) return;

      // ========================================================
      // ADMIN DASHBOARD
      // ========================================================

      context.go('/admin');
    } on DioException catch (error) {
      String message =
          'Unable to login. Please try again.';

      final responseData =
          error.response?.data;

      if (responseData is Map &&
          responseData['detail'] != null) {
        message =
            responseData['detail'].toString();
      } else if (
      error.type ==
          DioExceptionType.connectionError ||
          error.type ==
              DioExceptionType.connectionTimeout) {
        message =
        'Cannot connect to RentKaro server.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $error',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Admin Login',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width =
                MediaQuery.sizeOf(context).width;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal:
                width > 600 ? 80 : 24,
                vertical: 24,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                  constraints.maxHeight - 48,
                ),

                child: Center(
                  child: SizedBox(
                    width:
                    width > 600
                        ? 420
                        : double.infinity,

                    child: Form(
                      key: _formKey,

                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,

                        children: [
                          // ==================================================
                          // ICON
                          // ==================================================

                          Center(
                            child: Container(
                              width: 82,
                              height: 82,

                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFFFF7ED,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  22,
                                ),
                              ),

                              child:
                              const Icon(
                                Icons
                                    .admin_panel_settings_outlined,
                                size: 44,
                                color:
                                Color(
                                  0xFFEA580C,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // ==================================================
                          // TITLE
                          // ==================================================

                          const Text(
                            'RentKaro Admin',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              Color(
                                0xFF111827,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          const Text(
                            'Login to manage RentKaro',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                              Color(
                                0xFF6B7280,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 40,
                          ),

                          // ==================================================
                          // PHONE
                          // ==================================================

                          TextFormField(
                            controller:
                            _phoneController,

                            keyboardType:
                            TextInputType.phone,

                            decoration:
                            InputDecoration(
                              labelText:
                              'Admin Phone Number',

                              hintText:
                              'Enter admin phone number',

                              prefixIcon:
                              const Icon(
                                Icons
                                    .phone_outlined,
                              ),

                              filled: true,
                              fillColor:
                              Colors.white,

                              border:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  14,
                                ),
                              ),
                            ),

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return
                                  'Phone number is required';
                              }

                              if (value
                                  .trim()
                                  .length <
                                  10) {
                                return
                                  'Enter a valid phone number';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          // ==================================================
                          // PASSWORD
                          // ==================================================

                          TextFormField(
                            controller:
                            _passwordController,

                            obscureText:
                            _obscurePassword,

                            decoration:
                            InputDecoration(
                              labelText:
                              'Password',

                              hintText:
                              'Enter admin password',

                              prefixIcon:
                              const Icon(
                                Icons
                                    .lock_outline,
                              ),

                              suffixIcon:
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },

                                icon: Icon(
                                  _obscurePassword
                                      ? Icons
                                      .visibility_outlined
                                      : Icons
                                      .visibility_off_outlined,
                                ),
                              ),

                              filled: true,
                              fillColor:
                              Colors.white,

                              border:
                              OutlineInputBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  14,
                                ),
                              ),
                            ),

                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value.isEmpty) {
                                return
                                  'Password is required';
                              }

                              if (value.length <
                                  6) {
                                return
                                  'Minimum 6 characters required';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // ==================================================
                          // LOGIN BUTTON
                          // ==================================================

                          SizedBox(
                            height: 54,

                            child:
                            ElevatedButton(
                              onPressed:
                              _loading
                                  ? null
                                  : _login,

                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                const Color(
                                  0xFFEA580C,
                                ),

                                foregroundColor:
                                Colors.white,

                                elevation: 0,

                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    14,
                                  ),
                                ),
                              ),

                              child: _loading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                CircularProgressIndicator(
                                  color:
                                  Colors.white,
                                  strokeWidth:
                                  2.5,
                                ),
                              )
                                  : const Text(
                                'Admin Login',
                                style:
                                TextStyle(
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // BACK TO USER LOGIN
                          // ==================================================

                          TextButton(
                            onPressed: () {
                              context.go(
                                '/login',
                              );
                            },

                            child:
                            const Text(
                              'Back to User Login',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .w600,
                                color:
                                Color(
                                  0xFF2563EB,
                                ),
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
          },
        ),
      ),
    );
  }
}