import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_remake/game/game_controller.dart';
import 'package:bounce_remake/models/ball.dart';
import 'package:bounce_remake/models/platform.dart';
import 'package:bounce_remake/models/star.dart';

void main() {
  group('Performance Tests', () {
    test('Game loop handles many objects efficiently', () {
      final controller = GameController();
      controller.initialize(400, 800);
      
      // Add many platforms and stars
      for (int i = 0; i < 50; i++) {
        controller.state.platforms.add(
          Platform(x: i * 10, y: i * 20, width: 80, height: 12),
        );
        controller.state.stars.add(
          Star(x: i * 10, y: i * 20 - 40, radius: 10),
        );
      }
      
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 100; i++) {
        controller.update();
      }
      
      stopwatch.stop();
      
      // Should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('Physics calculations are fast', () {
      final ball = Ball(x: 200, y: 300, radius: 15, vx: 2, vy: 3);
      final platform = Platform(x: 200, y: 315, width: 80, height: 12);
      
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        ball.x += ball.vx;
        ball.y += ball.vy;
        ball.vy += 0.3;
      }
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMicroseconds, lessThan(1000));
    });
  });
}