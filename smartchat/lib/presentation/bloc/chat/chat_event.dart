part of 'chat_bloc.dart';

abstract class ChatEvent {}

class LoadMyConversationsEvent extends ChatEvent {}

class OpenConversationEvent extends ChatEvent {
  final String otherUserId;

  OpenConversationEvent(this.otherUserId);
}

class LoadMessagesEvent extends ChatEvent {
  final String conversationId;

  LoadMessagesEvent(this.conversationId);
}

class SendMessageEvent extends ChatEvent {
  final String content;

  SendMessageEvent(this.content);
}

class IncomingMessageEvent extends ChatEvent {
  final MessageResponse message;

  IncomingMessageEvent(this.message);
}

class MarkMessageAsReadEvent extends ChatEvent {
  final String messageId;

  MarkMessageAsReadEvent(this.messageId);
}

class OpenExistingConversationEvent extends ChatEvent {
  final ConversationResponse conversation;

  OpenExistingConversationEvent(this.conversation);
}

class CloseConversationEvent extends ChatEvent {}