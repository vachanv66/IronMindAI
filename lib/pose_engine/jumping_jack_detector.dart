import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'angle_calculator.dart';
import 'ema_filter.dart';

class JumpingJackDetector {
  String _stage = 'closed'; // 'closed', 'open'
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
    final lw = l[PoseLandmarkType.leftWrist];
    final rw = l[PoseLandmarkType.rightWrist];
    final lh = l[PoseLandmarkType.leftHip];
    final rh = l[PoseLandmarkType.rightHip];

    if (ls == null || rs == null || lh == null || rh == null) {
      onCue('Position camera so torso and arms are in frame.');
      return;
    }

    double leftArmAngle = 30;
    double rightArmAngle = 30;

    final le = l[PoseLandmarkType.leftElbow];
    final re = l[PoseLandmarkType.rightElbow];

    if (le != null) {
      leftArmAngle = AngleCalculator.computeAngle(lh, ls, le);
    }
    if (re != null) {
      rightArmAngle = AngleCalculator.computeAngle(rh, rs, re);
    }

    final armAngle = _emaFilter.filter((leftArmAngle + rightArmAngle) / 2);
    final now = DateTime.now();

    final handsOverhead = (lw != null && lw.y < ls.y) ||
        (rw != null && rw.y < rs.y) ||
        armAngle > 110;

    if (_stage == 'closed' && handsOverhead) {
      _stage = 'open';
      onScore(95);
      onCue('Wide jump! Return arms down to your sides.');
      return;
    }

    final handsDown = armAngle < 60 ||
        ((lw == null || lw.y > ls.y + 40) && (rw == null || rw.y > rs.y + 40));

    if (_stage == 'open' && handsDown) {
      if (now.difference(_lastRep).inMilliseconds > 400) {
        _lastRep = now;
        _repsCounted++;
        _stage = 'closed';
        onRep();
        onScore(96);
        onCue('Great jumping jack #$_repsCounted! Keep up the rhythm.');
      }
      return;
    }
  }

  void reset() {
    _stage = 'closed';
    _repsCounted = 0;
    _emaFilter.reset();
  }
}
