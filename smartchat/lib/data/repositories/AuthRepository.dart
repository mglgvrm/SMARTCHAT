import 'package:smartchat/data/models/UserModel.dart';
import 'package:smartchat/domain/entities/AuthUser.dart';

abstract class AuthRepository {
  Future<AuthUser> loginWithGoogle();
  Future<AuthUser> loginWithLocal({
    required String email,
    required String password,});
  Future<UserModel> completeProfile({
    required String username,
    required String fullName,
    required String birthDate,
  });

}