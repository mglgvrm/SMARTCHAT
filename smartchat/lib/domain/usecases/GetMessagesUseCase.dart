
import 'package:smartchat/data/models/MessageResponse.dart';
import 'package:smartchat/domain/repositories/ChatRepository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<MessageResponse>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}