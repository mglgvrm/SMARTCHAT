import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/data/models/ConversationResponse.dart';
import 'package:smartchat/data/models/MessageResponse.dart';
import 'package:smartchat/domain/repositories/ChatRepository.dart';
import 'package:smartchat/domain/usecases/GetMessagesUseCase.dart';
import 'package:smartchat/domain/usecases/GetMyConversationsUseCase.dart';
import 'package:smartchat/domain/usecases/GetOrCreateConversationUseCase.dart';
import 'package:smartchat/domain/usecases/MarkMessageAsReadUseCase.dart';
import 'package:smartchat/domain/usecases/SendMessageUseCase.dart';



part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final GetOrCreateConversationUseCase getOrCreateConversationUseCase;
  final GetMyConversationsUseCase getMyConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkMessageAsReadUseCase markMessageAsReadUseCase;

  ConversationResponse? _currentConversation;
  List<MessageResponse> _currentMessages = [];

  ChatBloc({
    required this.repository,
    required this.getOrCreateConversationUseCase,
    required this.getMyConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markMessageAsReadUseCase,
  }) : super(ChatInitial()) {
    on<LoadMyConversationsEvent>(_loadMyConversations);
    on<OpenConversationEvent>(_openConversation);
    on<LoadMessagesEvent>(_loadMessages);
    on<SendMessageEvent>(_sendMessage);
    on<IncomingMessageEvent>(_onIncomingMessage);
    on<MarkMessageAsReadEvent>(_markMessageAsRead);
    on<CloseConversationEvent>(_closeConversation);
    on<_WebSocketErrorEvent>((event, emit) {
      emit(ChatError(event.message));
    });
    on<OpenExistingConversationEvent>(_openExistingConversation);
    on<_ShowChatErrorEvent>((event, emit) {
      emit(ChatError(event.message));
    });
  }

  Future<void> _loadMyConversations(
      LoadMyConversationsEvent event,
      Emitter<ChatState> emit,
      ) async
  {
    emit(ConversationsLoading());

    try {
      final conversations = await getMyConversationsUseCase();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(_errorMessage(e)));
    }
  }

  Future<void> _openConversation(
      OpenConversationEvent event,
      Emitter<ChatState> emit,
      ) async
  {debugPrint('1. Inicia apertura. Usuario: ${event.otherUserId}');
    emit(ChatLoading());

    try {debugPrint('2. Desconectando chat anterior...');
      await repository.disconnectFromConversation();

    debugPrint('3. Solicitando crear/obtener conversación...');
      final conversation =
      await getOrCreateConversationUseCase(event.otherUserId);
    debugPrint('4. Conversación recibida: ${conversation.id}');
    debugPrint('5. Cargando mensajes...');
      final messages = await getMessagesUseCase(conversation.id);
    debugPrint('6. Mensajes recibidos: ${messages.length}');
      _currentConversation = conversation;
      _currentMessages = _sortMessages(messages);

      emit(
        ChatReady(
          conversation: conversation,
          messages: List.unmodifiable(_currentMessages),
        ),
      );

      await repository.connectToConversation(
        conversationId: conversation.id,
        onMessage: (message) {
          add(IncomingMessageEvent(message));
        },
        onError: (error) {
          // No cambiamos el estado actual por errores de conexión
          // para no borrar los mensajes ya cargados.
          add(_WebSocketErrorEvent(error));
        },
      );
    } catch (e) {
      emit(ChatError(_errorMessage(e)));
    }
  }

  Future<void> _loadMessages(
      LoadMessagesEvent event,
      Emitter<ChatState> emit,
      ) async
  {
    emit(ChatLoading());

    try {
      final messages = await getMessagesUseCase(event.conversationId);

      if (_currentConversation?.id != event.conversationId) {
        return;
      }

      _currentMessages = _sortMessages(messages);

      emit(
        ChatReady(
          conversation: _currentConversation!,
          messages: List.unmodifiable(_currentMessages),
        ),
      );
    } catch (e) {
      emit(ChatError(_errorMessage(e)));
    }
  }

  Future<void> _sendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async
  {
    final conversation = _currentConversation;
    final content = event.content.trim();

    if (conversation == null || content.isEmpty) {
      return;
    }

    final currentState = state;
    if (currentState is ChatReady) {
      emit(currentState.copyWith(sending: true));
    }

    try {
      final message = await sendMessageUseCase(
        conversationId: conversation.id,
        content: content,
      );

      _addMessageIfMissing(message);

      emit(
        ChatReady(
          conversation: conversation,
          messages: List.unmodifiable(_currentMessages),
          sending: false,
        ),
      );
    } catch (e) {
      emit(
        ChatReady(
          conversation: conversation,
          messages: List.unmodifiable(_currentMessages),
          sending: false,
        ),
      );
      // Mantiene los mensajes existentes y muestra el error
      // como un estado independiente al siguiente evento.
      add(_ShowChatErrorEvent(_errorMessage(e)));
    }
  }

  void _onIncomingMessage(
      IncomingMessageEvent event,
      Emitter<ChatState> emit,
      )
  {
    final conversation = _currentConversation;

    if (conversation == null ||
        event.message.conversationId != conversation.id) {
      return;
    }

    _addMessageIfMissing(event.message);

    emit(
      ChatReady(
        conversation: conversation,
        messages: List.unmodifiable(_currentMessages),
      ),
    );
  }

  Future<void> _markMessageAsRead(
      MarkMessageAsReadEvent event,
      Emitter<ChatState> emit,
      ) async
  {
    final conversation = _currentConversation;

    if (conversation == null) {
      return;
    }

    try {
      final updatedMessage = await markMessageAsReadUseCase(
        conversationId: conversation.id,
        messageId: event.messageId,
      );

      final index = _currentMessages.indexWhere(
            (message) => message.id == updatedMessage.id,
      );

      if (index != -1) {
        _currentMessages[index] = updatedMessage;
      }

      emit(
        ChatReady(
          conversation: conversation,
          messages: List.unmodifiable(_currentMessages),
        ),
      );
    } catch (e) {
      add(_ShowChatErrorEvent(_errorMessage(e)));
    }
  }

  Future<void> _closeConversation(
      CloseConversationEvent event,
      Emitter<ChatState> emit,
      ) async
  {
    await repository.disconnectFromConversation();
    _currentConversation = null;
    _currentMessages = [];
    emit(ChatInitial());
  }

  void _addMessageIfMissing(MessageResponse message) {
    final alreadyExists = _currentMessages.any(
          (item) => item.id == message.id,
    );

    if (alreadyExists) {
      return;
    }

    _currentMessages.add(message);
    _currentMessages = _sortMessages(_currentMessages);
  }

  List<MessageResponse> _sortMessages(List<MessageResponse> messages) {
    final result = List<MessageResponse>.from(messages);

    result.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });

    return result;
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() async {
    await repository.disconnectFromConversation();
    return super.close();
  }

  Future<void> _openExistingConversation(
      OpenExistingConversationEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(ChatLoading());

    try {
      await repository.disconnectFromConversation();

      final conversation = event.conversation;
      final messages = await getMessagesUseCase(conversation.id);

      _currentConversation = conversation;
      _currentMessages = _sortMessages(messages);

      emit(
        ChatReady(
          conversation: conversation,
          messages: List.unmodifiable(_currentMessages),
        ),
      );

      await repository.connectToConversation(
        conversationId: conversation.id,
        onMessage: (message) {
          add(IncomingMessageEvent(message));
        },
        onError: (error) {
          // Conserva los mensajes cargados si falla la conexión.
          add(_WebSocketErrorEvent(error));
        },
      );
    } catch (e) {
      emit(ChatError(_errorMessage(e)));
    }
  }
}

// Eventos internos para comunicar errores sin descartar el chat cargado.
class _WebSocketErrorEvent extends ChatEvent {
  final String message;
  _WebSocketErrorEvent(this.message);
}

class _ShowChatErrorEvent extends ChatEvent {
  final String message;
  _ShowChatErrorEvent(this.message);
}