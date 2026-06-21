import '../models/ball.dart';
import '../models/platform.dart';

class PhysicsEngine {
  void applyPhysics(Ball ball, double screenWidth, double screenHeight) {
    // Apply gravity
    ball.vy += PhysicsConstants.gravity;
    
    // Update position
    ball.x += ball.vx;
    ball.y += ball.vy;
    
    // Wall collisions
    _handleWallCollisions(ball, screenWidth);
  }
  
  void _handleWallCollisions(Ball ball, double screenWidth) {
    if (ball.x - ball.radius < 0) {
      ball.x = ball.radius;
      ball.vx = ball.vx.abs();
    } else if (ball.x + ball.radius > screenWidth) {
      ball.x = screenWidth - ball.radius;
      ball.vx = -ball.vx.abs();
    }
  }
  
  void bounceOnPlatform(Ball ball, Platform platform) {
    ball.vy = PhysicsConstants.bounceVelocity;
    
    // Add horizontal movement based on where ball hits the platform
    double hitPos = (ball.x - platform.x) / (platform.width / 2);
    ball.vx = hitPos * 3;
    
    // Clamp horizontal speed
    if (ball.vx > PhysicsConstants.maxHorizontalSpeed) {
      ball.vx = PhysicsConstants.maxHorizontalSpeed;
    }
    if (ball.vx < -PhysicsConstants.maxHorizontalSpeed) {
      ball.vx = -PhysicsConstants.maxHorizontalSpeed;
    }
  }
}

class PhysicsConstants {
  static const double gravity = 0.3;
  static const double bounceVelocity = -6.5;
  static const double maxHorizontalSpeed = 8.0;
  static const double dragSensitivity = 0.02;
  static const double platformWidth = 80;
  static const double platformHeight = 12;
  static const double starRadius = 10;
  static const double minPlatformSpacing = 80;
  static const double platformSpacingRange = 60;
  static const double starSpawnRate = 0.3;
}