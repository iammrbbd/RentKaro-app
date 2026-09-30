import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/host_booking.dart';
import '../services/host_booking_service.dart';


// ============================================================
// SERVICE PROVIDER
// ============================================================

final hostBookingServiceProvider =
Provider<HostBookingService>(
      (ref) {
    return HostBookingService();
  },
);


// ============================================================
// GET ALL HOST BOOKINGS
// ============================================================

final hostBookingsProvider =
FutureProvider<List<HostBooking>>(
      (ref) async {
    final service =
    ref.read(
      hostBookingServiceProvider,
    );

    return service.getBookings();
  },
);


// ============================================================
// GET PENDING HOST BOOKINGS
// ============================================================

final hostPendingBookingsProvider =
FutureProvider<List<HostBooking>>(
      (ref) async {
    final service =
    ref.read(
      hostBookingServiceProvider,
    );

    return service.getPendingBookings();
  },
);


// ============================================================
// HOST BOOKINGS NOTIFIER
// ============================================================

class HostBookingsNotifier
    extends StateNotifier<
        AsyncValue<List<HostBooking>>> {

  HostBookingsNotifier(
      this._service,
      ) : super(
    const AsyncValue.loading(),
  ) {
    loadBookings();
  }

  final HostBookingService _service;

  // ==========================================================
  // LOAD BOOKINGS
  // ==========================================================

  Future<void> loadBookings() async {
    state =
    const AsyncValue.loading();

    try {
      final bookings =
      await _service.getBookings();

      state =
          AsyncValue.data(bookings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error,
        stackTrace,
      );
    }
  }

  // ==========================================================
  // CONFIRM BOOKING
  // ==========================================================

  Future<void> confirmBooking(
      int bookingId,
      ) async {
    await _service.confirmBooking(
      bookingId,
    );

    await loadBookings();
  }

  // ==========================================================
  // REJECT BOOKING
  // ==========================================================

  Future<void> rejectBooking(
      int bookingId, {
        String? reason,
      }) async {
    await _service.rejectBooking(
      bookingId,
      reason: reason,
    );

    await loadBookings();
  }

  // ==========================================================
  // COMPLETE RENTAL
  // ==========================================================

  Future<void> completeBooking(
      int bookingId,
      ) async {
    await _service.completeBooking(
      bookingId,
    );

    await loadBookings();
  }
}


// ============================================================
// STATE NOTIFIER PROVIDER
// ============================================================

final hostBookingsNotifierProvider =
StateNotifierProvider<
    HostBookingsNotifier,
    AsyncValue<List<HostBooking>>>(
      (ref) {
    final service =
    ref.read(
      hostBookingServiceProvider,
    );

    return HostBookingsNotifier(
      service,
    );
  },
);