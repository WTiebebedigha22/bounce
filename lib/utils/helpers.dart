import 'dart:math';

class Helpers {
  static double clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }
  
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
  
  static double randomRange(double min, double max) {
    return min + (max - min) * Random().nextDouble();
  }
  
  static int randomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
  
  static bool chance(double probability) {
    return Random().nextDouble() < probability;
  }
  
  static String formatScore(int score) {
    if (score < 1000) return score.toString();
    if (score < 1000000) return '${(score / 1000).toStringAsFixed(1)}K';
    return '${(score / 1000000).toStringAsFixed(1)}M';
  }
}

class ColorHelpers {
  static List<int> darkenColors(List<int> colors, double factor) {
    return colors.map((color) {
      int r = (color >> 16) & 0xFF;
      int g = (color >> 8) & 0xFF;
      int b = color & 0xFF;
      
      r = (r * (1 - factor)).round().clamp(0, 255);
      g = (g * (1 - factor)).round().clamp(0, 255);
      b = (b * (1 - factor)).round().clamp(0, 255);
      
      return (0xFF << 24) | (r << 16) | (g << 8) | b;
    }).toList();
  }
}