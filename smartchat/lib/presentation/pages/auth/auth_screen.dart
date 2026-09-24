import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/presentation/bloc/auth_bloc.dart';
import 'package:smartchat/presentation/bloc/auth_event.dart';
import 'package:smartchat/presentation/bloc/auth_state.dart';
import 'package:smartchat/presentation/pages/auth/complete_profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _obscurePassword = true;
  bool _obscureRegisterPassword = true;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  // ── Colors ──────────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF050E2B);
  static const Color _surface = Color(0xFF0D1E45);
  static const Color _blue = Color(0xFF1A6DFF);
  static const Color _blueLight = Color(0xFF4D9FFF);
  static const Color _white = Colors.white;
  static const Color _hint = Color(0xFF5A7AAB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final user = state.user;
            if (kDebugMode) {
              print("Usuario: ${user.toString()}");
              print("Profile completed: ${user.profileCompleted}");
              print("Role: ${user.role}");
            }

            if (!state.user.profileCompleted) {
              Navigator.pushReplacementNamed(context, "/complete-profile");
            } else {

              switch (user.role?.toUpperCase()) {
                case "ADMIN":
                  Navigator.pushReplacementNamed(context, "/admin");
                  break;

                case "USER":
                  Navigator.pushReplacementNamed(context, "/home");
                  break;


                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No se pudo determinar el rol del usuario"),
                    ),
                  );
              }
            }


          }

          if (state is AuthError) {
            if (kDebugMode) {
              print(
                "####################################################################################### ${state.message}",
              );
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Stack(
          children: [
            const Positioned.fill(child: _NetworkBackground()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    _buildLogo(),
                    const SizedBox(height: 32),
                    _buildWelcomeText(),
                    const SizedBox(height: 28),
                    _buildTabBar(),
                    const SizedBox(height: 24),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final offset = _tabController.index == 0
                            ? const Offset(-1, 0)
                            : const Offset(1, 0);

                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: offset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _tabController.index == 0
                          ? _buildLoginForm()
                          : _buildRegisterForm(),
                    ),

                    const SizedBox(height: 28),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildSocialRow(),
                    const SizedBox(height: 28),
                    _buildBottomLink(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logo ─────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(),
            const SizedBox(width: 6),
            _tag('CONECTA'),
            const SizedBox(width: 6),
            _dot(),
            const SizedBox(width: 6),
            _tag('COMUNICA'),
            const SizedBox(width: 6),
            _dot(),
            const SizedBox(width: 6),
            _tag('CRECE'),
            const SizedBox(width: 6),
            _dot(),
          ],
        ),
      ],
    );
  }

  Widget _tag(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF8AAFD4),
      fontSize: 11,
      letterSpacing: 1.8,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _dot() => Container(
    width: 4,
    height: 4,
    decoration: const BoxDecoration(color: _blueLight, shape: BoxShape.circle),
  );

  // ── Welcome ──────────────────────────────────────────────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          '¡Bienvenido!',
          style: TextStyle(
            color: _white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFFB0C8E8),
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: _tabController.index == 0
                    ? 'Ingresa tus datos para continuar\ntu experiencia en '
                    : 'Únete a la comunidad y comienza\ntu experiencia en ',
              ),
              const TextSpan(
                text: 'SmartChat',
                style: TextStyle(
                  color: _blueLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab bar ──────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('Iniciar sesión', 0),
        const SizedBox(width: 16),
        _buildTab('Registrarse', 1),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? _blue : _white.withOpacity(0.55),
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 2.5,
            width: isActive ? (index == 0 ? 100 : 90) : 0,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login form ───────────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        _buildTextField(
          controller: _loginEmailController,
          hint: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          controller: _loginPasswordController,
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 6),
        _buildPasswordHint(),
        const SizedBox(height: 22),
        _buildPrimaryButton(
          label: 'Iniciar sesión',
          onPressed: () {
            context.read<AuthBloc>().add(LoginLocalEvent(
              email: _loginEmailController.text,
              password: _loginPasswordController.text,

            ));

          },
        ),
      ],
    );
  }

  // ── Register form ─────────────────────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        _buildTextField(
          controller: _registerNameController,
          hint: 'Nombre completo',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _registerEmailController,
          hint: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          controller: _registerPasswordController,
          obscure: _obscureRegisterPassword,
          onToggle: () => setState(
            () => _obscureRegisterPassword = !_obscureRegisterPassword,
          ),
        ),
        const SizedBox(height: 6),
        _buildPasswordHint(),
        const SizedBox(height: 22),
        _buildPrimaryButton(
          label: 'Crear cuenta',
          onPressed: () {
            // TODO: implement register logic
          },
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3660), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: _white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _hint, fontSize: 15),
          prefixIcon: Icon(icon, color: _hint, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3660), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: _white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: const TextStyle(color: _hint, fontSize: 15),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: _hint,
            size: 22,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _blueLight,
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordHint() {
    return const Align(
      alignment: Alignment.center,
      child: Text(
        'La contraseña debe tener al menos 8 caracteres',
        style: TextStyle(color: _hint, fontSize: 12),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A6DFF), Color(0xFF0A44CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final label = _tabController.index == 0
        ? 'O inicia sesión con'
        : 'O regístrate con';
    return Row(
      children: [
        Expanded(child: Divider(color: _white.withOpacity(0.12), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(color: _white.withOpacity(0.45), fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: _white.withOpacity(0.12), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
          onTap: () {
            context.read<AuthBloc>().add(LoginGoogleEvent());
          },
          child: Image.network(
            'https://www.svgrepo.com/show/475656/google-color.svg',
            width: 26,
            height: 26,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.g_mobiledata_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _socialButton(
          onTap: () {},
          child: const Icon(Icons.apple_rounded, color: _white, size: 28),
        ),
        const SizedBox(width: 16),
        _socialButton(
          onTap: () {},
          child: const Icon(
            Icons.facebook_rounded,
            color: Color(0xFF1877F2),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _socialButton({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 54,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1A3660), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildBottomLink() {
    final isLogin = _tabController.index == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? '¿No tienes una cuenta? ' : '¿Ya tienes una cuenta? ',
          style: TextStyle(color: _white.withOpacity(0.55), fontSize: 14),
        ),
        GestureDetector(
          onTap: () => _tabController.animateTo(isLogin ? 1 : 0),
          child: Text(
            isLogin ? 'Regístrate' : 'Inicia sesión',
            style: const TextStyle(
              color: _blueLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Network background ─────────────────────────────────────────────────────────
class _NetworkBackground extends StatelessWidget {
  const _NetworkBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _NetworkPainter());
}

class _NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF1A3D7A).withOpacity(0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF1A6DFF).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final nodes = [
      Offset(size.width * 0.05, size.height * 0.12),
      Offset(size.width * 0.18, size.height * 0.08),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.92, size.height * 0.10),
      Offset(size.width * 0.08, size.height * 0.75),
      Offset(size.width * 0.15, size.height * 0.82),
      Offset(size.width * 0.88, size.height * 0.72),
      Offset(size.width * 0.94, size.height * 0.78),
    ];

    for (final edge in [
      [0, 1],
      [2, 3],
      [4, 5],
      [6, 7],
      [0, 4],
      [1, 2],
      [3, 7],
      [5, 6],
    ]) {
      canvas.drawLine(nodes[edge[0]], nodes[edge[1]], linePaint);
    }
    for (final node in nodes) {
      canvas.drawCircle(node, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
