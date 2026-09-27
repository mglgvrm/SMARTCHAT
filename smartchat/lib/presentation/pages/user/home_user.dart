import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/presentation/bloc/chat/chat_bloc.dart';
import 'package:smartchat/presentation/bloc/user/user_bloc.dart';
import 'package:smartchat/presentation/pages/user/messages/chat_page.dart';
import 'package:smartchat/presentation/pages/user/messages/conversations_page.dart';
import 'package:smartchat/presentation/pages/user/user_cards.dart';


class HomeUser extends StatefulWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  State<HomeUser> createState() => _HomeUserState();
}

const Color smartChatBlue = Color(0xFF1677FF);

class _HomeUserState extends State<HomeUser> {
  final List<Widget> _pageList = [];
  String? _messagesTargetUserId;
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  DateTime? _lastPressed;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(
        GetChatableUsersEvent(),
      );
    });
  }


  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);

    if (_lastPressed == null ||
        now.difference(_lastPressed!) > maxDuration) {
      _lastPressed = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presiona de nuevo para salir'),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          allowImplicitScrolling: false,
          onPageChanged: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          children: _pageList.isEmpty
              ? [
            _buildHomePage(),
            _buildNotificationsPage(),
            _buildMessagesPage(),
            _buildProfilePage(),
          ]
              : _pageList,
        ),

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,

              currentIndex: _currentIndex,

              selectedItemColor: smartChatBlue,
              unselectedItemColor: Colors.black,

              backgroundColor: Colors.white,

              onTap: _changePage,

              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    color: _currentIndex == 0
                        ? smartChatBlue
                        : Colors.black,
                  ),
                  activeIcon: const Icon(
                    Icons.home,
                    color: smartChatBlue,
                  ),
                  label: 'Inicio',
                ),

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications_none,
                    color: _currentIndex == 1
                        ? smartChatBlue
                        : Colors.black,
                  ),
                  activeIcon: const Icon(
                    Icons.notifications,
                    color: smartChatBlue,
                  ),
                  label: 'Notificaciones',
                ),

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: _currentIndex == 2
                        ? smartChatBlue
                        : Colors.black,
                  ),
                  activeIcon: const Icon(
                    Icons.chat_bubble,
                    color: smartChatBlue,
                  ),
                  label: 'Mensajes',
                ),

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outline,
                    color: _currentIndex == 3
                        ? smartChatBlue
                        : Colors.black,
                  ),
                  activeIcon: const Icon(
                    Icons.person,
                    color: smartChatBlue,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INICIO
  // ─────────────────────────────────────────────────────────────

  Widget _buildHomePage() {
    return UserCardList(
      onMessageTap: (userId) {
        final chatBloc = context.read<ChatBloc>();

        setState(() {
          _currentIndex = 2;
        });

        _pageController.jumpToPage(2);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatBloc,
              child: ChatPage(
                otherUserId: userId,
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NOTIFICACIONES
  // ─────────────────────────────────────────────────────────────

  Widget _buildNotificationsPage() {
    return const Center(
      child: Text(
        'Notificaciones',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MENSAJES
  // ─────────────────────────────────────────────────────────────

  Widget _buildMessagesPage() {
    return const ConversationsPage();
  }

  // ─────────────────────────────────────────────────────────────
  // PERFIL
  // ─────────────────────────────────────────────────────────────

  Widget _buildProfilePage() {
    return const Center(
      child: Text(
        'Perfil',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


}

class _OpenChatFromHomePage extends StatelessWidget {
  final String otherUserId;

  const _OpenChatFromHomePage({
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future<void>.delayed(Duration.zero),
      builder: (context, snapshot) {
        return _OpenChatLoader(otherUserId: otherUserId);
      },
    );
  }
}

class _OpenChatLoader extends StatefulWidget {
  final String otherUserId;

  const _OpenChatLoader({
    required this.otherUserId,
  });

  @override
  State<_OpenChatLoader> createState() => _OpenChatLoaderState();
}

class _OpenChatLoaderState extends State<_OpenChatLoader> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ChatBloc>().add(
        OpenConversationEvent(widget.otherUserId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}