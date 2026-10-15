import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/audio_coaching_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/hd_video_demo_overlay.dart';
import '../widgets/systematic_motion_painter.dart';

class PreWorkoutDemoModal extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onStartSession;

  const PreWorkoutDemoModal({
    super.key,
    required this.exercise,
    required this.onStartSession,
  });

  static Future<void> show(
    BuildContext context, {
    required Exercise exercise,
    required VoidCallback onStartSession,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PreWorkoutDemoModal(
        exercise: exercise,
        onStartSession: onStartSession,
      ),
    );
  }

  @override
  State<PreWorkoutDemoModal> createState() => _PreWorkoutDemoModalState();
}

class _PreWorkoutDemoModalState extends State<PreWorkoutDemoModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _phaseAnimController;
  final AudioCoachingService _audioService = AudioCoachingService();
  int _selectedStepIndex = 0;
  bool _isPlaying = true;
  String _demoMode = 'athlete'; // 'athlete' or 'video'
  int _stepPlaySession = 0;

  final List<String> _stepTitles = [
    'Phase 1: Setup & Starting Alignment',
    'Phase 2: Controlled Range of Motion',
    'Phase 3: Peak Contraction & Posture Check',
    'Phase 4: Smooth Return & Reset',
  ];

  @override
  void initState() {
    super.initState();
    // Smooth kinematic cycle for the current step animation
    _phaseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _audioService.resetSession();
    _audioService.init().then((_) {
      if (mounted) {
        _playCurrentStep();
      }
    });
  }

  void _playCurrentStep() {
    if (!mounted || !_isPlaying) return;
    final currentSession = ++_stepPlaySession;
    final stepIndex = _selectedStepIndex;
    final title = _stepTitles[stepIndex];
    final guideList = widget.exercise.correctFormGuide;
    final detail = guideList.isNotEmpty
        ? guideList[stepIndex % guideList.length]
        : widget.exercise.description;
    final speech = '$title. $detail';

    _audioService.speakStepWithCompletion(
      speech,
      onComplete: () {
        if (!mounted || !_isPlaying || _stepPlaySession != currentSession) return;
        // Natural brief pause once speech finishes before advancing to next step
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted || !_isPlaying || _stepPlaySession != currentSession) return;
          setState(() {
            _selectedStepIndex = (_selectedStepIndex + 1) % 4;
          });
          _playCurrentStep();
        });
      },
    );
  }

  void _selectStep(int index) {
    _stepPlaySession++; // Immediately invalidates any previous completion callback or timer
    setState(() {
      _selectedStepIndex = index;
    });
    _audioService.stop();
    _playCurrentStep();
  }

  void _togglePlayPause() {
    _stepPlaySession++;
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _playCurrentStep();
    } else {
      _audioService.stop();
    }
  }

  @override
  void dispose() {
    _phaseAnimController.dispose();
    _audioService.stop();
    _audioService.resetSession();
    super.dispose();
  }

  Map<String, String> _getCameraPlacementInfo() {
    final id = widget.exercise.id.toLowerCase();
    if (id.contains('pushup') || id.contains('plank') || id.contains('crunch') || id.contains('bridge')) {
      return {
        'distance': '4–5 feet away',
        'height': 'Floor level or propped 6 inches high',
        'angle': 'Side profile view (horizontal alignment)',
        'tips': 'Ensure head, hips, and feet are visible from the side.',
      };
    } else if (id.contains('curl') || id.contains('press') || id.contains('raise') || id.contains('dip')) {
      return {
        'distance': '3–5 feet away',
        'height': 'Waist to chest height (e.g. table or shelf)',
        'angle': 'Front-facing portrait view',
        'tips': 'Stand centered so shoulders, elbows, and wrists are in frame.',
      };
    } else {
      // Squats, Lunges, Cardio, Stretches
      return {
        'distance': '5–7 feet away',
        'height': 'Waist height (propped on table / desk)',
        'angle': 'Full-body front or 45° angle',
        'tips': 'Step back until entire body from head to feet fits in view.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final camGuide = _getCameraPlacementInfo();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryDark,
                  child: Icon(widget.exercise.icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo • ${widget.exercise.name}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        '${widget.exercise.category} • Target: ${widget.exercise.target}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Demonstration Mode Switcher (Animated Human vs Video Overlay)
                  _buildDemoModeSelector(),

                  // Selected Demonstration Viewer (Animated Human or Video Overlay)
                  if (_demoMode == 'video')
                    HDVideoDemoOverlay(
                      exercise: widget.exercise,
                      currentStep: _selectedStepIndex,
                    )
                  else
                    AnimatedBuilder(
                      animation: _phaseAnimController,
                      builder: (context, child) {
                        return Container(
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // 3D Volumetric Animated Human Athlete
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: SystematicMotionPainter(
                                    exerciseId: widget.exercise.id,
                                    progress: _phaseAnimController.value,
                                    currentStep: _selectedStepIndex,
                                  ),
                                ),
                              ),
                              // Current Phase Tag
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background.withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: Text(
                                    _stepTitles[_selectedStepIndex],
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Play / Pause Button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_fill,
                                        color: AppColors.primary,
                                        size: 28,
                                      ),
                                      onPressed: _togglePlayPause,
                                      tooltip: _isPlaying ? 'Pause Step Sequence' : 'Play Step Sequence',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),

                  // Synchronized Step Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      final isSelected = _selectedStepIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _selectStep(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Step ${index + 1}',
                                  style: TextStyle(
                                    color: isSelected ? AppColors.background : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Step Voice & Motion Explanation Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.record_voice_over, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _stepTitles[_selectedStepIndex],
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.exercise.correctFormGuide.length > _selectedStepIndex
                              ? widget.exercise.correctFormGuide[_selectedStepIndex]
                              : widget.exercise.description,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📐 Dedicated Camera Placement & Position Guide Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.photo_camera_front, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '📐 Recommended Camera Placement',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildCameraInfoRow(Icons.straighten, 'Distance:', camGuide['distance']!),
                        const SizedBox(height: 6),
                        _buildCameraInfoRow(Icons.height, 'Height:', camGuide['height']!),
                        const SizedBox(height: 6),
                        _buildCameraInfoRow(Icons.rotate_90_degrees_ccw, 'Angle:', camGuide['angle']!),
                        const SizedBox(height: 6),
                        _buildCameraInfoRow(Icons.lightbulb_outline, 'Setup Tip:', camGuide['tips']!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Proper Form Checklist
                  const Text(
                    '✅ Step-by-Step Form Rules:',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.exercise.correctFormGuide.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mistakes to avoid
                  const Text(
                    '❌ Posture Mistakes to Avoid:',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.exercise.commonErrors.map(
                    (err) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              err,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Start Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: 'Start AI Camera Workout',
              icon: Icons.camera_alt_outlined,
              onPressed: () {
                _audioService.stop();
                Navigator.pop(context);
                widget.onStartSession();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoModeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _demoMode = 'athlete'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _demoMode == 'athlete' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.accessibility_new,
                      size: 16,
                      color: _demoMode == 'athlete' ? AppColors.background : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '3D Animated Human',
                      style: TextStyle(
                        color: _demoMode == 'athlete' ? AppColors.background : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _demoMode = 'video'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _demoMode == 'video' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 16,
                      color: _demoMode == 'video' ? AppColors.background : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'HD Video Overlay',
                      style: TextStyle(
                        color: _demoMode == 'video' ? AppColors.background : AppColors.textSecondary,
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

  Widget _buildCameraInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
