import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import 'systematic_motion_painter.dart';

/// HD Video Demonstration Overlay & Floating Coach Player
class HDVideoDemoOverlay extends StatefulWidget {
  final Exercise exercise;
  final int currentStep;
  final bool isPipMode;
  final VoidCallback? onTogglePip;
  final VoidCallback? onClose;
  final String? alertCue;
  final bool isCorrectionMode;

  const HDVideoDemoOverlay({
    super.key,
    required this.exercise,
    this.currentStep = 0,
    this.isPipMode = false,
    this.onTogglePip,
    this.onClose,
    this.alertCue,
    this.isCorrectionMode = false,
  });

  @override
  State<HDVideoDemoOverlay> createState() => _HDVideoDemoOverlayState();
}

class _HDVideoDemoOverlayState extends State<HDVideoDemoOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _videoController;
  bool _isPlaying = true;
  bool _isSlowMo = false;
  int _activeStep = 0;

  final List<String> _stepNames = [
    'Phase 1: Setup & Joint Alignment',
    'Phase 2: Controlled Range of Motion',
    'Phase 3: Peak Muscle Contraction',
    'Phase 4: Stable Return & Reset',
  ];

  @override
  void initState() {
    super.initState();
    _activeStep = widget.currentStep;
    _videoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant HDVideoDemoOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      setState(() {
        _activeStep = widget.currentStep;
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _videoController.repeat(reverse: true);
    } else {
      _videoController.stop();
    }
  }

  void _toggleSlowMo() {
    setState(() {
      _isSlowMo = !_isSlowMo;
      _videoController.duration = _isSlowMo
          ? const Duration(milliseconds: 4800)
          : const Duration(milliseconds: 2400);
      if (_isPlaying) {
        _videoController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPipMode) {
      return _buildPipCard();
    }
    return _buildFullPlayerCard();
  }

  /// Compact floating Picture-In-Picture Video Overlay for live workout screen
  Widget _buildPipCard() {
    final borderColor = widget.isCorrectionMode ? AppColors.error : AppColors.primary;

    return Container(
      width: 175,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Video motion canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _videoController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SystematicMotionPainter(
                    exerciseId: widget.exercise.id,
                    progress: _videoController.value,
                    currentStep: _activeStep,
                  ),
                );
              },
            ),
          ),

          // Cinematic camera viewfinder brackets
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 2),
                  left: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 2),
                  right: BorderSide(color: borderColor, width: 2),
                ),
              ),
            ),
          ),

          // Header Badge
          Positioned(
            top: 6,
            left: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isCorrectionMode ? Icons.warning_amber_rounded : Icons.videocam,
                    color: Colors.white,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.isCorrectionMode ? 'CORRECTION VIDEO' : 'PRO TECHNIQUE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom alert cue banner
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              color: Colors.black.withValues(alpha: 0.8),
              child: Text(
                widget.alertCue ?? widget.exercise.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Close button
          if (widget.onClose != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Full-Featured HD Video Demonstration Player for Demo Modal
  Widget _buildFullPlayerCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Broadcast Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                // 1080p HD badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '1080p HD',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                const Text(
                  'Coach Marcus • Biomechanics Master',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Slow-Mo Toggle
                GestureDetector(
                  onTap: _toggleSlowMo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isSlowMo ? AppColors.accent : Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isSlowMo ? '0.5x SLOW-MO' : '1.0x NORMAL',
                      style: TextStyle(
                        color: _isSlowMo ? AppColors.background : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Video Canvas
          SizedBox(
            height: 230,
            child: Stack(
              children: [
                // Motion animation canvas
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _videoController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: SystematicMotionPainter(
                          exerciseId: widget.exercise.id,
                          progress: _videoController.value,
                          currentStep: _activeStep,
                        ),
                      );
                    },
                  ),
                ),

                // Corner camera brackets
                _buildCornerBracket(top: 10, left: 10, isTop: true, isLeft: true),
                _buildCornerBracket(top: 10, right: 10, isTop: true, isLeft: false),
                _buildCornerBracket(bottom: 10, left: 10, isTop: false, isLeft: true),
                _buildCornerBracket(bottom: 10, right: 10, isTop: false, isLeft: false),

                // Live Angle Badge
                Positioned(
                  top: 12,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: AppColors.accent, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Side Profile 90°',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Play Button when paused
                if (!_isPlaying)
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Video Scrubber & Controls Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                // Timeline progress bar
                AnimatedBuilder(
                  animation: _videoController,
                  builder: (context, child) {
                    final progress = _videoController.value;
                    return Row(
                      children: [
                        Text(
                          '00:0${(progress * 6).floor()}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '00:06',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Controls and Phase Info
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      color: AppColors.primary,
                      iconSize: 28,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _togglePlayPause,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stepNames[_activeStep % _stepNames.length],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            widget.exercise.correctFormGuide.isNotEmpty
                                ? widget.exercise.correctFormGuide[_activeStep % widget.exercise.correctFormGuide.length]
                                : widget.exercise.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
            left: isLeft ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
