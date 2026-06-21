import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ball.dart';
import '../models/platform.dart';
import '../models/star.dart';
import '../models/game_state.dart';
import 'physics_engine.dart';
import 'collision_detector.dart';

class GameController {
  late GameState _state;
  final PhysicsEngine _physics = PhysicsEngine();
  final CollisionDetector _collision = CollisionDetector();
  final Random _random = Random();
  
  Timer? _gameLoop;
  Timer? _spawnTimer;
  
  GameState get state => _state;
  
  void initialize(double width, double height) {
    _state = GameState.initial(width, height);
  }
  
  void start() {
    _state = _state.copyWith(
      isPlaying: true,
      isGameOver: false,
      score: 0,
    );
    
    // Add initial platforms
    _addPlatform(_state.screenWidth / 2, _state.screenHeight - 50);
    _addPlatform(_state.screenWidth / 3, _state.screenHeight - 150);
    _addPlatform(_state.screenWidth * 2 / 3, _state.screenHeight - 250);
    
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => update(),
    );
    
    _spawnTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _spawnNewPlatform(),
    );
  }
  
  void update() {
    if (!_state.isPlaying || _state.isGameOver) return;
    
    // Apply physics
    _physics.applyPhysics(_state.ball, _state.screenWidth, _state.screenHeight);
    
    // Check collisions with platforms
    for (var platform in _state.platforms) {
      if (_collision.checkPlatformCollision(_state.ball, platform)) {
        _physics.bounceOnPlatform(_state.ball, platform);
        _state = _state.copyWith(score: _state.score + 1);
        // Play bounce sound
      }
    }
    
    // Check collisions with stars
    for (var star in _state.stars) {
      if (_collision.checkStarCollision(_state.ball, star)) {
        star.isCollected = true;
        _state = _state.copyWith(score: _state.score + 5);
        // Play collect sound
      }
    }
    _state.stars.removeWhere((star) => star.isCollected);
    
    // Check game over
    if (_collision.isOutOfBounds(_state.ball, _state.screenHeight)) {
      gameOver();
    }
  }
  
  void _spawnNewPlatform() {
    if (_state.platforms.isEmpty) return;
    
    double x = _random.nextDouble() * 
        (_state.screenWidth - PhysicsConstants.platformWidth) + 
        PhysicsConstants.platformWidth / 2;
    double y = _state.platforms.last.y - 
        PhysicsConstants.minPlatformSpacing - 
        _random.nextDouble() * PhysicsConstants.platformSpacingRange;
    
    _addPlatform(x, y);
    
    // Spawn star occasionally
    if (_random.nextDouble() < PhysicsConstants.starSpawnRate) {
      _addStar(
        x + _random.nextDouble() * 40 - 20,
        y - 40,
      );
    }
  }
  
  void _addPlatform(double x, double y) {
    final platform = Platform(
      x: x,
      y: y,
      width: PhysicsConstants.platformWidth,
      height: PhysicsConstants.platformHeight,
    );
    _state.platforms.add(platform);
  }
  
  void _addStar(double x, double y) {
    final star = Star(
      x: x,
      y: y,
      radius: PhysicsConstants.starRadius,
    );
    _state.stars.add(star);
  }
  
  void moveBall(double deltaX) {
    if (!_state.isPlaying || _state.isGameOver) return;
    _state.ball.vx += deltaX * PhysicsConstants.dragSensitivity;
    
    if (_state.ball.vx > PhysicsConstants.maxHorizontalSpeed) {
      _state.ball.vx = PhysicsConstants.maxHorizontalSpeed;
    }
    if (_state.ball.vx < -PhysicsConstants.maxHorizontalSpeed) {
      _state.ball.vx = -PhysicsConstants.maxHorizontalSpeed;
    }
  }
  
  void gameOver() async {
    _state = _state.copyWith(
      isGameOver: true,
      isPlaying: false,
    );
    
    if (_state.score > _state.highScore) {
      _state = _state.copyWith(highScore: _state.score);
      // Save high score
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _state.highScore);
    }
    
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
  }
  
  void dispose() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
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