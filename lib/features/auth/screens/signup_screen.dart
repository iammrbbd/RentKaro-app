import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    this.role = 'customer',
  });

  final String role;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SIGNUP
  // ==========================================================

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    final email = _emailController.text.trim();

    // --------------------------------------------------------
    // EMAIL IS REQUIRED
    // --------------------------------------------------------

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email is required because account verification is done through OTP.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedRole = widget.role.trim().toLowerCase();

      final role = selectedRole == 'owner'
          ? 'owner'
          : 'customer';

      // ------------------------------------------------------
      // START SIGNUP
      //
      // Backend does NOT create the user here.
      //
      // It creates a pending OTP signup session and sends
      // the verification code to the email address.
      // ------------------------------------------------------

      final response = await _authService.signup(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: email,
        password: _passwordController.text,
        role: role,
      );

      if (!mounted) {
        return;
      }

      // ------------------------------------------------------
      // OTP SCREEN
      // ------------------------------------------------------

      context.go(
        '/register/verify-otp',
        extra: {
          'email': response.email.isNotEmpty
              ? response.email
              : email,
          'role': role,
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
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
  // INPUT DECORATION
  // ==========================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isOwner =
        widget.role.toLowerCase() == 'owner';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              24,
              32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 52,
                      color: Color(0xFF2563EB),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      isOwner
                          ? 'Create Host Account'
                          : 'Create Account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isOwner
                          ? 'Create your RentKaro host account'
                          : 'Create your RentKaro account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // ROLE INFORMATION
                    // ==================================================

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius:
                        BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFDBEAFE),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isOwner
                                  ? 'You are signing up as a Host.'
                                  : 'You are signing up as a Customer.',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // NAME
                    // ==================================================

                    TextFormField(
                      controller: _nameController,
                      textCapitalization:
                      TextCapitalization.words,
                      keyboardType:
                      TextInputType.name,
                      textInputAction:
                      TextInputAction.next,
                      decoration:
                      _inputDecoration(
                        label: 'Full Name',
                        hint:
                        'Enter your full name',
                        icon:
                        Icons.person_outline,
                      ),
                      validator: (value) {
                        final name =
                            value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Name is required';
                        }

                        if (name.length < 2) {
                          return 'Enter a valid name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PHONE
                    // ==================================================

                    TextFormField(
                      controller:
                      _phoneController,
                      keyboardType:
                      TextInputType.phone,
                      textInputAction:
                      TextInputAction.next,
                      maxLength: 10,
                      decoration:
                      _inputDecoration(
                        label: 'Phone Number',
                        hint:
                        'Enter your 10-digit phone number',
                        icon:
                        Icons.phone_outlined,
                      ).copyWith(
                        counterText: '',
                      ),
                      validator: (value) {
                        final phone =
                            value?.trim() ?? '';

                        if (phone.isEmpty) {
                          return 'Phone number is required';
                        }

                        if (!RegExp(
                          r'^[0-9]{10}$',
                        ).hasMatch(phone)) {
                          return
                            'Enter a valid 10-digit phone number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    TextFormField(
                      controller:
                      _emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                      decoration:
                      _inputDecoration(
                        label: 'Email',
                        hint:
                        'Enter your email',
                        icon:
                        Icons.email_outlined,
                      ),
                      validator: (value) {
                        final email =
                            value?.trim() ?? '';

                        if (email.isEmpty) {
                          return
                            'Email is required for OTP verification';
                        }

                        final emailRegex =
                        RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex
                            .hasMatch(email)) {
                          return
                            'Enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // OTP INFORMATION
                    // ==================================================

                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A verification OTP will be sent to this email address.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                      _passwordController,
                      obscureText:
                      _obscurePassword,
                      textInputAction:
                      TextInputAction.next,
                      decoration:
                      _inputDecoration(
                        label: 'Password',
                        hint:
                        'Enter your password',
                        icon:
                        Icons.lock_outline,
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
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return
                            'Password is required';
                        }

                        if (value.length < 6) {
                          return
                            'Minimum 6 characters required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // CONFIRM PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                      _confirmPasswordController,
                      obscureText:
                      _obscureConfirmPassword,
                      textInputAction:
                      TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _signup();
                        }
                      },
                      decoration:
                      _inputDecoration(
                        label:
                        'Confirm Password',
                        hint:
                        'Re-enter your password',
                        icon:
                        Icons.lock_reset_outlined,
                        suffixIcon:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                .visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return
                            'Please confirm your password';
                        }

                        if (value !=
                            _passwordController.text) {
                          return
                            'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // SIGNUP BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _signup,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF2563EB,
                          ),
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          disabledBackgroundColor:
                          const Color(
                            0xFF93C5FD,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                          CircularProgressIndicator(
                            color:
                            Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          isOwner
                              ? 'Create Host Account'
                              : 'Create Account',
                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // LOGIN
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            color:
                            Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            context.go(
                              '/login',
                            );
                          },
                          child: const Text(
                            'Login',
                            style:
                            TextStyle(
                              color:
                              Color(0xFF2563EB),
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // TERMS
                    // ==================================================

                    const Text(
                      'By creating an account, you agree to '
                          'RentKaro Terms of Service and Privacy Policy.',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        Color(0xFF9CA3AF),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}