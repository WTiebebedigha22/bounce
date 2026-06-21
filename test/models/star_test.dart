import 'package:flutter_test/flutter_test.dart';
import 'package:bounce_remake/models/star.dart';
import 'dart:math';

void main() {
  group('Star Model Tests', () {
    late Star star;

    setUp(() {
      star = Star(
        x: 150,
        y: 200,
        radius: 10,
      );
    });

    test('Star initializes with correct values', () {
      expect(star.x, 150);
      expect(star.y, 200);
      expect(star.radius, 10);
      expect(star.isCollected, false);
      expect(star.rotation, 0);
      expect(star.pulseValue, 0);
    });

    test('Star copyWith creates new instance with updated values', () {
      final updatedStar = star.copyWith(
        x: 175,
        y: 225,
        isCollected: true,
      );

      expect(updatedStar.x, 175);
      expect(updatedStar.y, 225);
      expect(updatedStar.radius, 10); // unchanged
      expect(updatedStar.isCollected, true);
    });

    test('Star clone creates deep copy', () {
      final clonedStar = star.clone();

      expect(clonedStar.x, star.x);
      expect(clonedStar.y, star.y);
      expect(clonedStar.radius, star.radius);
      expect(clonedStar.isCollected, star.isCollected);
      expect(identical(clonedStar, star), false);
    });

    test('Star updateAnimation updates rotation and pulse', () {
      star.updateAnimation(0.1);
      expect(star.rotation, 0.2);
      expect(star.pulseValue, greaterThan(0));

      star.updateAnimation(0.5);
      expect(star.rotation, greaterThan(0.2));
    });

    test('Star getPulseScale returns correct scale', () {
      star.pulseValue = 0;
      expect(star.getPulseScale(), 1.0);

      star.pulseValue = pi;
      expect(star.getPulseScale(), 1.15);

      star.pulseValue = 2 * pi;
      expect(star.getPulseScale(), 1.0);
    });

    test('Star collidesWith returns true when ball overlaps', () {
      expect(star.collidesWith(150, 200, 10), true);
      expect(star.collidesWith(155, 205, 10), true);
      expect(star.collidesWith(160, 210, 10), true);
    });

    test('Star collidesWith returns false when ball does not overlap', () {
      expect(star.collidesWith(200, 250, 10), false);
      expect(star.collidesWith(300, 300, 10), false);
    });

    test('Star collidesWith returns false when collected', () {
      star.isCollected = true;
      expect(star.collidesWith(150, 200, 10), false);
    });

    test('Star toString returns correct string', () {
      expect(
        star.toString(),
        'Star(x: 150, y: 200, radius: 10, collected: false)',
      );
    });
  });
}