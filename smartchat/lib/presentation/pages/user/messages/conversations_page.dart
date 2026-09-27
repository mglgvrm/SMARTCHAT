import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/data/models/ConversationResponse.dart';
import 'package:smartchat/presentation/bloc/chat/chat_bloc.dart';
import 'chat_page.dart';

class ConversationsPage extends StatefulWidget {
  final ValueChanged<String>? onOpenUserChat;

  const ConversationsPage({
    super.key,
    this.onOpenUserChat,
  });

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  static const Color smartChatBlue = Color(0xFF1677FF);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ChatBloc>().add(LoadMyConversationsEvent());
    });
  }

  void _loadConversations() {
    context.read<ChatBloc>().add(LoadMyConversationsEvent());
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
                  if (state is ConversationsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: smartChatBlue,
                      ),
                    );
                  }

                  if (state is ChatError) {
                    return _buildError(state.message);
                  }

                  if (state is ConversationsLoaded) {
                    if (state.conversations.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: smartChatBlue,
                      onRefresh: () async {
                        _loadConversations();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          24,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.conversations.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final conversation =
                          state.conversations[index];

                          return _buildConversationCard(conversation);
                        },
                      ),
                    );
                  }

                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: _loadConversations,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Cargar conversaciones'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mensajes',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1E45),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tus conversaciones',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A8FB0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: _loadConversations,
              icon: const Icon(
                Icons.refresh_rounded,
                color: smartChatBlue,
              ),
              tooltip: 'Actualizar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ConversationResponse conversation) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // El endpoint actual solo devuelve IDs de participantes.
          // Para abrir un chat existente por ID de conversación,
          // el BLoC debe tener el evento OpenExistingConversationEvent.
          context.read<ChatBloc>().add(
            OpenExistingConversationEvent(conversation),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatPage(
                conversation: conversation,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: smartChatBlue.withOpacity(0.09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: smartChatBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conversación',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF17233C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.participantIds.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA8BD),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: smartChatBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 48,
                color: smartChatBlue,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Aún no tienes chats',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D1E45),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando comiences una conversación, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar tus conversaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadConversations,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}