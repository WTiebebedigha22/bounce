import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Platform {
  double x;
  double y;
  double width;
  double height;
  bool isMoving;
  double moveSpeed;
  double moveRange;
  double initialX;
  double moveDirection; // 1 for right, -1 for left
  
  // Visual properties
  Color color;
  Color highlightColor;
  double glowIntensity;

  Platform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.isMoving = false,
    this.moveSpeed = 0,
    this.moveRange = 0,
    double? initialX,
    this.moveDirection = 1,
    this.color = Colors.blue,
    this.highlightColor = Colors.lightBlue,
    this.glowIntensity = 0,
  }) : initialX = initialX ?? x;

  /// Creates a copy of the platform with optional new values
  Platform copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    bool? isMoving,
    double? moveSpeed,
    double? moveRange,
    double? initialX,
    double? moveDirection,
    Color? color,
    Color? highlightColor,
    double? glowIntensity,
  }) {
    return Platform(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      isMoving: isMoving ?? this.isMoving,
      moveSpeed: moveSpeed ?? this.moveSpeed,
      moveRange: moveRange ?? this.moveRange,
      initialX: initialX ?? this.initialX,
      moveDirection: moveDirection ?? this.moveDirection,
      color: color ?? this.color,
      highlightColor: highlightColor ?? this.highlightColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
    );
  }

  /// Creates a deep copy
  Platform clone() {
    return Platform(
      x: x,
      y: y,
      width: width,
      height: height,
      isMoving: isMoving,
      moveSpeed: moveSpeed,
      moveRange: moveRange,
      initialX: initialX,
      moveDirection: moveDirection,
      color: color,
      highlightColor: highlightColor,
      glowIntensity: glowIntensity,
    );
  }

  /// Update moving platform position
  void updatePosition(double deltaTime) {
    if (!isMoving) return;
    
    // Move platform
    x += moveSpeed * moveDirection * deltaTime;
    
    // Check if reached range limits
    double distanceFromCenter = x - initialX;
    
    if (distanceFromCenter > moveRange) {
      x = initialX + moveRange;
      moveDirection = -1;
    } else if (distanceFromCenter < -moveRange) {
      x = initialX - moveRange;
      moveDirection = 1;
    }
  }

  /// Check if ball is within platform's horizontal range
  bool isBallWithinRange(double ballX) {
    return ballX > x - width / 2 && ballX < x + width / 2;
  }

  /// Check if ball is above platform
  bool isBallAbove(double ballY, double ballRadius) {
    return ballY + ballRadius > y - height / 2;
  }

  /// Check if ball is colliding with platform from above
  bool checkCollisionFromAbove(double ballX, double ballY, double ballRadius, double ballVy) {
    // Ball must be falling
    if (ballVy >= 0) return false;
    
    // Check horizontal overlap
    if (!isBallWithinRange(ballX)) return false;
    
    // Check vertical collision (ball's bottom is at or above platform's top)
    double ballBottom = ballY + ballRadius;
    double platformTop = y - height / 2;
    double platformBottom = y + height / 2;
    
    // Check if ball is colliding with platform from above
    bool isAbovePlatform = ballBottom <= platformBottom && ballBottom >= platformTop;
    
    return isAbovePlatform;
  }

  /// Get the horizontal position relative to platform center (-1 to 1)
  double getHitPosition(double ballX) {
    return (ballX - x) / (width / 2);
  }

  /// Get the top of the platform
  double get top => y - height / 2;
  
  /// Get the bottom of the platform
  double get bottom => y + height / 2;
  
  /// Get the left of the platform
  double get left => x - width / 2;
  
  /// Get the right of the platform
  double get right => x + width / 2;

  /// Check if a point is inside the platform
  bool containsPoint(double px, double py) {
    return px > left && px < right && py > top && py < bottom;
  }

  /// Get distance from platform center to a point
  double distanceTo(double px, double py) {
    final dx = px - x;
    final dy = py - y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Check if platform is near the ball (for performance optimization)
  bool isNearBall(double ballX, double ballY, double maxDistance) {
    final dx = ballX - x;
    final dy = ballY - y;
    return (dx * dx + dy * dy) < (maxDistance * maxDistance);
  }

  /// Reset platform to initial position
  void reset() {
    x = initialX;
    moveDirection = 1;
    glowIntensity = 0;
  }

  /// Update glow intensity (for visual feedback)
  void updateGlow(double deltaTime) {
    if (glowIntensity > 0) {
      glowIntensity = max(0, glowIntensity - deltaTime * 0.5);
    }
  }

  /// Set glow intensity (when ball bounces)
  void setGlow(double intensity) {
    glowIntensity = min(1.0, intensity);
  }

  @override
  String toString() {
    return 'Platform(x: $x, y: $y, width: $width, height: $height, moving: $isMoving)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Platform &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.isMoving == isMoving;
  }

  @override
  int get hashCode {
    return x.hashCode ^ 
           y.hashCode ^ 
           width.hashCode ^ 
           height.hashCode ^ 
           isMoving.hashCode;
  }
}

/// Extension for creating different platform types
extension PlatformFactory on Platform {
  /// Create a moving platform
  static Platform moving({
    required double x,
    required double y,
    required double width,
    required double height,
    double moveSpeed = 1.0,
    double moveRange = 50,
  }) {
    return Platform(
      x: x,
      y: y,
      width: width,
      height: height,
      isMoving: true,
      moveSpeed: moveSpeed,
      moveRange: moveRange,
    );
  }

  /// Create a bouncing platform (moves up and down)
  static Platform bouncing({
    required double x,
    required double y,
    required double width,
    required double height,
    double moveSpeed = 0.5,
    double moveRange = 30,
  }) {
    return Platform(
      x: x,
      y: y,
      width: width,
      height: height,
      isMoving: true,
      moveSpeed: moveSpeed,
      moveRange: moveRange,
    );
  }

  /// Create a glowing platform (visual effect)
  static Platform glowing({
    required double x,
    required double y,
    required double width,
    required double height,
    Color color = Colors.purple,
    Color highlightColor = Colors.pink,
  }) {
    return Platform(
      x: x,
      y: y,
      width: width,
      height: height,
      color: color,
      highlightColor: highlightColor,
    );
  }

  /// Create a disappearing platform (will be removed after some time)
  static Platform disappearing({
    required double x,
    required double y,
    required double width,
    required double height,
    double duration = 2.0,
  }) {
    // This is a placeholder - you'd need to add a timer to the game logic
    return Platform(
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }
}