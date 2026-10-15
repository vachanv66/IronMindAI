import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class ShoulderPressDetector {
  String _stage = 'rack'; // 'rack', 'pressing', 'overhead'
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

    final leftArmVisible = ls != null && le != null && lw != null &&
        ls.likelihood > 0.25 && le.likelihood > 0.25 && lw.likelihood > 0.25;
    final rightArmVisible = rs != null && re != null && rw != null &&
        rs.likelihood > 0.25 && re.likelihood > 0.25 && rw.likelihood > 0.25;

    if (!leftArmVisible && !rightArmVisible) {
      onCue('Position camera so shoulders, elbows, and wrists are in frame.');
      return;
    }

    double? leftAngle;
    double? rightAngle;

    if (leftArmVisible) {
      leftAngle = AngleCalculator.computeAngle(ls, le, lw);
    }
    if (rightArmVisible) {
      rightAngle = AngleCalculator.computeAngle(rs, re, rw);
    }

    double activeAngle;
    if (leftAngle != null && rightAngle != null) {
      activeAngle = math.max(leftAngle, rightAngle);
    } else {
      activeAngle = leftAngle ?? rightAngle!;
    }

    final elbowAngle = _emaFilter.filter(activeAngle);
    final now = DateTime.now();

    if (_stage == 'rack' && elbowAngle > 120) {
      _stage = 'pressing';
      onCue('Pressing overhead — lock out smoothly.');
      return;
    }

    if (_stage == 'pressing' && elbowAngle > 145) {
      _stage = 'overhead';
      onScore(95);
      onCue('Full lockout! Lower hands back to shoulders.');
      return;
    }

    if (_stage == 'overhead' && elbowAngle < 110) {
      if (now.difference(_lastRep).inMilliseconds > 500) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'rack';
        onRep();
        onScore(96);
        onCue('Great press #$_repsCounted! Press up again when ready.');
      }
      return;
    }

    if (_stage == 'pressing' && elbowAngle < 100) {
      _stage = 'rack';
    }
  }

  void reset() {
    _stage = 'rack';
    _repsCounted = 0;
    _emaFilter.reset();
  }
}
