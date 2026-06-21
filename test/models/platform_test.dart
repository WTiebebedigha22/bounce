import 'package:bounce_remake/models/platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Platform Model Tests', () {
    late Platform platform;

    setUp(() {
      platform = Platform(
        x: 200,
        y: 300,
        width: 80,
        height: 12,
      );
    });

    test('Platform initializes with correct values', () {
      expect(platform.x, 200);
      expect(platform.y, 300);
      expect(platform.width, 80);
      expect(platform.height, 12);
      expect(platform.isMoving, false);
      expect(platform.moveSpeed, 0);
      expect(platform.moveRange, 0);
      expect(platform.initialX, 200);
    });

    test('Platform with moving properties initializes correctly', () {
      final movingPlatform = Platform(
        x: 200,
        y: 300,
        width: 80,
        height: 12,
        isMoving: true,
        moveSpeed: 2.0,
        moveRange: 50,
        initialX: 200,
      );

      expect(movingPlatform.isMoving, true);
      expect(movingPlatform.moveSpeed, 2.0);
      expect(movingPlatform.moveRange, 50);
    });

    test('Platform copyWith creates new instance with updated values', () {
      final updatedPlatform = platform.copyWith(
        x: 250,
        y: 350,
        isMoving: true,
      );

      expect(updatedPlatform.x, 250);
      expect(updatedPlatform.y, 350);
      expect(updatedPlatform.width, 80); // unchanged
      expect(updatedPlatform.height, 12); // unchanged
      expect(updatedPlatform.isMoving, true);
    });

    test('Platform clone creates deep copy', () {
      final clonedPlatform = platform.clone();

      expect(clonedPlatform.x, platform.x);
      expect(clonedPlatform.y, platform.y);
      expect(clonedPlatform.width, platform.width);
      expect(clonedPlatform.height, platform.height);
      expect(identical(clonedPlatform, platform), false);
    });

    test('Platform updatePosition moves platform correctly', () {
      final movingPlatform = Platform(
        x: 200,
        y: 300,
        width: 80,
        height: 12,
        isMoving: true,
        moveSpeed: 2.0,
        moveRange: 50,
        initialX: 200,
      );

      // Move right
      movingPlatform.updatePosition(1.0);
      expect(movingPlatform.x, 202);

      // Move right more
      for (int i = 0; i < 30; i++) {
        movingPlatform.updatePosition(1.0);
      }
      // Should bounce back when reaching range limit
      expect(movingPlatform.x, lessThan(200 + 50));
    });

    test('Platform isBallWithinRange returns true when ball is within range', () {
      expect(platform.isBallWithinRange(200), true);
      expect(platform.isBallWithinRange(180), true);
      expect(platform.isBallWithinRange(240), true);
    });

    test('Platform isBallWithinRange returns false when ball is outside range', () {
      expect(platform.isBallWithinRange(100), false);
      expect(platform.isBallWithinRange(300), false);
    });

    test('Platform isBallAbove returns correct value', () {
      expect(platform.isBallAbove(290, 15), true);
      expect(platform.isBallAbove(285, 15), true);
      expect(platform.isBallAbove(310, 15), false);
    });

    test('Platform toString returns correct string', () {
      expect(
        platform.toString(),
        'Platform(x: 200, y: 300, width: 80, height: 12)',
      );
    });
  });
}