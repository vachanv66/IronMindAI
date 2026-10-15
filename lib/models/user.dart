class User {
  final String userId;
  final String email;
  final String name;
  final String fitnessLevel;
  final String goal;
  final double height; // in cm (e.g. 175.0)
  final double weight; // in kg (e.g. 70.0)
  final int age; // in years (e.g. 26)
  final String gender; // 'Male', 'Female', 'Other'
  final String dietaryPreference; // 'Vegetarian', 'Vegan', 'Non-Vegetarian'
  final String activityLevel; // 'Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active'
  final double? targetWeight; // in kg

  const User({
    required this.userId,
    required this.email,
    required this.name,
    required this.fitnessLevel,
    required this.goal,
    this.height = 172.0,
    this.weight = 68.0,
    this.age = 25,
    this.gender = 'Male',
    this.dietaryPreference = 'Vegetarian',
    this.activityLevel = 'Moderately Active',
    this.targetWeight,
  });

  // --- Biometric Computations ---

  /// Body Mass Index (kg / m^2)
  double get bmi {
    if (height <= 0) return 22.0;
    final heightMeters = height / 100.0;
    return weight / (heightMeters * heightMeters);
  }

  /// Clinical WHO BMI Classification
  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal Weight';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Basal Metabolic Rate using Mifflin-St Jeor formula
  double get bmr {
    if (gender.toLowerCase() == 'female') {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    return (10 * weight) + (6.25 * height) - (5 * age) + 5;
  }

  /// Total Daily Energy Expenditure (TDEE) based on activity factor
  double get tdee {
    final multiplier = switch (activityLevel) {
      'Sedentary' => 1.2,
      'Lightly Active' => 1.375,
      'Moderately Active' => 1.55,
      'Very Active' => 1.725,
      _ => 1.45,
    };
    return bmr * multiplier;
  }

  /// Recommended Daily Calories tailored to fitness goal
  int get targetCalories {
    final base = tdee;
    return switch (goal) {
      'Lose weight' => (base - 450).clamp(1200, 3500).round(),
      'Build strength' => (base + 350).clamp(1600, 4200).round(),
      'Improve fitness' => base.round(),
      'Improve mobility' => (base - 100).round(),
      _ => base.round(),
    };
  }

  /// Recommended Daily Protein intake (grams)
  int get proteinGrams {
    final perKg = switch (goal) {
      'Build strength' => 2.0,
      'Lose weight' => 1.8,
      'Improve fitness' => 1.5,
      _ => 1.3,
    };
    return (weight * perKg).round();
  }

  /// Recommended Daily Fat intake (grams) (~25% of calories)
  int get fatsGrams {
    return ((targetCalories * 0.25) / 9.0).round();
  }

  /// Recommended Daily Carbohydrates (grams) (balance of calories)
  int get carbsGrams {
    final remainingCalories = targetCalories - (proteinGrams * 4) - (fatsGrams * 9);
    return (remainingCalories / 4.0).clamp(50, 600).round();
  }

  /// Daily Hydration target in Litres
  double get waterTargetLiters {
    return ((weight * 0.035) + 0.5);
  }

  User copyWith({
    String? userId,
    String? email,
    String? name,
    String? fitnessLevel,
    String? goal,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? dietaryPreference,
    String? activityLevel,
    double? targetWeight,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      activityLevel: activityLevel ?? this.activityLevel,
      targetWeight: targetWeight ?? this.targetWeight,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['user_id'] as String? ?? 'demo-user',
        email: json['email'] as String? ?? 'demo@ironmind.ai',
        name: json['name'] as String? ?? 'Athlete',
        fitnessLevel: json['fitness_level'] as String? ?? 'Beginner',
        goal: json['goal'] as String? ?? 'Build strength',
        height: (json['height'] as num?)?.toDouble() ?? 172.0,
        weight: (json['weight'] as num?)?.toDouble() ?? 68.0,
        age: (json['age'] as num?)?.toInt() ?? 25,
        gender: json['gender'] as String? ?? 'Male',
        dietaryPreference: json['dietary_preference'] as String? ?? 'Vegetarian',
        activityLevel: json['activity_level'] as String? ?? 'Moderately Active',
        targetWeight: (json['target_weight'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'name': name,
        'fitness_level': fitnessLevel,
        'goal': goal,
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
        'dietary_preference': dietaryPreference,
        'activity_level': activityLevel,
        if (targetWeight != null) 'target_weight': targetWeight,
      };
}
