import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';

class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  Future<void> _logout(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final authService =
      ref.read(authServiceProvider);

      await authService.logout();

      ref.read(
        authUserProvider.notifier,
      ).state = null;

      if (!context.mounted) {
        return;
      }

      context.go('/login');
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Host Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              context.push('/host/profile');
            },
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              _logout(
                context,
                ref,
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Manage your rentals',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage vehicles, bookings and earnings.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),

            // =================================================
            // HOST PROFILE
            // =================================================

            _DashboardCard(
              icon: Icons.account_circle_outlined,
              title: 'My Profile',
              subtitle:
              'View and manage your host profile',
              onTap: () {
                context.push('/host/profile');
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // HOST KYC
            // =================================================

            _DashboardCard(
              icon: Icons.verified_user_outlined,
              title: 'Host KYC',
              subtitle:
              'Complete and manage your host verification',
              onTap: () {
                context.push('/host/kyc');
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // MY VEHICLES
            // =================================================

            _DashboardCard(
              icon: Icons.directions_car_outlined,
              title: 'My Vehicles',
              subtitle:
              'View and manage your vehicles',
              onTap: () {
                context.push('/host/vehicles');
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // ADD VEHICLE
            // =================================================

            _DashboardCard(
              icon: Icons.add_circle_outline,
              title: 'Add Vehicle',
              subtitle:
              'List a new vehicle for rent',
              onTap: () {
                context.push('/host/vehicles/add');
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // BOOKINGS
            // =================================================

            _DashboardCard(
              icon: Icons.calendar_month_outlined,
              title: 'Bookings',
              subtitle:
              'Manage your vehicle bookings',
              onTap: () {
                context.push('/host/bookings');
              },
            ),

            const SizedBox(height: 12),

            // =================================================
            // EARNINGS
            // =================================================

            _DashboardCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Earnings',
              subtitle:
              'View your rental earnings',
              onTap: () {
                context.push('/host/earnings');
              },
            ),

            const SizedBox(height: 24),

            // =================================================
            // LOGOUT
            // =================================================

            OutlinedButton.icon(
              onPressed: () {
                _logout(
                  context,
                  ref,
                );
              },
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text(
                'Logout',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize:
                const Size.fromHeight(52),
                foregroundColor:
                const Color(0xFFDC2626),
                side: const BorderSide(
                  color: Color(0xFFDC2626),
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD CARD
// ============================================================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 27,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}