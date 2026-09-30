import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';

class ChangeAdminPasswordScreen
    extends ConsumerStatefulWidget {
  const ChangeAdminPasswordScreen({
    super.key,
  });

  @override
  ConsumerState<
      ChangeAdminPasswordScreen>
  createState() =>
      _ChangeAdminPasswordScreenState();
}

class _ChangeAdminPasswordScreenState
    extends ConsumerState<
        ChangeAdminPasswordScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _currentPasswordController =
  TextEditingController();

  final _newPasswordController =
  TextEditingController();

  final _confirmPasswordController =
  TextEditingController();

  bool _isLoading = false;

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentPasswordController
        .dispose();

    _newPasswordController
        .dispose();

    _confirmPasswordController
        .dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final authService =
      ref.read(authServiceProvider);

      await authService.changePassword(
        currentPassword:
        _currentPasswordController
            .text,
        newPassword:
        _newPasswordController
            .text,
        confirmPassword:
        _confirmPasswordController
            .text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password changed successfully.',
          ),
        ),
      );

      _currentPasswordController
          .clear();

      _newPasswordController.clear();

      _confirmPasswordController
          .clear();

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  String? _validateCurrent(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Current password is required';
    }

    return null;
  }

  String? _validateNew(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'New password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  String? _validateConfirm(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value !=
        _newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

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
          'Change Password',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              30,
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration:
                  const BoxDecoration(
                    color:
                    Color(0xFFEFF6FF),
                    shape:
                    BoxShape.circle,
                  ),
                  child:
                  const Icon(
                    Icons.lock_outline,
                    color:
                    Color(0xFF1565C0),
                    size: 34,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                const Text(
                  'Secure your admin account',
                  style:
                  TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    Color(0xFF111827),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                const Text(
                  'Use a strong password with at least 8 characters.',
                  textAlign:
                  TextAlign.center,
                  style:
                  TextStyle(
                    fontSize: 12,
                    color:
                    Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                _PasswordField(
                  controller:
                  _currentPasswordController,
                  label:
                  'Current Password',
                  hint:
                  'Enter current password',
                  obscure:
                  _hideCurrent,
                  onToggle: () {
                    setState(() {
                      _hideCurrent =
                      !_hideCurrent;
                    });
                  },
                  validator:
                  _validateCurrent,
                ),

                const SizedBox(
                  height: 16,
                ),

                _PasswordField(
                  controller:
                  _newPasswordController,
                  label:
                  'New Password',
                  hint:
                  'Enter new password',
                  obscure:
                  _hideNew,
                  onToggle: () {
                    setState(() {
                      _hideNew =
                      !_hideNew;
                    });
                  },
                  validator:
                  _validateNew,
                ),

                const SizedBox(
                  height: 16,
                ),

                _PasswordField(
                  controller:
                  _confirmPasswordController,
                  label:
                  'Confirm New Password',
                  hint:
                  'Re-enter new password',
                  obscure:
                  _hideConfirm,
                  onToggle: () {
                    setState(() {
                      _hideConfirm =
                      !_hideConfirm;
                    });
                  },
                  validator:
                  _validateConfirm,
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child:
                  ElevatedButton(
                    onPressed:
                    _isLoading
                        ? null
                        : _changePassword,
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF111827,
                      ),
                      foregroundColor:
                      Colors.white,
                      elevation: 0,
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
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2.5,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Text(
                      'Change Password',
                      style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PASSWORD FIELD
// ============================================================================

class _PasswordField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          const TextStyle(
            fontSize: 13,
            fontWeight:
            FontWeight.w700,
            color:
            Color(0xFF374151),
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        TextFormField(
          controller:
          controller,
          obscureText:
          obscure,
          validator:
          validator,
          decoration:
          InputDecoration(
            hintText: hint,
            prefixIcon:
            const Icon(
              Icons.lock_outline,
            ),
            suffixIcon:
            IconButton(
              onPressed:
              onToggle,
              icon: Icon(
                obscure
                    ? Icons
                    .visibility_off_outlined
                    : Icons
                    .visibility_outlined,
              ),
            ),
            filled: true,
            fillColor:
            Colors.white,
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              borderSide:
              const BorderSide(
                color:
                Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              borderSide:
              const BorderSide(
                color:
                Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
              borderSide:
              const BorderSide(
                color:
                Color(0xFF111827),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}