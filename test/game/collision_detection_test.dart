import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_remake/game/collision_detector.dart';
import 'package:bounce_remake/models/ball.dart';
import 'package:bounce_remake/models/platform.dart';
import 'package:bounce_remake/models/star.dart';

void main() {
  group('CollisionDetector Tests', () {
    late CollisionDetector detector;
    late Ball ball;

    setUp(() {
      detector = CollisionDetector();
      ball = Ball(
        x: 200,
        y: 300,
        radius: 15,
        vx: 2.0,
        vy: 3.0,
      );
    });

    group('Platform Collision Tests', () {
      test('checkPlatformCollision returns true when ball lands on platform', () {
        final platform = Platform(
          x: 200,
          y: 315,
          width: 80,
          height: 12,
        );

        expect(detector.checkPlatformCollision(ball, platform), true);
      });

      test('checkPlatformCollision returns false when ball is moving up', () {
        final platform = Platform(
          x: 200,
          y: 315,
          width: 80,
          height: 12,
        );
        ball.vy = -3.0;

        expect(detector.checkPlatformCollision(ball, platform), false);
      });

      test('checkPlatformCollision returns false when ball is outside horizontally', () {
        final platform = Platform(
          x: 300,
          y: 315,
          width: 80,
          height: 12,
        );

        expect(detector.checkPlatformCollision(ball, platform), false);
      });

      test('checkPlatformCollision returns false when ball is above platform', () {
        final platform = Platform(
          x: 200,
          y: 400,
          width: 80,
          height: 12,
        );

        expect(detector.checkPlatformCollision(ball, platform), false);
      });

      test('checkPlatformCollision returns false when ball is below platform', () {
        final platform = Platform(
          x: 200,
          y: 100,
          width: 80,
          height: 12,
        );

        expect(detector.checkPlatformCollision(ball, platform), false);
      });
    });

    group('Star Collision Tests', () {
      test('checkStarCollision returns true when ball overlaps star', () {
        final star = Star(
          x: 200,
          y: 300,
          radius: 10,
        );

        expect(detector.checkStarCollision(ball, star), true);
      });

      test('checkStarCollision returns false when ball does not overlap star', () {
        final star = Star(
          x: 300,
          y: 400,
          radius: 10,
        );

        expect(detector.checkStarCollision(ball, star), false);
      });

      test('checkStarCollision returns false when star is collected', () {
        final star = Star(
          x: 200,
          y: 300,
          radius: 10,
          isCollected: true,
        );

        expect(detector.checkStarCollision(ball, star), false);
      });

      test('checkStarCollision returns false when ball is far from star', () {
        final star = Star(
          x: 500,
          y: 500,
          radius: 10,
        );

        expect(detector.checkStarCollision(ball, star), false);
      });
    });

    group('Out of Bounds Tests', () {
      test('isOutOfBounds returns true when ball is below screen', () {
        ball.y = 800;
        expect(detector.isOutOfBounds(ball, 800), true);
      });

      test('isOutOfBounds returns false when ball is on screen', () {
        ball.y = 500;
        expect(detector.isOutOfBounds(ball, 800), false);
      });

      test('isOutOfBounds returns false when ball is just at bottom edge', () {
        ball.y = 785; // screenHeight - ball.radius
        expect(detector.isOutOfBounds(ball, 800), false);
      });
    });
  });
}