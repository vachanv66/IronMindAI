PLANS = {
    "Build strength": ["Push-ups", "Squats", "Lunges", "Plank"],
    "Lose weight": ["Jumping Jacks", "Squats", "Lunges", "Plank"],
    "Improve fitness": ["Jumping Jacks", "Push-ups", "Squats", "Plank"],
    "Improve mobility": ["Lunges", "Squats", "Plank"],
}


def workout_for_goal(goal: str) -> list[str]:
    return PLANS.get(goal, PLANS["Improve fitness"])
