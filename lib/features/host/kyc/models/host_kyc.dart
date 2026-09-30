class HostKyc {
  final int id;
  final int userId;

  final String? aadhaarNumber;
  final String? panNumber;
  final String? drivingLicenseNumber;

  final String? aadhaarDocument;
  final String? panDocument;
  final String? drivingLicenseDocument;

  final String verificationStatus;
  final String? rejectionReason;

  final DateTime createdAt;
  final DateTime updatedAt;

  const HostKyc({
    required this.id,
    required this.userId,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.drivingLicenseNumber,
    required this.aadhaarDocument,
    required this.panDocument,
    required this.drivingLicenseDocument,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HostKyc.fromJson(Map<String, dynamic> json) {
    return HostKyc(
      id: json["id"],
      userId: json["user_id"],
      aadhaarNumber: json["aadhaar_number"],
      panNumber: json["pan_number"],
      drivingLicenseNumber: json["driving_license_number"],
      aadhaarDocument: json["aadhaar_document"],
      panDocument: json["pan_document"],
      drivingLicenseDocument: json["driving_license_document"],
      verificationStatus: json["verification_status"] ?? "pending",
      rejectionReason: json["rejection_reason"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }

  bool get isPending => verificationStatus == "pending";

  bool get isApproved => verificationStatus == "approved";

  bool get isRejected => verificationStatus == "rejected";
}