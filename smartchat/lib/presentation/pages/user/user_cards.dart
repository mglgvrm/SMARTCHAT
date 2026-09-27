import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/data/models/UserCardResponse.dart';
import 'package:smartchat/presentation/bloc/user/user_bloc.dart';

class UserCardList extends StatelessWidget {
  final ValueChanged<String>? onMessageTap;

  const UserCardList({
    super.key,
    this.onMessageTap,
  });
  static const Color smartChatBlue = Color(0xFF1677FF);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserInitial || state is UserLoading) {
            return const Center(
              child: CircularProgressIndicator(color: smartChatBlue),
            );
          }

          if (state is UserError) {
            return _buildError(context, state.message);
          }

          if (state is UserLoaded) {
            if (state.users.isEmpty) return _buildEmptyState();

            return RefreshIndicator(
              color: smartChatBlue,
              onRefresh: () async {
                context.read<UserBloc>().add(GetChatableUsersEvent());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Header fijo ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildHeader(context, state.users.length),
                  ),

                  // ── Lista de usuarios ───────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => UserCard(
                          user: state.users[index],
                          onMessageTap: onMessageTap,
                        ),
                        childCount: state.users.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: smartChatBlue),
          );
        },
      ),
    );
  }

  // ── Header: título + contador + buscador ────────────────────────────────────
  Widget _buildHeader(BuildContext context, int userCount) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila título + badge contador
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descubre personas',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF0D1E45),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Conecta y comienza una conversación',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A8FB0),
                      ),
                    ),
                  ],
                ),
              ),

              // Badge contador
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1677FF).withOpacity(0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 16,
                      color: Color(0xFF1677FF),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$userCount',
                      style: const TextStyle(
                        color: Color(0xFF1677FF),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buscador decorativo
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Buscar usuarios...',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Estado error ────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No pudimos cargar los usuarios',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<UserBloc>().add(GetChatableUsersEvent());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1677FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado vacío ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1677FF).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 50,
                color: Color(0xFF1677FF),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No hay usuarios disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando haya personas disponibles para conectar, aparecerán aquí.',
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
}

// ── UserCard ───────────────────────────────────────────────────────────────────
class UserCard extends StatelessWidget {
  final UserCardResponse user;
  final ValueChanged<String>? onMessageTap;

  const UserCard({
    super.key,
    required this.user,
    this.onMessageTap,
  });

  static const Color smartChatBlue = Color(0xFF1677FF);

  @override
  Widget build(BuildContext context) {
    final bool isOnline = user.online == true;

    final String displayName =
    (user.fullName != null && user.fullName!.trim().isNotEmpty)
        ? user.fullName!.trim()
        : (user.username != null && user.username!.trim().isNotEmpty)
        ? user.username!.trim()
        : 'Usuario';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => debugPrint('Abrir perfil de: ${user.id}'),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Fila principal ─────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileImage(isOnline),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre + verificado
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                if (user.verifiedCreator == true)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Icon(
                                      Icons.verified_rounded,
                                      size: 19,
                                      color: smartChatBlue,
                                    ),
                                  ),
                              ],
                            ),

                            // Username
                            if (user.username != null &&
                                user.username!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  '@${user.username}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 7),

                            // Estado online
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOnline ? 'En línea' : 'Desconectado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isOnline
                                        ? Colors.green
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildChatButton(context),
                    ],
                  ),

                  // ── Bio ────────────────────────────────────────────────
                  if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      user.bio!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── Chips ──────────────────────────────────────────────
                  Row(
                    children: [
                      if (user.country != null &&
                          user.country!.trim().isNotEmpty)
                        _buildInfoChip(
                          Icons.location_on_outlined,
                          user.country!.trim(),
                        ),
                      if (user.country != null &&
                          user.country!.trim().isNotEmpty &&
                          user.subscriptionPlan != null)
                        const SizedBox(width: 8),
                      if (user.subscriptionPlan != null)
                        _buildPlanChip(user.subscriptionPlan!),
                      const Spacer(),
                      if (user.verifiedCreator == true) _buildCreatorBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool isOnline) {
    final bool hasImage =
        user.profilePicture != null && user.profilePicture!.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1677FF), Color(0xFF4D9BFF)],
            ),
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F4FA),
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                user.profilePicture!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitial(),
                loadingBuilder: (_, child, progress) =>
                progress == null ? child : _buildLoadingImage(),
              )
                  : _buildInitial(),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: -1,
            bottom: 1,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        _getInitial(),
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          color: smartChatBlue,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: smartChatBlue),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return Material(
      color: smartChatBlue,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () {
          debugPrint('Botón de chat presionado. Usuario: ${user.id}');
          onMessageTap?.call(user.id);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 45,
          height: 45,
          alignment: Alignment.center,
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanChip(String plan) {
    final String text = switch (plan.toUpperCase()) {
      'PREMIUM' => 'Premium',
      'VIP' => 'VIP',
      _ => 'Gratis',
    };
    final bool isVip = plan.toUpperCase() == 'VIP';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: smartChatBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVip ? Icons.workspace_premium_rounded : Icons.star_rounded,
            size: 14,
            color: smartChatBlue,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: smartChatBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: smartChatBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: smartChatBlue),
          SizedBox(width: 3),
          Text(
            'Creador',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: smartChatBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitial() {
    if (user.fullName != null && user.fullName!.trim().isNotEmpty) {
      return user.fullName!.trim().substring(0, 1).toUpperCase();
    }
    if (user.username != null && user.username!.trim().isNotEmpty) {
      return user.username!.trim().substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}