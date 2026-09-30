import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/providers/booking_provider.dart';
import 'booking_details_screen.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({
    super.key,
  });

  @override
  ConsumerState<BookingsScreen> createState() =>
      _BookingsScreenState();
}

class _BookingsScreenState
    extends ConsumerState<BookingsScreen> {
  String selectedFilter = 'All';

  final List<String> filters = const [
    'All',
    'Upcoming',
    'Completed',
    'Cancelled',
  ];

  // ==========================================================
  // REFRESH BOOKINGS
  // ==========================================================

  Future<void> _refreshBookings() async {
    ref.invalidate(myBookingsProvider);

    await ref.read(
      myBookingsProvider.future,
    );
  }

  // ==========================================================
  // CANCEL BOOKING
  // ==========================================================

  Future<void> _cancelBooking(
      int bookingId,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Booking',
          ),
          content: const Text(
            'Are you sure you want to cancel this booking?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(
        bookingServiceProvider,
      )
          .cancelBooking(
        bookingId,
      );

      if (!mounted) {
        return;
      }

      ref.invalidate(
        myBookingsProvider,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking cancelled successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to cancel booking: $error',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DATE
  // ==========================================================

  String _formatDate(
      DateTime dateTime,
      ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${dateTime.day} '
        '${months[dateTime.month - 1]} '
        '${dateTime.year}';
  }

  // ==========================================================
  // TIME
  // ==========================================================

  String _formatTime(
      DateTime dateTime,
      ) {
    final hour =
    dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour == 0
        ? 12
        : dateTime.hour;

    final minute = dateTime.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    final period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<Map<String, dynamic>> _filterBookings(
      List<Map<String, dynamic>> bookings,
      ) {
    if (selectedFilter == 'All') {
      return bookings;
    }

    return bookings.where(
          (booking) {
        final status =
            booking['status']
                ?.toString()
                .toLowerCase() ??
                '';

        if (selectedFilter ==
            'Upcoming') {
          return status == 'pending' ||
              status == 'confirmed';
        }

        if (selectedFilter ==
            'Completed') {
          return status == 'completed';
        }

        if (selectedFilter ==
            'Cancelled') {
          return status == 'cancelled' ||
              status == 'canceled';
        }

        return true;
      },
    ).toList();
  }

  // ==========================================================
  // OPEN BOOKING DETAILS
  // ==========================================================

  Future<void> _openBookingDetails(
      Map<String, dynamic> booking,
      ) async {
    final rawId =
    booking['id'];

    final bookingId =
    rawId is int
        ? rawId
        : int.tryParse(
      rawId?.toString() ?? '',
    );

    if (bookingId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid booking ID.',
          ),
        ),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BookingDetailsScreen(
              bookingId: bookingId,
            ),
      ),
    );

    if (!mounted) {
      return;
    }

    ref.invalidate(
      myBookingsProvider,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final bookingsAsync =
    ref.watch(
      myBookingsProvider,
    );

    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF8FAFC,
      ),

      appBar: AppBar(
        backgroundColor:
        const Color(
          0xFFF8FAFC,
        ),

        elevation: 0,

        surfaceTintColor:
        Colors.transparent,

        title: const Text(
          'My Bookings',

          style: TextStyle(
            color:
            Color(
              0xFF111827,
            ),

            fontSize: 24,

            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
            _refreshBookings,

            icon: const Icon(
              Icons.refresh_rounded,

              color:
              Color(
                0xFF111827,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ==================================================
          // FILTERS
          // ==================================================

          SizedBox(
            height: 55,

            child:
            ListView.separated(
              scrollDirection:
              Axis.horizontal,

              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              itemCount:
              filters.length,

              separatorBuilder:
                  (_, __) =>
              const SizedBox(
                width: 10,
              ),

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final filter =
                filters[index];

                final selected =
                    selectedFilter ==
                        filter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter =
                          filter;
                    });
                  },

                  child:
                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds: 200,
                    ),

                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),

                    decoration:
                    BoxDecoration(
                      color: selected
                          ? const Color(
                        0xFF111827,
                      )
                          : Colors.white,

                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),

                      border:
                      Border.all(
                        color: selected
                            ? const Color(
                          0xFF111827,
                        )
                            : const Color(
                          0xFFE5E7EB,
                        ),
                      ),
                    ),

                    child: Text(
                      filter,

                      style:
                      TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(
                          0xFF374151,
                        ),

                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ==================================================
          // BOOKINGS
          // ==================================================

          Expanded(
            child:
            bookingsAsync.when(
              loading: () {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              },

              error: (
                  error,
                  stack,
                  ) {
                return _buildErrorState(
                  error,
                );
              },

              data: (
                  bookings,
                  ) {
                final filteredBookings =
                _filterBookings(
                  bookings,
                );

                if (filteredBookings
                    .isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh:
                  _refreshBookings,

                  child:
                  ListView.builder(
                    padding:
                    const EdgeInsets
                        .all(
                      16,
                    ),

                    itemCount:
                    filteredBookings
                        .length,

                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      final booking =
                      filteredBookings[
                      index];

                      return _BookingCard(
                        booking:
                        booking,

                        formatDate:
                        _formatDate,

                        formatTime:
                        _formatTime,

                        onCancel:
                        _cancelBooking,

                        onTap:
                            () =>
                            _openBookingDetails(
                              booking,
                            ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh:
      _refreshBookings,

      child: ListView(
        children: [
          SizedBox(
            height:
            MediaQuery.of(
              context,
            ).size.height *
                0.25,
          ),

          const Icon(
            Icons
                .calendar_month_outlined,

            size: 85,

            color:
            Color(
              0xFF9CA3AF,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'No bookings found',

            textAlign:
            TextAlign.center,

            style:
            TextStyle(
              fontSize: 21,

              fontWeight:
              FontWeight.bold,

              color:
              Color(
                0xFF111827,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 40,
            ),

            child: Text(
              'Your vehicle bookings will appear here.',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                color:
                Color(
                  0xFF6B7280,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState(
      Object error,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,

              size: 70,

              color:
              Colors.redAccent,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Unable to load bookings',

              style:
              TextStyle(
                fontSize: 20,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              error.toString(),

              textAlign:
              TextAlign.center,

              maxLines: 3,

              overflow:
              TextOverflow.ellipsis,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed:
              _refreshBookings,

              child:
              const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOOKING CARD
// ============================================================

class _BookingCard
    extends StatelessWidget {
  final Map<String, dynamic> booking;

  final String Function(DateTime)
  formatDate;

  final String Function(DateTime)
  formatTime;

  final Future<void> Function(int)
  onCancel;

  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.formatDate,
    required this.formatTime,
    required this.onCancel,
    required this.onTap,
  });

  // ==========================================================
  // DATE
  // ==========================================================

  DateTime _parseDate(
      dynamic value,
      ) {
    try {
      return DateTime.parse(
        value.toString(),
      ).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  String _getStatus() {
    return booking['status']
        ?.toString()
        .toLowerCase() ??
        'pending';
  }

  Color _statusColor(
      String status,
      ) {
    switch (status) {
      case 'confirmed':
        return Colors.green;

      case 'completed':
        return Colors.blue;

      case 'cancelled':
      case 'canceled':
        return Colors.red;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;

      case 'completed':
        return Icons.task_alt;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel;

      case 'pending':
      default:
        return Icons.access_time_filled;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final status =
    _getStatus();

    final startTime =
    _parseDate(
      booking['start_time'],
    );

    final endTime =
    _parseDate(
      booking['end_time'],
    );

    final vehicleName =
    booking['vehicle_name']
        ?.toString()
        .trim()
        .isNotEmpty ==
        true
        ? booking['vehicle_name']
        .toString()
        : 'Vehicle';

    final vehicleImage =
        booking['vehicle_image']
            ?.toString() ??
            '';

    final reference =
        booking['booking_reference']
            ?.toString() ??
            'RK-BOOKING';

    final amount =
        double.tryParse(
          booking['total_amount']
              ?.toString() ??
              '0',
        ) ??
            0;

    final duration =
        double.tryParse(
          booking['duration_hours']
              ?.toString() ??
              '0',
        ) ??
            0;

    final location =
    booking['vehicle_area']
        ?.toString()
        .isNotEmpty ==
        true
        ? booking['vehicle_area']
        .toString()
        : booking['vehicle_city']
        ?.toString() ??
        '';

    final bookingId =
    int.tryParse(
      booking['id']?.toString() ??
          '',
    );

    final canCancel =
        status == 'pending' ||
            status == 'confirmed';

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        boxShadow: const [
          BoxShadow(
            color:
            Color(
              0x12000000,
            ),

            blurRadius: 12,

            offset:
            Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Material(
        color:
        Colors.transparent,

        child: InkWell(
          onTap:
          onTap,

          borderRadius:
          BorderRadius.circular(
            20,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ==============================================
              // VEHICLE IMAGE
              // ==============================================

              ClipRRect(
                borderRadius:
                const BorderRadius
                    .only(
                  topLeft:
                  Radius.circular(
                    20,
                  ),

                  topRight:
                  Radius.circular(
                    20,
                  ),
                ),

                child: SizedBox(
                  height: 180,

                  width:
                  double.infinity,

                  child:
                  vehicleImage
                      .isNotEmpty
                      ? Image.network(
                    vehicleImage,

                    fit:
                    BoxFit.cover,

                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return _imagePlaceholder();
                    },
                  )
                      : _imagePlaceholder(),
                ),
              ),

              // ==============================================
              // CONTENT
              // ==============================================

              Padding(
                padding:
                const EdgeInsets
                    .all(
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    // ========================================
                    // NAME + STATUS
                    // ========================================

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicleName,

                            style:
                            const TextStyle(
                              fontSize: 20,

                              fontWeight:
                              FontWeight.bold,

                              color:
                              Color(
                                0xFF111827,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal:
                            10,

                            vertical:
                            6,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            _statusColor(
                              status,
                            ).withValues(
                              alpha:
                              0.12,
                            ),

                            borderRadius:
                            BorderRadius
                                .circular(
                              20,
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                            MainAxisSize
                                .min,

                            children: [
                              Icon(
                                _statusIcon(
                                  status,
                                ),

                                size:
                                15,

                                color:
                                _statusColor(
                                  status,
                                ),
                              ),

                              const SizedBox(
                                width:
                                5,
                              ),

                              Text(
                                status
                                    .toUpperCase(),

                                style:
                                TextStyle(
                                  color:
                                  _statusColor(
                                    status,
                                  ),

                                  fontSize:
                                  11,

                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ========================================
                    // REFERENCE
                    // ========================================

                    Text(
                      reference,

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF6B7280,
                        ),

                        fontSize:
                        13,

                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    // ========================================
                    // LOCATION
                    // ========================================

                    if (location
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,

                            size: 18,

                            color:
                            Color(
                              0xFF6B7280,
                            ),
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Expanded(
                            child: Text(
                              location,

                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFF6B7280,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(
                      height: 18,
                    ),

                    const Divider(),

                    const SizedBox(
                      height: 12,
                    ),

                    // ========================================
                    // PICKUP + RETURN
                    // ========================================

                    Row(
                      children: [
                        Expanded(
                          child:
                          _InfoItem(
                            icon:
                            Icons
                                .login_rounded,

                            label:
                            'Pickup',

                            value:
                            '${formatDate(startTime)}\n${formatTime(startTime)}',
                          ),
                        ),

                        Container(
                          width: 1,

                          height: 45,

                          color:
                          const Color(
                            0xFFE5E7EB,
                          ),
                        ),

                        Expanded(
                          child:
                          _InfoItem(
                            icon:
                            Icons
                                .logout_rounded,

                            label:
                            'Return',

                            value:
                            '${formatDate(endTime)}\n${formatTime(endTime)}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ========================================
                    // DURATION + AMOUNT
                    // ========================================

                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .schedule,

                                size: 20,

                                color:
                                Color(
                                  0xFF6B7280,
                                ),
                              ),

                              const SizedBox(
                                width: 7,
                              ),

                              Text(
                                '${duration % 1 == 0 ? duration.toInt() : duration} hours',

                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '₹${amount.toStringAsFixed(0)}',

                          style:
                          const TextStyle(
                            fontSize: 20,

                            fontWeight:
                            FontWeight.bold,

                            color:
                            Color(
                              0xFF111827,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ========================================
                    // CANCEL BUTTON
                    // ========================================

                    if (canCancel &&
                        bookingId !=
                            null) ...[
                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        width:
                        double.infinity,

                        child:
                        OutlinedButton.icon(
                          onPressed:
                              () {
                            onCancel(
                              bookingId,
                            );
                          },

                          icon:
                          const Icon(
                            Icons
                                .cancel_outlined,
                          ),

                          label:
                          const Text(
                            'Cancel Booking',
                          ),

                          style:
                          OutlinedButton
                              .styleFrom(
                            foregroundColor:
                            Colors.red,

                            side:
                            const BorderSide(
                              color:
                              Colors.red,
                            ),

                            padding:
                            const EdgeInsets
                                .symmetric(
                              vertical:
                              14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE PLACEHOLDER
  // ==========================================================

  Widget _imagePlaceholder() {
    return const ColoredBox(
      color:
      Color(
        0xFFF3F4F6,
      ),

      child: Center(
        child: Icon(
          Icons
              .directions_car_filled_outlined,

          size: 70,

          color:
          Color(
            0xFF9CA3AF,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO ITEM
// ============================================================

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Icon(
          icon,

          size: 20,

          color:
          const Color(
            0xFF2563EB,
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style:
                const TextStyle(
                  color:
                  Color(
                    0xFF6B7280,
                  ),

                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,

                style:
                const TextStyle(
                  fontSize: 13,

                  fontWeight:
                  FontWeight.w600,

                  color:
                  Color(
                    0xFF111827,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}