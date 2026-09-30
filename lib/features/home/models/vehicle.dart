class Vehicle {
  final int id;
  final int ownerId;

  final String name;
  final String brand;
  final String model;

  final String category;
  final String vehicleType;
  final String registrationNumber;
  final String description;

  final double pricePerHour;
  final double price12Hours;
  final double price24Hours;
  final double securityDeposit;

  final String location;
  final String city;
  final String area;

  final int seats;
  final String fuelType;
  final String transmission;

  final String imageUrl;

  final double rating;
  final int reviewCount;
  final int totalTrips;

  final bool isAvailable;
  final bool isVerified;
  final bool isPremium;

  final double? latitude;
  final double? longitude;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.brand,
    required this.model,
    required this.category,
    required this.vehicleType,
    required this.registrationNumber,
    required this.description,
    required this.pricePerHour,
    required this.price12Hours,
    required this.price24Hours,
    required this.securityDeposit,
    required this.location,
    required this.city,
    required this.area,
    required this.seats,
    required this.fuelType,
    required this.transmission,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.totalTrips,
    required this.isAvailable,
    required this.isVerified,
    required this.isPremium,
    required this.latitude,
    required this.longitude,
  });

  factory Vehicle.fromJson(
      Map<String, dynamic> json,
      ) {
    final brand = _toString(
      json['brand'],
    );

    final model = _toString(
      json['model'],
    );

    final apiName = _toString(
      json['name'],
    );

    final resolvedName =
    apiName.isNotEmpty
        ? apiName
        : [
      if (brand.isNotEmpty) brand,
      if (model.isNotEmpty) model,
    ].join(' ').trim();

    return Vehicle(
      id: _toInt(
        json['id'],
      ),

      ownerId: _toInt(
        json['owner_id'] ??
            json['ownerId'],
      ),

      name: resolvedName,

      brand: brand,

      model: model,

      category: _toString(
        json['category'],
      ),

      vehicleType: _toString(
        json['vehicle_type'] ??
            json['vehicleType'],
      ),

      registrationNumber:
      _toString(
        json['registration_number'] ??
            json['registrationNumber'],
      ),

      description: _toString(
        json['description'],
      ),

      // ==========================================================
      // PRICING
      // Backend fields:
      // hourly_price
      // twelve_hour_price
      // daily_price
      // ==========================================================

      pricePerHour: _toDouble(
        json['hourly_price'] ??
            json['price_per_hour'] ??
            json['pricePerHour'],
      ),

      price12Hours: _toDouble(
        json['twelve_hour_price'] ??
            json['price_12_hours'] ??
            json['price12Hours'],
      ),

      price24Hours: _toDouble(
        json['daily_price'] ??
            json['price_24_hours'] ??
            json['price24Hours'],
      ),

      securityDeposit: _toDouble(
        json['security_deposit'] ??
            json['securityDeposit'],
      ),

      // ==========================================================
      // LOCATION
      // ==========================================================

      location: _toString(
        json['location'] ??
            json['address'],
      ),

      city: _toString(
        json['city'],
      ),

      area: _toString(
        json['area'],
      ),

      latitude: _toNullableDouble(
        json['latitude'],
      ),

      longitude: _toNullableDouble(
        json['longitude'],
      ),

      // ==========================================================
      // VEHICLE DETAILS
      // ==========================================================

      seats: _toInt(
        json['seats'],
      ),

      fuelType: _toString(
        json['fuel_type'] ??
            json['fuelType'],
      ),

      transmission: _toString(
        json['transmission'],
      ),

      // ==========================================================
      // IMAGE
      // ==========================================================

      imageUrl: _extractImageUrl(
        json,
      ),

      // ==========================================================
      // REVIEWS / STATS
      // ==========================================================

      rating: _toDouble(
        json['rating'],
      ),

      reviewCount: _toInt(
        json['review_count'] ??
            json['reviewCount'],
      ),

      totalTrips: _toInt(
        json['total_trips'] ??
            json['totalTrips'],
      ),

      // ==========================================================
      // STATUS
      // ==========================================================

      isAvailable: _toBool(
        json['is_available'] ??
            json['isAvailable'],
      ),

      isVerified: _toBool(
        json['is_verified'] ??
            json['isVerified'],
      ),

      // Backend currently does not return is_premium.
      // Keep false as safe default for existing UI.
      isPremium: _toBool(
        json['is_premium'] ??
            json['isPremium'] ??
            false,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,

      'name': name,
      'brand': brand,
      'model': model,

      'category': category,
      'vehicle_type': vehicleType,
      'registration_number':
      registrationNumber,
      'description': description,

      'hourly_price': pricePerHour,
      'twelve_hour_price': price12Hours,
      'daily_price': price24Hours,
      'security_deposit':
      securityDeposit,

      'location': location,
      'city': city,
      'area': area,

      'seats': seats,
      'fuel_type': fuelType,
      'transmission': transmission,

      'image_url': imageUrl,

      'rating': rating,
      'review_count': reviewCount,
      'total_trips': totalTrips,

      'is_available': isAvailable,
      'is_verified': isVerified,
      'is_premium': isPremium,

      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Vehicle copyWith({
    int? id,
    int? ownerId,
    String? name,
    String? brand,
    String? model,
    String? category,
    String? vehicleType,
    String? registrationNumber,
    String? description,
    double? pricePerHour,
    double? price12Hours,
    double? price24Hours,
    double? securityDeposit,
    String? location,
    String? city,
    String? area,
    int? seats,
    String? fuelType,
    String? transmission,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    int? totalTrips,
    bool? isAvailable,
    bool? isVerified,
    bool? isPremium,
    double? latitude,
    double? longitude,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId:
      ownerId ?? this.ownerId,

      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,

      category:
      category ?? this.category,

      vehicleType:
      vehicleType ?? this.vehicleType,

      registrationNumber:
      registrationNumber ??
          this.registrationNumber,

      description:
      description ??
          this.description,

      pricePerHour:
      pricePerHour ??
          this.pricePerHour,

      price12Hours:
      price12Hours ??
          this.price12Hours,

      price24Hours:
      price24Hours ??
          this.price24Hours,

      securityDeposit:
      securityDeposit ??
          this.securityDeposit,

      location:
      location ?? this.location,

      city: city ?? this.city,

      area: area ?? this.area,

      seats: seats ?? this.seats,

      fuelType:
      fuelType ?? this.fuelType,

      transmission:
      transmission ?? this.transmission,

      imageUrl:
      imageUrl ?? this.imageUrl,

      rating:
      rating ?? this.rating,

      reviewCount:
      reviewCount ??
          this.reviewCount,

      totalTrips:
      totalTrips ??
          this.totalTrips,

      isAvailable:
      isAvailable ??
          this.isAvailable,

      isVerified:
      isVerified ??
          this.isVerified,

      isPremium:
      isPremium ??
          this.isPremium,

      latitude:
      latitude ?? this.latitude,

      longitude:
      longitude ?? this.longitude,
    );
  }

  // ============================================================
  // IMAGE URL RESOLVER
  // ============================================================

  static String _extractImageUrl(
      Map<String, dynamic> json,
      ) {
    final dynamic imageUrl =
    json['image_url'];

    if (imageUrl is String &&
        imageUrl.trim().isNotEmpty &&
        _isHttpUrl(
          imageUrl.trim(),
        )) {
      return imageUrl.trim();
    }

    final dynamic imageUrlCamel =
    json['imageUrl'];

    if (imageUrlCamel is String &&
        imageUrlCamel.trim().isNotEmpty &&
        _isHttpUrl(
          imageUrlCamel.trim(),
        )) {
      return imageUrlCamel.trim();
    }

    final dynamic images =
    json['images'];

    if (images is List) {
      for (final dynamic image
      in images) {
        if (image is String &&
            image.trim().isNotEmpty &&
            _isHttpUrl(
              image.trim(),
            )) {
          return image.trim();
        }

        if (image
        is Map<String, dynamic>) {
          final dynamic url =
              image['url'] ??
                  image['image_url'] ??
                  image['imageUrl'];

          if (url is String &&
              url.trim().isNotEmpty &&
              _isHttpUrl(
                url.trim(),
              )) {
            return url.trim();
          }
        }
      }
    }

    return '';
  }

  static bool _isHttpUrl(
      String value,
      ) {
    return value.startsWith(
      'http://',
    ) ||
        value.startsWith(
          'https://',
        );
  }

  // ============================================================
  // STRING
  // ============================================================

  static String _toString(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  // ============================================================
  // INTEGER
  // ============================================================

  static int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
        value,
      ) ??
          0;
    }

    return 0;
  }

  // ============================================================
  // DOUBLE
  // ============================================================

  static double _toDouble(
      dynamic value,
      ) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.trim(),
      ) ??
          0.0;
    }

    return 0.0;
  }

  // ============================================================
  // NULLABLE DOUBLE
  // ============================================================

  static double? _toNullableDouble(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.trim(),
      );
    }

    return null;
  }

  // ============================================================
  // BOOLEAN
  // ============================================================

  static bool _toBool(
      dynamic value,
      ) {
    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value != 0;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized =
      value
          .toLowerCase()
          .trim();

      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes') {
        return true;
      }

      if (normalized == 'false' ||
          normalized == '0' ||
          normalized == 'no') {
        return false;
      }
    }

    return false;
  }
}