import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/host_kyc.dart';
import '../services/host_kyc_service.dart';

// ==========================================================
// HOST KYC SERVICE PROVIDER
// ==========================================================

final hostKycServiceProvider = Provider<HostKycService>((ref) {
  return HostKycService();
});

// ==========================================================
// HOST KYC LOADING PROVIDER
// ==========================================================
//
// Used for submit/resubmit operations if required later.
//

final hostKycLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

// ==========================================================
// MY HOST KYC
// ==========================================================
//
// Loads the currently logged-in host's KYC.
//
// Possible states:
//
// loading
// error
// data(null)       -> KYC not submitted yet
// data(HostKyc)    -> KYC exists
//
// The provider can be refreshed using:
//
// ref.invalidate(myHostKycProvider);
//
// ==========================================================

final myHostKycProvider = FutureProvider<HostKyc?>((ref) async {
  final service = ref.read(hostKycServiceProvider);

  return service.getMyKyc();
});