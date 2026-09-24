import 'package:smartchat/data/repositories/AuthRepository.dart';
import 'package:smartchat/domain/entities/AuthUser.dart';

class GoogleLoginUseCase {

  final AuthRepository
  repository;

  GoogleLoginUseCase(
      this.repository);

  Future<AuthUser> call() {

    return repository
        .loginWithGoogle();
  }
}