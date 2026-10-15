import 'exercise.dart';

class PlanExerciseItem {
  final String exerciseId;
  final String name;
  final int sets;
  final String repsOrDuration;
  final int restSeconds;
  final String primaryMuscle;
  final String cue;

  const PlanExerciseItem({
    required this.exerciseId,
    required this.name,
    required this.sets,
    required this.repsOrDuration,
    required this.restSeconds,
    required this.primaryMuscle,
    required this.cue,
  });

  Exercise? get catalogExercise {
    try {
      return exerciseCatalog.firstWhere((e) => e.id == exerciseId);
    } catch (_) {
      return null;
    }
  }
}

class DailyWorkoutPlan {
  final int dayIndex; // 0: Monday, ..., 6: Sunday
  final String dayName;
  final String title;
  final String focusArea;
  final String description;
  final bool isRestDay;
  final int estimatedMinutes;
  final int estimatedCalories;
  final String intensity; // 'Light', 'Moderate', 'High', 'Recovery'
  final List<PlanExerciseItem> exercises;

  const DailyWorkoutPlan({
    required this.dayIndex,
    required this.dayName,
    required this.title,
    required this.focusArea,
    required this.description,
    required this.isRestDay,
    required this.estimatedMinutes,
    required this.estimatedCalories,
    required this.intensity,
    required this.exercises,
  });
}

class WeeklyWorkoutPlan {
  final String goal;
  final String fitnessLevel;
  final String focusSummary;
  final int targetWeeklyCalories;
  final List<DailyWorkoutPlan> days;

  const WeeklyWorkoutPlan({
    required this.goal,
    required this.fitnessLevel,
    required this.focusSummary,
    required this.targetWeeklyCalories,
    required this.days,
  });

  DailyWorkoutPlan getDay(int weekday1To7) {
    // DateTime.weekday is 1 for Monday, 7 for Sunday
    final idx = (weekday1To7 - 1).clamp(0, 6);
    return days[idx];
  }
}
