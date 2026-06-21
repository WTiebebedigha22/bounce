import 'package:bounce_remake/models/ball.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ball Model Tests', () {
    late Ball ball;

    setUp(() {
      ball = Ball(
        x: 100,
        y: 200,
        radius: 15,
        vx: 2.0,
        vy: -3.0,
      );
    });

    test('Ball initializes with correct values', () {
      expect(ball.x, 100);
      expect(ball.y, 200);
      expect(ball.radius, 15);
      expect(ball.vx, 2.0);
      expect(ball.vy, -3.0);
    });

    test('Ball copyWith creates new instance with updated values', () {
      final updatedBall = ball.copyWith(
        x: 150,
        vy: -5.0,
      );

      expect(updatedBall.x, 150);
      expect(updatedBall.y, 200); // unchanged
      expect(updatedBall.radius, 15); // unchanged
      expect(updatedBall.vx, 2.0); // unchanged
      expect(updatedBall.vy, -5.0);
    });

    test('Ball clone creates deep copy', () {
      final clonedBall = ball.clone();

      expect(clonedBall.x, ball.x);
      expect(clonedBall.y, ball.y);
      expect(clonedBall.radius, ball.radius);
      expect(clonedBall.vx, ball.vx);
      expect(clonedBall.vy, ball.vy);

      // Ensure it's a different instance
      expect(identical(clonedBall, ball), false);
    });

    test('Ball reset sets correct initial values', () {
      ball.reset(300, 400);

      expect(ball.x, 150); // screenWidth / 2
      expect(ball.y, 300); // screenHeight - 100
      expect(ball.vx, 0);
      expect(ball.vy, -5);
    });

    test('Ball isOutOfBounds returns true when below screen', () {
      ball.y = 500;
      expect(ball.isOutOfBounds(400), true);
    });

    test('Ball isOutOfBounds returns false when above screen', () {
      ball.y = 300;
      expect(ball.isOutOfBounds(400), false);
    });

    test('Ball hitsLeftWall returns true when touching left wall', () {
      ball.x = 10;
      expect(ball.hitsLeftWall(), true);
    });

    test('Ball hitsLeftWall returns false when not touching left wall', () {
      ball.x = 100;
      expect(ball.hitsLeftWall(), false);
    });

    test('Ball hitsRightWall returns true when touching right wall', () {
      ball.x = 390;
      expect(ball.hitsRightWall(400), true);
    });

    test('Ball hitsRightWall returns false when not touching right wall', () {
      ball.x = 100;
      expect(ball.hitsRightWall(400), false);
    });

    test('Ball toJson returns correct map', () {
      final json = ball.toJson();

      expect(json['x'], 100);
      expect(json['y'], 200);
      expect(json['radius'], 15);
      expect(json['vx'], 2.0);
      expect(json['vy'], -3.0);
    });

    test('Ball fromJson creates correct instance', () {
      final json = {
        'x': 150.0,
        'y': 250.0,
        'radius': 20.0,
        'vx': 1.5,
        'vy': -2.5,
      };

      final newBall = Ball.fromJson(json);

      expect(newBall.x, 150);
      expect(newBall.y, 250);
      expect(newBall.radius, 20);
      expect(newBall.vx, 1.5);
      expect(newBall.vy, -2.5);
    });

    test('Ball toString returns correct string', () {
      expect(
        ball.toString(),
        'Ball(x: 100, y: 200, vx: 2.0, vy: -3.0)',
      );
    });
  });
}