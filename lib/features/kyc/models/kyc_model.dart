class KycModel {
  final int id;
  final int userId;

  final String fullName;
  final DateTime dateOfBirth;
  final String address;

  final String aadhaarLast4;

  final String drivingLicenseNumber;
  final DateTime drivingLicenseExpiry;

  final String verificationStatus;
  final String? rejectionReason;

  final bool hasAadhaarDocument;
  final bool hasDrivingLicenseDocument;

  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const KycModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.address,
    required this.aadhaarLast4,
    required this.drivingLicenseNumber,
    required this.drivingLicenseExpiry,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.hasAadhaarDocument,
    required this.hasDrivingLicenseDocument,
    required this.submittedAt,
    required this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory KycModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return KycModel(
      id: _parseInt(
        json['id'],
      ),

      userId: _parseInt(
        json['user_id'],
      ),

      fullName: _parseString(
        json['full_name'],
      ),

      dateOfBirth:
      _parseDate(
        json['date_of_birth'],
      ),

      address: _parseString(
        json['address'],
      ),

      aadhaarLast4:
      _parseString(
        json['aadhaar_last4'],
      ),

      drivingLicenseNumber:
      _parseString(
        json['driving_license_number'],
      ),

      drivingLicenseExpiry:
      _parseDate(
        json['driving_license_expiry'],
      ),

      verificationStatus:
      _parseString(
        json['verification_status'],
        fallback: 'pending',
      ).toLowerCase(),

      rejectionReason:
      _parseNullableString(
        json['rejection_reason'],
      ),

      hasAadhaarDocument:
      _parseBool(
        json['has_aadhaar_document'],
      ),

      hasDrivingLicenseDocument:
      _parseBool(
        json[
        'has_driving_license_document'
        ],
      ),

      submittedAt:
      _parseNullableDate(
        json['submitted_at'],
      ),

      reviewedAt:
      _parseNullableDate(
        json['reviewed_at'],
      ),

      createdAt:
      _parseDate(
        json['created_at'],
      ),

      updatedAt:
      _parseDate(
        json['updated_at'],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int _parseInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
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

  static String _parseString(
      dynamic value, {
        String fallback = '',
      }) {
    if (value == null) {
      return fallback;
    }

    if (value is String) {
      return value;
    }

    return value.toString();
  }

  static String? _parseNullableString(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final stringValue =
    value.toString().trim();

    if (stringValue.isEmpty) {
      return null;
    }

    return stringValue;
  }

  static bool _parseBool(
      dynamic value,
      ) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized =
      value.toLowerCase().trim();

      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes';
    }

    return false;
  }

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed =
      DateTime.tryParse(
        value,
      );

      if (parsed != null) {
        return parsed;
      }
    }

    // This prevents the entire KYC
    // screen from crashing if backend
    // sends an unexpected date.
    return DateTime(2000, 1, 1);
  }

  static DateTime? _parseNullableDate(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(
        value,
      );
    }

    return null;
  }
}