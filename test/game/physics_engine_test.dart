import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_remake/game/physics_engine.dart';
import 'package:bounce_remake/models/ball.dart';
import 'package:bounce_remake/models/platform.dart';

void main() {
  group('PhysicsEngine Tests', () {
    late PhysicsEngine physicsEngine;
    late Ball ball;

    setUp(() {
      physicsEngine = PhysicsEngine();
      ball = Ball(
        x: 200,
        y: 300,
        radius: 15,
        vx: 2.0,
        vy: -3.0,
      );
    });

    test('applyPhysics applies gravity correctly', () {
      physicsEngine.applyPhysics(ball, 400, 800);

      // Should add gravity to vy
      expect(ball.vy, -3.0 + PhysicsConstants.gravity);
      // Should update position
      expect(ball.x, 202);
      expect(ball.y, 300 + (-3.0 + PhysicsConstants.gravity));
    });

    test('applyPhysics handles wall collisions correctly', () {
      // Test left wall
      ball.x = 10;
      ball.vx = -5.0;
      physicsEngine.applyPhysics(ball, 400, 800);
      expect(ball.x, 15); // ball.radius
      expect(ball.vx > 0, true);

      // Test right wall
      ball.x = 390;
      ball.vx = 5.0;
      physicsEngine.applyPhysics(ball, 400, 800);
      expect(ball.x, 385); // screenWidth - ball.radius
      expect(ball.vx < 0, true);
    });

    test('bounceOnPlatform bounces ball correctly', () {
      final platform = Platform(
        x: 200,
        y: 350,
        width: 80,
        height: 12,
      );

      ball.x = 200;
      ball.vy = 5.0;
      physicsEngine.bounceOnPlatform(ball, platform);

      expect(ball.vy, PhysicsConstants.bounceVelocity);
      expect(ball.vx.abs(), lessThanOrEqualTo(PhysicsConstants.maxHorizontalSpeed));
    });

    test('bounceOnPlatform adds horizontal movement based on hit position', () {
      final platform = Platform(
        x: 200,
        y: 350,
        width: 80,
        height: 12,
      );

      // Hit left side of platform
      ball.x = 160;
      ball.vy = 5.0;
      physicsEngine.bounceOnPlatform(ball, platform);
      expect(ball.vx, lessThan(0));

      // Hit center of platform
      ball.x = 200;
      ball.vy = 5.0;
      physicsEngine.bounceOnPlatform(ball, platform);
      expect(ball.vx, 0);

      // Hit right side of platform
      ball.x = 240;
      ball.vy = 5.0;
      physicsEngine.bounceOnPlatform(ball, platform);
      expect(ball.vx, greaterThan(0));
    });

    test('bounceOnPlatform clamps horizontal speed', () {
      final platform = Platform(
        x: 200,
        y: 350,
        width: 80,
        height: 12,
      );

      // Ball far left of platform center
      ball.x = 100;
      ball.vy = 5.0;
      physicsEngine.bounceOnPlatform(ball, platform);
      expect(ball.vx, PhysicsConstants.maxHorizontalSpeed);
      expect(ball.vx <= PhysicsConstants.maxHorizontalSpeed, true);

      // Ball far right of platform center
      ball.x = 300;
      ball.vy = 5.0;
      physicsEngine.bounceOnPlatform(ball, platform);
      expect(ball.vx, -PhysicsConstants.maxHorizontalSpeed);
      expect(ball.vx >= -PhysicsConstants.maxHorizontalSpeed, true);
    });
  });
}