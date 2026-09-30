import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/providers/booking_provider.dart';
import '../../booking/services/booking_service.dart';
import '../../payments/screens/payment_screen.dart';
import '../../reviews/screens/write_review_screen.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final int bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final bookingAsync = ref.watch(
      bookingDetailsProvider(bookingId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF111827),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(
                bookingDetailsProvider(bookingId),
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: bookingAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            error: error,
            onRetry: () {
              ref.invalidate(
                bookingDetailsProvider(bookingId),
              );
            },
          );
        },
        data: (response) {
          final booking = _extractBooking(response);

          if (booking == null) {
            return _ErrorView(
              error: 'Booking data not found.',
              onRetry: () {
                ref.invalidate(
                  bookingDetailsProvider(bookingId),
                );
              },
            );
          }

          return _BookingDetailsBody(
            booking: booking,
            bookingId: bookingId,
          );
        },
      ),
    );
  }

  static Map<String, dynamic>? _extractBooking(
      Map<String, dynamic> response,
      ) {
    final value = response['booking'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return response;
  }
}

class _BookingDetailsBody extends ConsumerStatefulWidget {
  final Map<String, dynamic> booking;
  final int bookingId;

  const _BookingDetailsBody({
    required this.booking,
    required this.bookingId,
  });

  @override
  ConsumerState<_BookingDetailsBody> createState() {
    return _BookingDetailsBodyState();
  }
}

class _BookingDetailsBodyState
    extends ConsumerState<_BookingDetailsBody> {
  bool _isCancelling = false;
  bool _isOpeningPayment = false;
  bool _isLoadingCancellation = false;

  Map<String, dynamic>? _cancellation;

  String _stringValue(
      dynamic value, {
        String fallback = '',
      }) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return fallback;
    }

    return result;
  }

  double _doubleValue(dynamic value) {
    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  Map<String, dynamic> get _vehicle {
    final value = widget.booking['vehicle'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  String get _vehicleName {
    final directName = _stringValue(
      widget.booking['vehicle_name'],
    );

    if (directName.isNotEmpty) {
      return directName;
    }

    final nestedName = _stringValue(
      _vehicle['name'],
    );

    if (nestedName.isNotEmpty) {
      return nestedName;
    }

    final brand = _stringValue(
      widget.booking['vehicle_brand'] ??
          _vehicle['brand'],
    );

    final model = _stringValue(
      widget.booking['vehicle_model'] ??
          _vehicle['model'],
    );

    final combined = '$brand $model'.trim();

    if (combined.isNotEmpty) {
      return combined;
    }

    return 'Vehicle';
  }

  String get _vehicleImage {
    final directImage = _stringValue(
      widget.booking['vehicle_image'],
    );

    if (directImage.isNotEmpty) {
      return directImage;
    }

    final nestedImage = _stringValue(
      _vehicle['image'],
    );

    if (nestedImage.isNotEmpty) {
      return nestedImage;
    }

    final images = _vehicle['images'];

    if (images is List && images.isNotEmpty) {
      return _stringValue(images.first);
    }

    return '';
  }

  String get _location {
    final directArea = _stringValue(
      widget.booking['vehicle_area'],
    );

    final directCity = _stringValue(
      widget.booking['vehicle_city'],
    );

    if (directArea.isNotEmpty &&
        directCity.isNotEmpty) {
      return '$directArea, $directCity';
    }

    if (directArea.isNotEmpty) {
      return directArea;
    }

    if (directCity.isNotEmpty) {
      return directCity;
    }

    final area = _stringValue(
      _vehicle['area'],
    );

    final city = _stringValue(
      _vehicle['city'],
    );

    if (area.isNotEmpty && city.isNotEmpty) {
      return '$area, $city';
    }

    if (area.isNotEmpty) {
      return area;
    }

    return city;
  }

  int get _vehicleId {
    final directId = widget.booking['vehicle_id'];

    if (directId != null) {
      return int.tryParse(
        directId.toString(),
      ) ??
          0;
    }

    final nestedId = _vehicle['id'];

    return int.tryParse(
      nestedId.toString(),
    ) ??
        0;
  }

  DateTime _parseDate(dynamic value) {
    try {
      return DateTime.parse(
        value.toString(),
      ).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  String _formatDate(DateTime date) {
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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute
        .toString()
        .padLeft(2, '0');

    final period = date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  String get _status {
    return _stringValue(
      widget.booking['status'],
      fallback: 'pending',
    ).toLowerCase();
  }

  Color get _statusColor {
    switch (_status) {
      case 'confirmed':
        return const Color(0xFF16A34A);

      case 'completed':
        return const Color(0xFF2563EB);

      case 'cancelled':
      case 'canceled':
        return const Color(0xFFDC2626);

      case 'rejected':
        return const Color(0xFFDC2626);

      case 'payment_failed':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFFEA580C);
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'confirmed':
        return Icons.check_circle;

      case 'completed':
        return Icons.task_alt;

      case 'cancelled':
      case 'canceled':
        return Icons.cancel;

      case 'rejected':
        return Icons.block;

      case 'payment_failed':
        return Icons.payment;

      default:
        return Icons.access_time_filled;
    }
  }

  bool get _canCancel {
    return _status == 'pending' ||
        _status == 'confirmed';
  }

  String _money(dynamic value) {
    return '₹${_doubleValue(value).toStringAsFixed(0)}';
  }

  // ==========================================================
  // PAYMENT
  // ==========================================================

  Future<void> _openPayment() async {
    if (_isOpeningPayment) {
      return;
    }

    setState(() {
      _isOpeningPayment = true;
    });

    try {
      final paymentCompleted =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingId: widget.bookingId,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (paymentCompleted == true) {
        ref.invalidate(
          bookingDetailsProvider(
            widget.bookingId,
          ),
        );

        ref.invalidate(
          myBookingsProvider,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment successful. Booking confirmed.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPayment = false;
        });
      }
    }
  }

  // ==========================================================
  // CANCELLATION
  // ==========================================================

  Future<void> _cancelBooking() async {
    final reason = await _showCancellationDialog();

    if (!mounted || reason == null) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      final response = await ref
          .read(bookingServiceProvider)
          .cancelBooking(
        widget.bookingId,
        reason: reason,
      );

      final cancellation =
      response['cancellation'];

      if (cancellation is Map) {
        _cancellation =
        Map<String, dynamic>.from(
          cancellation,
        );
      }

      ref.invalidate(
        bookingDetailsProvider(
          widget.bookingId,
        ),
      );

      ref.invalidate(
        myBookingsProvider,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking cancelled successfully.',
          ),
        ),
      );

      await _loadCancellationDetails();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to cancel booking: $error',
          ),
          backgroundColor:
          const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Future<String?> _showCancellationDialog() async {
    String selectedReason =
        'Change of plans';

    final reasons = <String>[
      'Change of plans',
      'Found another vehicle',
      'Travel plan changed',
      'Vehicle no longer required',
      'Booked by mistake',
      'Other',
    ];

    final result =
    await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Cancel Booking?',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please select a reason for cancellation.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration:
                    InputDecoration(
                      labelText:
                      'Cancellation Reason',
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    items: reasons
                        .map(
                          (reason) =>
                          DropdownMenuItem<
                              String>(
                            value: reason,
                            child: Text(reason),
                          ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(() {
                        selectedReason =
                            value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFFFF7ED),
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Text(
                      'Cancellation charges depend on how much time is left before pickup.',
                      style: TextStyle(
                        color:
                        Color(0xFF9A3412),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Keep Booking',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      selectedReason,
                    );
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFDC2626),
                    foregroundColor:
                    Colors.white,
                  ),
                  child: const Text(
                    'Cancel Booking',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<void> _loadCancellationDetails() async {
    if (_status != 'cancelled' &&
        _status != 'canceled') {
      return;
    }

    if (_isLoadingCancellation) {
      return;
    }

    setState(() {
      _isLoadingCancellation = true;
    });

    try {
      final response = await ref
          .read(bookingServiceProvider)
          .getCancellation(
        widget.bookingId,
      );

      final cancellation =
      response['cancellation'];

      if (!mounted) {
        return;
      }

      if (cancellation is Map) {
        setState(() {
          _cancellation =
          Map<String, dynamic>.from(
            cancellation,
          );
        });
      }
    } catch (error) {
      debugPrint(
        'CANCELLATION DETAILS ERROR: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCancellation = false;
        });
      }
    }
  }

  // ==========================================================
  // WRITE REVIEW
  // ==========================================================

  Future<void> _openWriteReview() async {
    final vehicleId = _vehicleId;

    if (vehicleId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vehicle information is not available.',
          ),
        ),
      );
      return;
    }

    final result =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(
          bookingId: widget.bookingId,
          vehicleId: vehicleId,
          vehicleName: _vehicleName,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thank you for your review!',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadCancellationDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final startTime = _parseDate(
      widget.booking['start_time'],
    );

    final endTime = _parseDate(
      widget.booking['end_time'],
    );

    final duration = _doubleValue(
      widget.booking['duration_hours'],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildVehicleCard(),

          const SizedBox(height: 18),

          _SectionCard(
            title: 'Booking Information',
            child: Column(
              children: [
                _DetailRow(
                  label: 'Booking Reference',
                  value: _stringValue(
                    widget.booking[
                    'booking_reference'],
                    fallback: 'RK-BOOKING',
                  ),
                ),

                const Divider(),

                _DetailRow(
                  label: 'Booking ID',
                  value:
                  widget.bookingId.toString(),
                ),

                const Divider(),

                _DetailRow(
                  label: 'Duration',
                  value:
                  '${duration % 1 == 0 ? duration.toInt() : duration} hours',
                ),

                const Divider(),

                _DetailRow(
                  label: 'Status',
                  value:
                  _status.toUpperCase(),
                  valueColor:
                  _statusColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _SectionCard(
            title: 'Rental Schedule',
            child: Column(
              children: [
                _ScheduleRow(
                  icon: Icons.login_rounded,
                  title: 'Pickup',
                  date: _formatDate(
                    startTime,
                  ),
                  time: _formatTime(
                    startTime,
                  ),
                ),

                const SizedBox(height: 20),

                _ScheduleRow(
                  icon: Icons.logout_rounded,
                  title: 'Return',
                  date: _formatDate(
                    endTime,
                  ),
                  time: _formatTime(
                    endTime,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _SectionCard(
            title: 'Payment Summary',
            child: Column(
              children: [
                _PriceRow(
                  label: 'Rental Amount',
                  value: _money(
                    widget.booking[
                    'base_amount'],
                  ),
                ),

                const SizedBox(height: 12),

                _PriceRow(
                  label: 'Platform Fee',
                  value: _money(
                    widget.booking[
                    'platform_fee'],
                  ),
                ),

                const SizedBox(height: 12),

                _PriceRow(
                  label: 'Security Deposit',
                  value: _money(
                    widget.booking[
                    'security_deposit'],
                  ),
                ),

                const Divider(
                  height: 28,
                ),

                _PriceRow(
                  label: 'Total Amount',
                  value: _money(
                    widget.booking[
                    'total_amount'],
                  ),
                  isTotal: true,
                ),
              ],
            ),
          ),

          if (_status == 'cancelled' ||
              _status == 'canceled') ...[
            const SizedBox(height: 18),
            _buildCancellationDetails(),
          ],

          const SizedBox(height: 24),

          // ==================================================
          // PAYMENT BUTTON
          // ==================================================

          if (_status == 'pending' ||
              _status == 'payment_failed')
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                _isOpeningPayment
                    ? null
                    : _openPayment,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2563EB),
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child: _isOpeningPayment
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                    Colors.white,
                  ),
                )
                    : Text(
                  _status ==
                      'payment_failed'
                      ? 'Retry Payment'
                      : 'Pay Now',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          if (_status == 'pending' ||
              _status == 'confirmed')
            const SizedBox(height: 12),

          // ==================================================
          // CANCEL BUTTON
          // ==================================================

          if (_canCancel)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed:
                _isCancelling
                    ? null
                    : _cancelBooking,
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(0xFFDC2626),
                  side: const BorderSide(
                    color: Color(0xFFDC2626),
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
                child: _isCancelling
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ),

          // ==================================================
          // CANCELLED STATUS
          // ==================================================

          if (_status == 'cancelled' ||
              _status == 'canceled')
            const _StatusMessage(
              icon:
              Icons.cancel_outlined,
              text:
              'This booking has been cancelled.',
              color:
              Color(0xFFDC2626),
            ),

          // ==================================================
          // COMPLETED + WRITE REVIEW
          // ==================================================

          if (_status == 'completed') ...[
            const _StatusMessage(
              icon:
              Icons.check_circle_outline,
              text:
              'This booking has been completed.',
              color:
              Color(0xFF16A34A),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openWriteReview,
                icon: const Icon(
                  Icons.star_rounded,
                ),
                label: const Text(
                  'Write a Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFF59E0B),
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ==================================================
          // REJECTED STATUS
          // ==================================================

          if (_status == 'rejected')
            const _StatusMessage(
              icon: Icons.block,
              text:
              'This booking was rejected by the host.',
              color:
              Color(0xFFDC2626),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================================
  // CANCELLATION DETAILS CARD
  // ==========================================================

  Widget _buildCancellationDetails() {
    if (_isLoadingCancellation) {
      return const _SectionCard(
        title: 'Cancellation Details',
        child: Center(
          child: Padding(
            padding:
            EdgeInsets.all(10),
            child:
            CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_cancellation == null) {
      return const _SectionCard(
        title: 'Cancellation Details',
        child: Text(
          'Cancellation details are not available yet.',
          style: TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    final reason = _stringValue(
      _cancellation!['reason'],
      fallback: 'Not specified',
    );

    final fee = _doubleValue(
      _cancellation![
      'cancellation_fee'],
    );

    final refund = _doubleValue(
      _cancellation![
      'refund_amount'],
    );

    final refundStatus = _stringValue(
      _cancellation![
      'refund_status'],
      fallback: 'pending',
    ).toUpperCase();

    final cancelledAt =
    _cancellation!['cancelled_at'];

    DateTime? cancelledDate;

    if (cancelledAt != null) {
      try {
        cancelledDate =
            DateTime.parse(
              cancelledAt.toString(),
            ).toLocal();
      } catch (_) {}
    }

    return _SectionCard(
      title: 'Cancellation Details',
      child: Column(
        children: [
          _DetailRow(
            label: 'Reason',
            value: reason,
          ),

          const Divider(),

          _DetailRow(
            label: 'Cancellation Fee',
            value: _money(fee),
            valueColor:
            fee > 0
                ? const Color(
              0xFFDC2626,
            )
                : const Color(
              0xFF16A34A,
            ),
          ),

          const Divider(),

          _DetailRow(
            label: 'Refund Amount',
            value: _money(refund),
            valueColor:
            const Color(0xFF16A34A),
          ),

          const Divider(),

          _DetailRow(
            label: 'Refund Status',
            value: refundStatus,
            valueColor:
            refundStatus ==
                'COMPLETED'
                ? const Color(
              0xFF16A34A,
            )
                : const Color(
              0xFFEA580C,
            ),
          ),

          if (cancelledDate != null) ...[
            const Divider(),
            _DetailRow(
              label: 'Cancelled On',
              value:
              '${_formatDate(cancelledDate)} ${_formatTime(cancelledDate)}',
            ),
          ],

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
              const Color(0xFFEFF6FF),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 19,
                  color:
                  Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    refundStatus ==
                        'COMPLETED'
                        ? 'Your refund has been processed.'
                        : 'Refund is currently pending. Payment gateway refund processing will update this status.',
                    style:
                    const TextStyle(
                      color:
                      Color(0xFF1E40AF),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // VEHICLE CARD
  // ==========================================================

  Widget _buildVehicleCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.only(
              topLeft:
              Radius.circular(20),
              topRight:
              Radius.circular(20),
            ),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: _vehicleImage.isNotEmpty
                  ? Image.network(
                _vehicleImage,
                fit: BoxFit.cover,
                errorBuilder: (
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

          Padding(
            padding:
            const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _vehicleName,
                        style:
                        const TextStyle(
                          fontSize: 21,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          Color(0xFF111827),
                        ),
                      ),
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        _statusColor
                            .withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon,
                            size: 14,
                            color:
                            _statusColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            _status
                                .toUpperCase(),
                            style:
                            TextStyle(
                              color:
                              _statusColor,
                              fontSize: 10,
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,
                      size: 18,
                      color:
                      Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _location.isEmpty
                            ? 'Location not available'
                            : _location,
                        style:
                        const TextStyle(
                          color:
                          Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons
              .directions_car_filled_outlined,
          size: 75,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

// ==========================================================
// SECTION CARD
// ==========================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w700,
              color:
              Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ==========================================================
// DETAIL ROW
// ==========================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color:
              Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.right,
            style: TextStyle(
              color:
              valueColor ??
                  const Color(
                    0xFF111827,
                  ),
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// SCHEDULE ROW
// ==========================================================

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String time;

  const _ScheduleRow({
    required this.icon,
    required this.title,
    required this.date,
    required this.time,
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
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color:
            const Color(0xFFEFF6FF),
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color:
            const Color(0xFF2563EB),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(
                  color:
                  Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                date,
                style:
                const TextStyle(
                  color:
                  Color(0xFF111827),
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                time,
                style:
                const TextStyle(
                  color:
                  Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// PRICE ROW
// ==========================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal
                  ? const Color(
                0xFF111827,
              )
                  : const Color(
                0xFF64748B,
              ),
              fontSize:
              isTotal ? 15 : 13,
              fontWeight: isTotal
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
            const Color(0xFF111827),
            fontSize:
            isTotal ? 18 : 14,
            fontWeight: isTotal
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// STATUS MESSAGE
// ==========================================================

class _StatusMessage
    extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusMessage({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        top: 18,
      ),
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ERROR VIEW
// ==========================================================

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
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 65,
              color:
              Color(0xFFDC2626),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load booking',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w700,
                color:
                Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              error.toString(),
              textAlign:
              TextAlign.center,
              maxLines: 4,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                color:
                Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}