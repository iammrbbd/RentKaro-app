class AdminVehicle {
  final int id;
  final int ownerId;
  final String brand;
  final String model;
  final String vehicleType;
  final String category;
  final String registrationNumber;
  final String? description;
  final double hourlyPrice;
  final double? twelveHourPrice;
  final double dailyPrice;
  final double securityDeposit;
  final String city;
  final String area;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final int? seats;
  final String? fuelType;
  final String? transmission;
  final bool isAvailable;
  final bool isVerified;

  const AdminVehicle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.vehicleType,
    required this.category,
    required this.registrationNumber,
    required this.description,
    required this.hourlyPrice,
    required this.twelveHourPrice,
    required this.dailyPrice,
    required this.securityDeposit,
    required this.city,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.seats,
    required this.fuelType,
    required this.transmission,
    required this.isAvailable,
    required this.isVerified,
  });

  factory AdminVehicle.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminVehicle(
      id: (json['id'] as num).toInt(),
      ownerId: (json['owner_id'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      registrationNumber:
      json['registration_number']?.toString() ?? '',
      description: json['description']?.toString(),
      hourlyPrice:
      (json['hourly_price'] as num?)?.toDouble() ?? 0,
      twelveHourPrice:
      (json['twelve_hour_price'] as num?)?.toDouble(),
      dailyPrice:
      (json['daily_price'] as num?)?.toDouble() ?? 0,
      securityDeposit:
      (json['security_deposit'] as num?)?.toDouble() ?? 0,
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      latitude:
      (json['latitude'] as num?)?.toDouble(),
      longitude:
      (json['longitude'] as num?)?.toDouble(),
      images: json['images'] is List
          ? (json['images'] as List)
          .map((image) => image.toString())
          .toList()
          : <String>[],
      seats: (json['seats'] as num?)?.toInt(),
      fuelType: json['fuel_type']?.toString(),
      transmission:
      json['transmission']?.toString(),
      isAvailable:
      json['is_available'] as bool? ?? true,
      isVerified:
      json['is_verified'] as bool? ?? false,
    );
  }

  String get fullName => '$brand $model';

  String get approvalStatus {
    return isVerified ? 'Approved' : 'Pending Approval';
  }
}