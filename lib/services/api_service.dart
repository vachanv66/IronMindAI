import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_record.dart';
import 'storage_service.dart';

class ApiService {
  static const baseUrl = 'http://10.100.254.138:8000';

  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getAuthToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<void> saveProfile({
    required String name,
    required String level,
    required String goal,
    String userId = 'demo-user',
  }) async {
    try {
      final headers = await _headers();
      await http
          .put(
            Uri.parse('$baseUrl/profiles'),
            headers: headers,
            body: jsonEncode({
              'user_id': userId,
              'name': name,
              'fitness_level': level,
              'goal': goal,
            }),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  static Future<void> saveWorkout(
    WorkoutRecord record, {
    String userId = 'demo-user',
  }) async {
    try {
      final headers = await _headers();
      await http
          .post(
            Uri.parse('$baseUrl/workouts'),
            headers: headers,
            body: jsonEncode({
              'user_id': userId,
              'exercise': record.exercise,
              'reps': record.reps,
              'form_score': record.score.clamp(0, 100),
              'duration_seconds': record.seconds,
            }),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }
}
