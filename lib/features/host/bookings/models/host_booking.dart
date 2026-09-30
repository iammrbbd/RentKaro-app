class HostBooking {
  final int id;
  final String bookingReference;
  final int userId;
  final int vehicleId;

  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleType;
  final String? vehicleCategory;
  final String? registrationNumber;
  final String? city;
  final String? area;

  final DateTime startTime;
  final DateTime endTime;
  final double durationHours;

  final double baseAmount;
  final double securityDeposit;
  final double platformFee;
  final double totalAmount;

  final String status;
  final DateTime createdAt;

  const HostBooking({
    required this.id,
    required this.bookingReference,
    required this.userId,
    required this.vehicleId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleType,
    required this.vehicleCategory,
    required this.registrationNumber,
    required this.city,
    required this.area,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.baseAmount,
    required this.securityDeposit,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory HostBooking.fromJson(
      Map<String, dynamic> json,
      ) {
    final vehicle =
    json['vehicle'] is Map
        ? Map<String, dynamic>.from(
      json['vehicle'] as Map,
    )
        : <String, dynamic>{};

    return HostBooking(
      id: (json['id'] as num?)?.toInt() ?? 0,

      bookingReference:
      json['booking_reference']?.toString() ?? '',

      userId:
      (json['user_id'] as num?)?.toInt() ?? 0,

      vehicleId:
      (json['vehicle_id'] as num?)?.toInt() ?? 0,

      vehicleBrand:
      vehicle['brand']?.toString(),

      vehicleModel:
      vehicle['model']?.toString(),

      vehicleType:
      vehicle['vehicle_type']?.toString(),

      vehicleCategory:
      vehicle['category']?.toString(),

      registrationNumber:
      vehicle['registration_number']?.toString(),

      city:
      vehicle['city']?.toString(),

      area:
      vehicle['area']?.toString(),

      startTime:
      DateTime.tryParse(
        json['start_time']?.toString() ?? '',
      ) ??
          DateTime.now(),

      endTime:
      DateTime.tryParse(
        json['end_time']?.toString() ?? '',
      ) ??
          DateTime.now(),

      durationHours:
      (json['duration_hours'] as num?)
          ?.toDouble() ??
          0,

      baseAmount:
      (json['base_amount'] as num?)
          ?.toDouble() ??
          0,

      securityDeposit:
      (json['security_deposit'] as num?)
          ?.toDouble() ??
          0,

      platformFee:
      (json['platform_fee'] as num?)
          ?.toDouble() ??
          0,

      totalAmount:
      (json['total_amount'] as num?)
          ?.toDouble() ??
          0,

      status:
      json['status']?.toString() ?? 'pending',

      createdAt:
      DateTime.tryParse(
        json['created_at']?.toString() ?? '',
      ) ??
          DateTime.now(),
    );
  }

  String get vehicleName {
    final brand =
        vehicleBrand?.trim() ?? '';

    final model =
        vehicleModel?.trim() ?? '';

    final name =
    '$brand $model'.trim();

    return name.isEmpty
        ? 'Vehicle'
        : name;
  }

  bool get isPending =>
      status.toLowerCase() == 'pending';

  bool get isConfirmed =>
      status.toLowerCase() == 'confirmed';

  bool get isRejected =>
      status.toLowerCase() == 'rejected';

  bool get isCancelled =>
      status.toLowerCase() == 'cancelled';

  bool get isCompleted =>
      status.toLowerCase() == 'completed';
}