import 'package:smartchat/data/models/AuthUserModel.dart';
import 'package:smartchat/data/models/UserModel.dart';

abstract class AuthRemoteDataSource {

  Future<AuthUserModel>
  loginWithGoogle();
  Future<AuthUserModel>
  loginWithLocal({
    required String email,
    required String password,
});

  Future<UserModel> completeProfile({
    required String username,
    required String fullName,
    required String birthDate,
  });
}