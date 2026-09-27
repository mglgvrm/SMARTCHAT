
import 'package:smartchat/data/models/ConversationResponse.dart';
import 'package:smartchat/domain/repositories/ChatRepository.dart';

class GetOrCreateConversationUseCase {
  final ChatRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  Future<ConversationResponse> call(String otherUserId) {
    return repository.getOrCreateConversation(otherUserId);
  }
}