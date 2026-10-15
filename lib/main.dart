import 'package:flutter/material.dart';
import 'models/user.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  User? initialUser;
  try {
    initialUser = await AuthService.getCurrentUser();
  } catch (_) {}
  runApp(IronMindApp(initialUser: initialUser));
}

class IronMindApp extends StatelessWidget {
  final User? initialUser;

  const IronMindApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IronMind AI',
      theme: AppTheme.darkTheme,
      home: initialUser != null
          ? DashboardScreen(
              goal: initialUser!.goal,
              level: initialUser!.fitnessLevel,
            )
          : const WelcomeScreen(),
    );
  }
}
