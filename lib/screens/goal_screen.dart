import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart';

class GoalScreen extends StatefulWidget {
  final String level;
  final String name;
  final double height;
  final double weight;
  final int age;
  final String gender;
  final String dietaryPreference;

  const GoalScreen({
    super.key,
    required this.level,
    required this.name,
    this.height = 175.0,
    this.weight = 70.0,
    this.age = 25,
    this.gender = 'Male',
    this.dietaryPreference = 'Vegetarian',
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String goal = 'Build strength';
  final goals = const [
    'Build strength',
    'Lose weight',
    'Improve fitness',
    'Improve mobility',
  ];

  final goalDescriptions = const {
    'Build strength': 'Progressive mechanical tension & hypertrophy split to build lean muscle mass.',
    'Lose weight': 'Metabolic conditioning circuits with joint-safe calibration to maximize calorie burn.',
    'Improve fitness': 'Balanced athletic endurance, core stability, and functional full-body strength.',
    'Improve mobility': 'Thoracic spine, hip, and shoulder alignment flow to eliminate joint stiffness.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Goal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to achieve?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text(
              'Your weekly workout schedule and Indian meal plan will be dynamically generated based on this choice.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ...goals.map(
              (g) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: goal == g ? AppColors.primary : AppColors.border,
                    width: goal == g ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    g,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: goal == g ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    goalDescriptions[g] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  leading: Icon(
                    goal == g ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: goal == g ? AppColors.primary : AppColors.textMuted,
                  ),
                  onTap: () => setState(() => goal = g),
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Generate My Custom Program',
              onPressed: () async {
                final navigator = Navigator.of(context);

                final user = User(
                  userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                  email: 'athlete@ironmind.ai',
                  name: widget.name,
                  fitnessLevel: widget.level,
                  goal: goal,
                  height: widget.height,
                  weight: widget.weight,
                  age: widget.age,
                  gender: widget.gender,
                  dietaryPreference: widget.dietaryPreference,
                );

                // Save to local secure storage
                await StorageService.saveUserProfile(user.toJson());

                // Attempt API sync
                await ApiService.saveProfile(
                  name: widget.name,
                  level: widget.level,
                  goal: goal,
                );

                if (!mounted) return;
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => DashboardScreen(
                      goal: goal,
                      level: widget.level,
                      user: user,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
