class WorkoutRecord {
  final String exercise;
  final int reps;
  final int score;
  final int seconds;
  final DateTime date;

  const WorkoutRecord({
    required this.exercise,
    required this.reps,
    required this.score,
    required this.seconds,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'exercise': exercise,
    'reps': reps,
    'score': score,
    'seconds': seconds,
    'date': date.toIso8601String(),
  };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
    exercise: json['exercise'] as String,
    reps: json['reps'] as int,
    score: json['score'] as int,
    seconds: json['seconds'] as int,
    date: DateTime.parse(json['date'] as String),
  );
}
