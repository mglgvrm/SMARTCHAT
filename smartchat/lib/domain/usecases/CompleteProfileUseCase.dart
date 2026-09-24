import 'package:smartchat/data/repositories/AuthRepository.dart';
import 'package:smartchat/domain/entities/User.dart';

class CompleteProfileUseCase {

  final AuthRepository repository;

  CompleteProfileUseCase(
      this.repository,
      );

  Future<User> call({
    required String username,
    required String fullName,
    required String birthDate,
  }) {

    return repository.completeProfile(
      username: username,
      fullName: fullName,
      birthDate: birthDate,
    );
  }
}