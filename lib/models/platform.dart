class Platform {
  double x;
  double y;
  double width;
  double height;
  bool isMoving;
  double moveSpeed;
  double moveRange;
  double initialX;

  Platform({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.isMoving = false,
    this.moveSpeed = 0,
    this.moveRange = 0,
    double? initialX,
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
    );
  }

  /// Update moving platform position
  void updatePosition(double deltaTime) {
    if (!isMoving) return;
    
    x += moveSpeed * deltaTime;
    
    // Bounce back when reaching range limits
    if (x - initialX > moveRange || x - initialX < -moveRange) {
      moveSpeed = -moveSpeed;
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

  @override
  String toString() {
    return 'Platform(x: $x, y: $y, width: $width, height: $height)';
  }
}