import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/exercise.dart';

class AudioCoachingService {
  static final AudioCoachingService _instance = AudioCoachingService._internal();
  factory AudioCoachingService() => _instance;
  AudioCoachingService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool isMuted = false;

  // Voice Memory Engine State (timestamp-based cooldown per topic)
  final Map<String, DateTime> _topicLastSpokenTimes = {};
  DateTime _lastSpokenTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastRepCountSpoken = -1;
  DateTime _lastRepTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _activeStepSpeechToken = 0;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.50); // Natural human cadence
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0); // Natural conversational pitch
      await _flutterTts.awaitSpeakCompletion(true);

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Init Error: $e');
    }
  }

  /// Speaks rep count with natural human phrasing and milestone celebrations
  Future<void> speakRep(int count) async {
    if (isMuted || count <= 0) return;
    final now = DateTime.now();

    // Prevent duplicate rep speech within 700ms
    if (count == _lastRepCountSpoken || now.difference(_lastRepTime).inMilliseconds < 700) {
      return;
    }

    _lastRepCountSpoken = count;
    _lastRepTime = now;
    _lastSpokenTime = now;

    String speech;
    if (count == 1) {
      speech = 'One';
    } else if (count == 2) {
      speech = 'Two';
    } else if (count == 3) {
      speech = 'Three';
    } else if (count == 4) {
      speech = 'Four';
    } else if (count == 5) {
      speech = 'Five! Great rhythm, keep it up.';
    } else if (count == 10) {
      speech = 'Ten reps! Halfway through, stay strong.';
    } else if (count == 15) {
      speech = 'Fifteen! Fantastic stamina, finish strong.';
    } else if (count == 20) {
      speech = 'Twenty reps! Excellent work today.';
    } else {
      speech = '$count';
    }

    await _executeSpeak(speech);
  }

  /// Speaks timer milestone for isometric/timed exercises (Planks, Wall Sits, Stretches)
  Future<void> speakTimerMilestone(String exerciseName, int seconds) async {
    if (isMuted || seconds <= 0) return;
    final now = DateTime.now();
    if (now.difference(_lastSpokenTime).inMilliseconds < 3500) return;

    String? phrase;
    if (seconds == 5) {
      phrase = 'Five seconds in. Posture looks solid, hold steady.';
    } else if (seconds == 10) {
      phrase = 'Ten seconds. Maintain steady breathing.';
    } else if (seconds == 15) {
      phrase = 'Fifteen seconds. Halfway there, keep your core engaged.';
    } else if (seconds == 20) {
      phrase = 'Twenty seconds. Power through the burn!';
    } else if (seconds == 25) {
      phrase = 'Final five seconds! Hold your line!';
    } else if (seconds == 30) {
      phrase = 'Thirty seconds! Great hold, set completed!';
    }

    if (phrase != null) {
      _lastSpokenTime = now;
      await _executeSpeak(phrase);
    }
  }

  /// Announces exercise introduction when starting workout
  Future<void> speakExerciseIntro(Exercise exercise) async {
    if (isMuted) return;
    final text = 'Starting ${exercise.name}. ${exercise.target}. ${exercise.description}. Position yourself in frame and begin when ready.';
    await _executeSpeak(text);
  }

  /// Speaks a form correction cue with timestamp-based cooldown per topic (10s)
  Future<void> speakFormError(String errorMsg) async {
    if (isMuted || errorMsg.isEmpty) return;
    final topic = _deriveTopic(errorMsg);
    final now = DateTime.now();

    // 3.5s minimum gap between any voice utterance
    if (now.difference(_lastSpokenTime).inMilliseconds < 3500) {
      return;
    }

    // Cooldown per topic: 10 seconds (does not nag every second, but repeats if error continues)
    final lastTopicTime = _topicLastSpokenTimes[topic];
    if (lastTopicTime != null && now.difference(lastTopicTime).inSeconds < 10) {
      return;
    }

    _topicLastSpokenTimes[topic] = now;
    _lastSpokenTime = now;

    final humanCorrection = _humanizeCorrection(errorMsg, topic);
    await _executeSpeak(humanCorrection);
  }

  /// General cue with intelligent pacing and cooldown
  Future<void> speakCue(String rawCue, {String? topicKey}) async {
    if (isMuted || rawCue.isEmpty) return;
    final topic = topicKey ?? _deriveTopic(rawCue);
    final now = DateTime.now();

    if (now.difference(_lastSpokenTime).inMilliseconds < 4000) {
      return;
    }

    final lastTopicTime = _topicLastSpokenTimes[topic];
    if (lastTopicTime != null && now.difference(lastTopicTime).inSeconds < 12) {
      return;
    }

    _topicLastSpokenTimes[topic] = now;
    _lastSpokenTime = now;

    await _executeSpeak(rawCue);
  }

  /// Live coaching feedback called on posture evaluation
  Future<void> speakLiveFeedback({
    required String exerciseName,
    required String cue,
    required int score,
    int? count,
  }) async {
    if (isMuted) return;

    if (score < 75 && cue.isNotEmpty) {
      // Prioritize form correction
      await speakFormError(cue);
    } else if (score >= 90) {
      // Periodic encouraging feedback
      final now = DateTime.now();
      if (now.difference(_lastSpokenTime).inSeconds >= 14) {
        _lastSpokenTime = now;
        final affirmations = [
          'Great form! Keep that cadence.',
          'Posture looks clean and controlled.',
          'Solid execution, stay focused.',
          'Perfect alignment, keep moving!',
        ];
        final affirmation = affirmations[(count ?? 0) % affirmations.length];
        await _executeSpeak(affirmation);
      }
    }
  }

  /// Interactive: User asked "How's my form?"
  Future<void> speakFormCheckStatus(int score, String currentCue) async {
    if (isMuted) return;
    String feedback;
    if (score >= 90) {
      feedback = 'Form score is $score percent! Movement looks clean and well-controlled. Keep going!';
    } else if (score >= 75) {
      feedback = 'Looking good at $score percent. $currentCue. Focus on steady control.';
    } else {
      feedback = 'Form check: $currentCue. Take a quick breath, reset your alignment, and go again.';
    }
    await _executeSpeak(feedback);
  }

  Future<void> speakCameraPlacementIntro() async {
    if (isMuted) return;
    await _executeSpeak('AI coach active! Step back 4 to 6 feet until your body fits inside the frame.');
  }

  /// Interactive: User asked "Give me a tip"
  Future<void> speakInteractiveTip(Exercise exercise, int currentScore, int reps) async {
    if (isMuted) return;
    final tip = exercise.correctFormGuide.isNotEmpty
        ? exercise.correctFormGuide[reps % exercise.correctFormGuide.length]
        : 'Focus on exhaling on contraction and keeping core engaged.';
    final text = 'Quick tip for ${exercise.name}: $tip';
    await _executeSpeak(text);
  }

  /// Pre-workout demo step walkthrough
  Future<void> speakStepGuide(Exercise exercise, int stepIndex) async {
    if (isMuted) return;
    final steps = exercise.correctFormGuide;
    if (steps.isEmpty) return;
    final text = 'Step ${stepIndex + 1}: ${steps[stepIndex % steps.length]}';
    await _executeSpeak(text);
  }

  /// Speaks step instruction and fires onComplete when TTS finishes speaking (event-driven, not timer-based)
  Future<void> speakStepWithCompletion(String text, {required VoidCallback onComplete}) async {
    final token = ++_activeStepSpeechToken;

    if (isMuted || text.isEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      if (_activeStepSpeechToken == token) {
        onComplete();
      }
      return;
    }
    try {
      if (!_isInitialized) await init();
      bool hasFinished = false;

      void finish({required bool shouldComplete}) {
        if (!hasFinished && _activeStepSpeechToken == token) {
          hasFinished = true;
          if (shouldComplete) {
            onComplete();
          }
        }
      }

      _flutterTts.setCompletionHandler(() {
        finish(shouldComplete: true);
      });
      _flutterTts.setErrorHandler((_) {
        finish(shouldComplete: false);
      });
      _flutterTts.setCancelHandler(() {
        finish(shouldComplete: false);
      });

      await _flutterTts.stop();
      if (_activeStepSpeechToken != token) return;
      await _flutterTts.speak(text);

      // Safety timeout in case OS TTS engine listener doesn't trigger
      final wordsCount = text.split(' ').length;
      final safetySeconds = (wordsCount / 2.0).ceil().clamp(3, 15);
      Future.delayed(Duration(seconds: safetySeconds + 1), () {
        if (_activeStepSpeechToken == token) {
          finish(shouldComplete: true);
        }
      });
    } catch (_) {
      if (_activeStepSpeechToken == token) {
        onComplete();
      }
    }
  }

  Future<void> _executeSpeak(String message) async {
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.speak(message);
    } catch (_) {}
  }

  String _deriveTopic(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('back') || lower.contains('spine')) return 'back';
    if (lower.contains('hip') || lower.contains('squat') || lower.contains('lower')) return 'hip';
    if (lower.contains('elbow') || lower.contains('arm') || lower.contains('curl')) return 'elbow';
    if (lower.contains('knee')) return 'knee';
    if (lower.contains('chest') || lower.contains('shoulder')) return 'chest';
    if (lower.contains('camera') || lower.contains('frame') || lower.contains('visible')) return 'camera';
    return lower.length > 15 ? lower.substring(0, 15) : lower;
  }

  String _humanizeCorrection(String raw, String topic) {
    if (topic == 'back') {
      return 'Hey, keep your back straight and chest proud.';
    } else if (topic == 'hip') {
      return 'Remember to hinge your hips and lower under control.';
    } else if (topic == 'elbow') {
      return 'Try keeping your elbows steady and pinned.';
    } else if (topic == 'knee') {
      return 'Track your knees in line with your toes.';
    } else if (topic == 'chest') {
      return 'Keep your chest up and shoulders back.';
    } else if (topic == 'camera') {
      return 'Adjust your position so your full body is inside the camera frame.';
    }
    return 'Posture check: $raw';
  }

  /// Call this when starting a new session or finishing an exercise to clear memory
  void resetSession() {
    _topicLastSpokenTimes.clear();
    _lastRepCountSpoken = -1;
    _lastSpokenTime = DateTime.fromMillisecondsSinceEpoch(0);
    _lastRepTime = DateTime.fromMillisecondsSinceEpoch(0);
    stop();
  }

  void stop() {
    _activeStepSpeechToken++;
    try {
      _flutterTts.stop();
    } catch (_) {}
  }
}
