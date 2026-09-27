import 'package:smartchat/data/models/MessageResponse.dart';
import 'package:smartchat/domain/repositories/ChatRepository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<MessageResponse> call({
    required String conversationId,
    required String content,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }
}