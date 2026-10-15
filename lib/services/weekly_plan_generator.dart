import '../models/user.dart';
import '../models/weekly_workout_plan.dart';

class WeeklyPlanGenerator {
  static WeeklyWorkoutPlan generatePlan(User user) {
    final isOverweight = user.bmi >= 25.0;
    final isUnderweight = user.bmi < 18.5;
    final level = user.fitnessLevel;
    final goal = user.goal;

    // Intensity scaling by fitness level
    final setMultiplier = switch (level) {
      'Beginner' => 3,
      'Intermediate' => 4,
      'Advanced' => 4,
      _ => 3,
    };

    final repsDesc = switch (level) {
      'Beginner' => '10 reps',
      'Intermediate' => '12-15 reps',
      'Advanced' => '15-20 reps',
      _ => '12 reps',
    };

    final timerDesc = switch (level) {
      'Beginner' => '30 sec',
      'Intermediate' => '45 sec',
      'Advanced' => '60 sec',
      _ => '40 sec',
    };

    final restSec = switch (level) {
      'Beginner' => 60,
      'Intermediate' => 45,
      'Advanced' => 30,
      _ => 45,
    };

    final days = <DailyWorkoutPlan>[];

    if (goal == 'Lose weight') {
      // --- FAT LOSS & METABOLIC PROTOCOL ---
      days.add(
        DailyWorkoutPlan(
          dayIndex: 0,
          dayName: 'Monday',
          title: 'Day 1: Metabolic Leg & Calorie Burn',
          focusArea: 'Lower Body & Cardio',
          description: isOverweight
              ? 'Low-impact knee-friendly metabolic circuit to maximize caloric expenditure while protecting joints.'
              : 'High-tempo lower body explosive circuit to trigger post-exercise oxygen consumption (EPOC).',
          isRestDay: false,
          estimatedMinutes: 28,
          estimatedCalories: (user.weight * 3.8).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'squats',
              name: 'Bodyweight Squats',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Quadriceps & Glutes',
              cue: 'Drive through mid-foot and maintain an upright chest.',
            ),
            PlanExerciseItem(
              exerciseId: isOverweight ? 'wall_sit' : 'jumping_jacks',
              name: isOverweight ? 'Isometric Wall Sit' : 'Jumping Jacks',
              sets: setMultiplier,
              repsOrDuration: isOverweight ? timerDesc : '30-40 reps',
              restSeconds: restSec,
              primaryMuscle: isOverweight ? 'Quads' : 'Full Body Cardio',
              cue: isOverweight
                  ? 'Keep knees at 90° and back pressed flat against wall.'
                  : 'Soft balls of feet landing to absorb joint impact.',
            ),
            PlanExerciseItem(
              exerciseId: 'lunges',
              name: 'Alternating Walking Lunges',
              sets: setMultiplier,
              repsOrDuration: '10 reps/leg',
              restSeconds: restSec,
              primaryMuscle: 'Glutes & Hip Stabilizers',
              cue: 'Step forward smoothly; do not let lead knee drift inward.',
            ),
            PlanExerciseItem(
              exerciseId: 'high_knees',
              name: isOverweight ? 'Paced High Knee Drives' : 'High Knees Sprint',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Hip Flexors & Core',
              cue: 'Drive knees to hip height while pumping opposing arms.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 1,
          dayName: 'Tuesday',
          title: 'Day 2: Upper Body & Core Hyper-Burn',
          focusArea: 'Chest, Arms & Abs',
          description: 'Upper torso strength blended with core tension to sustain high fat oxidation.',
          isRestDay: false,
          estimatedMinutes: 25,
          estimatedCalories: (user.weight * 3.4).round(),
          intensity: 'Moderate',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'pushups',
              name: 'Standard / Incline Push-ups',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Pectorals & Triceps',
              cue: 'Elbows at 45° angle to torso; core locked tight.',
            ),
            PlanExerciseItem(
              exerciseId: 'shoulder_press',
              name: 'Overhead Shoulder Press',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Deltoids & Traps',
              cue: 'Press straight overhead without overarching lumbar spine.',
            ),
            PlanExerciseItem(
              exerciseId: 'plank',
              name: 'Forearm Core Plank',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Transverse Abdominis',
              cue: 'Posterior pelvic tilt; squeeze glutes and brace stomach.',
            ),
            PlanExerciseItem(
              exerciseId: 'mountain_climbers',
              name: 'Mountain Climbers',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Core & Shoulders',
              cue: 'Keep hips low and drive knees rhythmically under chest.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 2,
          dayName: 'Wednesday',
          title: 'Day 3: Active Rest & Joint Flush',
          focusArea: 'Mobility & Recovery',
          description: 'Active restoration to accelerate lymphatic drainage and lower cortisol levels.',
          isRestDay: false,
          estimatedMinutes: 18,
          estimatedCalories: (user.weight * 1.8).round(),
          intensity: 'Recovery',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'child_pose',
              name: 'Child’s Pose Lat Stretch',
              sets: 3,
              repsOrDuration: '45 sec',
              restSeconds: 30,
              primaryMuscle: 'Lats & Lower Back',
              cue: 'Deep diaphragmatic breathing; extend fingertips forward.',
            ),
            PlanExerciseItem(
              exerciseId: 'glute_bridges',
              name: 'Glute Bridges',
              sets: 3,
              repsOrDuration: '15 reps',
              restSeconds: 30,
              primaryMuscle: 'Glutes & Hamstrings',
              cue: 'Pause 2 seconds at top contraction.',
            ),
            PlanExerciseItem(
              exerciseId: 'cat_cow',
              name: 'Cat-Cow Spinal Flow',
              sets: 3,
              repsOrDuration: '45 sec',
              restSeconds: 30,
              primaryMuscle: 'Erector Spinae',
              cue: 'Inhale on cow arch; exhale on cat spinal dome.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 3,
          dayName: 'Thursday',
          title: 'Day 4: Posterior Chain & Glute Sculpt',
          focusArea: 'Hamstrings, Glutes & Back',
          description: 'Targeting largest muscle groups for maximum basal metabolic stimulus.',
          isRestDay: false,
          estimatedMinutes: 30,
          estimatedCalories: (user.weight * 4.0).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'sumo_squats',
              name: 'Wide Stance Sumo Squats',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Adductors & Glutes',
              cue: 'Toes out 45°; push knees wide over toes.',
            ),
            PlanExerciseItem(
              exerciseId: 'bicep_curls',
              name: 'Bicep Curls (Band / Weight)',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Biceps Brachii',
              cue: 'Pin elbows to sides; avoid momentum swing.',
            ),
            PlanExerciseItem(
              exerciseId: 'lunges',
              name: 'Reverse Lunges',
              sets: setMultiplier,
              repsOrDuration: '10 reps/side',
              restSeconds: restSec,
              primaryMuscle: 'Hamstrings & Glutes',
              cue: 'Step backward softly to minimize patellar pressure.',
            ),
            PlanExerciseItem(
              exerciseId: 'wall_sit',
              name: 'Isometric Wall Sit Burnout',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Quadriceps',
              cue: 'Breathe steadily through the muscular fatigue burn.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 4,
          dayName: 'Friday',
          title: 'Day 5: Total Body Metabolic Ignition',
          focusArea: 'Full Body HIIT',
          description: 'Full body dynamic intervals to peak fat oxidation ahead of the weekend.',
          isRestDay: false,
          estimatedMinutes: 30,
          estimatedCalories: (user.weight * 4.2).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'squats',
              name: 'Tempo Squats (3s Descent)',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Quads & Glutes',
              cue: 'Slow 3-second descent, explosive 1-second ascent.',
            ),
            PlanExerciseItem(
              exerciseId: 'pushups',
              name: 'Tempo Push-ups',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Pectorals & Triceps',
              cue: 'Touch chest to bottom without sagging hips.',
            ),
            PlanExerciseItem(
              exerciseId: 'mountain_climbers',
              name: 'Mountain Climbers Interval',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Core & Calves',
              cue: 'Consistent tempo; knees directly toward chest.',
            ),
            PlanExerciseItem(
              exerciseId: 'plank',
              name: 'High-to-Low Plank',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Core & Shoulders',
              cue: 'Keep hips square and stable throughout.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 5,
          dayName: 'Saturday',
          title: 'Day 6: Deep Core & Abdominal Definition',
          focusArea: 'Core & Functional Midsection',
          description: 'Anti-rotational and flexion stability to cinch the waistline.',
          isRestDay: false,
          estimatedMinutes: 22,
          estimatedCalories: (user.weight * 2.8).round(),
          intensity: 'Moderate',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'plank',
              name: 'Extended Forearm Plank',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Core & Lower Back',
              cue: 'Maintain rigid spinal line from head to heels.',
            ),
            PlanExerciseItem(
              exerciseId: 'bicycle_crunches',
              name: 'Bicycle Crunches',
              sets: setMultiplier,
              repsOrDuration: '16 reps (8/side)',
              restSeconds: restSec,
              primaryMuscle: 'Internal & External Obliques',
              cue: 'Rotate shoulder across, not just the elbow.',
            ),
            PlanExerciseItem(
              exerciseId: 'bird_dog',
              name: 'Bird Dog Balance & Reach',
              sets: 3,
              repsOrDuration: '10 reps/side',
              restSeconds: 30,
              primaryMuscle: 'Lower Back & Glutes',
              cue: 'Reach heel back straight without hyperextending spine.',
            ),
            PlanExerciseItem(
              exerciseId: 'glute_bridges',
              name: 'Single-Leg Glute Bridges',
              sets: 3,
              repsOrDuration: '8 reps/side',
              restSeconds: 30,
              primaryMuscle: 'Glutes',
              cue: 'Drive purely from the plant heel.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 6,
          dayName: 'Sunday',
          title: 'Day 7: Full Regeneration & Reset',
          focusArea: 'Rest & Neurological Recovery',
          description: 'Full day of deep restorative rest, hydration replenishment, and muscle repair.',
          isRestDay: true,
          estimatedMinutes: 0,
          estimatedCalories: 0,
          intensity: 'Recovery',
          exercises: [],
        ),
      );
    } else {
      // --- STRENGTH / HYPERTROPHY / GENERAL FITNESS PROTOCOL ---
      days.add(
        DailyWorkoutPlan(
          dayIndex: 0,
          dayName: 'Monday',
          title: 'Day 1: Upper Body Push & Press Power',
          focusArea: 'Chest, Shoulders & Triceps',
          description: isUnderweight
              ? 'Progressive mechanical overload to trigger muscular hypertrophy and protein synthesis.'
              : 'Compound pushing volume to build upper body mass and joint stability.',
          isRestDay: false,
          estimatedMinutes: 30,
          estimatedCalories: (user.weight * 3.5).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'pushups',
              name: 'Full Range Push-ups',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Chest & Triceps',
              cue: 'Full extension at top; lower chest until 2 inches from ground.',
            ),
            PlanExerciseItem(
              exerciseId: 'shoulder_press',
              name: 'Strict Overhead Shoulder Press',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Anterior & Lateral Deltoids',
              cue: 'Brace abdominals; press weight straight to lockout.',
            ),
            PlanExerciseItem(
              exerciseId: 'lateral_raises',
              name: 'Lateral Deltoid Raises',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Side Deltoids',
              cue: 'Lead with elbows and pour hands slightly at top.',
            ),
            PlanExerciseItem(
              exerciseId: 'plank',
              name: 'High Plank Shoulder Taps',
              sets: 3,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Core & Anterior Deltoid',
              cue: 'Resist hip rotation as each hand taps opposite shoulder.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 1,
          dayName: 'Tuesday',
          title: 'Day 2: Lower Body Quad & Glute Dominance',
          focusArea: 'Quads, Adductors & Calves',
          description: 'Fundamental squat and lunge mechanics for raw leg power and hormonal stimulus.',
          isRestDay: false,
          estimatedMinutes: 32,
          estimatedCalories: (user.weight * 4.1).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'squats',
              name: 'Deep Barbell / Bodyweight Squats',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec + 15,
              primaryMuscle: 'Quadriceps & Gluteus Maximus',
              cue: 'Break at hips and knees simultaneously; knees track toes.',
            ),
            PlanExerciseItem(
              exerciseId: 'lunges',
              name: 'Deficit Forward Lunges',
              sets: setMultiplier,
              repsOrDuration: '10 reps/leg',
              restSeconds: restSec,
              primaryMuscle: 'Glutes & VMO Quad',
              cue: '90° knee angle in front and back leg at bottom.',
            ),
            PlanExerciseItem(
              exerciseId: 'wall_sit',
              name: 'Isometric Wall Sit',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Quadriceps',
              cue: 'Thighs strictly parallel to ground; breathe smoothly.',
            ),
            PlanExerciseItem(
              exerciseId: 'calf_raises',
              name: 'Standing Calf Raises',
              sets: setMultiplier,
              repsOrDuration: '15-20 reps',
              restSeconds: 30,
              primaryMuscle: 'Gastrocnemius & Soleus',
              cue: 'Peak squeeze at the top of ankle plantarflexion for 1 sec.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 2,
          dayName: 'Wednesday',
          title: 'Day 3: Mid-Week Core & Active Mobility',
          focusArea: 'Core & Spine Decompression',
          description: 'Strengthen the muscular corset and restore full thoracic and hip rotation.',
          isRestDay: false,
          estimatedMinutes: 20,
          estimatedCalories: (user.weight * 2.0).round(),
          intensity: 'Recovery',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'plank',
              name: 'Forearm Plank',
              sets: 3,
              repsOrDuration: timerDesc,
              restSeconds: 45,
              primaryMuscle: 'Core',
              cue: 'Tuck pelvis under and drive elbows toward toes.',
            ),
            PlanExerciseItem(
              exerciseId: 'bicycle_crunches',
              name: 'Bicycle Crunches',
              sets: 3,
              repsOrDuration: '16 reps',
              restSeconds: 30,
              primaryMuscle: 'Obliques',
              cue: 'Slow 2-second rotation per side.',
            ),
            PlanExerciseItem(
              exerciseId: 'child_pose',
              name: 'Child’s Pose',
              sets: 3,
              repsOrDuration: '45 sec',
              restSeconds: 30,
              primaryMuscle: 'Lats & Spine',
              cue: 'Sink hips into heels and let chest melt to floor.',
            ),
            PlanExerciseItem(
              exerciseId: 'cobra_stretch',
              name: 'Prone Cobra Stretch',
              sets: 3,
              repsOrDuration: '30 sec',
              restSeconds: 30,
              primaryMuscle: 'Abdominals & Hip Flexors',
              cue: 'Roll shoulders back away from ears; lengthen neck.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 3,
          dayName: 'Thursday',
          title: 'Day 4: Upper Body Pull & Arm Hypertrophy',
          focusArea: 'Biceps, Back & Rear Shoulders',
          description: 'Focus on elbow flexion and scapular retraction for balanced upper body posture.',
          isRestDay: false,
          estimatedMinutes: 28,
          estimatedCalories: (user.weight * 3.3).round(),
          intensity: 'Moderate',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'bicep_curls',
              name: 'Strict Bicep Curls',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Biceps Brachii',
              cue: 'Supinate wrists at top for maximum peak bicep recruitment.',
            ),
            PlanExerciseItem(
              exerciseId: 'lateral_raises',
              name: 'Shoulder Lateral Raises',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Lateral Deltoids',
              cue: 'Raise weights until arms are parallel to floor.',
            ),
            PlanExerciseItem(
              exerciseId: 'pushups',
              name: 'Close-Grip Diamond Push-ups',
              sets: 3,
              repsOrDuration: '8-12 reps',
              restSeconds: restSec,
              primaryMuscle: 'Triceps Brachii',
              cue: 'Thumbs and index fingers touching under sternum.',
            ),
            PlanExerciseItem(
              exerciseId: 'bird_dog',
              name: 'Bird Dog Stabilizers',
              sets: 3,
              repsOrDuration: '10 reps/side',
              restSeconds: 30,
              primaryMuscle: 'Posterior Sling',
              cue: 'Hold extension for 2 seconds with zero lumbar rotation.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 4,
          dayName: 'Friday',
          title: 'Day 5: Posterior Chain & Hamstring Power',
          focusArea: 'Glutes, Hamstrings & Adductors',
          description: 'Posterior chain recruitment to build athletic speed, jump height, and posture.',
          isRestDay: false,
          estimatedMinutes: 30,
          estimatedCalories: (user.weight * 3.9).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'sumo_squats',
              name: 'Sumo Squats',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Inner Thighs & Glutes',
              cue: 'Chest high; push knees actively outward.',
            ),
            PlanExerciseItem(
              exerciseId: 'glute_bridges',
              name: 'Weighted / Elevated Glute Bridges',
              sets: setMultiplier,
              repsOrDuration: '15 reps',
              restSeconds: restSec,
              primaryMuscle: 'Gluteus Maximus',
              cue: 'Squeeze glutes at top like holding a coin.',
            ),
            PlanExerciseItem(
              exerciseId: 'lunges',
              name: 'Reverse Deficit Lunges',
              sets: setMultiplier,
              repsOrDuration: '10 reps/side',
              restSeconds: restSec,
              primaryMuscle: 'Hamstrings & Glutes',
              cue: 'Control the descent slowly to recruit stabilizing muscle fibers.',
            ),
            PlanExerciseItem(
              exerciseId: 'wall_sit',
              name: 'Isometric Wall Sit',
              sets: 3,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Quadriceps',
              cue: 'Keep weight through midfoot and heels.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 5,
          dayName: 'Saturday',
          title: 'Day 6: Functional Full Body Conditioning',
          focusArea: 'Full Body Athletic Power',
          description: 'Integrates all major movement patterns for functional power and conditioning.',
          isRestDay: false,
          estimatedMinutes: 28,
          estimatedCalories: (user.weight * 3.7).round(),
          intensity: 'High',
          exercises: [
            PlanExerciseItem(
              exerciseId: 'squats',
              name: 'Bodyweight Squats',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Full Legs',
              cue: 'Fast ascent, controlled descent.',
            ),
            PlanExerciseItem(
              exerciseId: 'pushups',
              name: 'Push-ups',
              sets: setMultiplier,
              repsOrDuration: repsDesc,
              restSeconds: restSec,
              primaryMuscle: 'Chest & Arms',
              cue: 'Keep core braced like an arrow.',
            ),
            PlanExerciseItem(
              exerciseId: 'mountain_climbers',
              name: 'Mountain Climbers',
              sets: setMultiplier,
              repsOrDuration: timerDesc,
              restSeconds: restSec,
              primaryMuscle: 'Core & Shoulders',
              cue: 'Sprint pace while holding shoulders rigid.',
            ),
            PlanExerciseItem(
              exerciseId: 'plank',
              name: 'Plank Hold Finisher',
              sets: 3,
              repsOrDuration: timerDesc,
              restSeconds: 30,
              primaryMuscle: 'Core',
              cue: 'Total body contraction from neck to calves.',
            ),
          ],
        ),
      );

      days.add(
        DailyWorkoutPlan(
          dayIndex: 6,
          dayName: 'Sunday',
          title: 'Day 7: Full Regeneration & Growth Rest',
          focusArea: 'Rest & Neurological Recovery',
          description: 'Rest is where protein synthesis occurs. Focus on deep sleep and optimal nutrition.',
          isRestDay: true,
          estimatedMinutes: 0,
          estimatedCalories: 0,
          intensity: 'Recovery',
          exercises: [],
        ),
      );
    }

    final totalWeeklyCals = days.fold<int>(0, (sum, d) => sum + d.estimatedCalories);

    final summary = switch (goal) {
      'Lose weight' =>
        'Customized 6-Day Metabolic Protocol calibrated for ${user.weight}kg (${user.bmiCategory}). Focuses on sustained caloric output with joint-safe mechanics.',
      'Build strength' =>
        'Customized Hypertrophy & Power Split tailored for ${user.height}cm / ${user.weight}kg. High mechanical tension and progressive volume.',
      'Improve mobility' =>
        'Joint Stability & Mobility Protocol emphasizing spinal decompression and kinetic chain flow.',
      _ =>
        'All-Around Functional Conditioning Plan balancing cardiovascular endurance with compound muscular strength.',
    };

    return WeeklyWorkoutPlan(
      goal: goal,
      fitnessLevel: level,
      focusSummary: summary,
      targetWeeklyCalories: totalWeeklyCals,
      days: days,
    );
  }
}
