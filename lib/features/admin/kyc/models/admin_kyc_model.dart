class AdminKycModel {
  final int id;
  final int userId;

  final String userName;
  final String userPhone;
  final String? userEmail;

  final String fullName;
  final DateTime? dateOfBirth;
  final String address;

  final String aadhaarLast4;

  final String drivingLicenseNumber;
  final DateTime? drivingLicenseExpiry;

  final String verificationStatus;
  final String? rejectionReason;

  final bool hasAadhaarDocument;
  final bool hasDrivingLicenseDocument;

  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminKycModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
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
  // SAFE STRING
  // ============================================================

  static String _string(
      dynamic value, {
        String fallback = '',
      }) {
    if (value == null) {
      return fallback;
    }

    return value.toString();
  }

  // ============================================================
  // SAFE INT
  // ============================================================

  static int _int(
      dynamic value, {
        int fallback = 0,
      }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        fallback;
  }

  // ============================================================
  // SAFE BOOL
  // ============================================================

  static bool _bool(
      dynamic value, {
        bool fallback = false,
      }) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized =
      value.trim().toLowerCase();

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

    return fallback;
  }

  // ============================================================
  // SAFE DATE
  // ============================================================

  static DateTime? _date(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    final text =
    value.toString().trim();

    if (text.isEmpty ||
        text == 'null') {
      return null;
    }

    return DateTime.tryParse(
      text,
    );
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory AdminKycModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminKycModel(

      // ========================================================
      // BASIC
      // ========================================================

      id: _int(
        json['id'],
      ),

      userId: _int(
        json['user_id'],
      ),

      // ========================================================
      // USER
      // ========================================================

      userName: _string(
        json['user_name'],
      ),

      userPhone: _string(
        json['user_phone'],
      ),

      userEmail:
      json['user_email'] == null
          ? null
          : _string(
        json['user_email'],
      ),

      // ========================================================
      // PERSONAL DETAILS
      // ========================================================

      fullName: _string(
        json['full_name'],
        fallback: 'Not provided',
      ),

      dateOfBirth: _date(
        json['date_of_birth'],
      ),

      address: _string(
        json['address'],
        fallback: 'Not provided',
      ),

      // ========================================================
      // IDENTITY
      // ========================================================

      aadhaarLast4: _string(
        json['aadhaar_last4'],
        fallback: 'Not available',
      ),

      drivingLicenseNumber:
      _string(
        json['driving_license_number'],
        fallback: 'Not available',
      ),

      drivingLicenseExpiry:
      _date(
        json['driving_license_expiry'],
      ),

      // ========================================================
      // VERIFICATION
      // ========================================================

      verificationStatus:
      _string(
        json['verification_status'],
        fallback: 'pending',
      ).trim().toLowerCase(),

      rejectionReason:
      json['rejection_reason'] == null
          ? null
          : _string(
        json['rejection_reason'],
      ),

      // ========================================================
      // DOCUMENTS
      // ========================================================

      hasAadhaarDocument:
      _bool(
        json['has_aadhaar_document'],
      ),

      hasDrivingLicenseDocument:
      _bool(
        json[
        'has_driving_license_document'
        ],
      ),

      // ========================================================
      // TIMESTAMPS
      // ========================================================

      submittedAt: _date(
        json['submitted_at'],
      ),

      reviewedAt: _date(
        json['reviewed_at'],
      ),

      createdAt: _date(
        json['created_at'],
      ),

      updatedAt: _date(
        json['updated_at'],
      ),
    );
  }
}