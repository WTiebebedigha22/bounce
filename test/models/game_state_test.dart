import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_remake/models/game_state.dart';
import 'package:bounce_remake/models/ball.dart';
import 'package:bounce_remake/models/platform.dart';
import 'package:bounce_remake/models/star.dart';

void main() {
  group('GameState Model Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState.initial(400, 800);
    });

    test('GameState initializes with correct values', () {
      expect(gameState.screenWidth, 400);
      expect(gameState.screenHeight, 800);
      expect(gameState.score, 0);
      expect(gameState.highScore, 0);
      expect(gameState.isGameOver, false);
      expect(gameState.isPlaying, false);
      expect(gameState.platforms, isEmpty);
      expect(gameState.stars, isEmpty);
    });

    test('GameState copyWith creates new instance with updated values', () {
      final ball = Ball(x: 200, y: 400, radius: 15, vx: 2, vy: -3);
      final platform = Platform(x: 200, y: 600, width: 80, height: 12);
      final star = Star(x: 200, y: 500, radius: 10);

      final updatedState = gameState.copyWith(
        ball: ball,
        platforms: [platform],
        stars: [star],
        score: 10,
        highScore: 15,
        isPlaying: true,
      );

      expect(updatedState.ball, ball);
      expect(updatedState.platforms, [platform]);
      expect(updatedState.stars, [star]);
      expect(updatedState.score, 10);
      expect(updatedState.highScore, 15);
      expect(updatedState.isPlaying, true);
    });

    test('GameState reset resets all values', () {
      gameState = gameState.copyWith(
        score: 10,
        isGameOver: true,
        isPlaying: true,
      );

      gameState.reset();

      expect(gameState.score, 0);
      expect(gameState.isGameOver, false);
      expect(gameState.isPlaying, false);
      expect(gameState.platforms, isEmpty);
      expect(gameState.stars, isEmpty);
    });

    test('GameState getBottomPlatform returns correct platform', () {
      final platform1 = Platform(x: 200, y: 600, width: 80, height: 12);
      final platform2 = Platform(x: 300, y: 700, width: 80, height: 12);
      final platform3 = Platform(x: 100, y: 500, width: 80, height: 12);

      gameState = gameState.copyWith(
        platforms: [platform1, platform2, platform3],
      );

      expect(gameState.getBottomPlatform(), platform2);
    });

    test('GameState getBottomPlatform returns null when empty', () {
      expect(gameState.getBottomPlatform(), null);
    });

    test('GameState getTopPlatform returns correct platform', () {
      final platform1 = Platform(x: 200, y: 600, width: 80, height: 12);
      final platform2 = Platform(x: 300, y: 700, width: 80, height: 12);
      final platform3 = Platform(x: 100, y: 500, width: 80, height: 12);

      gameState = gameState.copyWith(
        platforms: [platform1, platform2, platform3],
      );

      expect(gameState.getTopPlatform(), platform3);
    });

    test('GameState getTopPlatform returns null when empty', () {
      expect(gameState.getTopPlatform(), null);
    });

    test('GameState toString returns correct string', () {
      gameState = gameState.copyWith(
        score: 10,
        isGameOver: true,
      );

      expect(
        gameState.toString(),
        'GameState(score: 10, platforms: 0, stars: 0, gameOver: true)',
      );
    });
  });
}