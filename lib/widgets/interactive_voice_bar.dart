import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/audio_coaching_service.dart';
import '../theme/app_colors.dart';

class InteractiveVoiceBar extends StatefulWidget {
  final Exercise exercise;
  final int formScore;
  final int repCount;
  final String activeCue;
  final bool isMuted;
  final ValueChanged<bool> onToggleMute;

  const InteractiveVoiceBar({
    super.key,
    required this.exercise,
    required this.formScore,
    required this.repCount,
    required this.activeCue,
    required this.isMuted,
    required this.onToggleMute,
  });

  @override
  State<InteractiveVoiceBar> createState() => _InteractiveVoiceBarState();
}

class _InteractiveVoiceBarState extends State<InteractiveVoiceBar>
    with SingleTickerProviderStateMixin {
  final AudioCoachingService _audioService = AudioCoachingService();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isMuted
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.5),
        ),
        boxShadow: widget.isMuted
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice Assistant Avatar & Header
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                ),
                child: const Icon(
                  Icons.graphic_eq,
                  color: AppColors.background,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI Voice Coach',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!widget.isMuted)
                          AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Row(
                                children: List.generate(3, (idx) {
                                  final val = (_mathSin(
                                            _waveController.value * 3.14 +
                                                idx * 0.8,
                                          ) +
                                          1) /
                                      2;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    width: 2.5,
                                    height: 6 + val * 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                      ],
                    ),
                    Text(
                      widget.isMuted
                          ? 'Muted • Tap quick actions to unmute'
                          : 'Interactive • Listening & coaching',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Mute button
              IconButton(
                icon: Icon(
                  widget.isMuted
                      ? Icons.volume_off_outlined
                      : Icons.volume_up,
                  color: widget.isMuted
                      ? AppColors.textMuted
                      : AppColors.primary,
                  size: 20,
                ),
                onPressed: () => widget.onToggleMute(!widget.isMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Interactive Voice Triggers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.analytics_outlined,
                  label: 'How\'s my form?',
                  onTap: () {
                    if (widget.isMuted) widget.onToggleMute(false);
                    _audioService.speakFormCheckStatus(
                      widget.formScore,
                      widget.activeCue,
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.lightbulb_outline,
                  label: 'Give me a tip',
                  onTap: () {
                    if (widget.isMuted) widget.onToggleMute(false);
                    _audioService.speakInteractiveTip(
                      widget.exercise,
                      widget.formScore,
                      widget.repCount,
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.play_circle_outline,
                  label: 'Explain step 1',
                  onTap: () {
                    if (widget.isMuted) widget.onToggleMute(false);
                    _audioService.speakStepGuide(widget.exercise, 0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _mathSin(double v) {
    return (v == 0) ? 0 : (v - (v * v * v) / 6);
  }
}
