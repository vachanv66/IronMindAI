import 'package:flutter/material.dart';
import '../models/diet_plan.dart';
import '../models/exercise.dart';
import '../models/user.dart';
import '../models/weekly_workout_plan.dart';
import '../services/auth_service.dart';
import '../services/diet_service.dart';
import '../services/storage_service.dart';
import '../services/weekly_plan_generator.dart';
import '../theme/app_colors.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/pre_workout_demo_modal.dart';
import 'analytics_screen.dart';
import 'welcome_screen.dart';
import 'workout_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String goal;
  final String level;
  final User? user;

  const DashboardScreen({
    super.key,
    required this.goal,
    required this.level,
    this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0; // 0: Workouts, 1: Diet Plan, 2: Analytics, 3: Profile
  late User _currentUser;
  late WeeklyWorkoutPlan _weeklyPlan;
  late IndianDietPlan _dietPlan;
  int _selectedDayIndex = 0;
  int _selectedDietDayIndex = 0;
  String _selectedDietPreference = 'Vegetarian';
  String _selectedCategory = 'All';
  int _waterGlasses = 4;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final cached = widget.user ?? await AuthService.getCurrentUser();
    final user = cached ??
        User(
          userId: 'athlete-101',
          email: 'athlete@ironmind.ai',
          name: 'Athlete',
          fitnessLevel: widget.level,
          goal: widget.goal,
          height: 175.0,
          weight: 72.0,
          age: 26,
          gender: 'Male',
          dietaryPreference: 'Vegetarian',
        );

    _currentUser = user;
    _selectedDietPreference = user.dietaryPreference;
    _weeklyPlan = WeeklyPlanGenerator.generatePlan(user);
    _dietPlan = DietService.generateDietPlan(user, preferenceOverride: _selectedDietPreference);

    // Default selected days to today (Monday = 0 ... Sunday = 6)
    final today = (DateTime.now().weekday - 1).clamp(0, 6);
    _selectedDayIndex = today;
    _selectedDietDayIndex = today;

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _updateUserBiometrics(User updated) async {
    await StorageService.saveUserProfile(updated.toJson());
    setState(() {
      _currentUser = updated;
      _weeklyPlan = WeeklyPlanGenerator.generatePlan(updated);
      _dietPlan = DietService.generateDietPlan(updated, preferenceOverride: _selectedDietPreference);
    });
  }

  void _switchDietPreference(String pref) {
    setState(() {
      _selectedDietPreference = pref;
      _dietPlan = DietService.generateDietPlan(_currentUser, preferenceOverride: pref);
    });
  }

  List<Exercise> get _filteredCatalog {
    if (_selectedCategory == 'All') return exerciseCatalog;
    return exerciseCatalog.where((e) => e.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_currentTabIndex) {
            0 => 'IronMind • Workouts',
            1 => 'Indian Diet & Nutrition',
            2 => 'Progress Analytics',
            3 => 'Athlete Biometrics',
            _ => 'IronMind AI',
          },
        ),
        actions: [
          if (_currentTabIndex != 2)
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              tooltip: 'Analytics',
              onPressed: () => setState(() => _currentTabIndex = 2),
            ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: () async {
              final nav = Navigator.of(context);
              await AuthService.logout();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildWorkoutsTab(),
          _buildDietTab(),
          AnalyticsScreen(user: _currentUser),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center, color: AppColors.primary),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.primary),
            label: 'Diet Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 0: CUSTOM WORKOUTS & WEEKLY RECOMMENDATION PLAN
  // =========================================================================
  Widget _buildWorkoutsTab() {
    final currentDayPlan = _weeklyPlan.days[_selectedDayIndex];
    final todayWeekday = DateTime.now().weekday - 1;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Biometric Quick Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.surfaceLight.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.person_pin, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentUser.name} • ${_currentUser.fitnessLevel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal: ${_currentUser.goal} • ${_currentUser.height.toStringAsFixed(0)}cm, ${_currentUser.weight.toStringAsFixed(1)}kg (BMI ${_currentUser.bmi.toStringAsFixed(1)})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Exercise Plan (7-Day)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '~${_weeklyPlan.targetWeeklyCalories} Kcal/wk',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _weeklyPlan.focusSummary,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 14),

        // 7-Day Day Selector Bar
        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, idx) {
              final day = _weeklyPlan.days[idx];
              final isSelected = idx == _selectedDayIndex;
              final isToday = idx == todayWeekday;

              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = idx),
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday ? AppColors.primaryDark : AppColors.surface),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
                      width: isToday || isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.dayName.substring(0, 3),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.background : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        day.isRestDay ? Icons.spa : Icons.fitness_center,
                        size: 16,
                        color: isSelected
                            ? AppColors.background
                            : (day.isRestDay ? Colors.teal : AppColors.primary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Selected Day Plan Details Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDayPlan.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Focus: ${currentDayPlan.focusArea}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (!currentDayPlan.isRestDay)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${currentDayPlan.estimatedMinutes}m • ${currentDayPlan.estimatedCalories} kcal',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentDayPlan.description,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (currentDayPlan.isRestDay)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.self_improvement, color: Colors.teal, size: 32),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Recovery Day: Hydrate well, stretch, and let muscle fibers repair for maximum strength adaptation.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                const Text(
                  'Prescribed Exercises:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                ...currentDayPlan.exercises.map((item) {
                  final catalogEx = item.catalogExercise;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryDark,
                          child: Icon(
                            catalogEx?.icon ?? Icons.fitness_center,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${item.sets} sets × ${item.repsOrDuration} • ${item.primaryMuscle}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '💡 ${item.cue}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.ondemand_video, color: AppColors.primary, size: 20),
                          tooltip: 'Interactive Demo',
                          onPressed: () {
                            if (catalogEx != null) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => PreWorkoutDemoModal(
                                  exercise: catalogEx,
                                  onStartSession: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => WorkoutScreen(exercise: catalogEx)),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: AppColors.accent, size: 26),
                          tooltip: 'Start Exercise',
                          onPressed: () {
                            if (catalogEx != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => WorkoutScreen(exercise: catalogEx)),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 25+ Exercise Library Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercise Library (25+)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_filteredCatalog.length} Exercises',
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Lower Body', 'Upper Body', 'Core', 'Cardio', 'Mobility']
                .map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedCategory == cat,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        color: _selectedCategory == cat ? AppColors.background : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        ..._filteredCatalog.map(
          (e) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryDark,
                child: Icon(e.icon, color: AppColors.primary),
              ),
              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${e.category} • ${e.target}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: AppColors.textSecondary, size: 20),
                    tooltip: 'Demo',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => PreWorkoutDemoModal(
                          exercise: e,
                          onStartSession: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => WorkoutScreen(exercise: e)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.primary),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkoutScreen(exercise: e)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 1: PERSONALIZED INDIAN DIET & NUTRITION PLAN
  // =========================================================================
  Widget _buildDietTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Diet Preference Switcher Bar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: ['Vegetarian', 'Vegan', 'Non-Vegetarian'].map((pref) {
              final isSel = _selectedDietPreference == pref;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _switchDietPreference(pref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        pref,
                        style: TextStyle(
                          color: isSel ? AppColors.background : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Daily Macro Targets Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Indian Macro Targets',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_dietPlan.dailyCalories} kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMacroMiniCard('Protein', '${_dietPlan.targetProtein}g', const Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroMiniCard('Carbs', '${_dietPlan.targetCarbs}g', const Color(0xFF38BDF8)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroMiniCard('Fats', '${_dietPlan.targetFats}g', const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroMiniCard('Hydration', '${_dietPlan.waterLiters.toStringAsFixed(1)}L', const Color(0xFF06B6D4)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Hydration Tracker Quick Log
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.water_drop, color: Color(0xFF38BDF8), size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration: $_waterGlasses / 8 Glasses (${(_waterGlasses * 0.35).toStringAsFixed(1)}L logged)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (_waterGlasses / 8.0).clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_waterGlasses < 12) _waterGlasses++;
                  });
                },
                icon: const Icon(Icons.add_circle, color: Color(0xFF38BDF8), size: 26),
                tooltip: 'Log Glass',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 7-Day Food Plan Selector Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Indian Meal Plan (7-Day)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '7 Varied Menus',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Distinct, culturally authentic high-protein dishes for every day of the week.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 14),

        // 7-Day Day Selector Bar for Diet
        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, idx) {
              final day = _dietPlan.getDay(idx);
              final isSelected = idx == _selectedDietDayIndex;
              final isToday = idx == (DateTime.now().weekday - 1);

              return GestureDetector(
                onTap: () => setState(() => _selectedDietDayIndex = idx),
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday ? AppColors.primaryDark : AppColors.surface),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
                      width: isToday || isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.dayName.substring(0, 3),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.background : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: isSelected ? AppColors.background : AppColors.primary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Selected Day Theme & Meals
        Builder(
          builder: (context) {
            final currentDietDay = _dietPlan.getDay(_selectedDietDayIndex);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${currentDietDay.dayName}: ${currentDietDay.theme}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Total Day Targets: ~${currentDietDay.totalCalories} kcal • ${currentDietDay.totalProtein}g Protein',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...currentDietDay.meals.map((meal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                meal.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${meal.calories} kcal',
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${meal.timeSlot} • ${meal.protein}g Protein',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary),
                        ),
                        const Divider(color: AppColors.border, height: 16),
                        ...meal.dishes.map((dish) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${dish.name}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      '${dish.protein}g P | ${dish.calories} kcal',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 2),
                                  child: Text(
                                    'Portion: ${dish.portion} • ${dish.ingredients}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  meal.chefTip,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
        const SizedBox(height: 18),

        // Smart Indian Food Swaps Guide
        Text(
          'Desi Smart Food Swaps',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 10),
        ..._dietPlan.smartSwaps.map((swap) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        swap.unhealthyItem,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        swap.healthySwap,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      swap.impact,
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  swap.benefit,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMacroMiniCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: PROFILE & BIOMETRIC TUNER
  // =========================================================================
  Widget _buildProfileTab() {
    final heightCtrl = TextEditingController(text: _currentUser.height.toStringAsFixed(0));
    final weightCtrl = TextEditingController(text: _currentUser.weight.toStringAsFixed(1));
    final ageCtrl = TextEditingController(text: _currentUser.age.toString());
    final nameCtrl = TextEditingController(text: _currentUser.name);

    String selGoal = _currentUser.goal;
    String selLevel = _currentUser.fitnessLevel;
    String selDiet = _currentUser.dietaryPreference;
    String selGender = _currentUser.gender;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            BmiGaugeWidget(user: _currentUser),
            const SizedBox(height: 20),

            Text(
              'Biometric Profile Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: nameCtrl,
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: heightCtrl,
                    label: 'Height (cm)',
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: weightCtrl,
                    label: 'Weight (kg)',
                    prefixIcon: Icons.monitor_weight_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: ageCtrl,
                    label: 'Age',
                    prefixIcon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setInnerState(() => selGender = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: selGoal,
              decoration: const InputDecoration(labelText: 'Fitness Goal'),
              items: ['Build strength', 'Lose weight', 'Improve fitness', 'Improve mobility']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setInnerState(() => selGoal = v!),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: selLevel,
              decoration: const InputDecoration(labelText: 'Fitness Level'),
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setInnerState(() => selLevel = v!),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: selDiet,
              decoration: const InputDecoration(labelText: 'Dietary Preference'),
              items: ['Vegetarian', 'Vegan', 'Non-Vegetarian']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setInnerState(() => selDiet = v!),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Save & Recalculate Everything',
              onPressed: () {
                final newH = double.tryParse(heightCtrl.text.trim()) ?? _currentUser.height;
                final newW = double.tryParse(weightCtrl.text.trim()) ?? _currentUser.weight;
                final newAge = int.tryParse(ageCtrl.text.trim()) ?? _currentUser.age;
                final newName = nameCtrl.text.trim().isEmpty ? _currentUser.name : nameCtrl.text.trim();

                final updated = _currentUser.copyWith(
                  name: newName,
                  height: newH,
                  weight: newW,
                  age: newAge,
                  gender: selGender,
                  goal: selGoal,
                  fitnessLevel: selLevel,
                  dietaryPreference: selDiet,
                );

                _updateUserBiometrics(updated);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile and Biometrics updated successfully!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
