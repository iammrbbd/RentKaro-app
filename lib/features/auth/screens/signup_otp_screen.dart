import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class SignupOtpScreen extends StatefulWidget {
  const SignupOtpScreen({
    super.key,
    required this.email,
    required this.role,
  });

  final String email;
  final String role;

  @override
  State<SignupOtpScreen> createState() =>
      _SignupOtpScreenState();
}

class _SignupOtpScreenState
    extends State<SignupOtpScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _otpController =
  TextEditingController();

  final AuthService _authService =
  AuthService();

  Timer? _timer;

  bool _isLoading = false;
  bool _isResending = false;

  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // ==========================================================
  // TIMER
  // ==========================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            _remainingSeconds = 0;
          });

          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  // ==========================================================
  // VERIFY OTP
  // ==========================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading || _isResending) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user =
      await _authService.verifySignupOtp(
        email: widget.email,
        otp: _otpController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      final role =
      user.role.trim().toLowerCase();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );

      // ======================================================
      // HOST
      // ======================================================

      if (role == 'owner' ||
          role == 'host') {
        context.go('/host/kyc');
        return;
      }

      // ======================================================
      // CUSTOMER
      // ======================================================

      context.go('/home');
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
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
  // RESEND OTP
  // ==========================================================

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0 ||
        _isResending ||
        _isLoading) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final response =
      await _authService.resendSignupOtp(
        email: widget.email,
      );

      if (!mounted) {
        return;
      }

      _otpController.clear();

      _startTimer();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            response.message,
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        foregroundColor:
        const Color(0xFF111827),
        leading: IconButton(
          onPressed:
          _isLoading || _isResending
              ? null
              : () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
                  children: [
                    // ==================================================
                    // ICON
                    // ==================================================

                    Container(
                      width: 72,
                      height: 72,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFEFF6FF,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .mark_email_read_outlined,
                        size: 38,
                        color:
                        Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    const Text(
                      'Verify Your Email',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'We sent a 6-digit verification code to',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                        Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      widget.email,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Color(0xFF2563EB),
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // ==================================================
                    // OTP FIELD
                    // ==================================================

                    TextFormField(
                      controller:
                      _otpController,
                      keyboardType:
                      TextInputType.number,
                      textInputAction:
                      TextInputAction.done,
                      maxLength: 6,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        fontSize: 26,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing: 8,
                      ),
                      decoration:
                      InputDecoration(
                        labelText:
                        'Verification Code',
                        hintText:
                        '000000',
                        counterText: '',
                        prefixIcon:
                        const Icon(
                          Icons
                              .password_outlined,
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
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFFE5E7EB,
                            ),
                          ),
                        ),
                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            14,
                          ),
                          borderSide:
                          const BorderSide(
                            color:
                            Color(
                              0xFF2563EB,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final otp =
                            value?.trim() ??
                                '';

                        if (otp.isEmpty) {
                          return 'Enter the OTP';
                        }

                        if (!RegExp(
                          r'^[0-9]{6}$',
                        ).hasMatch(otp)) {
                          return 'OTP must be exactly 6 digits';
                        }

                        return null;
                      },
                      onFieldSubmitted:
                          (_) {
                        if (!_isLoading &&
                            !_isResending) {
                          _verifyOtp();
                        }
                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // VERIFY BUTTON
                    // ==================================================

                    SizedBox(
                      height: 54,
                      child:
                      ElevatedButton(
                        onPressed:
                        _isLoading ||
                            _isResending
                            ? null
                            : _verifyOtp,
                        style:
                        ElevatedButton
                            .styleFrom(
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
                            BorderRadius
                                .circular(
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
                            strokeWidth:
                            2.5,
                          ),
                        )
                            : const Text(
                          'Verify & Create Account',
                          style:
                          TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // RESEND OTP
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        const Text(
                          'Didn\'t receive the code?',
                          style:
                          TextStyle(
                            fontSize: 14,
                            color:
                            Color(
                              0xFF6B7280,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        TextButton(
                          onPressed:
                          _remainingSeconds >
                              0 ||
                              _isResending ||
                              _isLoading
                              ? null
                              : _resendOtp,
                          child:
                          _isResending
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                            ),
                          )
                              : Text(
                            _remainingSeconds >
                                0
                                ? 'Resend in ${_remainingSeconds}s'
                                : 'Resend OTP',
                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF2563EB,
                              ),
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // SECURITY MESSAGE
                    // ==================================================

                    Container(
                      padding:
                      const EdgeInsets.all(
                        14,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF0FDF4,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                        border:
                        Border.all(
                          color:
                          const Color(
                            0xFFDCFCE7,
                          ),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Icon(
                            Icons
                                .security_outlined,
                            size: 19,
                            color:
                            Color(
                              0xFF16A34A,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              'Your verification code is valid for 5 minutes. Never share your OTP with anyone.',
                              style:
                              TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color:
                                Color(
                                  0xFF166534,
                                ),
                              ),
                            ),
                          ),
                        ],
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