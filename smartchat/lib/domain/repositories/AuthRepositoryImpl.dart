import 'package:smartchat/data/datasource/AuthRemoteDataSource.dart';
import 'package:smartchat/data/models/UserModel.dart';
import 'package:smartchat/data/repositories/AuthRepository.dart';
import 'package:smartchat/domain/entities/AuthUser.dart';

class AuthRepositoryImpl implements AuthRepository{

  final AuthRemoteDataSource
  remoteDataSource;

  AuthRepositoryImpl(
      this.remoteDataSource);

  @override
  Future<AuthUser>
  loginWithGoogle() {

    return remoteDataSource
        .loginWithGoogle();
  }
  @override
  Future<AuthUser> loginWithLocal({
    required String email,
    required String password,
}) {
    return remoteDataSource.loginWithLocal(
        email: email, password: password
    );
  }
  @override
  Future<UserModel> completeProfile({
    required String username,
    required String fullName,
    required String birthDate,
  }) {

    return remoteDataSource.completeProfile(
      username: username,
      fullName: fullName,
      birthDate: birthDate,
    );
  }


}