class IndianDish {
  final String name;
  final String portion;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String ingredients;
  final String tag;

  const IndianDish({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    this.tag = 'Core Dish',
  });
}

class IndianMeal {
  final String mealId;
  final String title;
  final String timeSlot;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<IndianDish> dishes;
  final String chefTip;

  const IndianMeal({
    required this.mealId,
    required this.title,
    required this.timeSlot,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.dishes,
    required this.chefTip,
  });
}

class DailyDietPlan {
  final int dayIndex; // 0: Monday ... 6: Sunday
  final String dayName;
  final String theme;
  final int totalCalories;
  final int totalProtein;
  final List<IndianMeal> meals;

  const DailyDietPlan({
    required this.dayIndex,
    required this.dayName,
    required this.theme,
    required this.totalCalories,
    required this.totalProtein,
    required this.meals,
  });
}

class DietSwap {
  final String unhealthyItem;
  final String healthySwap;
  final String benefit;
  final String impact;

  const DietSwap({
    required this.unhealthyItem,
    required this.healthySwap,
    required this.benefit,
    required this.impact,
  });
}

class IndianDietPlan {
  final String preference; // 'Vegetarian', 'Vegan', 'Non-Vegetarian'
  final String goal;
  final int dailyCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFats;
  final int targetFiber;
  final double waterLiters;
  final List<DailyDietPlan> weeklyDays;
  final List<DietSwap> smartSwaps;
  final List<String> nutritionHighlights;

  const IndianDietPlan({
    required this.preference,
    required this.goal,
    required this.dailyCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.targetFiber,
    required this.waterLiters,
    required this.weeklyDays,
    required this.smartSwaps,
    required this.nutritionHighlights,
  });

  DailyDietPlan getDay(int dayIndex) {
    if (weeklyDays.isEmpty) {
      return DailyDietPlan(
        dayIndex: 0,
        dayName: 'Today',
        theme: 'Balanced Nutrition',
        totalCalories: dailyCalories,
        totalProtein: targetProtein,
        meals: const [],
      );
    }
    return weeklyDays[dayIndex.clamp(0, weeklyDays.length - 1)];
  }

  // Backwards-compatible getter for first day's meals
  List<IndianMeal> get meals => weeklyDays.isNotEmpty ? weeklyDays.first.meals : const [];
}
