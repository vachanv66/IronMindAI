import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class BicepCurlDetector {
  String _stage = 'extended'; // 'extended', 'curling', 'top'
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

    // Check visibility of left and right arms independently
    final leftArmVisible = ls != null && le != null && lw != null &&
        ls.likelihood > 0.25 && le.likelihood > 0.25 && lw.likelihood > 0.25;
    final rightArmVisible = rs != null && re != null && rw != null &&
        rs.likelihood > 0.25 && re.likelihood > 0.25 && rw.likelihood > 0.25;

    if (!leftArmVisible && !rightArmVisible) {
      onCue('Position camera so at least one arm (shoulder, elbow, wrist) is visible.');
      return;
    }

    double activeAngle;
    double? leftAngle;
    double? rightAngle;

    if (leftArmVisible) {
      leftAngle = AngleCalculator.computeAngle(ls, le, lw);
    }
    if (rightArmVisible) {
      rightAngle = AngleCalculator.computeAngle(rs, re, rw);
    }

    // Pick active arm undergoing flexion
    if (leftAngle != null && rightAngle != null) {
      activeAngle = math.min(leftAngle, rightAngle);
    } else {
      activeAngle = leftAngle ?? rightAngle!;
    }

    final elbowAngle = _emaFilter.filter(activeAngle);
    final now = DateTime.now();

    // Responsive State Machine
    if (_stage == 'extended' && elbowAngle < 100) {
      _stage = 'curling';
      onCue('Curling up — squeeze biceps at the top.');
      return;
    }

    if (_stage == 'curling' && elbowAngle < 78) {
      _stage = 'top';
      onScore(95);
      onCue('Peak contraction reached! Lower under control.');
      return;
    }

    // Rep Completion: Returning from top back down to extension
    if (_stage == 'top' && elbowAngle > 115) {
      if (now.difference(_lastRep).inMilliseconds > 500) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'extended';
        onRep();
        onScore(96);
        onCue('Great curl #$_repsCounted! Extend fully for next rep.');
      }
      return;
    }

    if (_stage == 'curling' && elbowAngle > 130) {
      // Returned down without completing curl
      _stage = 'extended';
    }
  }

  void reset() {
    _stage = 'extended';
    _repsCounted = 0;
    _emaFilter.reset();
  }
}
