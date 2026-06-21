// lib/utils/high_score_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreManager {
  static const String HIGH_SCORE_KEY = 'high_score';
  
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(HIGH_SCORE_KEY) ?? 0;
  }
  
  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = await getHighScore();
    if (score > currentHigh) {
      await prefs.setInt(HIGH_SCORE_KEY, score);
    }
  }
  
  static Future<bool> isNewHighScore(int score) async {
    final currentHigh = await getHighScore();
    return score > currentHigh;
  }
}