class AdminBooking {
  final int id;
  final String bookingReference;
  final int userId;
  final int vehicleId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String vehicleName;
  final String registrationNumber;
  final String city;
  final String area;
  final DateTime startTime;
  final DateTime endTime;
  final double durationHours;
  final double baseAmount;
  final double securityDeposit;
  final double platformFee;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  const AdminBooking({
    required this.id,
    required this.bookingReference,
    required this.userId,
    required this.vehicleId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.vehicleName,
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

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map
        ? Map<String, dynamic>.from(json['customer'] as Map)
        : <String, dynamic>{};
    final vehicle = json['vehicle'] is Map
        ? Map<String, dynamic>.from(json['vehicle'] as Map)
        : <String, dynamic>{};

    final brand = vehicle['brand']?.toString().trim() ?? '';
    final model = vehicle['model']?.toString().trim() ?? '';

    return AdminBooking(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingReference: json['booking_reference']?.toString() ?? '',
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      vehicleId: (json['vehicle_id'] as num?)?.toInt() ?? 0,
      customerName: customer['name']?.toString() ?? 'Unknown customer',
      customerPhone: customer['phone']?.toString() ?? '',
      customerEmail: customer['email']?.toString() ?? '',
      vehicleName: '$brand $model'.trim().isEmpty ? 'Vehicle' : '$brand $model'.trim(),
      registrationNumber: vehicle['registration_number']?.toString() ?? '',
      city: vehicle['city']?.toString() ?? '',
      area: vehicle['area']?.toString() ?? '',
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time']?.toString() ?? '') ?? DateTime.now(),
      durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 0,
      baseAmount: (json['base_amount'] as num?)?.toDouble() ?? 0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get normalizedStatus => status.trim().toLowerCase();
}
