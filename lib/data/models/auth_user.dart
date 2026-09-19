class AuthUser {
  final String token;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String tenantId;

  AuthUser({
    required this.token,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthUser(
      token: json['token'] as String,
      userId: user['id'] as String,
      email: user['email'] as String,
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      role: user['role'] as String? ?? '',
      tenantId: user['tenantId'] as String,
    );
  }

  String get displayName => '$firstName $lastName'.trim();
}
