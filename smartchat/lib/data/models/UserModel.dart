

import 'package:smartchat/domain/entities/User.dart';

class UserModel extends User {

  UserModel({
    required super.id,
    required super.email,
    super.username,
    super.fullName,
    required super.profileCompleted,
    super.role,
  });

  factory UserModel.fromJson(
      Map<String,dynamic> json) {

    return UserModel(
      id: json["userId"] ?? "",
      email: json["email"] ?? "",
      username: json["username"],
      fullName: json["fullName"],
      profileCompleted:
      json["profileCompleted"] ?? false,
      role: json["role"],
    );
  }
}