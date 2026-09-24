class AuthUser {

  final String id;
  final String email;
  final String token;
  final bool profileCompleted;
  final String? role;

  AuthUser({
    required this.id,
    required this.email,
    required this.token,
    required this.profileCompleted,
    this.role
  });

}