import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartchat/data/models/MessageResponse.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';


import '../../data/models/ConversationResponse.dart';
import 'ChatRepository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  StompClient? _stompClient;

  // IMPORTANTE:
  // Usa aquí exactamente la misma clave donde guardas el JWT
  // durante el inicio de sesión.
  static const String tokenKey = 'token';

  ChatRepositoryImpl({
    required this.dio,
    required this.storage,
  });

  Future<String> _getToken() async {
    final token = await storage.read(key: tokenKey);

    if (token == null || token.isEmpty) {
      throw Exception(
        'No se encontró el token de autenticación. Inicia sesión nuevamente.',
      );
    }

    return token;
  }

  Options _authOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  Future<ConversationResponse> getOrCreateConversation(
      String otherUserId,
      ) async {
    final token = await _getToken();

    final response = await dio.post(
      '/api/conversations/$otherUserId',
      options: _authOptions(token),
    );

    return ConversationResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  @override
  Future<List<ConversationResponse>> getMyConversations() async {
    final token = await _getToken();

    final response = await dio.get(
      '/api/conversations',
      options: _authOptions(token),
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => ConversationResponse.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  @override
  Future<List<MessageResponse>> getMessages(
      String conversationId,
      ) async {
    final token = await _getToken();

    final response = await dio.get(
      '/api/conversations/$conversationId/messages',
      options: _authOptions(token),
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => MessageResponse.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  @override
  Future<MessageResponse> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final token = await _getToken();

    final response = await dio.post(
      '/api/conversations/$conversationId/messages',
      data: {
        'content': content,
      },
      options: _authOptions(token),
    );

    return MessageResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  @override
  Future<MessageResponse> markAsRead({
    required String conversationId,
    required String messageId,
  }) async {
    final token = await _getToken();

    final response = await dio.post(
      '/api/conversations/$conversationId/messages/$messageId/read',
      options: _authOptions(token),
    );

    return MessageResponse.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  @override
  Future<void> connectToConversation({
    required String conversationId,
    required void Function(MessageResponse message) onMessage,
    required void Function(String error) onError,
  }) async {
    await disconnectFromConversation();

    final token = await _getToken();

    // Para el emulador Android, el host 10.0.2.2 apunta al computador.
    // El puerto debe coincidir con el backend.
    final baseUrl = dio.options.baseUrl;
    final wsUrl = baseUrl.replaceFirst(
      RegExp(r'^http'),
      'ws',
    ) + '/ws';

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onConnect: (StompFrame frame) {
          _stompClient?.subscribe(
            destination: '/topic/conversation/$conversationId',
            callback: (StompFrame frame) {
              final body = frame.body;

              if (body == null || body.isEmpty) {
                return;
              }

              try {
                final json = jsonDecode(body) as Map<String, dynamic>;
                onMessage(MessageResponse.fromJson(json));
              } catch (e) {
                onError('No se pudo interpretar el mensaje recibido: $e');
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          onError('Error de conexión WebSocket: $error');
        },
        onStompError: (StompFrame frame) {
          onError(
            'Error STOMP: ${frame.body ?? 'Error desconocido'}',
          );
        },
        onDisconnect: (StompFrame frame) {},
        onWebSocketDone: () {},
      ),
    );

    _stompClient!.activate();
  }

  @override
  Future<void> disconnectFromConversation() async {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}