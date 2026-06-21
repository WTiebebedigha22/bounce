class AppConstants {
  // Colors
  static const List<int> gradientColors = [
    0xFF0D47A1,
    0xFF1565C0,
    0xFF1E88E5,
    0xFF42A5F5,
  ];
  
  // Animations
  static const Duration gameLoopDuration = Duration(milliseconds: 16);
  static const Duration spawnInterval = Duration(seconds: 2);
  static const Duration pulseDuration = Duration(seconds: 2);
  
  // UI
  static const double cornerRadius = 20.0;
  static const double buttonHeight = 60.0;
  static const double titleFontSize = 48.0;
  static const double scoreFontSize = 24.0;
}

class GameKeys {
  static const String highScore = 'highScore';
  static const String settings = 'settings';
}