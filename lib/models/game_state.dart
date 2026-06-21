import 'ball.dart';
import 'platform.dart';
import 'star.dart';

class GameState {
  Ball ball;
  List<Platform> platforms;
  List<Star> stars;
  int score;
  int highScore;
  bool isGameOver;
  bool isPlaying;
  double screenWidth;
  double screenHeight;

  GameState({
    required this.ball,
    required this.platforms,
    required this.stars,
    this.score = 0,
    this.highScore = 0,
    this.isGameOver = false,
    this.isPlaying = false,
    required this.screenWidth,
    required this.screenHeight,
  });

  /// Create initial game state
  factory GameState.initial(double width, double height) {
    return GameState(
      ball: Ball(
        x: width / 2,
        y: height - 100,
        radius: 15,
        vx: 0,
        vy: -5,
      ),
      platforms: [],
      stars: [],
      screenWidth: width,
      screenHeight: height,
    );
  }

  /// Create a copy of the game state
  GameState copyWith({
    Ball? ball,
    List<Platform>? platforms,
    List<Star>? stars,
    int? score,
    int? highScore,
    bool? isGameOver,
    bool? isPlaying,
    double? screenWidth,
    double? screenHeight,
  }) {
    return GameState(
      ball: ball ?? this.ball,
      platforms: platforms ?? this.platforms,
      stars: stars ?? this.stars,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      isGameOver: isGameOver ?? this.isGameOver,
      isPlaying: isPlaying ?? this.isPlaying,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
    );
  }

  /// Reset game state
  void reset() {
    ball.reset(screenWidth, screenHeight);
    platforms.clear();
    stars.clear();
    score = 0;
    isGameOver = false;
    isPlaying = false;
  }

  /// Get the bottom platform (closest to ball)
  Platform? getBottomPlatform() {
    if (platforms.isEmpty) return null;
    return platforms.reduce((a, b) => a.y > b.y ? a : b);
  }

  /// Get the top platform (furthest from ball)
  Platform? getTopPlatform() {
    if (platforms.isEmpty) return null;
    return platforms.reduce((a, b) => a.y < b.y ? a : b);
  }

  @override
  String toString() {
    return 'GameState(score: $score, platforms: ${platforms.length}, '
        'stars: ${stars.length}, gameOver: $isGameOver)';
  }
}