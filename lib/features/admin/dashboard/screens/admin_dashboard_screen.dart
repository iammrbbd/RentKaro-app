import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../providers/admin_dashboard_provider.dart';

// ============================================================
// ADMIN EARNINGS PROVIDER
// ============================================================

final adminTotalEarningsProvider =
FutureProvider.autoDispose<double>((ref) async {
  const storage = FlutterSecureStorage();

  final token = await storage.read(
    key: 'access_token',
  );

  if (token == null || token.trim().isEmpty) {
    throw Exception(
      'Authentication token not found. Please login again.',
    );
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://rentkaro.up.railway.app',
      connectTimeout:
      const Duration(seconds: 10),
      receiveTimeout:
      const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  try {
    final response = await dio.get(
      '/api/admin/bookings',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.data is! Map) {
      throw Exception(
        'Invalid bookings response from server.',
      );
    }

    final responseData =
    Map<String, dynamic>.from(
      response.data as Map,
    );

    final rawBookings =
    responseData['bookings'];

    if (rawBookings is! List) {
      return 0.0;
    }

    double totalEarnings = 0.0;

    for (final rawBooking in rawBookings) {
      if (rawBooking is! Map) {
        continue;
      }

      final booking =
      Map<String, dynamic>.from(
        rawBooking,
      );

      final status =
          booking['status']
              ?.toString()
              .trim()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // Only completed bookings count as actual earnings.
      // --------------------------------------------------------

      if (status != 'completed') {
        continue;
      }

      final platformFee =
      _toDouble(
        booking['platform_fee'],
      );

      totalEarnings += platformFee;
    }

    return double.parse(
      totalEarnings.toStringAsFixed(2),
    );
  } on DioException catch (error) {
    final data = error.response?.data;

    if (data is Map &&
        data['detail'] != null) {
      throw Exception(
        data['detail'].toString(),
      );
    }

    if (error.response?.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    throw Exception(
      'Unable to load total earnings.',
    );
  }
});

// ============================================================
// SAFE DOUBLE PARSER
// ============================================================

double _toDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value.toString(),
  ) ??
      0.0;
}

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboardScreen
    extends ConsumerWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final user =
    ref.watch(authUserProvider);

    final adminName =
    user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'Administrator';

    final statsAsync = ref.watch(
      adminDashboardStatsProvider,
    );

    final earningsAsync = ref.watch(
      adminTotalEarningsProvider,
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FB),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
        const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.white,

        title: const Text(
          'RentKaro Admin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(
                adminDashboardStatsProvider,
              );

              ref.invalidate(
                adminTotalEarningsProvider,
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),

          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              context.push(
                '/admin/profile',
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ==========================================================
      // DRAWER
      // ==========================================================

      drawer: _buildDrawer(
        context,
        ref,
        adminName,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.refresh(
                adminDashboardStatsProvider
                    .future,
              ),
              ref.refresh(
                adminTotalEarningsProvider
                    .future,
              ),
            ]);
          },

          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            padding:
            const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              30,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TITLE
                // ==================================================

                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 26,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Welcome back, $adminName',
                  style: const TextStyle(
                    color:
                    Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // OVERVIEW
                // ==================================================

                const Text(
                  'Overview',
                  style: TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // USERS + VEHICLES
                // ==================================================

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon:
                        Icons.people_outline,
                        title: 'Users',
                        value:
                        statsAsync.when(
                          data: (stats) =>
                              stats.users
                                  .toString(),
                          loading: () => '...',
                          error: (_, __) =>
                          '--',
                        ),
                        subtitle:
                        'Registered users',
                        onTap: () {
                          context.push(
                            '/admin/users',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCard(
                        icon: Icons
                            .directions_car_outlined,
                        title: 'Vehicles',
                        value:
                        statsAsync.when(
                          data: (stats) =>
                              stats.vehicles
                                  .toString(),
                          loading: () => '...',
                          error: (_, __) =>
                          '--',
                        ),
                        subtitle:
                        'Total vehicles',
                        onTap: () {
                          context.push(
                            '/admin/vehicles',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // KYC + BOOKINGS
                // ==================================================

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons
                            .verified_user_outlined,
                        title: 'Host KYC',
                        value:
                        statsAsync.when(
                          data: (stats) =>
                              stats.pendingHostKyc
                                  .toString(),
                          loading: () => '...',
                          error: (_, __) =>
                          '--',
                        ),
                        subtitle:
                        'Pending applications',
                        onTap: () {
                          context.push(
                            '/admin/host-kyc',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCard(
                        icon: Icons
                            .book_online_outlined,
                        title: 'Bookings',
                        value:
                        statsAsync.when(
                          data: (stats) =>
                              stats.bookings
                                  .toString(),
                          loading: () => '...',
                          error: (_, __) =>
                          '--',
                        ),
                        subtitle:
                        'Total bookings',
                        onTap: () {
                          context.push(
                            '/admin/bookings',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TOTAL EARNINGS
                // ==================================================

                _EarningsCard(
                  value: earningsAsync.when(
                    data: (amount) =>
                        _formatCurrency(
                          amount,
                        ),
                    loading: () => '...',
                    error: (_, __) => '--',
                  ),
                  onTap: () {
                    context.push(
                      '/admin/bookings',
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // MANAGEMENT
                // ==================================================

                const Text(
                  'Management',
                  style: TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                // HOST KYC

                _ManagementCard(
                  icon: Icons
                      .verified_user_outlined,
                  title:
                  'Host KYC Verification',
                  subtitle:
                  'Review and approve host KYC applications',
                  iconBackground:
                  const Color(0xFFEFF6FF),
                  iconColor:
                  const Color(0xFF2563EB),
                  onTap: () {
                    context.push(
                      '/admin/host-kyc',
                    );
                  },
                ),

                const SizedBox(height: 12),

                // VEHICLES

                _ManagementCard(
                  icon: Icons
                      .directions_car_outlined,
                  title:
                  'Vehicle Approvals',
                  subtitle:
                  'Review vehicles submitted by hosts',
                  iconBackground:
                  const Color(0xFFF0FDF4),
                  iconColor:
                  const Color(0xFF16A34A),
                  onTap: () {
                    context.push(
                      '/admin/vehicles',
                    );
                  },
                ),

                const SizedBox(height: 12),

                // USERS

                _ManagementCard(
                  icon:
                  Icons.people_outline,
                  title: 'Users',
                  subtitle:
                  'View and manage RentKaro users',
                  iconBackground:
                  const Color(0xFFF3F4F6),
                  iconColor:
                  const Color(0xFF374151),
                  onTap: () {
                    context.push(
                      '/admin/users',
                    );
                  },
                ),

                const SizedBox(height: 12),

                // BOOKINGS

                _ManagementCard(
                  icon: Icons
                      .book_online_outlined,
                  title: 'Bookings',
                  subtitle:
                  'Monitor customer bookings',
                  iconBackground:
                  const Color(0xFFFFF7ED),
                  iconColor:
                  const Color(0xFFEA580C),
                  onTap: () {
                    context.push(
                      '/admin/bookings',
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // ADMIN ACCOUNT
                // ==================================================

                const Text(
                  'Admin Account',
                  style: TextStyle(
                    color:
                    Color(0xFF111827),
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                _ManagementCard(
                  icon:
                  Icons.person_outline,
                  title:
                  'Admin Profile',
                  subtitle:
                  'View and update administrator information',
                  iconBackground:
                  const Color(0xFFF3F4F6),
                  iconColor:
                  const Color(0xFF111827),
                  onTap: () {
                    context.push(
                      '/admin/profile',
                    );
                  },
                ),

                const SizedBox(height: 12),

                _ManagementCard(
                  icon:
                  Icons.lock_outline,
                  title:
                  'Change Password',
                  subtitle:
                  'Update your administrator password',
                  iconBackground:
                  const Color(0xFFEFF6FF),
                  iconColor:
                  const Color(0xFF2563EB),
                  onTap: () {
                    context.push(
                      '/admin/profile/change-password',
                    );
                  },
                ),

                const SizedBox(height: 12),

                _ManagementCard(
                  icon: Icons
                      .notifications_none_outlined,
                  title:
                  'Notifications',
                  subtitle:
                  'Manage administrator notifications',
                  iconBackground:
                  const Color(0xFFFFF7ED),
                  iconColor:
                  const Color(0xFFEA580C),
                  onTap: () {
                    context.push(
                      '/admin/profile/notifications',
                    );
                  },
                ),

                const SizedBox(height: 12),

                _ManagementCard(
                  icon:
                  Icons.history_rounded,
                  title:
                  'Activity Logs',
                  subtitle:
                  'View administrator activity history',
                  iconBackground:
                  const Color(0xFFF3F4F6),
                  iconColor:
                  const Color(0xFF374151),
                  onTap: () {
                    context.push(
                      '/admin/profile/activity-logs',
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SYSTEM STATUS
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(16),
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color: const Color(
                        0xFFE5E7EB,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor:
                        Color(0xFFECFDF5),
                        child: Icon(
                          Icons
                              .check_circle_outline,
                          color:
                          Color(0xFF16A34A),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              'System Status',
                              style:
                              TextStyle(
                                color:
                                Color(0xFF111827),
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'RentKaro services are operational',
                              style:
                              TextStyle(
                                color:
                                Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Online',
                        style: TextStyle(
                          color:
                          Color(0xFF16A34A),
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w700,
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
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawer(
      BuildContext context,
      WidgetRef ref,
      String adminName,
      ) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                22,
              ),
              color:
              const Color(0xFF111827),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment:
                    Alignment.center,
                    decoration:
                    const BoxDecoration(
                      color: Colors.white,
                      shape:
                      BoxShape.circle,
                    ),
                    child: Text(
                      _initial(adminName),
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF111827),
                        fontSize: 24,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    adminName,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    'Administrator',
                    style: TextStyle(
                      color:
                      Color(0xFFD1D5DB),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _DrawerItem(
              icon:
              Icons.dashboard_outlined,
              title: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _DrawerItem(
              icon: Icons
                  .verified_user_outlined,
              title: 'Host KYC',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/host-kyc',
                );
              },
            ),

            _DrawerItem(
              icon: Icons
                  .directions_car_outlined,
              title:
              'Vehicle Approvals',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/vehicles',
                );
              },
            ),

            _DrawerItem(
              icon:
              Icons.people_outline,
              title: 'Users',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/users',
                );
              },
            ),

            _DrawerItem(
              icon: Icons
                  .book_online_outlined,
              title: 'Bookings',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/bookings',
                );
              },
            ),

            _DrawerItem(
              icon:
              Icons.payments_outlined,
              title: 'Payments',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/bookings',
                );
              },
            ),

            const Divider(
              height: 28,
              indent: 18,
              endIndent: 18,
            ),

            _DrawerItem(
              icon:
              Icons.person_outline,
              title: 'Admin Profile',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/profile',
                );
              },
            ),

            _DrawerItem(
              icon:
              Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/profile/change-password',
                );
              },
            ),

            _DrawerItem(
              icon: Icons
                  .notifications_none_outlined,
              title: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/profile/notifications',
                );
              },
            ),

            _DrawerItem(
              icon:
              Icons.history_rounded,
              title: 'Activity Logs',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/admin/profile/activity-logs',
                );
              },
            ),

            const Spacer(),

            _DrawerItem(
              icon:
              Icons.logout_rounded,
              title: 'Logout',
              danger: true,
              onTap: () async {
                Navigator.pop(context);
                await _logout(
                  context,
                  ref,
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final shouldLogout =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
          const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color:
                  Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      final authService =
      ref.read(
        authServiceProvider,
      );

      await authService.logout();

      ref
          .read(
        authUserProvider
            .notifier,
      )
          .state = null;

      if (!context.mounted) {
        return;
      }

      context.go(
        '/admin/login',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _initial(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return 'A';
    }

    return value[0].toUpperCase();
  }

  static String _formatCurrency(
      double amount,
      ) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    }

    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }
}

// ============================================================================
// DRAWER ITEM
// ============================================================================

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final color = danger
        ? const Color(0xFFDC2626)
        : const Color(0xFF374151);

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: color,
              ),
              const SizedBox(
                width: 13,
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
              if (!danger)
                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 13,
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

// ============================================================================
// STAT CARD
// ============================================================================

class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints:
          const BoxConstraints(
            minHeight: 140,
          ),
          padding:
          const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor:
                const Color(
                  0xFFF3F4F6,
                ),
                child: Icon(
                  icon,
                  color:
                  const Color(
                    0xFF111827,
                  ),
                  size: 21,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Color(0xFF6B7280),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style:
                const TextStyle(
                  color:
                  Color(0xFF111827),
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              Text(
                subtitle,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  color:
                  Color(0xFF9CA3AF),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EARNINGS CARD
// ============================================================================

class _EarningsCard
    extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _EarningsCard({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment:
                Alignment.center,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFECFDF5,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color:
                  Color(0xFF16A34A),
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Earnings',
                      style:
                      TextStyle(
                        color:
                        Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      value,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF111827),
                        fontSize: 22,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Platform fees from completed bookings',
                      style:
                      TextStyle(
                        color:
                        Color(0xFF9CA3AF),
                        fontSize: 9,
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

// ============================================================================
// MANAGEMENT CARD
// ============================================================================

class _ManagementCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(18),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment:
                Alignment.center,
                decoration:
                BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF111827),
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF6B7280),
                        fontSize: 11,
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