import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/host_earnings.dart';
import '../services/host_earnings_service.dart';

final hostEarningsServiceProvider =
Provider<HostEarningsService>((ref) {
  return HostEarningsService();
});

final hostEarningsProvider =
FutureProvider<HostEarnings>((ref) async {
  final service =
  ref.read(hostEarningsServiceProvider);

  return service.getEarnings();
});