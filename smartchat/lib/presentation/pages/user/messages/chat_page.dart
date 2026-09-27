import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/data/models/ConversationResponse.dart';
import 'package:smartchat/presentation/bloc/chat/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final ConversationResponse? conversation;
  final String? otherUserId;

  const ChatPage({
    super.key,
    this.conversation,
    this.otherUserId,
  }) : assert(conversation != null || otherUserId != null);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color smartChatBlue = Color(0xFF1677FF);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  final TextEditingController _messageController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<ChatBloc>();

      if (widget.conversation != null) {
        bloc.add(
          OpenExistingConversationEvent(widget.conversation!),
        );
      } else if (widget.otherUserId != null) {
        bloc.add(
          OpenConversationEvent(widget.otherUserId!),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();

    // No cerramos el WebSocket aquí: el BLoC global puede seguir vivo
    // y la lista de conversaciones no debe destruir su instancia.
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();

    if (content.isEmpty) return;

    context.read<ChatBloc>().add(
      SendMessageEvent(content),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  debugPrint('ChatPage recibió: ${state.runtimeType}');
                  if (state is ChatLoading || state is ChatInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: smartChatBlue,
                      ),
                    );
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  debugPrint('ChatPage recibió: ${state.runtimeType}');
                  if (state is ChatReady) {
                    if (state.messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Saluda para comenzar la conversación',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];

                        // Por ahora alineamos todos los mensajes a la izquierda.
                        // Cuando conectemos el ID del usuario autenticado,
                        // podremos distinguir mensajes enviados y recibidos.
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width * 0.78,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(message.content),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Volver',
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(
              Icons.person_rounded,
              color: smartChatBlue,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chat',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.conversation?.id ?? 'Iniciando conversación...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor: backgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: smartChatBlue,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Enviar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}