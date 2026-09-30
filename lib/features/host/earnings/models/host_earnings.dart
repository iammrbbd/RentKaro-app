class HostEarningTransaction {
  final int bookingId;
  final String bookingReference;
  final int vehicleId;
  final String vehicleName;
  final double baseAmount;
  final double platformFee;
  final double totalAmount;
  final double earnedAmount;
  final String status;
  final DateTime completedAt;

  const HostEarningTransaction({
    required this.bookingId,
    required this.bookingReference,
    required this.vehicleId,
    required this.vehicleName,
    required this.baseAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.earnedAmount,
    required this.status,
    required this.completedAt,
  });

  factory HostEarningTransaction.fromJson(
      Map<String, dynamic> json,
      ) {
    return HostEarningTransaction(
      bookingId:
      (json['booking_id'] as num?)?.toInt() ?? 0,
      bookingReference:
      json['booking_reference']?.toString() ?? '',
      vehicleId:
      (json['vehicle_id'] as num?)?.toInt() ?? 0,
      vehicleName:
      json['vehicle_name']?.toString() ?? 'Vehicle',
      baseAmount:
      (json['base_amount'] as num?)?.toDouble() ?? 0,
      platformFee:
      (json['platform_fee'] as num?)?.toDouble() ?? 0,
      totalAmount:
      (json['total_amount'] as num?)?.toDouble() ?? 0,
      earnedAmount:
      (json['earned_amount'] as num?)?.toDouble() ?? 0,
      status:
      json['status']?.toString() ?? 'completed',
      completedAt:
      DateTime.tryParse(
        json['completed_at']?.toString() ?? '',
      ) ??
          DateTime.now(),
    );
  }
}


class HostEarnings {
  final double totalEarned;
  final double thisMonth;
  final int completedTrips;
  final double availableBalance;
  final List<HostEarningTransaction> bookings;

  const HostEarnings({
    required this.totalEarned,
    required this.thisMonth,
    required this.completedTrips,
    required this.availableBalance,
    required this.bookings,
  });

  factory HostEarnings.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawBookings = json['bookings'];

    final bookings =
    rawBookings is List
        ? rawBookings
        .whereType<Map>()
        .map(
          (item) =>
          HostEarningTransaction.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList()
        : <HostEarningTransaction>[];

    return HostEarnings(
      totalEarned:
      (json['total_earned'] as num?)?.toDouble() ?? 0,
      thisMonth:
      (json['this_month'] as num?)?.toDouble() ?? 0,
      completedTrips:
      (json['completed_trips'] as num?)?.toInt() ?? 0,
      availableBalance:
      (json['available_balance'] as num?)?.toDouble() ?? 0,
      bookings: bookings,
    );
  }
}