import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({
    super.key,
  });

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = ref.read(authUserProvider);

    if (currentUser != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      final user = await authService.getCurrentUser();

      if (!mounted) {
        return;
      }

      ref.read(authUserProvider.notifier).state = user;
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

  String _getRoleLabel(String role) {
    switch (role.toLowerCase().trim()) {
      case 'admin':
        return 'Admin';

      case 'owner':
      case 'host':
        return 'Host';

      case 'customer':
      default:
        return 'Customer';
    }
  }

  String _getVerificationStatus(bool isVerified) {
    return isVerified ? 'Verified' : 'Not Verified';
  }

  String _getAccountStatus(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : user == null
            ? _EmptyUserState(
          onRetry: _loadUser,
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            30,
          ),
          child: Column(
            children: [
              // ==================================================
              // PROFILE HEADER
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 76,
                      width: 76,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1E4FA3),
                            Color(0xFF3B73D1),
                          ],
                        ),
                      ),
                      child: Text(
                        user.name.trim().isNotEmpty
                            ? user.name
                            .trim()[0]
                            .toUpperCase()
                            : 'R',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      user.name.trim().isNotEmpty
                          ? user.name
                          : 'RentKaro User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRoleLabel(user.role),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // BASIC INFORMATION
              // ==================================================

              _SectionCard(
                title: 'Basic Information',
                children: [
                  _InformationRow(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    value: user.name.trim().isNotEmpty
                        ? user.name
                        : 'Not available',
                  ),

                  const Divider(height: 1),

                  _InformationRow(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: user.phone.trim().isNotEmpty
                        ? user.phone
                        : 'Not available',
                  ),

                  const Divider(height: 1),

                  _InformationRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email?.trim().isNotEmpty == true
                        ? user.email!
                        : 'Not added',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // ACCOUNT INFORMATION
              // ==================================================

              _SectionCard(
                title: 'Account Information',
                children: [
                  _InformationRow(
                    icon: Icons.badge_outlined,
                    title: 'Account Type',
                    value: _getRoleLabel(user.role),
                  ),

                  const Divider(height: 1),

                  _InformationRow(
                    icon: Icons.verified_user_outlined,
                    title: 'Verification',
                    value: _getVerificationStatus(
                      user.isVerified,
                    ),
                    valueColor: user.isVerified
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEA580C),
                  ),

                  const Divider(height: 1),

                  _InformationRow(
                    icon: Icons.account_circle_outlined,
                    title: 'Account Status',
                    value: _getAccountStatus(
                      user.isActive,
                    ),
                    valueColor: user.isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // INFORMATION NOTE
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDBEAFE),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Your account information is securely loaded from your RentKaro account.',
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 13,
                          height: 1.4,
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
    );
  }
}


// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              10,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }
}


// ============================================================
// INFORMATION ROW
// ============================================================

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InformationRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ??
                        const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// EMPTY USER STATE
// ============================================================

class _EmptyUserState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyUserState({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}