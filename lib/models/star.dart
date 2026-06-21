class Star {
  double x;
  double y;
  double radius;
  bool isCollected;
  double rotation;
  double pulseValue;

  Star({
    required this.x,
    required this.y,
    required this.radius,
    this.isCollected = false,
    this.rotation = 0,
    this.pulseValue = 0,
  });

  /// Creates a copy with optional new values
  Star copyWith({
    double? x,
    double? y,
    double? radius,
    bool? isCollected,
    double? rotation,
    double? pulseValue,
  }) {
    return Star(
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      isCollected: isCollected ?? this.isCollected,
      rotation: rotation ?? this.rotation,
      pulseValue: pulseValue ?? this.pulseValue,
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
    );
  }

  /// Update star animation
  void updateAnimation(double deltaTime) {
    rotation += 2.0 * deltaTime;
    pulseValue = (pulseValue + deltaTime) % (2 * 3.14159);
  }

  /// Get current pulse scale for animation
  double getPulseScale() {
    return 1.0 + 0.15 * (pulseValue / (2 * 3.14159));
  }

  /// Check if ball collides with star
  bool collidesWith(double ballX, double ballY, double ballRadius) {
    if (isCollected) return false;
    
    double dx = ballX - x;
    double dy = ballY - y;
    double distance = dx * dx + dy * dy;
    double collisionDistance = radius + ballRadius;
    
    return distance < collisionDistance * collisionDistance;
  }

  @override
  String toString() {
    return 'Star(x: $x, y: $y, radius: $radius, collected: $isCollected)';
  }
}