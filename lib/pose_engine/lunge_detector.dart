import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class LungeDetector {
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
    final lh = l[PoseLandmarkType.leftHip];
    final rh = l[PoseLandmarkType.rightHip];
    final lk = l[PoseLandmarkType.leftKnee];
    final rk = l[PoseLandmarkType.rightKnee];
    final la = l[PoseLandmarkType.leftAnkle];
    final ra = l[PoseLandmarkType.rightAnkle];
    final ls = l[PoseLandmarkType.leftShoulder];
    final rs = l[PoseLandmarkType.rightShoulder];

    final leftLeg = lh != null && lk != null && lh.likelihood > 0.25 && lk.likelihood > 0.25;
    final rightLeg = rh != null && rk != null && rh.likelihood > 0.25 && rk.likelihood > 0.25;

    if (!leftLeg && !rightLeg) {
      onCue('Position camera so hips and knees are in frame.');
      return;
    }

    double? leftKneeAngle;
    double? rightKneeAngle;

    if (leftLeg) {
      if (la != null && la.likelihood > 0.25) {
        leftKneeAngle = AngleCalculator.computeAngle(lh, lk, la);
      } else if (ls != null) {
        leftKneeAngle = AngleCalculator.computeAngle(ls, lh, lk);
      }
    }

    if (rightLeg) {
      if (ra != null && ra.likelihood > 0.25) {
        rightKneeAngle = AngleCalculator.computeAngle(rh, rk, ra);
      } else if (rs != null) {
        rightKneeAngle = AngleCalculator.computeAngle(rs, rh, rk);
      }
    }

    double activeAngle;
    if (leftKneeAngle != null && rightKneeAngle != null) {
      activeAngle = math.min(leftKneeAngle, rightKneeAngle);
    } else {
      activeAngle = leftKneeAngle ?? rightKneeAngle ?? 180;
    }

    final kneeAngle = _emaFilter.filter(activeAngle);
    final now = DateTime.now();

    if (_stage == 'up' && kneeAngle < 120) {
      _stage = 'down';
      onScore(95);
      onCue('Deep lunge — push through front heel to return.');
      return;
    }

    if (_stage == 'down' && kneeAngle > 140) {
      if (now.difference(_lastRep).inMilliseconds > 500) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'up';
        onRep();
        onScore(96);
        onCue('Great lunge #$_repsCounted! Step again when ready.');
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
