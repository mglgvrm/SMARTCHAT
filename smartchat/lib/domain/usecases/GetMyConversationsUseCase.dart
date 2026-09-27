import 'package:smartchat/data/models/ConversationResponse.dart';
import 'package:smartchat/domain/repositories/ChatRepository.dart';



class GetMyConversationsUseCase {
  final ChatRepository repository;

  GetMyConversationsUseCase(this.repository);

  Future<List<ConversationResponse>> call() {
    return repository.getMyConversations();
  }
}