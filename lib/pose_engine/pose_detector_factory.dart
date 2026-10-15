import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'squat_detector.dart';
import 'pushup_detector.dart';
import 'lunge_detector.dart';
import 'jumping_jack_detector.dart';
import 'plank_detector.dart';
import 'bicep_curl_detector.dart';
import 'shoulder_press_detector.dart';
import 'high_knees_detector.dart';
import 'generic_pose_detector.dart';

class PoseDetectorEngine {
  final String exerciseId;
  final String exerciseName;
  final String kind;

  final SquatDetector _squatDetector = SquatDetector();
  final PushupDetector _pushupDetector = PushupDetector();
  final LungeDetector _lungeDetector = LungeDetector();
  final JumpingJackDetector _jjDetector = JumpingJackDetector();
  final PlankDetector _plankDetector = PlankDetector();
  final BicepCurlDetector _bicepCurlDetector = BicepCurlDetector();
  final ShoulderPressDetector _shoulderPressDetector = ShoulderPressDetector();
  final HighKneesDetector _highKneesDetector = HighKneesDetector();
  late final GenericPoseDetector _genericDetector;

  PoseDetectorEngine({
    required this.exerciseId,
    required this.exerciseName,
    required this.kind,
  }) {
    _genericDetector = GenericPoseDetector(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      kind: kind,
    );
  }

  void evaluate({
    required Pose pose,
    required Function(String cue) onCue,
    required Function(int score) onScore,
    required Function() onRep,
  }) {
    final nameLower = exerciseName.toLowerCase();
    final idLower = exerciseId.toLowerCase();

    if (idLower.contains('squat') || nameLower.contains('squat')) {
      _squatDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('pushup') || nameLower.contains('push-up') || nameLower.contains('pushup') || idLower.contains('dip')) {
      _pushupDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('lunge') || nameLower.contains('lunge')) {
      _lungeDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('jumping_jack') || nameLower.contains('jumping jack')) {
      _jjDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('plank') || idLower.contains('sit') || idLower.contains('stretch') || idLower.contains('pose')) {
      _plankDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('curl') || nameLower.contains('curl') || idLower.contains('raise') || idLower.contains('arm_circle')) {
      _bicepCurlDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('press') || nameLower.contains('press')) {
      _shoulderPressDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else if (idLower.contains('knee') || nameLower.contains('knee') || idLower.contains('kick')) {
      _highKneesDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    } else {
      _genericDetector.evaluate(pose: pose, onCue: onCue, onScore: onScore, onRep: onRep);
    }
  }

  void reset() {
    _squatDetector.reset();
    _pushupDetector.reset();
    _lungeDetector.reset();
    _jjDetector.reset();
    _plankDetector.reset();
    _bicepCurlDetector.reset();
    _shoulderPressDetector.reset();
    _highKneesDetector.reset();
    _genericDetector.reset();
  }
}
