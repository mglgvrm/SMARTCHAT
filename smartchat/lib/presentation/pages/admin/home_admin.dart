import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key}) : super(key: key);

  @override
  State<HomeAdmin> createState() => _HomeUserState();
}

const Color smartChatBlue = Color(0xFF1677FF);

class _HomeUserState extends State<HomeAdmin> {
  final List<Widget> _pageList = [];

  int _currentIndex = 0;

  final PageController _pageController = PageController();

  DateTime? _lastPressed;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);

    if (_lastPressed == null || now.difference(_lastPressed!) > maxDuration) {
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
                  _buildDashboardPage(),
                  _buildProfilePage(),
                ]
              : _pageList,
        ),

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
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
                    color: _currentIndex == 0 ? smartChatBlue : Colors.black,
                  ),
                  activeIcon: const Icon(Icons.home, color: smartChatBlue),
                  label: 'Inicio',
                ),

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications_none,
                    color: _currentIndex == 1 ? smartChatBlue : Colors.black,
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
                    color: _currentIndex == 2 ? smartChatBlue : Colors.black,
                  ),
                  activeIcon: const Icon(
                    Icons.chat_bubble,
                    color: smartChatBlue,
                  ),
                  label: 'Mensajes',
                ),

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.dashboard_outlined,
                    color: _currentIndex == 3 ? smartChatBlue : Colors.black,
                  ),
                  activeIcon: const Icon(Icons.dashboard, color: smartChatBlue),
                  label: 'Dashboard',
                ),

                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outline,
                    color: _currentIndex == 4 ? smartChatBlue : Colors.black,
                  ),
                  activeIcon: const Icon(Icons.person, color: smartChatBlue),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return const Center(
      child: Text(
        'Inicio',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return const Center(
      child: Text(
        'Notificaciones',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMessagesPage() {
    return const Center(
      child: Text(
        'Mensajes',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDashboardPage() {
    return const Center(
      child: Text(
        'Dashboard',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfilePage() {
    return const Center(
      child: Text(
        'Perfil',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
