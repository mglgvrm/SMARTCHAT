class User {

  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final bool profileCompleted;
  final String? role;

  User({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    required this.profileCompleted,
    this.role
  });

  
}