import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import 'change_admin_password_screen.dart';
import 'edit_admin_profile_screen.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState
    extends ConsumerState<AdminProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = ref.read(authUserProvider);

    if (user != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService =
      ref.read(authServiceProvider);

      final currentUser =
      await authService.getCurrentUser();

      if (!mounted) return;

      ref.read(authUserProvider.notifier).state =
          currentUser;
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst(
          'Exception: ',
          '',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _initial(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return 'A';
    }

    return value[0].toUpperCase();
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const EditAdminProfileScreen(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openChangePassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const ChangeAdminPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF8FAFC),
        elevation: 0,
        foregroundColor:
        const Color(0xFF111827),
        title: const Text(
          'Admin Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : user == null
          ? _EmptyProfile(
        onRetry: _loadUser,
      )
          : SafeArea(
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
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  22,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color:
                      Color(0x12000000),
                      blurRadius: 18,
                      offset:
                      Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 39,
                      backgroundColor:
                      const Color(
                        0xFF111827,
                      ),
                      child: Text(
                        _initial(
                          user.name,
                        ),
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize: 30,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      user.name,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
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
                      child:
                      const Text(
                        'ADMIN',
                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF1565C0,
                          ),
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title:
                'Account Information',
                children: [
                  _InfoTile(
                    icon:
                    Icons.person_outline,
                    title:
                    'Full Name',
                    value:
                    user.name,
                  ),
                  _InfoTile(
                    icon:
                    Icons.phone_outlined,
                    title:
                    'Phone',
                    value:
                    user.phone,
                  ),
                  _InfoTile(
                    icon:
                    Icons.email_outlined,
                    title:
                    'Email',
                    value:
                    user.email
                        ?.isNotEmpty ==
                        true
                        ? user.email!
                        : 'Not provided',
                  ),
                  _InfoTile(
                    icon: Icons
                        .admin_panel_settings_outlined,
                    title: 'Role',
                    value:
                    'Administrator',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _ActionTile(
                icon:
                Icons.edit_outlined,
                title:
                'Edit Profile',
                subtitle:
                'Update your name, phone and email',
                onTap:
                _openEditProfile,
              ),

              const SizedBox(height: 10),

              _ActionTile(
                icon:
                Icons.lock_outline,
                title:
                'Change Password',
                subtitle:
                'Update your account password',
                onTap:
                _openChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyProfile({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 55,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load admin profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF6B7280),
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
                    color:
                    Color(0xFF9CA3AF),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment:
                Alignment.center,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFF3F4F6),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  const Color(0xFF111827),
                  size: 21,
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
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style:
                      const TextStyle(
                        fontSize: 11,
                        color:
                        Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 15,
                color:
                Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}