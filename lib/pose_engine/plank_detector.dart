import 'dart:async';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';

class PlankDetector {
  Timer? _secondTimer;
  int _secondsHeld = 0;

  void evaluate({
    required Pose pose,
    required Function(String cue) onCue,
    required Function(int score) onScore,
    required Function() onRep,
  }) {
    final l = pose.landmarks;
    final ls = l[PoseLandmarkType.leftShoulder];
    final rs = l[PoseLandmarkType.rightShoulder];
    final lh = l[PoseLandmarkType.leftHip];
    final rh = l[PoseLandmarkType.rightHip];
    final lk = l[PoseLandmarkType.leftKnee];
    final rk = l[PoseLandmarkType.rightKnee];
    final la = l[PoseLandmarkType.leftAnkle];
    final ra = l[PoseLandmarkType.rightAnkle];

    final leftSide = ls != null && lh != null && (lk != null || la != null);
    final rightSide = rs != null && rh != null && (rk != null || ra != null);

    if (!leftSide && !rightSide) {
      onCue('Position camera so torso and legs are visible in plank.');
      _stopTimer();
      return;
    }

    double bodyLine = 180;
    if (leftSide) {
      bodyLine = AngleCalculator.computeAngle(ls, lh, la ?? lk!);
    } else if (rightSide) {
      bodyLine = AngleCalculator.computeAngle(rs, rh, ra ?? rk!);
    }

    final issues = <String>[];
    if (bodyLine < 145) {
      issues.add('Hips are sagging — engage your core.');
    } else if (bodyLine > 200) {
      issues.add('Hips are too high — lower to flat line.');
    }

    if (issues.isEmpty) {
      onScore(95);
      onCue('Holding solid plank: ${_secondsHeld}s. Breathe steadily.');
      _startTimerIfNeeded(onRep);
    } else {
      onScore(70);
      onCue(issues.first);
      _stopTimer();
    }
  }

  void _startTimerIfNeeded(Function() onTick) {
    if (_secondTimer == null || !_secondTimer!.isActive) {
      _secondTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          _secondsHeld++;
          onTick();
        },
      );
    }
  }

  void _stopTimer() {
    _secondTimer?.cancel();
    _secondTimer = null;
  }

  void reset() {
    _stopTimer();
    _secondsHeld = 0;
  }
}
