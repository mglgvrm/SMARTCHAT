part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ConversationsLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationResponse> conversations;

  ConversationsLoaded(this.conversations);
}

class ChatLoading extends ChatState {}

class ChatReady extends ChatState {
  final ConversationResponse conversation;
  final List<MessageResponse> messages;
  final bool sending;

  ChatReady({
    required this.conversation,
    required this.messages,
    this.sending = false,
  });

  ChatReady copyWith({
    ConversationResponse? conversation,
    List<MessageResponse>? messages,
    bool? sending,
  }) {
    return ChatReady(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}