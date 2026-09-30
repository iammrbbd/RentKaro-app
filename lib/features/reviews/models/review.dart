class Review {
  final int id;
  final int userId;
  final String userName;
  final int vehicleId;
  final int bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.vehicleId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      userName: _toString(json['user_name']),
      vehicleId: _toInt(json['vehicle_id']),
      bookingId: _toInt(json['booking_id']),
      rating: _toInt(json['rating']),
      comment: _nullableString(json['comment']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static String _toString(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    if (valueString.isEmpty) {
      return null;
    }

    return valueString;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value?.toString() ?? '',
    ) ??
        DateTime.now();
  }
}


class VehicleReviews {
  final int vehicleId;
  final double averageRating;
  final int reviewCount;
  final List<Review> reviews;

  const VehicleReviews({
    required this.vehicleId,
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
  });

  factory VehicleReviews.fromJson(
      Map<String, dynamic> json,
      ) {
    final reviewsData = json['reviews'];

    return VehicleReviews(
      vehicleId: _toInt(json['vehicle_id']),
      averageRating: _toDouble(
        json['average_rating'],
      ),
      reviewCount: _toInt(
        json['review_count'],
      ),
      reviews: reviewsData is List
          ? reviewsData
          .map(
            (item) => Review.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        ),
      )
          .toList()
          : [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }
}