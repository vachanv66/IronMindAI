import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class SquatDetector {
  String _stage = 'standing'; // 'standing', 'descending', 'bottom'
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

    // Need at least one hip and one knee with reasonable confidence
    final leftLegPresent = lh != null && lk != null && lh.likelihood > 0.25 && lk.likelihood > 0.25;
    final rightLegPresent = rh != null && rk != null && rh.likelihood > 0.25 && rk.likelihood > 0.25;

    if (!leftLegPresent && !rightLegPresent) {
      onCue('Position camera so hips and knees are visible in frame.');
      return;
    }

    double? leftAngle;
    double? rightAngle;

    // Left leg angle
    if (leftLegPresent) {
      if (la != null && la.likelihood > 0.25) {
        leftAngle = AngleCalculator.computeAngle(lh, lk, la);
      } else if (ls != null && ls.likelihood > 0.25) {
        leftAngle = AngleCalculator.computeAngle(ls, lh, lk);
      } else {
        leftAngle = AngleCalculator.computeAngle(lh, lk, lk);
      }
    }

    // Right leg angle
    if (rightLegPresent) {
      if (ra != null && ra.likelihood > 0.25) {
        rightAngle = AngleCalculator.computeAngle(rh, rk, ra);
      } else if (rs != null && rs.likelihood > 0.25) {
        rightAngle = AngleCalculator.computeAngle(rs, rh, rk);
      } else {
        rightAngle = AngleCalculator.computeAngle(rh, rk, rk);
      }
    }

    // Calculate active bending angle
    double activeAngle;
    if (leftAngle != null && rightAngle != null) {
      activeAngle = math.min(leftAngle, rightAngle);
    } else {
      activeAngle = leftAngle ?? rightAngle!;
    }

    final kneeAngle = _emaFilter.filter(activeAngle);
    final now = DateTime.now();

    // Responsive Squat State Machine
    if (_stage == 'standing' && kneeAngle < 125) {
      _stage = 'descending';
      onCue('Squatting down — keep chest proud and back flat.');
      return;
    }

    if (_stage == 'descending' && kneeAngle < 105) {
      _stage = 'bottom';
      onScore(95);
      onCue('Good depth! Drive through heels back to top.');
      return;
    }

    // Rep completed on standing return
    if (_stage == 'bottom' && kneeAngle > 130) {
      if (now.difference(_lastRep).inMilliseconds > 500) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'standing';
        onRep();
        onScore(96);
        onCue('Great squat #$_repsCounted! Stand tall and repeat.');
      }
      return;
    }

    if (_stage == 'descending' && kneeAngle > 135) {
      // Stood up before hitting bottom
      _stage = 'standing';
    }
  }

  void reset() {
    _stage = 'standing';
    _repsCounted = 0;
    _emaFilter.reset();
  }
}
