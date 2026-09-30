import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';

class HostLoginScreen extends ConsumerStatefulWidget {
  const HostLoginScreen({super.key});

  @override
  ConsumerState<HostLoginScreen> createState() =>
      _HostLoginScreenState();
}

class _HostLoginScreenState
    extends ConsumerState<HostLoginScreen> {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final authService =
      ref.read(authServiceProvider);

      final user = await authService.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      final role =
      user.role.toLowerCase().trim();

      if (role != 'owner' &&
          role != 'host') {
        await authService.logout();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This account is not registered as a Host.',
            ),
          ),
        );

        return;
      }

      ref.read(authUserProvider.notifier).state =
          user;

      if (!mounted) {
        return;
      }

      context.go('/host');
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
            error
                .toString()
                .replaceFirst(
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

  String _errorMessage(
      DioException error,
      ) {
    final data = error.response?.data;

    if (data is Map) {
      final detail = data['detail'];

      if (detail != null &&
          detail.toString().isNotEmpty) {
        return detail.toString();
      }

      final message = data['message'];

      if (message != null &&
          message.toString().isNotEmpty) {
        return message.toString();
      }
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return 'Unable to connect to RentKaro server.';
    }

    if (error.response?.statusCode == 401) {
      return 'Invalid phone number or password.';
    }

    return 'Unable to login. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Host Login',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 34,
                      color: Colors.blue.shade700,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Welcome, Host',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Login to manage your rental vehicles',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType:
                    TextInputType.phone,
                    maxLength: 10,
                    decoration:
                    const InputDecoration(
                      labelText: 'Phone Number',
                      hintText:
                      'Enter your phone number',
                      prefixIcon:
                      Icon(Icons.phone_outlined),
                      border:
                      OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (value) {
                      final phone =
                          value?.trim() ?? '';

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

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                    _passwordController,
                    obscureText:
                    _obscurePassword,
                    decoration:
                    InputDecoration(
                      labelText: 'Password',
                      hintText:
                      'Enter your password',
                      prefixIcon:
                      const Icon(
                        Icons.lock_outline,
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
                      border:
                      const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      _isLoading
                          ? null
                          : _login,
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Host Login',
                        style:
                        TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    child: const Text(
                      'Back to User Login',
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