import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/presentation/bloc/auth_bloc.dart';
import 'package:smartchat/presentation/bloc/auth_event.dart';

import '../../bloc/auth_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  DateTime? _selectedDate;

  // ── Colors ──────────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF050E2B);
  static const Color _surface = Color(0xFF0D1E45);
  static const Color _blue = Color(0xFF1A6DFF);
  static const Color _blueLight = Color(0xFF4D9FFF);
  static const Color _white = Colors.white;
  static const Color _hint = Color(0xFF5A7AAB);

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _blue,
              onPrimary: _white,
              surface: Color(0xFF0D1E45),
              onSurface: _white,
            ),
            dialogBackgroundColor: const Color(0xFF050E2B),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Fecha de nacimiento';
    final d = _selectedDate!;
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            // loader
          }

          if (state is CompleteSuccess) {
            final user = state.user;
            if (kDebugMode){
              print(user.role);
            }
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

          if (state is AuthError) {
            print("###################### ${state.message}################");
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 36),

                    // Header
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Avatar picker
                    _buildAvatarPicker(),

                    const SizedBox(height: 10),

                    Text(
                      'Toca para subir tu foto',
                      style: TextStyle(
                        color: _blueLight.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Username field
                    _buildTextField(
                      controller: _fullNameController,
                      hint: 'Nombre de Completo',
                      icon: Icons.alternate_email_rounded,
                    ),

                    const SizedBox(height: 14),
                    // Username field
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'Nombre de usuario',
                      icon: Icons.alternate_email_rounded,
                    ),

                    const SizedBox(height: 14),

                    // Date picker field
                    _buildDateField(),

                    const SizedBox(height: 32),

                    // Continue button
                    _buildPrimaryButton(
                      label: 'Continuar',
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          CompleteProfileRequested(
                            username: _usernameController.text,
                            fullName: _fullNameController.text,
                            birthDate: _selectedDate!
                                .toIso8601String()
                                .split('T')
                                .first
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo small
        Image.asset(
          'assets/images/logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        const Text(
          'Completa tu perfil',
          style: TextStyle(
            color: _white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Agrega tu información para que otros\npuedan encontrarte en ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white.withOpacity(0.55),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        // Inline SmartChat text (separate to avoid RichText issues)
        const Text(
          'SmartChat',
          style: TextStyle(
            color: _blueLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Avatar picker ─────────────────────────────────────────────────────────────
  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: () {
        // TODO: open image picker
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _blue, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Avatar circle
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: _blueLight, size: 32),
                const SizedBox(height: 6),
                const Text(
                  'Foto',
                  style: TextStyle(
                    color: _blueLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Badge
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
                border: Border.all(color: _bg, width: 2),
                boxShadow: [
                  BoxShadow(color: _blue.withOpacity(0.5), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: _white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3660), width: 1),
      ),
      child: TextField(
        controller: controller,
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

  // ── Date field ────────────────────────────────────────────────────────────────
  Widget _buildDateField() {
    final hasDate = _selectedDate != null;
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasDate ? _blue.withOpacity(0.6) : const Color(0xFF1A3660),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              color: hasDate ? _blueLight : _hint,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              _formattedDate,
              style: TextStyle(color: hasDate ? _white : _hint, fontSize: 15),
            ),
            const Spacer(),
            Icon(
              Icons.calendar_today_outlined,
              color: hasDate ? _blueLight : _hint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Primary button ────────────────────────────────────────────────────────────
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
