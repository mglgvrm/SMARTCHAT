import 'package:smartchat/data/repositories/AuthRepository.dart';
import 'package:smartchat/domain/entities/AuthUser.dart';

class LocalLoginUseCase {

  final AuthRepository
  repository;

  LocalLoginUseCase(
      this.repository);

  Future<AuthUser> call({
    required String email,
    required String password,
}) {

    return repository
        .loginWithLocal(
        email: email,
        password: password
    );
  }
}