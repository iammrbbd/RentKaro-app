class AuthUser {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final bool isVerified;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
