import 'package:smartchat/domain/entities/AuthUser.dart';

class AuthUserModel extends AuthUser {

  AuthUserModel({
    required super.id,
    required super.email,
    required super.token,
    required super.profileCompleted,
    super.role,
  });

  factory AuthUserModel.fromJson(
      Map<String, dynamic> json
      ) {

    return AuthUserModel(
      id: json['userId'],
      email: json['email'] ?? '',
      token: json['token'],
      profileCompleted:
      json['profileCompleted'] ?? false,
      role: json["role"],
    );
  }
}