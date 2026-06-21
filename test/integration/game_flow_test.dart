import 'package:bounce_remake/models/platform.dart';
import 'package:bounce_remake/models/star.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_remake/game/game_controller.dart';
import 'package:bounce_remake/models/ball.dart';

void main() {
  group('Game Flow Integration Tests', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
      controller.initialize(400, 800);
    });

    test('Game starts correctly', () {
      controller.start();
      
      expect(controller.state.isPlaying, true);
      expect(controller.state.isGameOver, false);
      expect(controller.state.platforms.length, 3);
      expect(controller.state.score, 0);
    });

    test('Game over triggers correctly', () {
      controller.start();
      
      // Simulate ball falling below screen
      controller.state.ball.y = 900;
      controller.update();
      
      expect(controller.state.isGameOver, true);
      expect(controller.state.isPlaying, false);
    });

    test('Moving ball updates horizontal velocity', () {
      controller.start();
      
      controller.moveBall(5.0);
      expect(controller.state.ball.vx, greaterThan(0));
      
      controller.moveBall(-5.0);
      expect(controller.state.ball.vx, lessThan(0));
    });

    test('Collecting star increases score', () {
      controller.start();
      
      // Add a star at ball position
      controller.state.stars.add(
        Star(x: controller.state.ball.x, y: controller.state.ball.y - 20, radius: 10),
      );
      
      controller.update();
      
      expect(controller.state.score, 5); // Star bonus
    });

    test('Hitting platform increases score', () {
      controller.start();
      
      // Position ball above platform
      controller.state.ball.x = 200;
      controller.state.ball.y = 300;
      controller.state.ball.vy = 5.0;
      
      // Add platform below ball
      controller.state.platforms.add(
        Platform(x: 200, y: 315, width: 80, height: 12),
      );
      
      controller.update();
      
      expect(controller.state.score, 1);
    });

    test('High score updates correctly', () {
      controller.start();
      
      // Set high score
      controller.state.highScore = 10;
      controller.state.score = 15;
      controller.gameOver();
      
      expect(controller.state.highScore, 15);
    });
  });
}