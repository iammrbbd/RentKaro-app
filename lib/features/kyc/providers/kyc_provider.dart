import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kyc_model.dart';
import '../services/kyc_service.dart';

// ============================================================
// KYC SERVICE PROVIDER
// ============================================================

final kycServiceProvider =
Provider<KycService>(
      (ref) {
    return KycService();
  },
);

// ============================================================
// MY KYC PROVIDER
// ============================================================

final myKycProvider =
FutureProvider.autoDispose<KycModel?>(
      (ref) async {
    final service =
    ref.read(
      kycServiceProvider,
    );

    return service.getMyKyc();
  },
);