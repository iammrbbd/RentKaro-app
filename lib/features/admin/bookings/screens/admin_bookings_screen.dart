import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_booking_model.dart';
import '../services/admin_booking_service.dart';

final adminBookingServiceProvider = Provider<AdminBookingService>((ref) {
  return AdminBookingService();
});

final adminBookingsProvider =
    FutureProvider.family<List<AdminBooking>, String>((ref, status) async {
  return ref.read(adminBookingServiceProvider).getBookings(
        status: status == 'all' ? null : status,
      );
});

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  String _status = 'all';

  static const _filters = <String>[
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
    'rejected',
  ];

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsProvider(_status));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = _status == filter;
                return ChoiceChip(
                  label: Text(_label(filter)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _status = filter);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminBookingsProvider(_status));
                await ref.read(adminBookingsProvider(_status).future);
              },
              child: bookingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => _ErrorState(
                  message: error.toString().replaceFirst('Exception: ', ''),
                  onRetry: () => ref.invalidate(
                    adminBookingsProvider(_status),
                  ),
                ),
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const _EmptyState();
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return _BookingCard(
                        booking: bookings[index],
                        onTap: () => _showDetails(bookings[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(String value) {
    if (value == 'all') return 'All';
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> _showDetails(AdminBooking booking) async {
    final latest = await ref
        .read(adminBookingServiceProvider)
        .getBooking(booking.id);

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BookingDetails(
        booking: latest,
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';

  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}, $hour12:$minute $period';
}

class _BookingCard extends StatelessWidget {
  final AdminBooking booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.bookingReference.isEmpty
                          ? 'Booking #${booking.id}'
                          : booking.bookingReference,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusChip(status: booking.normalizedStatus),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                booking.vehicleName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (booking.registrationNumber.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  booking.registrationNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 17),
                  const SizedBox(width: 6),
                  Expanded(child: Text(booking.customerName)),
                  Text(
                    '₹${booking.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(booking.startTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (booking.city.isNotEmpty || booking.area.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  [booking.area, booking.city]
                      .where((e) => e.trim().isNotEmpty)
                      .join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade100,
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status[0].toUpperCase() + status.substring(1),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookingDetails extends StatelessWidget {
  final AdminBooking booking;

  const _BookingDetails({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.bookingReference.isEmpty
                  ? 'Booking #${booking.id}'
                  : booking.bookingReference,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _StatusChip(status: booking.normalizedStatus),
            const SizedBox(height: 22),
            _SectionTitle('Customer'),
            _InfoRow('Name', booking.customerName),
            _InfoRow('Phone', booking.customerPhone),
            _InfoRow('Email', booking.customerEmail),
            const SizedBox(height: 18),
            _SectionTitle('Vehicle'),
            _InfoRow('Vehicle', booking.vehicleName),
            _InfoRow('Registration', booking.registrationNumber),
            _InfoRow(
              'Location',
              [booking.area, booking.city]
                  .where((e) => e.trim().isNotEmpty)
                  .join(', '),
            ),
            const SizedBox(height: 18),
            _SectionTitle('Trip'),
            _InfoRow('Start', _formatDate(booking.startTime)),
            _InfoRow('End', _formatDate(booking.endTime)),
            _InfoRow('Duration', '${booking.durationHours} hours'),
            const SizedBox(height: 18),
            _SectionTitle('Amount'),
            _InfoRow('Base amount', '₹${booking.baseAmount.toStringAsFixed(2)}'),
            _InfoRow('Security deposit', '₹${booking.securityDeposit.toStringAsFixed(2)}'),
            _InfoRow('Platform fee', '₹${booking.platformFee.toStringAsFixed(2)}'),
            _InfoRow('Total', '₹${booking.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 170),
        Icon(Icons.event_busy_outlined, size: 58),
        SizedBox(height: 16),
        Center(
          child: Text(
            'No bookings found.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 130),
        const Icon(Icons.error_outline, size: 58),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
