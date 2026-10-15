import 'dart:math';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/metric_card.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final Exercise exercise;
  final int reps;
  final int score;
  final int seconds;

  const WorkoutSummaryScreen({
    super.key,
    required this.exercise,
    required this.reps,
    required this.score,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.primaryDark,
                child: Icon(Icons.check, size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Workout Complete!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(value: '$reps', label: 'Reps'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      value: '${score.clamp(0, 100)}%',
                      label: 'Form score',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      value: '${max(1, seconds ~/ 60)} min',
                      label: 'Duration',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CustomButton(
                text: 'Back to Dashboard',
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
