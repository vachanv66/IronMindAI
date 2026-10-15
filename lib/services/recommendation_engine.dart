import '../models/exercise.dart';

class RecommendationEngine {
  static List<Exercise> getRecommendations({
    required String goal,
    required String fitnessLevel,
    List<String> recentExercises = const [],
    int avgScore = 90,
  }) {
    List<Exercise> pool = List.from(exerciseCatalog);

    // 1. Filter / rank by primary fitness goal
    switch (goal) {
      case 'Build strength':
        pool.sort((a, b) {
          final aIsUpperLower = (a.category == 'Upper Body' || a.category == 'Lower Body') ? 0 : 1;
          final bIsUpperLower = (b.category == 'Upper Body' || b.category == 'Lower Body') ? 0 : 1;
          return aIsUpperLower.compareTo(bIsUpperLower);
        });
        break;
      case 'Lose weight':
        pool.sort((a, b) {
          final aIsCardio = (a.category == 'Cardio' || a.category == 'Core') ? 0 : 1;
          final bIsCardio = (b.category == 'Cardio' || b.category == 'Core') ? 0 : 1;
          return aIsCardio.compareTo(bIsCardio);
        });
        break;
      case 'Improve mobility':
        pool.sort((a, b) {
          final aIsMobility = (a.category == 'Mobility' || a.category == 'Lower Body') ? 0 : 1;
          final bIsMobility = (b.category == 'Mobility' || b.category == 'Lower Body') ? 0 : 1;
          return aIsMobility.compareTo(bIsMobility);
        });
        break;
      default:
        pool.shuffle();
        break;
    }

    // 2. Adjust count based on fitness level
    int count = switch (fitnessLevel) {
      'Beginner' => 5,
      'Intermediate' => 8,
      'Advanced' => 12,
      _ => 6,
    };

    return pool.take(count).toList();
  }

  static String getAIRecommendationInsight({
    required String goal,
    required String fitnessLevel,
    required int completedSessions,
    required int avgScore,
  }) {
    if (completedSessions == 0) {
      return "Welcome to IronMind AI! We've crafted a custom $fitnessLevel $goal plan covering fundamental movement patterns.";
    }

    if (avgScore >= 90) {
      return "Outstanding biomechanical precision ($avgScore% avg score)! You're ready for advanced multi-joint exercises.";
    } else if (avgScore >= 75) {
      return "Good consistency ($avgScore% avg score)! Focus on smooth range of motion and controlled tempo.";
    } else {
      return "Form priority ($avgScore% avg score): Follow the live visual overlay cues to protect your joints.";
    }
  }
}
