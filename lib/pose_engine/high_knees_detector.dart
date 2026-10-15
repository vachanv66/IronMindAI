import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class HighKneesDetector {
  String _stage = 'standing'; // 'standing', 'knee_up'
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
    final ls = l[PoseLandmarkType.leftShoulder];
    final rs = l[PoseLandmarkType.rightShoulder];

    final leftLeg = lh != null && lk != null && lh.likelihood > 0.25 && lk.likelihood > 0.25;
    final rightLeg = rh != null && rk != null && rh.likelihood > 0.25 && rk.likelihood > 0.25;

    if (!leftLeg && !rightLeg) {
      onCue('Position camera so hips and knees are visible.');
      return;
    }

    double leftHipAngle = 180;
    double rightHipAngle = 180;

    if (leftLeg && ls != null) {
      leftHipAngle = AngleCalculator.computeAngle(ls, lh, lk);
    }
    if (rightLeg && rs != null) {
      rightHipAngle = AngleCalculator.computeAngle(rs, rh, rk);
    }

    final activeHipAngle = _emaFilter.filter(
      leftHipAngle < rightHipAngle ? leftHipAngle : rightHipAngle,
    );
    final now = DateTime.now();

    final kneeLifted = activeHipAngle < 125 ||
        (leftLeg && (lh.y - lk.y).abs() < 55) ||
        (rightLeg && (rh.y - rk.y).abs() < 55);

    if (_stage == 'standing' && kneeLifted) {
      _stage = 'knee_up';
      onScore(95);
      onCue('High knee! Drive back down and switch legs.');
      return;
    }

    if (_stage == 'knee_up' && activeHipAngle > 140) {
      if (now.difference(_lastRep).inMilliseconds > 300) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'standing';
        onRep();
        onScore(96);
        onCue('Great drive #$_repsCounted! Keep a rapid cadence.');
      }
      return;
    }
  }

  void reset() {
    _stage = 'standing';
    _repsCounted = 0;
    _emaFilter.reset();
  }
}
