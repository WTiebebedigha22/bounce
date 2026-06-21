class Ball {
  double x;
  double y;
  double radius;
  double vx; // velocity in x direction
  double vy; // velocity in y direction

  Ball({
    required this.x,
    required this.y,
    required this.radius,
    required this.vx,
    required this.vy,
  });

  /// Creates a copy of the ball with optional new values
  Ball copyWith({
    double? x,
    double? y,
    double? radius,
    double? vx,
    double? vy,
  }) {
    return Ball(
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
    );
  }

  /// Creates a deep copy of the ball
  Ball clone() {
    return Ball(
      x: x,
      y: y,
      radius: radius,
      vx: vx,
      vy: vy,
    );
  }

  /// Resets the ball to initial state
  void reset(double screenWidth, double screenHeight) {
    x = screenWidth / 2;
    y = screenHeight - 100;
    vx = 0;
    vy = -5;
  }

  /// Checks if ball is out of bounds
  bool isOutOfBounds(double screenHeight) {
    return y + radius > screenHeight;
  }

  /// Checks if ball hits left wall
  bool hitsLeftWall() {
    return x - radius < 0;
  }

  /// Checks if ball hits right wall
  bool hitsRightWall(double screenWidth) {
    return x + radius > screenWidth;
  }

  @override
  String toString() {
    return 'Ball(x: $x, y: $y, vx: $vx, vy: $vy)';
  }

  /// Convert to JSON for saving game state
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'radius': radius,
        'vx': vx,
        'vy': vy,
      };

  /// Create from JSON for loading game state
  factory Ball.fromJson(Map<String, dynamic> json) => Ball(
        x: json['x']?.toDouble() ?? 0,
        y: json['y']?.toDouble() ?? 0,
        radius: json['radius']?.toDouble() ?? 15,
        vx: json['vx']?.toDouble() ?? 0,
        vy: json['vy']?.toDouble() ?? 0,
      );
}