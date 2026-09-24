import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_config.dart';

class PreferencesService {
  static const String _keyConfig = 'quizzical_last_config';
  static const String _keyUserName = 'quizzical_user_name';
  static const String _keyLastScore = 'quizzical_last_score';
  static const String _keyLastTotal = 'quizzical_last_total';

  Future<void> saveConfig(QuizConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyConfig, config.toJson());
    } catch (e) {
      // Ignored if storage unavailable
    }
  }

  Future<QuizConfig?> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyConfig);
      if (jsonStr != null) {
        return QuizConfig.fromJson(jsonStr);
      }
    } catch (e) {
      // Ignored
    }
    return null;
  }

  Future<void> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserName, name);
    } catch (_) {}
  }

  Future<String> loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName) ?? 'Alex';
    } catch (_) {
      return 'Alex';
    }
  }

  Future<void> saveLastResult(int score, int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastScore, score);
      await prefs.setInt(_keyLastTotal, total);
    } catch (_) {}
  }
}
