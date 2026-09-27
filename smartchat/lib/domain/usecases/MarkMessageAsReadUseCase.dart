import 'package:smartchat/data/models/MessageResponse.dart';
import 'package:smartchat/domain/repositories/ChatRepository.dart';

class MarkMessageAsReadUseCase {
  final ChatRepository repository;

  MarkMessageAsReadUseCase(this.repository);

  Future<MessageResponse> call({
    required String conversationId,
    required String messageId,
  }) {
    return repository.markAsRead(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}