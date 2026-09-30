import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';

class EditAdminProfileScreen
    extends ConsumerStatefulWidget {
  const EditAdminProfileScreen({
    super.key,
  });

  @override
  ConsumerState<EditAdminProfileScreen>
  createState() =>
      _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState
    extends ConsumerState<
        EditAdminProfileScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    final user =
    ref.read(authUserProvider);

    if (user != null) {
      _nameController.text =
          user.name;

      _phoneController.text =
          user.phone;

      _emailController.text =
          user.email ?? '';

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
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

      final updatedUser =
      await authService.updateProfile(
        name:
        _nameController.text.trim(),
        phone:
        _phoneController.text.trim(),
        email:
        _emailController.text
            .trim()
            .isEmpty
            ? null
            : _emailController.text
            .trim(),
      );

      if (!mounted) return;

      ref.read(
        authUserProvider.notifier,
      ).state = updatedUser;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Admin profile updated successfully.',
          ),
        ),
      );

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

  String? _validateName(
      String? value,
      ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Name is required';
    }

    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  String? _validatePhone(
      String? value,
      ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Phone number is required';
    }

    if (!RegExp(
      r'^[0-9]{10}$',
    ).hasMatch(text)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  String? _validateEmail(
      String? value,
      ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(text)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user =
    ref.watch(authUserProvider);

    if (!_initialized &&
        user != null) {
      _nameController.text =
          user.name;
      _phoneController.text =
          user.phone;
      _emailController.text =
          user.email ?? '';
      _initialized = true;
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Edit Admin Profile',
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
              18,
              16,
              30,
            ),
            child: Column(
              children: [
                _Field(
                  controller:
                  _nameController,
                  label:
                  'Full Name',
                  hint:
                  'Enter your name',
                  icon:
                  Icons.person_outline,
                  validator:
                  _validateName,
                ),

                const SizedBox(
                  height: 16,
                ),

                _Field(
                  controller:
                  _phoneController,
                  label:
                  'Phone Number',
                  hint:
                  '10-digit phone number',
                  icon:
                  Icons.phone_outlined,
                  keyboardType:
                  TextInputType.phone,
                  maxLength: 10,
                  validator:
                  _validatePhone,
                ),

                const SizedBox(
                  height: 16,
                ),

                _Field(
                  controller:
                  _emailController,
                  label:
                  'Email',
                  hint:
                  'Enter your email',
                  icon:
                  Icons.email_outlined,
                  keyboardType:
                  TextInputType.emailAddress,
                  validator:
                  _validateEmail,
                ),

                const SizedBox(
                  height: 28,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                    _isLoading
                        ? null
                        : _saveProfile,
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
                        BorderRadius
                            .circular(
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
                      'Save Changes',
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
// FIELD
// ============================================================================

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLength,
    this.validator,
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
          controller: controller,
          keyboardType:
          keyboardType,
          maxLength:
          maxLength,
          validator:
          validator,
          decoration:
          InputDecoration(
            hintText: hint,
            prefixIcon:
            Icon(icon),
            filled: true,
            fillColor:
            Colors.white,
            counterText: '',
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