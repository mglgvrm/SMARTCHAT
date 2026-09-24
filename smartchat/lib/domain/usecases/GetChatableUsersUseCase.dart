import 'package:smartchat/data/models/UserCardResponse.dart';
import 'package:smartchat/domain/repositories/UserRepository.dart';

class GetChatableUsersUseCase {
  final UserRepository userRepository;

  GetChatableUsersUseCase(this.userRepository);

  Future<List<UserCardResponse>> call() async {
    return await userRepository.getChatableUsers();
  }
}
