import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_dashboard_service.dart';


final adminDashboardServiceProvider =
Provider<AdminDashboardService>(
      (ref) {
    return AdminDashboardService();
  },
);


final adminDashboardStatsProvider =
FutureProvider.autoDispose<AdminDashboardStats>(
      (ref) async {
    final service =
    ref.read(
      adminDashboardServiceProvider,
    );

    return service.fetchStats();
  },
);