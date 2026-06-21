import 'dart:math';

class Star {
  double x;
  double y;
  double radius;
  bool isCollected;
  double rotation;
  double pulseValue;
  double scale;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    this.isCollected = false,
    this.rotation = 0,
    this.pulseValue = 0,
    this.scale = 1.0,
  });

  /// Creates a copy with optional new values
  Star copyWith({
    double? x,
    double? y,
    double? radius,
    bool? isCollected,
    double? rotation,
    double? pulseValue,
    double? scale,
  }) {
    return Star(
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      isCollected: isCollected ?? this.isCollected,
      rotation: rotation ?? this.rotation,
      pulseValue: pulseValue ?? this.pulseValue,
      scale: scale ?? this.scale,
    );
  }

  /// Creates a deep copy
  Star clone() {
    return Star(
      x: x,
      y: y,
      radius: radius,
      isCollected: isCollected,
      rotation: rotation,
      pulseValue: pulseValue,
      scale: scale,
    );
  }

  /// Update star animation with delta time
  void updateAnimation(double deltaTime) {
    // Rotate continuously
    rotation += 2.0 * deltaTime;
    
    // Update pulse value for breathing effect (0 to 2π)
    pulseValue = (pulseValue + deltaTime * 1.5) % (2 * pi);
    
    // Calculate scale based on pulse (0.85 to 1.15)
    scale = 1.0 + 0.15 * sin(pulseValue);
  }

  /// Get current pulse scale (convenience method)
  double getScale() => scale;

  /// Check if ball collides with star
  bool collidesWith(double ballX, double ballY, double ballRadius) {
    if (isCollected) return false;
    
    final dx = ballX - x;
    final dy = ballY - y;
    final distance = dx * dx + dy * dy;
    final collisionDistance = radius + ballRadius;
    
    return distance < collisionDistance * collisionDistance;
  }

  /// Get distance from ball to star
  double distanceTo(double ballX, double ballY) {
    final dx = ballX - x;
    final dy = ballY - y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Check if star is on screen
  bool isOnScreen(double screenWidth, double screenHeight) {
    return x > -radius && 
           x < screenWidth + radius && 
           y > -radius && 
           y < screenHeight + radius;
  }

  @override
  String toString() {
    return 'Star(x: $x, y: $y, radius: $radius, collected: $isCollected, rotation: $rotation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Star &&
        other.x == x &&
        other.y == y &&
        other.radius == radius &&
        other.isCollected == isCollected;
  }

  @override
  int get hashCode {
    return x.hashCode ^ 
           y.hashCode ^ 
           radius.hashCode ^ 
           isCollected.hashCode;
  }
}