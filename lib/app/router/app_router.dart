import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/signup_role_screen.dart';
import '../../features/auth/screens/signup_otp_screen.dart';
import '../../features/auth/services/auth_service.dart';

import '../../features/favorites/screens/favorites_screen.dart';

import '../../features/home/screens/main_shell.dart';

import '../../features/kyc/screens/kyc_screen.dart';

import '../../features/profile/screens/personal_information_screen.dart';

import '../../features/host/auth/screens/host_login_screen.dart';
import '../../features/host/presentation/screens/host_dashboard_screen.dart';
import '../../features/host/bookings/screens/host_bookings_screen.dart';
import '../../features/host/earnings/screens/host_earnings_screen.dart';
import '../../features/host/kyc/screens/host_kyc_screen.dart';

// HOST PROFILE
import '../../features/host/profile/screens/host_profile_screen.dart';
import '../../features/host/profile/screens/edit_host_profile_screen.dart';
import '../../features/host/profile/screens/change_host_password_screen.dart';

import '../../features/owner/vehicles/screens/my_vehicles_screen.dart';
import '../../features/owner/vehicles/screens/add_vehicle_screen.dart';

import '../../features/admin/auth/screens/admin_login_screen.dart';
import '../../features/admin/dashboard/screens/admin_dashboard_screen.dart';
import '../../features/admin/kyc/screens/admin_kyc_screen.dart';
import '../../features/admin/vehicles/screens/admin_vehicles_screen.dart';
import '../../features/admin/bookings/screens/admin_bookings_screen.dart';

// ADMIN PROFILE / NOTIFICATIONS
import '../../features/admin/profile/screens/admin_notifications_screen.dart';

// ============================================================
// APP ROUTER
// ============================================================

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  // ==========================================================
  // REDIRECT
  // ==========================================================

  redirect: (context, state) async {
    final authService = AuthService();

    final isLoggedIn =
    await authService.isLoggedIn();

    final location =
        state.matchedLocation;

    // ========================================================
    // PUBLIC ROUTES
    // ========================================================

    final isPublicRoute =
        (kIsWeb && location == '/') ||
            location == '/login' ||
            location == '/register-role' ||
            location == '/register' ||
            location == '/register/verify-otp' ||
            location == '/admin/login' ||
            location == '/host/login';

    // ========================================================
    // NOT LOGGED IN
    // ========================================================

    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    // ========================================================
    // LOGGED-IN USER ON LOGIN / REGISTER
    // ========================================================

    if (isLoggedIn &&
        (location == '/login' ||
            location == '/register')) {
      try {
        final user =
        await authService.getCurrentUser();

        final role =
        user.role.toLowerCase();

        // ADMIN
        if (role == 'admin') {
          return '/admin';
        }

        // HOST / OWNER
        if (role == 'owner' ||
            role == 'host') {
          return '/host';
        }
      } catch (_) {
        // Continue to customer home.
      }

      return '/home';
    }

    // ========================================================
    // ADMIN LOGIN
    // ========================================================

    if (isLoggedIn &&
        location == '/admin/login') {
      try {
        final user =
        await authService.getCurrentUser();

        final role =
        user.role.toLowerCase();

        if (role == 'admin') {
          return '/admin';
        }
      } catch (_) {
        // Continue.
      }

      return '/home';
    }

    // ========================================================
    // HOST LOGIN
    // ========================================================

    if (isLoggedIn &&
        location == '/host/login') {
      try {
        final user =
        await authService.getCurrentUser();

        final role =
        user.role.toLowerCase();

        if (role == 'owner' ||
            role == 'host') {
          return '/host';
        }
      } catch (_) {
        // Continue.
      }

      return '/home';
    }

    return null;
  },

  // ==========================================================
  // ERROR BUILDER
  // ==========================================================

  errorBuilder: (context, state) {
    return _RouterErrorScreen(
      error: state.error,
      currentLocation: state.uri.path,
    );
  },

  // ==========================================================
  // ROUTES
  // ==========================================================

  routes: [
    // ========================================================
    // ROOT
    // ========================================================

    GoRoute(
      path: '/',
      builder: (context, state) {
        if (kIsWeb) {
          return const _WebLandingScreen();
        }

        return const _SplashRedirectScreen();
      },
    ),

    // ========================================================
    // CUSTOMER LOGIN
    // ========================================================

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    // ========================================================
    // REGISTER ROLE
    // ========================================================

    GoRoute(
      path: '/register-role',
      builder: (context, state) {
        return const SignupRoleScreen();
      },
    ),

    // ========================================================
    // REGISTER
    // ========================================================

    GoRoute(
      path: '/register',
      builder: (context, state) {
        final role =
            (state.extra as String?) ??
                'customer';

        return SignupScreen(
          role: role,
        );
      },
    ),

    // ========================================================
    // SIGNUP EMAIL OTP VERIFICATION
    // ========================================================

    GoRoute(
      path: '/register/verify-otp',
      builder: (context, state) {
        final data =
            state.extra as Map<String, dynamic>? ??
                <String, dynamic>{};

        final email =
            data['email']?.toString() ?? '';

        final role =
            data['role']?.toString() ??
                'customer';

        return SignupOtpScreen(
          email: email,
          role: role,
        );
      },
    ),

    // ========================================================
    // CUSTOMER HOME
    // ========================================================

    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const MainShell();
      },
    ),

    // ========================================================
    // FAVORITES
    // ========================================================

    GoRoute(
      path: '/favorites',
      builder: (context, state) {
        return const FavoritesScreen();
      },
    ),

    // ========================================================
    // CUSTOMER KYC
    // ========================================================

    GoRoute(
      path: '/kyc',
      builder: (context, state) {
        return const KycScreen();
      },
    ),

    // ========================================================
    // CUSTOMER PERSONAL INFORMATION
    // ========================================================

    GoRoute(
      path: '/profile/personal-information',
      builder: (context, state) {
        return const PersonalInformationScreen();
      },
    ),

    // ========================================================
    // HOST LOGIN
    // ========================================================

    GoRoute(
      path: '/host/login',
      builder: (context, state) {
        return const HostLoginScreen();
      },
    ),

    // ========================================================
    // HOST DASHBOARD
    // ========================================================

    GoRoute(
      path: '/host',
      builder: (context, state) {
        return const HostDashboardScreen();
      },
    ),

    // ========================================================
    // HOST PROFILE
    // ========================================================

    GoRoute(
      path: '/host/profile',
      builder: (context, state) {
        return const HostProfileScreen();
      },
    ),

    // ========================================================
    // HOST EDIT PROFILE
    // ========================================================

    GoRoute(
      path: '/host/edit-profile',
      builder: (context, state) {
        return const EditHostProfileScreen();
      },
    ),

    // ========================================================
    // HOST CHANGE PASSWORD
    // ========================================================

    GoRoute(
      path: '/host/change-password',
      builder: (context, state) {
        return const ChangeHostPasswordScreen();
      },
    ),

    // ========================================================
    // HOST KYC
    // ========================================================

    GoRoute(
      path: '/host/kyc',
      builder: (context, state) {
        return const HostKycScreen();
      },
    ),

    // ========================================================
    // HOST BOOKINGS
    // ========================================================

    GoRoute(
      path: '/host/bookings',
      builder: (context, state) {
        return const HostBookingsScreen();
      },
    ),

    // ========================================================
    // HOST EARNINGS
    // ========================================================

    GoRoute(
      path: '/host/earnings',
      builder: (context, state) {
        return const HostEarningsScreen();
      },
    ),

    // ========================================================
    // HOST VEHICLES
    // ========================================================

    GoRoute(
      path: '/host/vehicles',
      builder: (context, state) {
        return const MyVehiclesScreen();
      },
    ),

    // ========================================================
    // ADD VEHICLE
    // ========================================================

    GoRoute(
      path: '/host/vehicles/add',
      builder: (context, state) {
        return const AddVehicleScreen();
      },
    ),

    // ========================================================
    // EDIT VEHICLE
    // ========================================================

    GoRoute(
      path: '/host/vehicles/edit/:vehicleId',
      builder: (context, state) {
        final vehicleId =
        int.tryParse(
          state.pathParameters[
          'vehicleId'] ??
              '',
        );

        if (vehicleId == null) {
          return const _InvalidVehicleRouteScreen();
        }

        return AddVehicleScreen(
          vehicleId: vehicleId,
        );
      },
    ),

    // ========================================================
    // ADMIN LOGIN
    // ========================================================

    GoRoute(
      path: '/admin/login',
      builder: (context, state) {
        return const AdminLoginScreen();
      },
    ),

    // ========================================================
    // ADMIN DASHBOARD
    // ========================================================

    GoRoute(
      path: '/admin',
      builder: (context, state) {
        return const AdminDashboardScreen();
      },
    ),

    // ========================================================
    // ADMIN HOST KYC
    // ========================================================

    GoRoute(
      path: '/admin/host-kyc',
      builder: (context, state) {
        return const AdminKycScreen();
      },
    ),

    // ========================================================
    // ADMIN CUSTOMER KYC
    // ========================================================

    GoRoute(
      path: '/admin/kyc',
      builder: (context, state) {
        return const AdminKycScreen();
      },
    ),

    // ========================================================
    // ADMIN VEHICLES
    // ========================================================

    GoRoute(
      path: '/admin/vehicles',
      builder: (context, state) {
        return const AdminVehiclesScreen();
      },
    ),

    // ========================================================
    // ADMIN BOOKINGS
    // ========================================================

    GoRoute(
      path: '/admin/bookings',
      builder: (context, state) {
        return const AdminBookingsScreen();
      },
    ),

    // ========================================================
    // ADMIN NOTIFICATIONS
    // ========================================================

    GoRoute(
      path: '/admin/profile/notifications',
      builder: (context, state) {
        return const AdminNotificationsScreen();
      },
    ),
  ],
);


// ============================================================
// WEB LANDING PAGE
// ============================================================

class _WebLandingScreen extends StatelessWidget {
  const _WebLandingScreen();

  static final Uri _apkUri = Uri.parse(
    'https://github.com/iammrbbd/RentKaro-app/releases/download/v1.0.0/app-release.apk',
  );

  Future<void> _downloadApp() async {
    await launchUrl(
      _apkUri,
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              titleSpacing: isMobile ? 16 : 40,
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WebBrandMark(),
                  SizedBox(width: 10),
                  Text(
                    'RentKaro',
                    style: TextStyle(
                      color: Color(0xFF0B1F44),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                if (!isMobile)
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Login'),
                  ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: _downloadApp,
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 19,
                    ),
                    label: Text(
                      isMobile ? 'Download' : 'Download App',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _WebHeroSection(
                isMobile: isMobile,
                onDownload: _downloadApp,
                onLogin: () => context.go('/login'),
              ),
            ),
            SliverToBoxAdapter(
              child: _WebFeatureSection(isMobile: isMobile),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: 32,
                ),
                color: const Color(0xFF0B1F44),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1180,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 24,
                      runSpacing: 18,
                      children: [
                        const Text(
                          'RentKaro — your self-drive rental marketplace.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _downloadApp,
                          icon: const Icon(
                            Icons.android_rounded,
                          ),
                          label: const Text('Get Android App'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white54,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebBrandMark extends StatelessWidget {
  const _WebBrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1F44),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.directions_car_filled_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _WebHeroSection extends StatelessWidget {
  final bool isMobile;
  final Future<void> Function() onDownload;
  final VoidCallback onLogin;

  const _WebHeroSection({
    required this.isMobile,
    required this.onDownload,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEFF6FF),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 60,
              vertical: isMobile ? 58 : 90,
            ),
            child: isMobile
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroText(),
                const SizedBox(height: 44),
                const _HeroVisual(),
              ],
            )
                : Row(
              children: [
                Expanded(child: _heroText()),
                const SizedBox(width: 70),
                const Expanded(child: _HeroVisual()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'SMART SELF-DRIVE RENTALS',
            style: TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Rent a vehicle.\nDrive your way.',
          style: TextStyle(
            color: Color(0xFF0B1F44),
            fontSize: 52,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Discover cars and bikes, compare rental options, '
              'complete your booking, and manage your trips with RentKaro.',
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 17,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.android_rounded),
              label: const Text(
                'Download Android App',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: onLogin,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B1F44),
                side: const BorderSide(
                  color: Color(0xFFCBD5E1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Row(
          children: [
            Icon(
              Icons.verified_rounded,
              color: Color(0xFF16A34A),
              size: 18,
            ),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                'Download the official RentKaro Android app',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1F44),
            blurRadius: 35,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Color(0xFF16A34A),
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Ready to ride',
                    style: TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 230,
              height: 230,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF2563EB),
                  size: 125,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 28,
            bottom: 28,
            child: _HeroStat(
              icon: Icons.search_rounded,
              title: 'Discover',
              subtitle: 'Find nearby vehicles',
            ),
          ),
          const Positioned(
            right: 28,
            bottom: 28,
            child: _HeroStat(
              icon: Icons.calendar_month_rounded,
              title: 'Book',
              subtitle: 'Choose your trip',
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HeroStat({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9,
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

class _WebFeatureSection extends StatelessWidget {
  final bool isMobile;

  const _WebFeatureSection({
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    const features = [
      (
      Icons.directions_car_filled_rounded,
      'Cars & Bikes',
      'Browse vehicles available for self-drive rental.',
      ),
      (
      Icons.location_on_rounded,
      'Nearby Discovery',
      'Explore vehicles using location and map-based discovery.',
      ),
      (
      Icons.verified_user_rounded,
      'Secure Booking',
      'Complete KYC, booking and payment through one platform.',
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 55 : 75,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1180,
          ),
          child: Column(
            children: [
              const Text(
                'Everything you need for your next ride',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0B1F44),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Simple discovery, booking and rental management in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 38),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = isMobile
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 32) / 3;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: features.map((feature) {
                      return SizedBox(
                        width: cardWidth,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FF),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  feature.$1,
                                  color: const Color(0xFF2563EB),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                feature.$2,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                feature.$3,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SPLASH REDIRECT
// ============================================================

class _SplashRedirectScreen
    extends StatefulWidget {
  const _SplashRedirectScreen();

  @override
  State<_SplashRedirectScreen>
  createState() =>
      _SplashRedirectScreenState();
}

class _SplashRedirectScreenState
    extends State<_SplashRedirectScreen> {
  @override
  void initState() {
    super.initState();

    _redirect();
  }

  Future<void> _redirect() async {
    final authService =
    AuthService();

    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    try {
      final isLoggedIn =
      await authService.isLoggedIn();

      if (!mounted) {
        return;
      }

      if (!isLoggedIn) {
        context.go('/login');
        return;
      }

      final user =
      await authService.getCurrentUser();

      if (!mounted) {
        return;
      }

      final role =
      user.role.toLowerCase();

      if (role == 'admin') {
        context.go('/admin');
        return;
      }

      if (role == 'owner' ||
          role == 'host') {
        context.go('/host');
        return;
      }

      context.go('/home');
    } catch (_) {
      if (!mounted) {
        return;
      }

      context.go('/login');
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Scaffold(
      body: Center(
        child:
        CircularProgressIndicator(),
      ),
    );
  }
}

// ============================================================
// ROUTER ERROR SCREEN
// ============================================================

class _RouterErrorScreen
    extends StatelessWidget {
  final GoException? error;
  final String currentLocation;

  const _RouterErrorScreen({
    required this.error,
    required this.currentLocation,
  });

  String _getHomeRoute() {
    if (currentLocation
        .startsWith('/admin')) {
      return '/admin';
    }

    if (currentLocation
        .startsWith('/host')) {
      return '/host';
    }

    return '/home';
  }

  String _getHomeLabel() {
    if (currentLocation
        .startsWith('/admin')) {
      return 'Go to Admin Dashboard';
    }

    if (currentLocation
        .startsWith('/host')) {
      return 'Go to Host Dashboard';
    }

    return 'Go to Home';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Something went wrong',
        ),
      ),
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 56,
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Unable to open this page.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                error?.toString() ??
                    'Unknown router error.',
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () {
                  context.go(
                    _getHomeRoute(),
                  );
                },
                child: Text(
                  _getHomeLabel(),
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
// INVALID VEHICLE ROUTE
// ============================================================

class _InvalidVehicleRouteScreen
    extends StatelessWidget {
  const _InvalidVehicleRouteScreen();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vehicle',
        ),
      ),
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                size: 56,
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Invalid vehicle ID.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              ElevatedButton(
                onPressed: () {
                  context.go(
                    '/host/vehicles',
                  );
                },
                child: const Text(
                  'Back to My Vehicles',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}