import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/models/vehicle.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const BookingScreen({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends ConsumerState<BookingScreen> {
  late DateTime pickupDateTime;
  late DateTime returnDateTime;

  bool _checkingAvailability = false;
  bool? _isAvailable;
  String? _availabilityMessage;

  Timer? _availabilityDebounce;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    final nextHour = now.add(
      const Duration(hours: 1),
    );

    pickupDateTime = DateTime(
      nextHour.year,
      nextHour.month,
      nextHour.day,
      nextHour.hour,
      0,
    );

    returnDateTime = pickupDateTime.add(
      const Duration(hours: 24),
    );

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _checkAvailability();
      },
    );
  }

  @override
  void dispose() {
    _availabilityDebounce?.cancel();
    super.dispose();
  }

  // ==========================================================
  // DURATION
  // ==========================================================

  double get durationHours {
    final minutes = returnDateTime
        .difference(pickupDateTime)
        .inMinutes;

    if (minutes <= 0) {
      return 0;
    }

    return minutes / 60;
  }

  // ==========================================================
  // DURATION TEXT
  // ==========================================================

  String get durationText {
    final difference =
    returnDateTime.difference(pickupDateTime);

    if (difference.isNegative ||
        difference.inMinutes <= 0) {
      return 'Invalid duration';
    }

    final days = difference.inDays;

    final remainingHours =
    difference.inHours.remainder(24);

    final minutes =
    difference.inMinutes.remainder(60);

    final parts = <String>[];

    if (days > 0) {
      parts.add(
        '$days ${days == 1 ? 'Day' : 'Days'}',
      );
    }

    if (remainingHours > 0) {
      parts.add(
        '$remainingHours '
            '${remainingHours == 1 ? 'Hour' : 'Hours'}',
      );
    }

    if (minutes > 0) {
      parts.add(
        '$minutes Minutes',
      );
    }

    if (parts.isEmpty) {
      return '0 Hours';
    }

    return parts.join(' ');
  }

  // ==========================================================
  // RENTAL PRICE
  // ==========================================================

  double get rentalPrice {
    final hours = durationHours;

    if (hours <= 0) {
      return 0;
    }

    // Less than 24 hours
    if (hours < 24) {
      // Exact 12-hour package
      if (hours == 12) {
        return widget.vehicle.price12Hours;
      }

      return widget.vehicle.pricePerHour * hours;
    }

    // 24 hours or more
    final days = hours / 24;

    return widget.vehicle.price24Hours * days;
  }

  // ==========================================================
  // SECURITY DEPOSIT
  // ==========================================================

  double get securityDeposit {
    return widget.vehicle.securityDeposit;
  }

  // ==========================================================
  // PLATFORM FEE
  // ==========================================================

  double get platformFee {
    return double.parse(
      (rentalPrice * 0.05).toStringAsFixed(2),
    );
  }

  // ==========================================================
  // TOTAL PRICE
  // ==========================================================

  double get totalPrice {
    return double.parse(
      (
          rentalPrice +
              platformFee +
              securityDeposit
      ).toStringAsFixed(2),
    );
  }

  // ==========================================================
  // CHECK AVAILABILITY
  // ==========================================================

  Future<void> _checkAvailability({
    bool debounce = false,
  }) async {
    if (widget.vehicle.id <= 0) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAvailable = false;
        _availabilityMessage =
        'Invalid vehicle ID.';
      });

      return;
    }

    if (durationHours <= 0) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAvailable = false;
        _availabilityMessage =
        'Please select a valid rental duration.';
      });

      return;
    }

    if (pickupDateTime.isBefore(
      DateTime.now(),
    )) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAvailable = false;
        _availabilityMessage =
        'Pickup time cannot be in the past.';
      });

      return;
    }

    if (debounce) {
      _availabilityDebounce?.cancel();

      _availabilityDebounce = Timer(
        const Duration(milliseconds: 500),
            () {
          _performAvailabilityCheck();
        },
      );

      return;
    }

    await _performAvailabilityCheck();
  }

  Future<void> _performAvailabilityCheck() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _checkingAvailability = true;
      _isAvailable = null;
      _availabilityMessage = null;
    });

    try {
      final result = await ref
          .read(bookingServiceProvider)
          .checkAvailability(
        vehicleId: widget.vehicle.id,
        startTime: pickupDateTime,
        durationHours: durationHours,
      );

      if (!mounted) {
        return;
      }

      final available =
          result['available'] == true;

      final reason =
      result['reason']?.toString();

      setState(() {
        _isAvailable = available;
        _availabilityMessage =
        available
            ? 'Vehicle is available for the selected time.'
            : (reason ??
            'Vehicle is not available for the selected time.');
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAvailable = null;
        _availabilityMessage =
            _cleanExceptionMessage(
              error,
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _checkingAvailability = false;
        });
      }
    }
  }

  // ==========================================================
  // PICKUP DATE
  // ==========================================================

  Future<void> selectPickupDate() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: pickupDateTime.isBefore(today)
          ? today
          : pickupDateTime,
      firstDate: today,
      lastDate: today.add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      pickupDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickupDateTime.hour,
        pickupDateTime.minute,
      );

      if (!returnDateTime.isAfter(
        pickupDateTime,
      )) {
        returnDateTime = pickupDateTime.add(
          const Duration(hours: 24),
        );
      }
    });

    await _checkAvailability(
      debounce: true,
    );
  }

  // ==========================================================
  // PICKUP TIME
  // ==========================================================

  Future<void> selectPickupTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        pickupDateTime,
      ),
    );

    if (pickedTime == null) {
      return;
    }

    final newPickup = DateTime(
      pickupDateTime.year,
      pickupDateTime.month,
      pickupDateTime.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final now = DateTime.now();

    if (newPickup.isBefore(now)) {
      _showError(
        'Pickup time cannot be in the past.',
      );

      return;
    }

    setState(() {
      pickupDateTime = newPickup;

      if (!returnDateTime.isAfter(
        pickupDateTime,
      )) {
        returnDateTime = pickupDateTime.add(
          const Duration(hours: 24),
        );
      }
    });

    await _checkAvailability(
      debounce: true,
    );
  }

  // ==========================================================
  // RETURN DATE
  // ==========================================================

  Future<void> selectReturnDate() async {
    final pickupDay = DateTime(
      pickupDateTime.year,
      pickupDateTime.month,
      pickupDateTime.day,
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: returnDateTime.isBefore(
        pickupDateTime,
      )
          ? pickupDateTime
          : returnDateTime,
      firstDate: pickupDay,
      lastDate: pickupDay.add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate == null) {
      return;
    }

    final newReturn = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      returnDateTime.hour,
      returnDateTime.minute,
    );

    if (!newReturn.isAfter(
      pickupDateTime,
    )) {
      _showError(
        'Return date and time must be after pickup.',
      );

      return;
    }

    setState(() {
      returnDateTime = newReturn;
    });

    await _checkAvailability(
      debounce: true,
    );
  }

  // ==========================================================
  // RETURN TIME
  // ==========================================================

  Future<void> selectReturnTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        returnDateTime,
      ),
    );

    if (pickedTime == null) {
      return;
    }

    final newReturn = DateTime(
      returnDateTime.year,
      returnDateTime.month,
      returnDateTime.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!newReturn.isAfter(
      pickupDateTime,
    )) {
      _showError(
        'Return time must be after pickup time.',
      );

      return;
    }

    setState(() {
      returnDateTime = newReturn;
    });

    await _checkAvailability(
      debounce: true,
    );
  }

  // ==========================================================
  // QUICK DURATION
  // ==========================================================

  void setQuickDuration(
      int hours,
      ) {
    setState(() {
      returnDateTime = pickupDateTime.add(
        Duration(hours: hours),
      );
    });

    _checkAvailability(
      debounce: true,
    );
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ==========================================================
  // FORMAT TIME
  // ==========================================================

  String formatTime(
      DateTime date,
      ) {
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

  // ==========================================================
  // CREATE BOOKING
  // ==========================================================

  Future<void> createBooking() async {
    final isLoading = ref.read(
      bookingLoadingProvider,
    );

    if (isLoading ||
        _checkingAvailability) {
      return;
    }

    if (widget.vehicle.id <= 0) {
      _showError(
        'Invalid vehicle ID.',
      );

      return;
    }

    if (!returnDateTime.isAfter(
      pickupDateTime,
    )) {
      _showError(
        'Return date and time must be after pickup.',
      );

      return;
    }

    if (pickupDateTime.isBefore(
      DateTime.now(),
    )) {
      _showError(
        'Pickup time cannot be in the past.',
      );

      return;
    }

    if (durationHours <= 0) {
      _showError(
        'Please select a valid rental duration.',
      );

      return;
    }

    // --------------------------------------------------------
    // FRESH AVAILABILITY CHECK
    // --------------------------------------------------------

    setState(() {
      _checkingAvailability = true;
      _isAvailable = null;
      _availabilityMessage = null;
    });

    try {
      final availabilityResult =
      await ref
          .read(bookingServiceProvider)
          .checkAvailability(
        vehicleId: widget.vehicle.id,
        startTime: pickupDateTime,
        durationHours: durationHours,
      );

      final available =
          availabilityResult['available'] == true;

      final reason =
      availabilityResult['reason']
          ?.toString();

      if (!mounted) {
        return;
      }

      setState(() {
        _isAvailable = available;
        _availabilityMessage =
        available
            ? 'Vehicle is available for the selected time.'
            : (reason ??
            'Vehicle is not available for the selected time.');
      });

      if (!available) {
        _showError(
          reason ??
              'Vehicle is already booked for the selected time.',
        );

        return;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanExceptionMessage(error),
      );

      return;
    } finally {
      if (mounted) {
        setState(() {
          _checkingAvailability = false;
        });
      }
    }

    // --------------------------------------------------------
    // START BOOKING
    // --------------------------------------------------------

    if (!mounted) {
      return;
    }

    ref
        .read(
      bookingLoadingProvider.notifier,
    )
        .state = true;

    try {
      final result = await ref
          .read(bookingServiceProvider)
          .createBooking(
        vehicleId: widget.vehicle.id,
        startTime: pickupDateTime,
        durationHours: durationHours,
      );

      if (!mounted) {
        return;
      }

      final booking =
      result['booking'];

      if (booking is! Map) {
        throw Exception(
          'Invalid booking response from server.',
        );
      }

      final bookingReference =
          booking['booking_reference']
              ?.toString() ??
              'N/A';

      final bookingId =
          booking['id']
              ?.toString() ??
              'N/A';

      final status =
          booking['status']
              ?.toString() ??
              'pending';

      final backendTotal =
      _toDouble(
        booking['total_amount'],
      );

      final backendBaseAmount =
      _toDouble(
        booking['base_amount'],
      );

      final backendPlatformFee =
      _toDouble(
        booking['platform_fee'],
      );

      final backendSecurityDeposit =
      _toDouble(
        booking['security_deposit'],
      );

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 30,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Booking Created',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            content:
            SingleChildScrollView(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your vehicle booking has been created successfully.',
                    style: TextStyle(
                      color:
                      Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _BookingInfoRow(
                    title: 'Booking ID',
                    value: bookingId,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Reference',
                    value:
                    bookingReference,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Vehicle',
                    value:
                    widget.vehicle.name,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Pickup',
                    value:
                    '${formatDate(pickupDateTime)}\n'
                        '${formatTime(pickupDateTime)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Return',
                    value:
                    '${formatDate(returnDateTime)}\n'
                        '${formatTime(returnDateTime)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Duration',
                    value: durationText,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Rental',
                    value:
                    '₹${backendBaseAmount.toStringAsFixed(0)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Platform fee',
                    value:
                    '₹${backendPlatformFee.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title:
                    'Security deposit',
                    value:
                    '₹${backendSecurityDeposit.toStringAsFixed(0)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Total',
                    value:
                    '₹${backendTotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _BookingInfoRow(
                    title: 'Status',
                    value:
                    status.toUpperCase(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop();

                  Navigator.of(
                    this.context,
                  ).pop();
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanExceptionMessage(error),
      );
    } finally {
      if (mounted) {
        ref
            .read(
          bookingLoadingProvider
              .notifier,
        )
            .state = false;
      }
    }
  }

  // ==========================================================
  // CLEAN ERROR MESSAGE
  // ==========================================================

  String _cleanExceptionMessage(
      Object error,
      ) {
    final message =
    error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // SAFE DOUBLE
  // ==========================================================

  double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final isLoading = ref.watch(
      bookingLoadingProvider,
    );

    final interactionDisabled =
        isLoading ||
            _checkingAvailability;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF7F8FA),
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
        title: const Text(
          'Book Vehicle',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          120,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==================================================
            // VEHICLE
            // ==================================================

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color:
                  const Color(
                    0xFFE5E7EB,
                  ),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                    child:
                    Image.network(
                      widget.vehicle.imageUrl,
                      height: 85,
                      width: 105,
                      fit: BoxFit.cover,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          height: 85,
                          width: 105,
                          color:
                          const Color(
                            0xFFE5E7EB,
                          ),
                          child:
                          const Icon(
                            Icons
                                .directions_car,
                            size: 40,
                            color:
                            Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          widget.vehicle.name,
                          style:
                          const TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.vehicle
                              .location,
                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF6B7280,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // PICKUP
            // ==================================================

            const Text(
              'Pickup',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            _DateTimeSelectionCard(
              icon:
              Icons.calendar_month_outlined,
              title: 'Pickup date',
              value:
              formatDate(
                pickupDateTime,
              ),
              onTap:
              interactionDisabled
                  ? null
                  : selectPickupDate,
            ),

            const SizedBox(
              height: 10,
            ),

            _DateTimeSelectionCard(
              icon:
              Icons.access_time_rounded,
              title: 'Pickup time',
              value:
              formatTime(
                pickupDateTime,
              ),
              onTap:
              interactionDisabled
                  ? null
                  : selectPickupTime,
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // RETURN
            // ==================================================

            const Text(
              'Return',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            _DateTimeSelectionCard(
              icon:
              Icons.calendar_month_outlined,
              title: 'Return date',
              value:
              formatDate(
                returnDateTime,
              ),
              onTap:
              interactionDisabled
                  ? null
                  : selectReturnDate,
            ),

            const SizedBox(
              height: 10,
            ),

            _DateTimeSelectionCard(
              icon:
              Icons.access_time_rounded,
              title: 'Return time',
              value:
              formatTime(
                returnDateTime,
              ),
              onTap:
              interactionDisabled
                  ? null
                  : selectReturnTime,
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // QUICK DURATION
            // ==================================================

            const Text(
              'Quick duration',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickDurationButton(
                  title: '1 Hour',
                  hours: 1,
                  onTap:
                  interactionDisabled
                      ? null
                      : setQuickDuration,
                ),
                _QuickDurationButton(
                  title: '12 Hours',
                  hours: 12,
                  onTap:
                  interactionDisabled
                      ? null
                      : setQuickDuration,
                ),
                _QuickDurationButton(
                  title: '1 Day',
                  hours: 24,
                  onTap:
                  interactionDisabled
                      ? null
                      : setQuickDuration,
                ),
                _QuickDurationButton(
                  title: '2 Days',
                  hours: 48,
                  onTap:
                  interactionDisabled
                      ? null
                      : setQuickDuration,
                ),
                _QuickDurationButton(
                  title: '7 Days',
                  hours: 168,
                  onTap:
                  interactionDisabled
                      ? null
                      : setQuickDuration,
                ),
                _QuickDurationButton(
                  title: '30 Days',
                  hours: 720,
                  onTap:
                  interactionDisabled
                      ? null
                      : setQuickDuration,
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // AVAILABILITY
            // ==================================================

            _AvailabilityCard(
              isChecking:
              _checkingAvailability,
              isAvailable:
              _isAvailable,
              message:
              _availabilityMessage,
              onRetry:
              _checkingAvailability
                  ? null
                  : () {
                _checkAvailability();
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // DURATION SUMMARY
            // ==================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(16),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFEFF6FF,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color:
                  const Color(
                    0xFFBFDBFE,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color:
                    Color(0xFF1565C0),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        const Text(
                          'Rental duration',
                          style:
                          TextStyle(
                            color:
                            Color(
                              0xFF6B7280,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          durationText,
                          style:
                          const TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight
                                .bold,
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
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // PRICE SUMMARY
            // ==================================================

            const Text(
              'Price summary',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              padding:
              const EdgeInsets.all(18),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color:
                  const Color(
                    0xFFE5E7EB,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _PriceRow(
                    title: 'Rental',
                    value:
                    '₹${rentalPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _PriceRow(
                    title:
                    'Platform fee (5%)',
                    value:
                    '₹${platformFee.toStringAsFixed(2)}',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _PriceRow(
                    title:
                    'Security deposit',
                    value:
                    '₹${securityDeposit.toStringAsFixed(2)}',
                  ),
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  _PriceRow(
                    title: 'Total',
                    value:
                    '₹${totalPrice.toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // INFO
            // ==================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(14),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFFFFBEB,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color:
                  const Color(
                    0xFFFDE68A,
                  ),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .info_outline_rounded,
                    color:
                    Color(0xFFB45309),
                    size: 21,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      'Security deposit is refundable subject to the vehicle rental terms and vehicle condition.',
                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF92400E,
                        ),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BOOK BUTTON
      // ========================================================

      bottomNavigationBar:
      SafeArea(
        child: Container(
          padding:
          const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            height: 54,
            child:
            ElevatedButton(
              onPressed:
              isLoading ||
                  _checkingAvailability ||
                  _isAvailable != true
                  ? null
                  : createBooking,
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFF1565C0,
                ),
                foregroundColor:
                Colors.white,
                disabledBackgroundColor:
                const Color(
                  0xFF93B4D7,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                  Colors.white,
                ),
              )
                  : _checkingAvailability
                  ? const Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Checking availability...',
                    style:
                    TextStyle(
                      fontSize:
                      15,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ],
              )
                  : Text(
                _isAvailable == true
                    ? 'Continue • ₹${totalPrice.toStringAsFixed(2)}'
                    : 'Vehicle Unavailable',
                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AVAILABILITY CARD
// ============================================================

class _AvailabilityCard
    extends StatelessWidget {
  final bool isChecking;
  final bool? isAvailable;
  final String? message;
  final VoidCallback? onRetry;

  const _AvailabilityCard({
    required this.isChecking,
    required this.isAvailable,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    if (isChecking) {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color:
            const Color(0xFFE5E7EB),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                'Checking vehicle availability...',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isAvailable == true) {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
          const Color(0xFFECFDF5),
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color:
            const Color(0xFFA7F3D0),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color:
              Color(0xFF059669),
              size: 25,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                message ??
                    'Vehicle is available for the selected time.',
                style:
                const TextStyle(
                  color:
                  Color(0xFF065F46),
                  fontWeight:
                  FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isAvailable == false) {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
          const Color(0xFFFEF2F2),
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color:
            const Color(0xFFFECACA),
          ),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.cancel_rounded,
              color:
              Color(0xFFDC2626),
              size: 25,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                message ??
                    'Vehicle is not available for the selected time.',
                style:
                const TextStyle(
                  color:
                  Color(0xFF991B1B),
                  fontWeight:
                  FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color:
          const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color:
            Color(0xFF6B7280),
            size: 24,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              message ??
                  'Select your rental time to check availability.',
              style:
              const TextStyle(
                color:
                Color(0xFF4B5563),
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// DATE TIME SELECTION CARD
// ============================================================

class _DateTimeSelectionCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _DateTimeSelectionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(15),
      child: Container(
        padding:
        const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(15),
          border: Border.all(
            color:
            const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFEFF6FF,
                ),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child: Icon(
                icon,
                color:
                const Color(
                  0xFF1565C0,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
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
                      fontWeight:
                      FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUICK DURATION BUTTON
// ============================================================

class _QuickDurationButton
    extends StatelessWidget {
  final String title;
  final int hours;

  final void Function(
      int hours,
      )? onTap;

  const _QuickDurationButton({
    required this.title,
    required this.hours,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return OutlinedButton(
      onPressed: onTap == null
          ? null
          : () {
        onTap!(hours);
      },
      style:
      OutlinedButton.styleFrom(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        side: const BorderSide(
          color:
          Color(0xFFBFDBFE),
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
      child: Text(title),
    );
  }
}

// ============================================================
// PRICE ROW
// ============================================================

class _PriceRow
    extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _PriceRow({
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
              color: bold
                  ? const Color(
                0xFF111827,
              )
                  : const Color(
                0xFF6B7280,
              ),
              fontWeight: bold
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:
            bold ? 18 : 14,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BOOKING INFO ROW
// ============================================================

class _BookingInfoRow
    extends StatelessWidget {
  final String title;
  final String value;

  const _BookingInfoRow({
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
        SizedBox(
          width: 110,
          child: Text(
            title,
            style:
            const TextStyle(
              color:
              Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}