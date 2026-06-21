import 'ball.dart';
import 'platform.dart';
import 'star.dart';

class GameState {
  Ball ball;
  List<Platform> platforms;
  List<Star> stars;
  int score;
  int highScore;
  int combo;
  int bestCombo;
  int lives;
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
    this.combo = 0,
    this.bestCombo = 0,
    this.lives = 3,
    this.isGameOver = false,
    this.isPlaying = false,
    required this.screenWidth,
    required this.screenHeight,
  });

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

  GameState copyWith({
    Ball? ball,
    List<Platform>? platforms,
    List<Star>? stars,
    int? score,
    int? highScore,
    int? combo,
    int? bestCombo,
    int? lives,
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
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      lives: lives ?? this.lives,
      isGameOver: isGameOver ?? this.isGameOver,
      isPlaying: isPlaying ?? this.isPlaying,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
    );
  }

  void reset() {
    ball.reset(screenWidth, screenHeight);
    platforms.clear();
    stars.clear();
    score = 0;
    combo = 0;
    bestCombo = 0;
    lives = 3;
    isGameOver = false;
    isPlaying = false;
  }

  Platform? getBottomPlatform() {
    if (platforms.isEmpty) return null;
    return platforms.reduce((a, b) => a.y > b.y ? a : b);
  }

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