import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/host_booking.dart';
import '../providers/host_booking_provider.dart';

class HostBookingsScreen extends ConsumerStatefulWidget {
  const HostBookingsScreen({
    super.key,
  });

  @override
  ConsumerState<HostBookingsScreen> createState() =>
      _HostBookingsScreenState();
}

class _HostBookingsScreenState
    extends ConsumerState<HostBookingsScreen> {
  String _selectedFilter = 'all';

  final List<String> _filters = const [
    'all',
    'pending',
    'confirmed',
    'rejected',
    'cancelled',
    'completed',
  ];

  Future<void> _refresh() async {
    await ref
        .read(hostBookingsNotifierProvider.notifier)
        .loadBookings();

    ref.invalidate(hostBookingsProvider);
    ref.invalidate(hostPendingBookingsProvider);
  }

  // ============================================================
  // CONFIRM BOOKING
  // ============================================================

  Future<void> _confirmBooking(
      HostBooking booking,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirm Booking',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Confirm booking ${booking.bookingReference} '
                'for ${booking.vehicleName}?',
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
              child: const Text('Confirm'),
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
          .read(hostBookingsNotifierProvider.notifier)
          .confirmBooking(booking.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking confirmed successfully.',
          ),
        ),
      );

      ref.invalidate(hostBookingsProvider);
      ref.invalidate(hostPendingBookingsProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error);
    }
  }

  // ============================================================
  // REJECT BOOKING
  // ============================================================

  Future<void> _rejectBooking(
      HostBooking booking,
      ) async {
    final reasonController =
    TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Booking',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reject ${booking.bookingReference}?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText:
                  'Enter rejection reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  null,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  reasonController.text.trim(),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (result == null) {
      return;
    }

    try {
      await ref
          .read(hostBookingsNotifierProvider.notifier)
          .rejectBooking(
        booking.id,
        reason: result.isEmpty
            ? null
            : result,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking rejected successfully.',
          ),
        ),
      );

      ref.invalidate(hostBookingsProvider);
      ref.invalidate(hostPendingBookingsProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error);
    }
  }

  // ============================================================
  // COMPLETE RENTAL
  // ============================================================

  Future<void> _completeBooking(
      HostBooking booking,
      ) async {
    final completed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Complete Rental',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Mark booking ${booking.bookingReference} '
                'as completed?\n\n'
                'Vehicle: ${booking.vehicleName}',
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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Complete Rental',
              ),
            ),
          ],
        );
      },
    );

    if (completed != true) {
      return;
    }

    try {
      await ref
          .read(hostBookingsNotifierProvider.notifier)
          .completeBooking(booking.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rental completed successfully.',
          ),
        ),
      );

      ref.invalidate(hostBookingsProvider);
      ref.invalidate(hostPendingBookingsProvider);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error);
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
      Object error,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        const Color(0xFFDC2626),
        content: Text(
          error
              .toString()
              .replaceFirst(
            'Exception: ',
            '',
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<HostBooking> _filterBookings(
      List<HostBooking> bookings,
      ) {
    if (_selectedFilter == 'all') {
      return bookings;
    }

    return bookings.where(
          (booking) {
        return booking.status
            .toLowerCase() ==
            _selectedFilter;
      },
    ).toList();
  }

  // ============================================================
  // DATE
  // ============================================================

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

  // ============================================================
  // TIME
  // ============================================================

  String _formatTime(
      DateTime dateTime,
      ) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour == 0
        ? 12
        : dateTime.hour;

    final minute = dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
    dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD97706);

      case 'confirmed':
        return const Color(0xFF2563EB);

      case 'completed':
        return const Color(0xFF16A34A);

      case 'rejected':
        return const Color(0xFFDC2626);

      case 'cancelled':
      case 'canceled':
        return const Color(0xFF6B7280);

      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions_rounded;

      case 'confirmed':
        return Icons.check_circle_outline_rounded;

      case 'completed':
        return Icons.task_alt_rounded;

      case 'rejected':
        return Icons.cancel_outlined;

      case 'cancelled':
      case 'canceled':
        return Icons.block_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  String _prettyStatus(
      String status,
      ) {
    if (status.isEmpty) {
      return 'UNKNOWN';
    }

    return status
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final bookingsAsync =
    ref.watch(
      hostBookingsNotifierProvider,
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF8FAFC),
        elevation: 0,
        surfaceTintColor:
        Colors.transparent,
        title: const Text(
          'Bookings',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
      body: bookingsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (
            error,
            stackTrace,
            ) {
          return _ErrorView(
            error: error,
            onRetry: _refresh,
          );
        },
        data: (
            bookings,
            ) {
          final filteredBookings =
          _filterBookings(
            bookings,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                32,
              ),
              children: [
                _SummarySection(
                  bookings: bookings,
                ),

                const SizedBox(height: 18),

                _FilterSection(
                  filters: _filters,
                  selectedFilter:
                  _selectedFilter,
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter =
                          filter;
                    });
                  },
                ),

                const SizedBox(height: 18),

                if (filteredBookings.isEmpty)
                  _EmptyBookings(
                    filter:
                    _selectedFilter,
                  )
                else
                  ...filteredBookings.map(
                        (booking) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child:
                        _BookingCard(
                          booking: booking,
                          statusColor:
                          _statusColor(
                            booking.status,
                          ),
                          statusIcon:
                          _statusIcon(
                            booking.status,
                          ),
                          statusText:
                          _prettyStatus(
                            booking.status,
                          ),
                          formatDate:
                          _formatDate,
                          formatTime:
                          _formatTime,
                          onConfirm:
                          booking.isPending
                              ? () =>
                              _confirmBooking(
                                booking,
                              )
                              : null,
                          onReject:
                          booking.isPending
                              ? () =>
                              _rejectBooking(
                                booking,
                              )
                              : null,
                          onComplete:
                          booking.isConfirmed
                              ? () =>
                              _completeBooking(
                                booking,
                              )
                              : null,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =================================================================
// SUMMARY
// =================================================================

class _SummarySection
    extends StatelessWidget {
  final List<HostBooking> bookings;

  const _SummarySection({
    required this.bookings,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final pending = bookings
        .where(
          (booking) =>
      booking.isPending,
    )
        .length;

    final confirmed = bookings
        .where(
          (booking) =>
      booking.isConfirmed,
    )
        .length;

    final completed = bookings
        .where(
          (booking) =>
      booking.isCompleted,
    )
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total',
            value:
            bookings.length.toString(),
            icon:
            Icons.calendar_month_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Pending',
            value: pending.toString(),
            icon:
            Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Confirmed',
            value:
            confirmed.toString(),
            icon:
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Done',
            value:
            completed.toString(),
            icon:
            Icons.task_alt_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 21,
            color:
            const Color(0xFF1565C0),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.w800,
              color:
              Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color:
              Color(0xFF6B7280),
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// FILTERS
// =================================================================

class _FilterSection
    extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String>
  onSelected;

  const _FilterSection({
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  String _label(
      String filter,
      ) {
    if (filter == 'all') {
      return 'All';
    }

    return filter[0].toUpperCase() +
        filter.substring(1);
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder:
            (_, index) =>
        const SizedBox(width: 8),
        itemBuilder:
            (context, index) {
          final filter =
          filters[index];

          final selected =
              selectedFilter ==
                  filter;

          return ChoiceChip(
            label: Text(
              _label(filter),
            ),
            selected: selected,
            onSelected: (_) {
              onSelected(filter);
            },
            selectedColor:
            const Color(
              0xFF1565C0,
            ),
            backgroundColor:
            Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(
                0xFF1565C0,
              )
                  : const Color(
                0xFFE5E7EB,
              ),
            ),
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(
                0xFF374151,
              ),
              fontWeight:
              FontWeight.w600,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}

// =================================================================
// BOOKING CARD
// =================================================================

class _BookingCard
    extends StatelessWidget {
  final HostBooking booking;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final String Function(DateTime)
  formatDate;
  final String Function(DateTime)
  formatTime;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const _BookingCard({
    required this.booking,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
    required this.formatDate,
    required this.formatTime,
    required this.onConfirm,
    required this.onReject,
    required this.onComplete,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final location =
    [
      booking.area,
      booking.city,
    ]
        .where(
          (value) =>
      value != null &&
          value!.trim().isNotEmpty,
    )
        .map(
          (value) =>
          value!.trim(),
    )
        .join(', ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color:
            Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.vehicleName,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w800,
                          color:
                          Color(
                            0xFF111827,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        booking.bookingReference,
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF6B7280,
                          ),
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 15,
                        color:
                        statusColor,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        statusText,
                        style:
                        TextStyle(
                          color:
                          statusColor,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(
              height: 1,
            ),

            const SizedBox(height: 14),

            // ======================================================
            // LOCATION
            // ======================================================

            if (location.isNotEmpty)
              _InfoRow(
                icon:
                Icons.location_on_outlined,
                title: 'Location',
                value: location,
              ),

            if (location.isNotEmpty)
              const SizedBox(height: 11),

            // ======================================================
            // PICKUP / RETURN
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon:
                    Icons.login_rounded,
                    title: 'Pickup',
                    value:
                    '${formatDate(booking.startTime)}\n'
                        '${formatTime(booking.startTime)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoRow(
                    icon:
                    Icons.logout_rounded,
                    title: 'Return',
                    value:
                    '${formatDate(booking.endTime)}\n'
                        '${formatTime(booking.endTime)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ======================================================
            // AMOUNT
            // ======================================================

            Container(
              padding:
              const EdgeInsets.all(
                13,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                children: [
                  _AmountRow(
                    title: 'Base amount',
                    value:
                    '₹${booking.baseAmount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  _AmountRow(
                    title:
                    'Platform fee',
                    value:
                    '₹${booking.platformFee.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  _AmountRow(
                    title:
                    'Security deposit',
                    value:
                    '₹${booking.securityDeposit.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  const Divider(
                    height: 1,
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  _AmountRow(
                    title:
                    'Total booking value',
                    value:
                    '₹${booking.totalAmount.toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),

            // ======================================================
            // ACTIONS
            // ======================================================

            if (onConfirm != null ||
                onReject != null ||
                onComplete != null) ...[
              const SizedBox(height: 14),

              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child:
                      OutlinedButton(
                        onPressed:
                        onReject,
                        style:
                        OutlinedButton
                            .styleFrom(
                          foregroundColor:
                          const Color(
                            0xFFDC2626,
                          ),
                          side:
                          const BorderSide(
                            color:
                            Color(
                              0xFFFCA5A5,
                            ),
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              11,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'Reject',
                        ),
                      ),
                    ),

                  if (onReject != null &&
                      onConfirm != null)
                    const SizedBox(
                      width: 10,
                    ),

                  if (onConfirm != null)
                    Expanded(
                      child:
                      ElevatedButton(
                        onPressed:
                        onConfirm,
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF1565C0,
                          ),
                          foregroundColor:
                          Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              11,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'Confirm',
                        ),
                      ),
                    ),

                  if (onComplete != null)
                    Expanded(
                      child:
                      ElevatedButton(
                        onPressed:
                        onComplete,
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          const Color(
                            0xFF16A34A,
                          ),
                          foregroundColor:
                          Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              11,
                            ),
                          ),
                        ),
                        child:
                        const Text(
                          'Complete Rental',
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =================================================================
// INFO ROW
// =================================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
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
        Container(
          height: 36,
          width: 36,
          decoration:
          BoxDecoration(
            color:
            const Color(0xFFEFF6FF),
            borderRadius:
            BorderRadius.circular(
              9,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color:
            const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  fontSize: 10,
                  color:
                  Color(0xFF6B7280),
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// AMOUNT ROW
// =================================================================

class _AmountRow
    extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _AmountRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize:
              bold ? 13 : 12,
              color: bold
                  ? const Color(
                0xFF111827,
              )
                  : const Color(
                0xFF6B7280,
              ),
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:
            bold ? 15 : 12,
            color:
            const Color(
              0xFF111827,
            ),
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// EMPTY
// =================================================================

class _EmptyBookings
    extends StatelessWidget {
  final String filter;

  const _EmptyBookings({
    required this.filter,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final title = filter == 'all'
        ? 'No bookings yet'
        : 'No $filter bookings';

    final message = filter == 'all'
        ? 'New customer bookings will appear here.'
        : 'There are no bookings in this status.';

    return Container(
      margin:
      const EdgeInsets.only(
        top: 35,
      ),
      padding:
      const EdgeInsets.all(30),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 68,
            width: 68,
            decoration:
            const BoxDecoration(
              color:
              Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .calendar_month_outlined,
              size: 34,
              color:
              Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w800,
              color:
              Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              fontSize: 13,
              color:
              Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// ERROR
// =================================================================

class _ErrorView
    extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final message = error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration:
              const BoxDecoration(
                color:
                Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .error_outline_rounded,
                size: 36,
                color:
                Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load bookings',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 13,
                color:
                Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}