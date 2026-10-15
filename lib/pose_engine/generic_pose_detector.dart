import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class GenericPoseDetector {
  final String exerciseId;
  final String exerciseName;
  final String kind; // 'reps' or 'timer'

  String _stage = 'ready'; // 'ready', 'active'
  final EmaFilter _emaFilter = EmaFilter(alpha: 0.35);
  DateTime _lastRep = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _timerStart = DateTime.now();
  int _lastReportedSec = 0;
  int _repsCounted = 0;
  double _baseline = 160.0;
  bool _initialized = false;

  GenericPoseDetector({
    required this.exerciseId,
    required this.exerciseName,
    required this.kind,
  });

  void evaluate({
    required Pose pose,
    required Function(String cue) onCue,
    required Function(int score) onScore,
    required Function() onRep,
  }) {
    final l = pose.landmarks;
    final now = DateTime.now();

    // Timer Exercises (Plank, Wall Sit, Stretches)
    if (kind == 'timer') {
      final elapsed = now.difference(_timerStart).inSeconds;
      if (elapsed != _lastReportedSec) {
        _lastReportedSec = elapsed;
        onRep(); // Each second counts as an increment for timer exercises
        onScore(95);
        onCue('$exerciseName held: ${elapsed}s. Maintain steady breathing.');
      }
      return;
    }

    // Reps Exercises: Track upper or lower body joints based on what is visible
    final ls = l[PoseLandmarkType.leftShoulder];
    final rs = l[PoseLandmarkType.rightShoulder];
    final le = l[PoseLandmarkType.leftElbow];
    final re = l[PoseLandmarkType.rightElbow];
    final lw = l[PoseLandmarkType.leftWrist];
    final rw = l[PoseLandmarkType.rightWrist];
    final lh = l[PoseLandmarkType.leftHip];
    final rh = l[PoseLandmarkType.rightHip];
    final lk = l[PoseLandmarkType.leftKnee];
    final rk = l[PoseLandmarkType.rightKnee];

    double currentAngle = 160;

    // Check if arm motion is visible
    if (ls != null && le != null && lw != null && le.likelihood > 0.25) {
      currentAngle = AngleCalculator.computeAngle(ls, le, lw);
    } else if (rs != null && re != null && rw != null && re.likelihood > 0.25) {
      currentAngle = AngleCalculator.computeAngle(rs, re, rw);
    } else if (lh != null && lk != null && ls != null && lk.likelihood > 0.25) {
      currentAngle = AngleCalculator.computeAngle(ls, lh, lk);
    } else if (rh != null && rk != null && rs != null && rk.likelihood > 0.25) {
      currentAngle = AngleCalculator.computeAngle(rs, rh, rk);
    } else {
      onCue('Position camera so active body joints are in frame.');
      return;
    }

    final filtered = _emaFilter.filter(currentAngle);

    if (!_initialized) {
      _baseline = filtered;
      _initialized = true;
      onScore(95);
      onCue('AI tracking active for $exerciseName. Begin reps.');
      return;
    }

    // Dynamically drift baseline smoothly
    _baseline = _baseline * 0.98 + filtered * 0.02;

    final deviation = (filtered - _baseline).abs();

    if (_stage == 'ready' && deviation > 22) {
      _stage = 'active';
      onCue('Good motion — complete the rep.');
      return;
    }

    if (_stage == 'active' && deviation < 12) {
      if (now.difference(_lastRep).inMilliseconds > 500) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'ready';
        onRep();
        onScore(95);
        onCue('Great rep #$_repsCounted! Repeat with steady tempo.');
      }
      return;
    }
  }

  void reset() {
    _stage = 'ready';
    _repsCounted = 0;
    _initialized = false;
    _timerStart = DateTime.now();
    _lastReportedSec = 0;
    _emaFilter.reset();
  }
}
