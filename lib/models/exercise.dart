import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final String target;
  final String kind; // 'reps' or 'timer'
  final String description;
  final List<String> correctFormGuide;
  final List<String> commonErrors;
  final List<String> targetMuscles;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.target,
    required this.kind,
    required this.description,
    required this.correctFormGuide,
    required this.commonErrors,
    required this.targetMuscles,
  });
}

const List<Exercise> exerciseCatalog = [
  // --- LOWER BODY ---
  Exercise(
    id: 'squats',
    name: 'Squats',
    category: 'Lower Body',
    icon: Icons.accessibility_new,
    target: '3 sets × 12 reps',
    kind: 'reps',
    description: 'A fundamental lower-body exercise that targets the quadriceps, hamstrings, and glutes.',
    correctFormGuide: [
      'Keep feet shoulder-width apart.',
      'Lower hips until knees reach a 90° bend.',
      'Maintain a neutral spine and chest proud.',
    ],
    commonErrors: [
      'Knees caving inward past toes.',
      'Rounding the lower back during descent.',
    ],
    targetMuscles: ['Quads', 'Glutes', 'Hamstrings'],
  ),
  Exercise(
    id: 'lunges',
    name: 'Lunges',
    category: 'Lower Body',
    icon: Icons.directions_walk,
    target: '3 sets × 10 reps',
    kind: 'reps',
    description: 'Unilateral leg strength builder for quad, glute, and hip stability.',
    correctFormGuide: [
      'Step forward keeping front knee over ankle.',
      'Lower rear knee toward the floor.',
      'Keep upper body upright and core engaged.',
    ],
    commonErrors: [
      'Leaning torso too far forward.',
      'Front knee extending far past front toes.',
    ],
    targetMuscles: ['Quads', 'Glutes', 'Calves'],
  ),
  Exercise(
    id: 'sumo_squat',
    name: 'Sumo Squats',
    category: 'Lower Body',
    icon: Icons.sports_gymnastics,
    target: '3 sets × 12 reps',
    kind: 'reps',
    description: 'Wide-stance squat emphasizing the inner thighs (adductors) and glutes.',
    correctFormGuide: [
      'Set stance 1.5x shoulder width with toes angled 45° outward.',
      'Lower hips while pushing knees outward along toe angle.',
      'Keep torso upright throughout the motion.',
    ],
    commonErrors: ['Knees collapsing inward', 'Shallow squat depth'],
    targetMuscles: ['Adductors', 'Glutes', 'Quads'],
  ),
  Exercise(
    id: 'calf_raises',
    name: 'Calf Raises',
    category: 'Lower Body',
    icon: Icons.height,
    target: '3 sets × 15 reps',
    kind: 'reps',
    description: 'Isolates gastrocnemius and soleus muscles for ankle stability and calf strength.',
    correctFormGuide: [
      'Stand feet hip-width apart.',
      'Press through the balls of feet to elevate body straight up.',
      'Pause at the peak for 1 second before lowering slowly.',
    ],
    commonErrors: ['Rocking body weight backward', 'Rushing reps without peak hold'],
    targetMuscles: ['Calves', 'Ankle Stabilizers'],
  ),
  Exercise(
    id: 'glute_bridge',
    name: 'Glute Bridges',
    category: 'Lower Body',
    icon: Icons.horizontal_distribute,
    target: '3 sets × 15 reps',
    kind: 'reps',
    description: 'Lying hip extension movement targeting posterior chain and glute activation.',
    correctFormGuide: [
      'Lie on back with knees bent and feet flat on floor.',
      'Drive through heels to lift hips until knees, hips, and shoulders form a straight line.',
      'Squeeze glutes tightly at the top.',
    ],
    commonErrors: ['Arching the lower back excessively', 'Pushing through toes instead of heels'],
    targetMuscles: ['Glutes', 'Hamstrings', 'Lower Back'],
  ),
  Exercise(
    id: 'wall_sit',
    name: 'Wall Sit',
    category: 'Lower Body',
    icon: Icons.chair,
    target: '3 sets × 30 sec',
    kind: 'timer',
    description: 'Isometric quad endurance exercise holding a 90° knee angle against a surface.',
    correctFormGuide: [
      'Press back flat against wall.',
      'Slide down until knees form a 90° angle.',
      'Keep thighs parallel to the ground.',
    ],
    commonErrors: ['Resting hands on knees', 'Sliding hips too high or low'],
    targetMuscles: ['Quads', 'Glutes'],
  ),
  Exercise(
    id: 'side_lunges',
    name: 'Side Lunges',
    category: 'Lower Body',
    icon: Icons.swap_calls,
    target: '3 sets × 10 reps',
    kind: 'reps',
    description: 'Lateral leg movement strengthening adductors, hips, and quads.',
    correctFormGuide: [
      'Take a wide step to the side and bend trailing knee.',
      'Keep opposite leg straight and trailing heel grounded.',
      'Push off side foot to return to standing.',
    ],
    commonErrors: ['Rounding spine forward', 'Lifting trailing foot heel'],
    targetMuscles: ['Quads', 'Adductors', 'Glutes'],
  ),

  // --- UPPER BODY ---
  Exercise(
    id: 'pushups',
    name: 'Push-ups',
    category: 'Upper Body',
    icon: Icons.fitness_center,
    target: '3 sets × 10 reps',
    kind: 'reps',
    description: 'Classic upper-body pushing exercise for chest, shoulders, and triceps.',
    correctFormGuide: [
      'Place hands slightly wider than shoulder width.',
      'Keep hips, spine, and head in a straight line.',
      'Lower chest until elbows reach 90° angle.',
    ],
    commonErrors: ['Hip sagging or arching lower back', 'Elbows flaring out at 90° to torso'],
    targetMuscles: ['Pectorals', 'Triceps', 'Anterior Deltoids'],
  ),
  Exercise(
    id: 'bicep_curls',
    name: 'Bicep Curls',
    category: 'Upper Body',
    icon: Icons.sports_mma,
    target: '3 sets × 12 reps',
    kind: 'reps',
    description: 'Arm flexion exercise targeting the biceps brachii with strict elbow positioning.',
    correctFormGuide: [
      'Pin elbows close to ribcage throughout movement.',
      'Curl palms upward toward shoulders in a smooth arc.',
      'Lower down slowly without swinging torso.',
    ],
    commonErrors: ['Swinging upper body for momentum', 'Elbows drifting forward'],
    targetMuscles: ['Biceps', 'Brachialis'],
  ),
  Exercise(
    id: 'shoulder_press',
    name: 'Shoulder Press',
    category: 'Upper Body',
    icon: Icons.north,
    target: '3 sets × 10 reps',
    kind: 'reps',
    description: 'Overhead pushing exercise for deltoid strength and shoulder mobility.',
    correctFormGuide: [
      'Start with hands at shoulder level with palms facing forward.',
      'Press arms overhead until wrists are aligned above shoulders.',
      'Lower down with control back to shoulder height.',
    ],
    commonErrors: ['Arching lower back excessively', 'Not extending arms fully overhead'],
    targetMuscles: ['Deltoids', 'Triceps', 'Upper Chest'],
  ),
  Exercise(
    id: 'lateral_raises',
    name: 'Lateral Arm Raises',
    category: 'Upper Body',
    icon: Icons.open_in_full,
    target: '3 sets × 12 reps',
    kind: 'reps',
    description: 'Shoulder abduction exercise building side deltoid width and stability.',
    correctFormGuide: [
      'Stand tall with slight bend in elbows.',
      'Raise arms out to sides until parallel to the floor.',
      'Lower down smoothly without shrugging shoulders.',
    ],
    commonErrors: ['Shrugging shoulders into neck', 'Using momentum to swing arms'],
    targetMuscles: ['Lateral Deltoids', 'Trapezius'],
  ),
  Exercise(
    id: 'tricep_dips',
    name: 'Tricep Dips',
    category: 'Upper Body',
    icon: Icons.south,
    target: '3 sets × 10 reps',
    kind: 'reps',
    description: 'Bodyweight pressing exercise isolating triceps brachii.',
    correctFormGuide: [
      'Grip bench or floor behind hips with knuckles facing forward.',
      'Bend elbows backward to lower hips until upper arms are parallel to floor.',
      'Press firmly through palms to straighten arms.',
    ],
    commonErrors: ['Elbows flaring outward', 'Shallow depth of descent'],
    targetMuscles: ['Triceps', 'Anterior Deltoids'],
  ),
  Exercise(
    id: 'arm_circles',
    name: 'Arm Circles',
    category: 'Upper Body',
    icon: Icons.sync,
    target: '3 sets × 30 sec',
    kind: 'timer',
    description: 'Rotational shoulder conditioning and warm-up exercise.',
    correctFormGuide: [
      'Extend arms straight out to sides at shoulder height.',
      'Rotate arms in smooth 12-inch circles.',
      'Keep core engaged and shoulders depressed.',
    ],
    commonErrors: ['Dropping arms below shoulder height', 'Bending elbows'],
    targetMuscles: ['Rotator Cuff', 'Deltoids'],
  ),

  // --- CORE & ABS ---
  Exercise(
    id: 'plank',
    name: 'Plank',
    category: 'Core',
    icon: Icons.horizontal_rule,
    target: '3 sets × 30 sec',
    kind: 'timer',
    description: 'Isometric core stability hold strengthening the full abdominal wall and spine.',
    correctFormGuide: [
      'Place forearms on floor with elbows directly under shoulders.',
      'Maintain a rigid straight line from head to ankles.',
      'Squeeze glutes and pull navel toward spine.',
    ],
    commonErrors: ['Hips sagging toward floor', 'Piking hips into the air'],
    targetMuscles: ['Transverse Abdominis', 'Rectus Abdominis', 'Obliques'],
  ),
  Exercise(
    id: 'crunches',
    name: 'Crunches',
    category: 'Core',
    icon: Icons.airline_seat_recline_extra,
    target: '3 sets × 15 reps',
    kind: 'reps',
    description: 'Thoracic flexion exercise targeting upper rectus abdominis.',
    correctFormGuide: [
      'Lie on back with knees bent and feet flat.',
      'Flex shoulders off floor by contracting abdominal muscles.',
      'Exhale on the upward contraction.',
    ],
    commonErrors: ['Pulling neck with hands', 'Lifting lower back off the ground'],
    targetMuscles: ['Upper Abdominis'],
  ),
  Exercise(
    id: 'leg_raises',
    name: 'Leg Raises',
    category: 'Core',
    icon: Icons.vertical_align_top,
    target: '3 sets × 12 reps',
    kind: 'reps',
    description: 'Lower abdominal isolation exercise lifting straight legs with core control.',
    correctFormGuide: [
      'Lie flat with hands supporting under lower back/hips.',
      'Keep legs straight and raise ankles toward ceiling until 90°.',
      'Lower legs slowly without letting heels touch floor.',
    ],
    commonErrors: ['Arching lower back off floor', 'Using momentum to swing legs'],
    targetMuscles: ['Lower Abdominis', 'Hip Flexors'],
  ),
  Exercise(
    id: 'mountain_climbers',
    name: 'Mountain Climbers',
    category: 'Core',
    icon: Icons.directions_run,
    target: '3 sets × 20 reps',
    kind: 'reps',
    description: 'Dynamic plank variation driving knees rapidly toward chest for core & cardio.',
    correctFormGuide: [
      'Begin in high plank position with shoulders over wrists.',
      'Drive one knee straight toward chest, then quickly switch legs.',
      'Keep hips stable and level throughout dynamic drive.',
    ],
    commonErrors: ['Piking hips high in air', 'Bouncing shoulders up and down'],
    targetMuscles: ['Rectus Abdominis', 'Hip Flexors', 'Cardio System'],
  ),
  Exercise(
    id: 'russian_twists',
    name: 'Russian Twists',
    category: 'Core',
    icon: Icons.screen_rotation,
    target: '3 sets × 20 reps',
    kind: 'reps',
    description: 'Rotational core movement strengthening internal and external obliques.',
    correctFormGuide: [
      'Sit with knees bent, feet slightly elevated or light heel tap.',
      'Lean torso back to a 45° angle.',
      'Rotate shoulders and hands from side to side smoothly.',
    ],
    commonErrors: ['Moving only arms without torso rotation', 'Slouching spine'],
    targetMuscles: ['Obliques', 'Transverse Abdominis'],
  ),
  Exercise(
    id: 'side_plank',
    name: 'Side Plank',
    category: 'Core',
    icon: Icons.border_vertical,
    target: '3 sets × 30 sec',
    kind: 'timer',
    description: 'Unilateral lateral core hold strengthening obliques and lateral hip stabilizers.',
    correctFormGuide: [
      'Lie on side supported by forearm under shoulder.',
      'Lift hips until body forms a straight diagonal line.',
      'Keep top arm reaching upward or rested on hip.',
    ],
    commonErrors: ['Hips sagging toward floor', 'Top shoulder rolling forward'],
    targetMuscles: ['Obliques', 'Gluteus Medius'],
  ),

  // --- CARDIO & FULL BODY ---
  Exercise(
    id: 'jumping_jacks',
    name: 'Jumping Jacks',
    category: 'Cardio',
    icon: Icons.air,
    target: '3 sets × 20 reps',
    kind: 'reps',
    description: 'Full-body cardiovascular exercise expanding arms overhead and legs outward.',
    correctFormGuide: [
      'Jump feet outward wider than shoulders while swinging arms overhead.',
      'Land softly on balls of feet.',
      'Jump back to starting position immediately.',
    ],
    commonErrors: ['Landing heavily on flat feet', 'Half-hearted arm extension'],
    targetMuscles: ['Full Body Cardio', 'Calves', 'Deltoids'],
  ),
  Exercise(
    id: 'high_knees',
    name: 'High Knees',
    category: 'Cardio',
    icon: Icons.speed,
    target: '3 sets × 20 reps',
    kind: 'reps',
    description: 'High-intensity dynamic running movement lifting knees to hip height.',
    correctFormGuide: [
      'Run in place lifting knees up to hip level (90° bend).',
      'Pump arms rhythmically in opposition to legs.',
      'Stay light on balls of feet.',
    ],
    commonErrors: ['Leaning backward during knee drive', 'Knees elevated below waist level'],
    targetMuscles: ['Hip Flexors', 'Quads', 'Cardiovascular System'],
  ),
  Exercise(
    id: 'butt_kicks',
    name: 'Butt Kicks',
    category: 'Cardio',
    icon: Icons.directions_bike,
    target: '3 sets × 20 reps',
    kind: 'reps',
    description: 'Rapid hamstring contraction cardio drill driving heels toward glutes.',
    correctFormGuide: [
      'Jog in place flexing knees backward to bring heels toward glutes.',
      'Keep thighs perpendicular to floor.',
      'Maintain quick cadence.',
    ],
    commonErrors: ['Kicking legs forward', 'Slouching upper body'],
    targetMuscles: ['Hamstrings', 'Calves'],
  ),
  Exercise(
    id: 'burpees',
    name: 'Burpees',
    category: 'Cardio',
    icon: Icons.bolt,
    target: '3 sets × 10 reps',
    kind: 'reps',
    description: 'Full-body explosive exercise combining squat, plank, push-up, and vertical jump.',
    correctFormGuide: [
      'Squat down and place hands flat on floor.',
      'Kick feet back into plank position, do a push-up.',
      'Hop feet forward to hands and jump up with hands overhead.',
    ],
    commonErrors: ['Sagging lower back in plank', 'Skipping vertical jump'],
    targetMuscles: ['Full Body', 'Cardio', 'Core'],
  ),

  // --- MOBILITY & FLEXIBILITY ---
  Exercise(
    id: 'cobra_stretch',
    name: 'Cobra Stretch',
    category: 'Mobility',
    icon: Icons.self_improvement,
    target: '3 sets × 30 sec',
    kind: 'timer',
    description: 'Abdominal and anterior spine stretch relieving chest and lower back tightness.',
    correctFormGuide: [
      'Lie face down with hands under shoulders.',
      'Press through palms to lift chest off floor while keeping hips grounded.',
      'Keep shoulders drawn away from ears.',
    ],
    commonErrors: ['Shrugging shoulders into ears', 'Lifting hips off ground'],
    targetMuscles: ['Abdominals', 'Spinal Erectors'],
  ),
  Exercise(
    id: 'child_pose',
    name: 'Child’s Pose',
    category: 'Mobility',
    icon: Icons.spa,
    target: '3 sets × 30 sec',
    kind: 'timer',
    description: 'Restorative hip and lat mobility stretch relieving tension in back and hips.',
    correctFormGuide: [
      'Kneel on floor, sit hips back onto heels.',
      'Extend arms forward flat on floor and lower forehead down.',
      'Breathe deeply expanding back ribcage.',
    ],
    commonErrors: ['Tensing shoulders', 'Forcing hips back painfully'],
    targetMuscles: ['Lats', 'Glutes', 'Spine'],
  ),
];

List<Exercise> getWorkoutPlanFor(String goal, String level) {
  final strength = exerciseCatalog.where((e) => e.category == 'Upper Body' || e.category == 'Lower Body').toList();
  final weightLoss = exerciseCatalog.where((e) => e.category == 'Cardio' || e.category == 'Core' || e.id == 'squats').toList();
  final mobility = exerciseCatalog.where((e) => e.category == 'Mobility' || e.category == 'Lower Body').toList();
  final fitness = exerciseCatalog;

  final selection = switch (goal) {
    'Build strength' => strength,
    'Lose weight' => weightLoss,
    'Improve mobility' => mobility,
    _ => fitness,
  };

  final count = level == 'Beginner' ? 4 : (level == 'Intermediate' ? 6 : 8);
  return selection.take(count).toList();
}

String getRecommendationNote(String goal, String level) => switch (goal) {
  'Build strength' =>
    '$level Strength Protocol: Focus on controlled joint movement, high muscular activation, and steady form.',
  'Lose weight' =>
    '$level Fat-Burn Protocol: High-tempo dynamic cardio & core movements to maximize metabolic rate.',
  'Improve mobility' =>
    '$level Mobility & Posture Protocol: Controlled spine, hip, and shoulder joint alignment.',
  _ => '$level All-Round Protocol: Balanced functional conditioning across all major muscle groups.',
};
