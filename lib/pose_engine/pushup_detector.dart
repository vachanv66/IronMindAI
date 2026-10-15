import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class PushupDetector {
  String _stage = 'up'; // 'up', 'down'
  final EmaFilter _emaFilter = EmaFilter(alpha: 0.35);
  DateTime _lastRep = DateTime.fromMillisecondsSinceEpoch(0);
  int _repsCounted = 0;

  void evaluate({
    required Pose pose,
    required Function(String cue) onCue,
    required Function(int score) onScore,
    required Function() onRep,
  }) {
    final l = pose.landmarks;
    final ls = l[PoseLandmarkType.leftShoulder];
    final rs = l[PoseLandmarkType.rightShoulder];
    final le = l[PoseLandmarkType.leftElbow];
    final re = l[PoseLandmarkType.rightElbow];
    final lw = l[PoseLandmarkType.leftWrist];
    final rw = l[PoseLandmarkType.rightWrist];

    // Single-side or double-side visibility
    final leftArm = ls != null && le != null && lw != null &&
        ls.likelihood > 0.25 && le.likelihood > 0.25 && lw.likelihood > 0.25;
    final rightArm = rs != null && re != null && rw != null &&
        rs.likelihood > 0.25 && re.likelihood > 0.25 && rw.likelihood > 0.25;

    if (!leftArm && !rightArm) {
      onCue('Position camera so at least one arm (shoulder, elbow, wrist) is in frame.');
      return;
    }

    double? leftAngle;
    double? rightAngle;

    if (leftArm) {
      leftAngle = AngleCalculator.computeAngle(ls, le, lw);
    }
    if (rightArm) {
      rightAngle = AngleCalculator.computeAngle(rs, re, rw);
    }

    double activeAngle;
    if (leftAngle != null && rightAngle != null) {
      activeAngle = math.min(leftAngle, rightAngle);
    } else {
      activeAngle = leftAngle ?? rightAngle!;
    }

    final elbowAngle = _emaFilter.filter(activeAngle);
    final now = DateTime.now();

    if (_stage == 'up' && elbowAngle < 105) {
      _stage = 'down';
      onScore(95);
      onCue('Good depth — press straight back up.');
      return;
    }

    if (_stage == 'down' && elbowAngle > 130) {
      if (now.difference(_lastRep).inMilliseconds > 500) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'up';
        onRep();
        onScore(96);
        onCue('Great push-up #$_repsCounted! Keep core tight for next rep.');
      }
      return;
    }
  }

  void reset() {
    _stage = 'up';
    _repsCounted = 0;
    _emaFilter.reset();
  }
}
