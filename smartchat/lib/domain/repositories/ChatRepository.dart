

import 'package:smartchat/data/models/ConversationResponse.dart';
import 'package:smartchat/data/models/MessageResponse.dart';

abstract class ChatRepository {
  Future<ConversationResponse> getOrCreateConversation(
      String otherUserId,
      );

  Future<List<ConversationResponse>> getMyConversations();

  Future<List<MessageResponse>> getMessages(
      String conversationId,
      );

  Future<MessageResponse> sendMessage({
    required String conversationId,
    required String content,
  });

  Future<MessageResponse> markAsRead({
    required String conversationId,
    required String messageId,
  });

  Future<void> connectToConversation({
    required String conversationId,
    required void Function(MessageResponse message) onMessage,
    required void Function(String error) onError,
  });

  Future<void> disconnectFromConversation();
}