import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  static double computeAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = atan2(a.y - b.y, a.x - b.x);
    final cb = atan2(c.y - b.y, c.x - b.x);
    var value = (ab - cb).abs() * 180 / pi;
    if (value > 180) {
      value = 360 - value;
    }
    return value;
  }
}
