import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/booking_service.dart';

// ==========================================================
// BOOKING SERVICE
// ==========================================================

final bookingServiceProvider =
Provider<BookingService>((ref) {
  return BookingService();
});

// ==========================================================
// BOOKING LOADING
// ==========================================================

final bookingLoadingProvider =
StateProvider<bool>((ref) {
  return false;
});

// ==========================================================
// MY BOOKINGS
// ==========================================================

final myBookingsProvider =
FutureProvider<List<Map<String, dynamic>>>(
      (ref) async {
    final bookingService =
    ref.read(
      bookingServiceProvider,
    );

    return bookingService.getMyBookings();
  },
);

// ==========================================================
// SINGLE BOOKING DETAILS
// ==========================================================

final bookingDetailsProvider =
FutureProvider.family<
    Map<String, dynamic>,
    int
>(
      (ref, bookingId) async {
    final bookingService =
    ref.read(
      bookingServiceProvider,
    );

    return bookingService.getBooking(
      bookingId,
    );
  },
);