import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/payment_service.dart';

final paymentServiceProvider =
Provider<PaymentService>((ref) {
  return PaymentService();
});

final paymentLoadingProvider =
StateProvider<bool>((ref) {
  return false;
});

final paymentErrorProvider =
StateProvider<String?>((ref) {
  return null;
});