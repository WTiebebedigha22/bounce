import 'dart:math';
import 'package:flutter/material.dart';

class Ball {
  // Position
  double x;
  double y;
  double radius;
  
  // Velocity
  double vx;
  double vy;
  
  // Physics properties
  double mass;
  double bounceFactor;
  double friction;
  double drag;
  
  // Visual properties
  Color color;
  Color glowColor;
  double glowIntensity;
  double rotation;
  double angularVelocity;
  
  // Trail - now properly initialized as mutable list
  List<Offset> trail;
  int maxTrailLength;
  
  // Power-up states
  bool isMagnetized;
  bool isShielded;
  bool isSuperBounce;
  double magnetRadius;
  double powerUpTimer;

  Ball({
    required this.x,
    required this.y,
    required this.radius,
    required this.vx,
    required this.vy,
    this.mass = 1.0,
    this.bounceFactor = 0.8,
    this.friction = 0.99,
    this.drag = 0.999,
    this.color = Colors.orange,
    this.glowColor = Colors.orange,
    this.glowIntensity = 0.0,
    this.rotation = 0.0,
    this.angularVelocity = 0.0,
    List<Offset>? trail,
    this.maxTrailLength = 20,
    this.isMagnetized = false,
    this.isShielded = false,
    this.isSuperBounce = false,
    this.magnetRadius = 150.0,
    this.powerUpTimer = 0.0,
  }) : trail = trail ?? [];

  /// Creates a copy of the ball with optional new values
  Ball copyWith({
    double? x,
    double? y,
    double? radius,
    double? vx,
    double? vy,
    double? mass,
    double? bounceFactor,
    double? friction,
    double? drag,
    Color? color,
    Color? glowColor,
    double? glowIntensity,
    double? rotation,
    double? angularVelocity,
    List<Offset>? trail,
    int? maxTrailLength,
    bool? isMagnetized,
    bool? isShielded,
    bool? isSuperBounce,
    double? magnetRadius,
    double? powerUpTimer,
  }) {
    return Ball(
      x: x ?? this.x,
      y: y ?? this.y,
      radius: radius ?? this.radius,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      mass: mass ?? this.mass,
      bounceFactor: bounceFactor ?? this.bounceFactor,
      friction: friction ?? this.friction,
      drag: drag ?? this.drag,
      color: color ?? this.color,
      glowColor: glowColor ?? this.glowColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      rotation: rotation ?? this.rotation,
      angularVelocity: angularVelocity ?? this.angularVelocity,
      trail: trail ?? List.from(this.trail), // Create a copy
      maxTrailLength: maxTrailLength ?? this.maxTrailLength,
      isMagnetized: isMagnetized ?? this.isMagnetized,
      isShielded: isShielded ?? this.isShielded,
      isSuperBounce: isSuperBounce ?? this.isSuperBounce,
      magnetRadius: magnetRadius ?? this.magnetRadius,
      powerUpTimer: powerUpTimer ?? this.powerUpTimer,
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
      mass: mass,
      bounceFactor: bounceFactor,
      friction: friction,
      drag: drag,
      color: color,
      glowColor: glowColor,
      glowIntensity: glowIntensity,
      rotation: rotation,
      angularVelocity: angularVelocity,
      trail: List.from(trail), // Create a copy
      maxTrailLength: maxTrailLength,
      isMagnetized: isMagnetized,
      isShielded: isShielded,
      isSuperBounce: isSuperBounce,
      magnetRadius: magnetRadius,
      powerUpTimer: powerUpTimer,
    );
  }

  /// Resets the ball to initial state
  void reset(double screenWidth, double screenHeight) {
    x = screenWidth / 2;
    y = screenHeight - 100;
    vx = 0;
    vy = -5;
    rotation = 0;
    angularVelocity = 0;
    glowIntensity = 0;
    trail.clear(); // Now works because trail is mutable
    isMagnetized = false;
    isShielded = false;
    isSuperBounce = false;
    powerUpTimer = 0;
  }

  /// Update ball physics
  void update(double deltaTime, double gravity) {
    // Apply gravity
    vy += gravity * deltaTime * 60;
    
    // Apply drag (air resistance)
    vx *= pow(drag, deltaTime * 60);
    vy *= pow(drag, deltaTime * 60);
    
    // Update position
    x += vx * deltaTime * 60;
    y += vy * deltaTime * 60;
    
    // Update rotation based on velocity
    angularVelocity = (vx / radius) * deltaTime * 60;
    rotation += angularVelocity;
    
    // Update trail
    updateTrail();
    
    // Update power-up timer
    if (powerUpTimer > 0) {
      powerUpTimer -= deltaTime;
      if (powerUpTimer <= 0) {
        isMagnetized = false;
        isShielded = false;
        isSuperBounce = false;
      }
    }
    
    // Update glow intensity
    glowIntensity = max(0, glowIntensity - deltaTime * 0.5);
  }

  /// Update trail
  void updateTrail() {
    trail.add(Offset(x, y));
    if (trail.length > maxTrailLength) {
      trail.removeAt(0);
    }
  }

  /// Apply bounce with bounce factor
  void bounce(double surfaceBounceFactor) {
    vy = -vy.abs() * bounceFactor * surfaceBounceFactor;
    if (isSuperBounce) {
      vy *= 1.5;
    }
    setGlow(0.5);
  }

  /// Apply horizontal bounce
  void bounceHorizontal() {
    vx = -vx * bounceFactor;
  }

  /// Apply friction to horizontal movement
  void applyFriction() {
    vx *= friction;
    if (vx.abs() < 0.01) vx = 0;
  }

  /// Get current speed
  double get speed => sqrt(vx * vx + vy * vy);
  
  /// Get current direction angle
  double get angle => atan2(vy, vx);

  /// Get kinetic energy
  double get kineticEnergy => 0.5 * mass * speed * speed;

  /// Check if ball is moving
  bool get isMoving => speed > 0.1;

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

  /// Checks if ball hits top wall
  bool hitsTopWall() {
    return y - radius < 0;
  }

  /// Get position at a specific time in the future (for prediction)
  Offset predictPosition(double time, double gravity) {
    double futureX = x + vx * time;
    double futureY = y + vy * time + 0.5 * gravity * time * time;
    return Offset(futureX, futureY);
  }

  /// Check if ball collides with a point
  bool collidesWithPoint(double px, double py) {
    final dx = x - px;
    final dy = y - py;
    return (dx * dx + dy * dy) < (radius * radius);
  }

  /// Check if ball collides with another ball
  bool collidesWithBall(Ball other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final minDist = radius + other.radius;
    return (dx * dx + dy * dy) < (minDist * minDist);
  }

  /// Get distance to another ball
  double distanceToBall(Ball other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Activate power-up
  void activatePowerUp(String type, double duration) {
    switch (type) {
      case 'magnet':
        isMagnetized = true;
        magnetRadius = 150.0;
        break;
      case 'shield':
        isShielded = true;
        break;
      case 'super_bounce':
        isSuperBounce = true;
        break;
    }
    powerUpTimer = duration;
  }

  /// Set glow intensity (visual feedback)
  void setGlow(double intensity) {
    glowIntensity = min(1.0, intensity);
  }

  /// Get trail position for rendering
  List<Offset> getTrailPositions() {
    return trail;
  }

  /// Clear trail
  void clearTrail() {
    trail.clear();
  }

  /// Get color with glow effect
  Color getColorWithGlow() {
    if (isSuperBounce) {
      return Colors.purple;
    } else if (isShielded) {
      return Colors.blue;
    } else if (isMagnetized) {
      return Colors.green;
    }
    return color;
  }

  /// Get glow color based on state
  Color getGlowColor() {
    if (isSuperBounce) {
      return Colors.purpleAccent;
    } else if (isShielded) {
      return Colors.blueAccent;
    } else if (isMagnetized) {
      return Colors.greenAccent;
    }
    return glowColor;
  }

  @override
  String toString() {
    return 'Ball(x: $x, y: $y, vx: $vx, vy: $vy, speed: ${speed.toStringAsFixed(2)})';
  }

  /// Convert to JSON for saving game state
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'radius': radius,
        'vx': vx,
        'vy': vy,
        'mass': mass,
        'bounceFactor': bounceFactor,
        'isMagnetized': isMagnetized,
        'isShielded': isShielded,
        'isSuperBounce': isSuperBounce,
        'powerUpTimer': powerUpTimer,
        'trail': trail.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      };

  /// Create from JSON for loading game state
  factory Ball.fromJson(Map<String, dynamic> json) => Ball(
        x: json['x']?.toDouble() ?? 0,
        y: json['y']?.toDouble() ?? 0,
        radius: json['radius']?.toDouble() ?? 15,
        vx: json['vx']?.toDouble() ?? 0,
        vy: json['vy']?.toDouble() ?? 0,
        mass: json['mass']?.toDouble() ?? 1.0,
        bounceFactor: json['bounceFactor']?.toDouble() ?? 0.8,
        isMagnetized: json['isMagnetized'] ?? false,
        isShielded: json['isShielded'] ?? false,
        isSuperBounce: json['isSuperBounce'] ?? false,
        powerUpTimer: json['powerUpTimer']?.toDouble() ?? 0.0,
        trail: (json['trail'] as List?)?.map((e) => Offset(e['x'] ?? 0, e['y'] ?? 0)).toList() ?? [],
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ball &&
        other.x == x &&
        other.y == y &&
        other.radius == radius;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode ^ radius.hashCode;
  }
}