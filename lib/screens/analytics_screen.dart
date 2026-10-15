import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/workout_record.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/bmi_gauge_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/form_trend_chart_painter.dart';
import '../widgets/metric_card.dart';

class AnalyticsScreen extends StatefulWidget {
  final User? user;

  const AnalyticsScreen({super.key, this.user});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  List<WorkoutRecord> _history = [];
  User? _currentUser;
  bool _loading = true;
  int _waterGlasses = 4;
  late AnimationController _chartAnimController;

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadData();
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final records = await StorageService.loadHistory();
    final user = widget.user ?? await AuthService.getCurrentUser() ?? const User(
      userId: 'demo-user',
      email: 'demo@ironmind.ai',
      name: 'Athlete',
      fitnessLevel: 'Intermediate',
      goal: 'Build strength',
      height: 175.0,
      weight: 72.0,
    );

    if (mounted) {
      setState(() {
        _history = records;
        _currentUser = user;
        _loading = false;
      });
      _chartAnimController.forward(from: 0.0);
    }
  }

  Future<void> _generateSampleData() async {
    final now = DateTime.now();
    final sampleRecords = [
      WorkoutRecord(
        exercise: 'Squats',
        reps: 15,
        score: 78,
        seconds: 140,
        date: now.subtract(const Duration(days: 6)),
      ),
      WorkoutRecord(
        exercise: 'Push-ups',
        reps: 12,
        score: 82,
        seconds: 120,
        date: now.subtract(const Duration(days: 5)),
      ),
      WorkoutRecord(
        exercise: 'Forearm Plank',
        reps: 1,
        score: 85,
        seconds: 60,
        date: now.subtract(const Duration(days: 4)),
      ),
      WorkoutRecord(
        exercise: 'Lunges',
        reps: 20,
        score: 89,
        seconds: 180,
        date: now.subtract(const Duration(days: 3)),
      ),
      WorkoutRecord(
        exercise: 'Shoulder Press',
        reps: 14,
        score: 91,
        seconds: 130,
        date: now.subtract(const Duration(days: 2)),
      ),
      WorkoutRecord(
        exercise: 'Squats',
        reps: 18,
        score: 94,
        seconds: 160,
        date: now.subtract(const Duration(days: 1)),
      ),
      WorkoutRecord(
        exercise: 'Bicep Curls',
        reps: 16,
        score: 96,
        seconds: 110,
        date: now,
      ),
    ];

    for (final r in sampleRecords) {
      await StorageService.saveWorkout(r);
    }

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loaded 7-day realistic performance history!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset Session History?'),
        content: const Text('This will clear all logged workout analytics on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear history in storage
      final prefs = await StorageService.getUserProfile();
      await StorageService.clearAuth();
      if (prefs != null) {
        await StorageService.saveUserProfile(prefs);
      }
      await _loadData();
    }
  }

  void _showBiometricsEditDialog() {
    if (_currentUser == null) return;
    final heightCtrl = TextEditingController(text: _currentUser!.height.toStringAsFixed(0));
    final weightCtrl = TextEditingController(text: _currentUser!.weight.toStringAsFixed(1));
    final ageCtrl = TextEditingController(text: _currentUser!.age.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.tune, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Update Biometrics', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: heightCtrl,
                label: 'Height (cm)',
                prefixIcon: Icons.height,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: weightCtrl,
                label: 'Weight (kg)',
                prefixIcon: Icons.monitor_weight_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: ageCtrl,
                label: 'Age (years)',
                prefixIcon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newH = double.tryParse(heightCtrl.text.trim()) ?? _currentUser!.height;
              final newW = double.tryParse(weightCtrl.text.trim()) ?? _currentUser!.weight;
              final newAge = int.tryParse(ageCtrl.text.trim()) ?? _currentUser!.age;

              final updated = _currentUser!.copyWith(
                height: newH,
                weight: newW,
                age: newAge,
              );

              final nav = Navigator.of(ctx);
              await StorageService.saveUserProfile(updated.toJson());
              if (!mounted) return;
              nav.pop();
              setState(() {
                _currentUser = updated;
              });
            },
            child: const Text('Save & Recalculate', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _currentUser!;
    final totalReps = _history.fold<int>(0, (sum, item) => sum + item.reps);
    final totalSeconds = _history.fold<int>(0, (sum, item) => sum + item.seconds);
    final totalMinutes = totalSeconds ~/ 60;
    final averageScore = _history.isEmpty
        ? 0
        : (_history.map((item) => item.score).reduce((a, b) => a + b) / _history.length).round();

    // Caloric output: based on METs & bodyweight (~0.07 kcal/kg/min for calisthenics)
    final totalCaloriesBurned = (totalMinutes * user.weight * 0.085).round();

    // Form Mastery tier
    final String masteryTitle;
    final Color masteryColor;
    if (averageScore >= 90) {
      masteryTitle = 'Biomechanics Master 🥇';
      masteryColor = const Color(0xFF10B981);
    } else if (averageScore >= 78) {
      masteryTitle = 'Form Verified Athlete 🥈';
      masteryColor = AppColors.primary;
    } else if (averageScore >= 60) {
      masteryTitle = 'Developing Technique 🥉';
      masteryColor = const Color(0xFFF59E0B);
    } else {
      masteryTitle = 'Form Focus Required ⚠️';
      masteryColor = Colors.orange;
    }

    // Scores for trend chart (chronological order)
    final trendScores = _history.reversed.map((e) => e.score).toList();

    // Grouping by exercise
    final exerciseMap = <String, List<WorkoutRecord>>{};
    for (final r in _history) {
      exerciseMap.putIfAbsent(r.exercise, () => []).add(r);
    }

    // Calculate Weekly Streak (past 7 days active)
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final hasWorkout = _history.any((r) =>
          r.date.year == day.year && r.date.month == day.month && r.date.day == day.day);
      return {'day': day, 'active': hasWorkout};
    });
    final activeDaysCount = weekDays.where((d) => d['active'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Update Biometrics',
            onPressed: _showBiometricsEditDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'sample') _generateSampleData();
              if (val == 'clear') _clearHistory();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'sample',
                child: Row(
                  children: [
                    Icon(Icons.auto_graph, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Load Sample 7-Day Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Reset Session History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // 1. Mastery Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  masteryColor.withValues(alpha: 0.22),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: masteryColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: masteryColor.withValues(alpha: 0.2),
                  radius: 22,
                  child: Icon(Icons.verified, color: masteryColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        masteryTitle,
                        style: TextStyle(
                          color: masteryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _history.isEmpty
                            ? 'Complete your first workout to unlock precision tracking.'
                            : '$averageScore% average joint alignment across ${_history.length} sessions.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Executive KPI Cards
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  value: '${_history.length}',
                  label: 'Workouts',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  value: '$totalReps',
                  label: 'Total Reps',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  value: '$totalMinutes m',
                  label: 'Training Time',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  value: '$totalCaloriesBurned',
                  label: 'Kcal Burned',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  value: '$averageScore%',
                  label: 'Avg. Form',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  value: '$activeDaysCount/7',
                  label: 'Days Active',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Biometric & BMI Clinical Gauge
          BmiGaugeWidget(
            user: user,
            onEditRequested: _showBiometricsEditDialog,
          ),
          const SizedBox(height: 20),

          // 4. Weekly 7-Day Consistency & Streak Tracker
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
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Weekly Training Consistency',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🔥 $activeDaysCount Days This Week',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((d) {
                    final date = d['day'] as DateTime;
                    final active = d['active'] as bool;
                    final dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
                    final isToday = date.day == now.day && date.month == now.month;

                    return Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? AppColors.primary
                                : (isToday ? AppColors.primaryDark : AppColors.background),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : (isToday ? AppColors.primary : AppColors.border),
                              width: isToday ? 2 : 1,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              active ? Icons.check : (isToday ? Icons.adjust : Icons.circle_outlined),
                              size: 18,
                              color: active ? AppColors.background : AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLetters,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Biomechanical Form Score Trajectory Area Chart
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
                    const Row(
                      children: [
                        Icon(Icons.show_chart, color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Form Accuracy Trajectory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (trendScores.isNotEmpty)
                      Text(
                        'Latest: ${trendScores.last}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'On-device AI optical joint telemetry progression across workouts',
                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (trendScores.isEmpty)
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_graph, color: AppColors.textMuted, size: 36),
                          const SizedBox(height: 10),
                          const Text(
                            'No sessions recorded yet',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _generateSampleData,
                            child: const Text('Load Sample 7-Day Data'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _chartAnimController,
                    builder: (context, _) {
                      return SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: FormTrendChartPainter(
                            scores: trendScores,
                            animationValue: _chartAnimController.value,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 6. Hydration & Daily Intake Quick Tracker
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.water_drop, color: Color(0xFF38BDF8), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hydration Tracker',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_waterGlasses / 8 Glasses (${(_waterGlasses * 0.35).toStringAsFixed(1)}L of ${user.waterTargetLiters.toStringAsFixed(1)}L target)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_waterGlasses / 8.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_waterGlasses < 12) _waterGlasses++;
                    });
                  },
                  icon: const Icon(Icons.add_circle, color: Color(0xFF38BDF8), size: 30),
                  tooltip: 'Drink 1 Glass',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 7. Exercise-Specific Performance Breakdown
          if (exerciseMap.isNotEmpty) ...[
            Text(
              'Exercise Performance Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            ...exerciseMap.entries.map((entry) {
              final exName = entry.key;
              final logs = entry.value;
              final exReps = logs.fold<int>(0, (s, l) => s + l.reps);
              final exAvgScore = (logs.map((l) => l.score).reduce((a, b) => a + b) / logs.length).round();
              final bestScore = logs.map((l) => l.score).reduce((a, b) => a > b ? a : b);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryDark,
                        child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$exReps total reps • ${logs.length} sessions • Best: $bestScore%',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: exAvgScore / 100.0,
                                minHeight: 4,
                                backgroundColor: AppColors.background,
                                valueColor: AlwaysStoppedAnimation(
                                  exAvgScore >= 85 ? AppColors.primary : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$exAvgScore%',
                            style: TextStyle(
                              color: exAvgScore >= 85 ? AppColors.primary : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Avg Form',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 18),
          ],

          // 8. Session History Logs
          Text(
            'Recent Session Log',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          if (_history.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.history, color: AppColors.textMuted, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'No workouts logged yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Load Sample 7-Day History',
                      onPressed: _generateSampleData,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._history.take(15).map(
                  (record) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryDark,
                        child: Icon(
                          record.score >= 85 ? Icons.check_circle : Icons.fitness_center,
                          color: record.score >= 85 ? AppColors.primary : Colors.orange,
                        ),
                      ),
                      title: Text(
                        record.exercise,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${record.date.day}/${record.date.month}/${record.date.year} • ${record.seconds ~/ 60}m ${record.seconds % 60}s',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${record.reps} reps',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${record.score}% form',
                            style: TextStyle(
                              color: record.score >= 85 ? AppColors.primary : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
