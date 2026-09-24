import 'package:flutter/material.dart';
import 'package:smartchat/presentation/pages/admin/home_admin.dart';
import 'package:smartchat/presentation/pages/user/home_user.dart';
import '../../presentation/pages/auth/auth_screen.dart';
import '../../presentation/pages/auth/complete_profile_screen.dart';

class AppRoutes {
  static const String login = "/";
  static const String completeProfile = "/complete-profile";
  static const String home = "/home";

  static const String admin = "/admin";


  static Route<dynamic> generateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        );

      case completeProfile:
        return MaterialPageRoute(
          builder: (_) => const CompleteProfileScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeUser(),
        );

      case admin:
        return MaterialPageRoute(
          builder: (_) => const HomeAdmin(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                "Ruta no encontrada",
              ),
            ),
          ),
        );
    }
  }
}