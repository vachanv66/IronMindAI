import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_record.dart';

class StorageService {
  static const _historyKey = 'ironmind_workout_history';
  static const _tokenKey = 'ironmind_auth_token';
  static const _userKey = 'ironmind_user_profile';

  static Future<List<WorkoutRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_historyKey) ?? [];
    return saved
        .map(
          (item) =>
              WorkoutRecord.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> saveWorkout(WorkoutRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.insert(0, record);
    await prefs.setStringList(
      _historyKey,
      history.take(50).map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
