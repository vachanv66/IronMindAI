import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout_record.dart';
import '../services/api_service.dart';
import '../services/audio_coaching_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/exercise_guide_overlay.dart';
import '../widgets/hd_video_demo_overlay.dart';
import '../widgets/interactive_voice_bar.dart';
import '../widgets/pose_camera_preview.dart';
import '../widgets/pre_workout_demo_modal.dart';
import 'workout_summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final Exercise exercise;

  const WorkoutScreen({super.key, required this.exercise});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int count = 0;
  int formScore = 100;
  bool active = false;
  DateTime? startedAt;
  String cue = 'Tap Start to enable AI camera coaching.';
  bool isAudioMuted = false;
  bool showVideoPip = false;

  final AudioCoachingService _audioService = AudioCoachingService();

  @override
  void initState() {
    super.initState();
    _audioService.resetSession();
    _audioService.init();

    // Show Pre-Workout Demo Modal automatically on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDemoModal();
    });
  }

  void _showDemoModal() {
    PreWorkoutDemoModal.show(
      context,
      exercise: widget.exercise,
      onStartSession: () {
        setState(() {
          active = true;
          startedAt ??= DateTime.now();
        });
        _audioService.resetSession();
        _audioService.speakExerciseIntro(widget.exercise);
      },
    );
  }

  void _showCameraGuide() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.photo_camera_front, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Camera Setup Guide',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSetupTip(Icons.straighten, 'Distance: 4 to 6 feet back', 'Stand far enough that your working joints fit inside the screen.'),
            const SizedBox(height: 10),
            _buildSetupTip(Icons.height, 'Height: Waist level', 'Prop your phone on a table or shelf tilted slightly upward.'),
            const SizedBox(height: 10),
            _buildSetupTip(Icons.wb_sunny_outlined, 'Lighting: Front light', 'Make sure light is on your body, not behind you.'),
            const SizedBox(height: 10),
            _buildSetupTip(Icons.check_circle_outline, 'Indicator: Green Box', 'When the AI detects your posture, the border glows green.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupTip(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioService.stop();
    _audioService.resetSession();
    super.dispose();
  }

  Future<void> _finish() async {
    _audioService.stop();
    final seconds = DateTime.now()
        .difference(startedAt ?? DateTime.now())
        .inSeconds;
    final record = WorkoutRecord(
      exercise: widget.exercise.name,
      reps: count,
      score: formScore,
      seconds: seconds,
      date: DateTime.now(),
    );

    await StorageService.saveWorkout(record);
    await ApiService.saveWorkout(record);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSummaryScreen(
          exercise: widget.exercise,
          reps: count,
          score: formScore,
          seconds: seconds,
        ),
      ),
    );
  }

  Color _getScoreColor() {
    if (formScore >= 85) return AppColors.primary;
    if (formScore >= 65) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormFault = formScore > 0 && formScore < 75;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: AppColors.primary),
            tooltip: 'Watch technique demo',
            onPressed: _showDemoModal,
          ),
          IconButton(
            icon: Icon(showVideoPip ? Icons.videocam : Icons.videocam_outlined,
                color: showVideoPip ? AppColors.primary : AppColors.textSecondary),
            tooltip: showVideoPip ? 'Hide video overlay' : 'Show video overlay',
            onPressed: () {
              setState(() {
                showVideoPip = !showVideoPip;
              });
            },
          ),
          IconButton(
            icon: Icon(isAudioMuted ? Icons.volume_off : Icons.volume_up),
            tooltip: isAudioMuted ? 'Unmute voice coach' : 'Mute voice coach',
            onPressed: () {
              setState(() {
                isAudioMuted = !isAudioMuted;
                _audioService.isMuted = isAudioMuted;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
            tooltip: 'Camera placement instructions',
            onPressed: _showCameraGuide,
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Finish workout',
            onPressed: _finish,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Interactive Visual Form Technique & Correction Overlay
              ExerciseGuideOverlay(
                exercise: widget.exercise,
                activeCue: cue,
                formScore: formScore,
              ),
              const SizedBox(height: 8),

              // Camera Preview with Floating HD Video Overlay (PIP)
              Expanded(
                child: Stack(
                  children: [
                    // Base Live Camera Preview
                    Positioned.fill(
                      child: PoseCameraPreview(
                        active: active,
                        exerciseId: widget.exercise.id,
                        exerciseName: widget.exercise.name,
                        kind: widget.exercise.kind,
                        onRep: () {
                          if (mounted) {
                            setState(() => count++);
                            if (widget.exercise.kind == 'timer') {
                              _audioService.speakTimerMilestone(widget.exercise.name, count);
                            } else {
                              _audioService.speakRep(count);
                            }
                          }
                        },
                        onCue: (text) {
                          if (mounted) {
                            setState(() => cue = text);
                            _audioService.speakLiveFeedback(
                              exerciseName: widget.exercise.name,
                              cue: text,
                              score: formScore,
                              count: count,
                            );
                          }
                        },
                        onScore: (score) {
                          if (mounted) {
                            final previousScore = formScore;
                            setState(() => formScore = score);
                            if (score < 75) {
                              _audioService.speakFormError(cue);
                            } else if (previousScore < 75 && score >= 80) {
                              _audioService.speakCue('Good correction! Keep that form locked in.', topicKey: 'form_fixed');
                            }
                          }
                        },
                      ),
                    ),

                    // Quick Toggle for Video Overlay on camera
                    Positioned(
                      top: 10,
                      left: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showVideoPip = !showVideoPip;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (showVideoPip || isFormFault) ? AppColors.primary : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (showVideoPip || isFormFault) ? Icons.videocam : Icons.videocam_outlined,
                                color: (showVideoPip || isFormFault) ? AppColors.primary : Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                (showVideoPip || isFormFault) ? 'Video Overlay ON' : 'Video Overlay',
                                style: TextStyle(
                                  color: (showVideoPip || isFormFault) ? AppColors.primary : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Floating Picture-In-Picture HD Video Demonstration Overlay
                    // Triggered automatically on form faults (<75) or when manually toggled
                    if (showVideoPip || isFormFault)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: HDVideoDemoOverlay(
                          exercise: widget.exercise,
                          isPipMode: true,
                          isCorrectionMode: isFormFault,
                          alertCue: isFormFault ? cue : 'Coach Video Guide',
                          onClose: () {
                            setState(() {
                              showVideoPip = false;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Interactive Voice Assistant Control Panel
              InteractiveVoiceBar(
                exercise: widget.exercise,
                formScore: formScore,
                repCount: count,
                activeCue: cue,
                isMuted: isAudioMuted,
                onToggleMute: (muted) {
                  setState(() {
                    isAudioMuted = muted;
                    _audioService.isMuted = isAudioMuted;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Dynamic Status HUD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Form Score: $formScore%',
                    style: TextStyle(
                      color: _getScoreColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    widget.exercise.kind == 'timer'
                        ? 'Count: ${count}s'
                        : 'Completed: $count reps',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              CustomButton(
                text: active ? 'AI Camera Coaching Active' : 'Start Camera Session',
                icon: Icons.play_arrow,
                onPressed: () {
                  setState(() {
                    active = true;
                    startedAt ??= DateTime.now();
                  });
                  _audioService.resetSession();
                  _audioService.speakExerciseIntro(widget.exercise);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
