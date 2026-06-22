import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/ball.dart';
import '../models/platform.dart';
import '../models/star.dart';
import '../models/game_state.dart';
import '../utils/high_score_manager.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  final Random random = Random();
  Timer? _gameTimer;
  Timer? _spawnTimer;

  // Game constants
  static const double gravity = 0.15;
  static const double bounceVelocity = -8.0;
  static const double maxHorizontalSpeed = 12.0;
  static const double platformWidth = 80;
  static const double platformHeight = 12;
  static const double starRadius = 10;
  static const double dragSensitivity = 0.12;
  
  // Camera system
  double _cameraY = 0;
  double _screenTopY = 0;
  double _screenBottomY = 0;
  static const double scrollThreshold = 100.0;
  
  // Platform generation
  double _highestPlatformY = 0;
  double _lowestPlatformY = 0;
  int _platformsSpawned = 0;
  double _difficulty = 1.0;
  bool _isGameInitialized = false;
  
  // Checkpoints
  double _nextCheckpoint = -200.0;
  int _checkpointCount = 0;
  
  // Screen shake
  double _shakeAmount = 0;

  List<Offset> _trailPositions = [];
  static const int maxTrailLength = 12;

  @override
  void initState() {
    super.initState();
    gameState = GameState.initial(400, 800);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (gameState.screenWidth != screenWidth ||
        gameState.screenHeight != screenHeight) {
      gameState = GameState.initial(screenWidth, screenHeight);
      _screenTopY = 0;
      _screenBottomY = screenHeight;
      _isGameInitialized = false;
    }

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          if (gameState.isPlaying && !gameState.isGameOver) {
            _moveBall(details.delta.dx);
          }
        },
        onTap: () {
          if (!gameState.isPlaying || gameState.isGameOver) {
            _startGame();
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
            ),
            _buildGameObjects(),
            _buildUIOverlay(),
            if (!gameState.isPlaying || gameState.isGameOver)
              _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameObjects() {
    return CustomPaint(
      painter: GamePainter(
        ball: gameState.ball,
        platforms: gameState.platforms,
        stars: gameState.stars,
        trailPositions: _trailPositions,
        cameraY: _cameraY,
        shakeAmount: _shakeAmount,
        screenHeight: gameState.screenHeight,
        screenTop: _screenTopY,
        screenBottom: _screenBottomY,
      ),
      size: Size(gameState.screenWidth, gameState.screenHeight),
    );
  }

  Widget _buildUIOverlay() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: ${gameState.score}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                ),
              ),
              Text(
                'High: ${gameState.highScore}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                ),
              ),
              Text(
                'Distance: ${_checkpointCount * 100}m',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (gameState.combo > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Text(
                    '🔥 ${gameState.combo}x Combo!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.stars.where((s) => s.isCollected).length}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.favorite, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.lives}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Text(
                  '🏁 ${_checkpointCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (gameState.isGameOver) ...[
            const Icon(Icons.sentiment_very_dissatisfied, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 20, color: Colors.black45)],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Final Score: ${gameState.score}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
              ),
            ),
            Text(
              'Distance: ${_checkpointCount * 100}m',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Best Score: ${gameState.highScore}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (gameState.score == gameState.highScore && gameState.score > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '🏆 New High Score! 🏆',
                  style: TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat('Platforms', gameState.platforms.length),
                const SizedBox(width: 30),
                _buildStat('Checkpoints', _checkpointCount),
                const SizedBox(width: 30),
                _buildStat('Best Combo', gameState.bestCombo),
              ],
            ),
          ] else ...[
            const Icon(Icons.sports_esports, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Bounce Game',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 20, color: Colors.black45)],
              ),
            ),
          ],
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _startGame,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                gameState.isGameOver ? '🔄 Play Again' : '▶️ Play',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          if (!gameState.isGameOver && !gameState.isPlaying)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                '← Drag to move →',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  void _startGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    
    setState(() {
      gameState.reset();
      gameState.isPlaying = true;
      _trailPositions.clear();
      gameState.lives = 3;
      _cameraY = 0;
      _screenTopY = 0;
      _screenBottomY = gameState.screenHeight;
      _nextCheckpoint = -200.0;
      _checkpointCount = 0;
      _shakeAmount = 0;
      _platformsSpawned = 0;
      _difficulty = 1.0;
      _highestPlatformY = gameState.screenHeight;
      _lowestPlatformY = gameState.screenHeight - 50;
      _isGameInitialized = true;

      // Add initial platforms at the bottom
      _addGenerativePlatform(gameState.screenWidth / 2, gameState.screenHeight - 50);
      _addGenerativePlatform(gameState.screenWidth / 3, gameState.screenHeight - 100);
      _addGenerativePlatform(gameState.screenWidth * 2 / 3, gameState.screenHeight - 155);
      _addGenerativePlatform(gameState.screenWidth / 2, gameState.screenHeight - 210);
      _addGenerativePlatform(gameState.screenWidth / 3, gameState.screenHeight - 270);
      _addGenerativePlatform(gameState.screenWidth * 2 / 3, gameState.screenHeight - 330);
      
      // Track lowest and highest platforms
      _lowestPlatformY = gameState.screenHeight - 50;
      _highestPlatformY = gameState.screenHeight - 330;
      
      // Set ball position on the lowest platform
      gameState.ball.x = gameState.screenWidth / 2;
      gameState.ball.y = gameState.screenHeight - 50 - gameState.ball.radius - 5;
      gameState.ball.vy = -5;
      gameState.ball.vx = 2;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (gameState.isPlaying && !gameState.isGameOver) {
        _updateGame();
        if (mounted) {
          setState(() {});
        }
      }
    });

    // Fast spawn timer to keep platforms coming
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (gameState.isPlaying && !gameState.isGameOver && mounted) {
        _difficulty = 1.0 + _platformsSpawned * 0.008;
        _spawnPlatformsIfNeeded();
        _removeOffscreenPlatforms();
      }
    });
  }

  void _spawnPlatformsIfNeeded() {
    if (!_isGameInitialized) return;
    
    // Always keep at least 15 platforms ahead
    int targetPlatformCount = 15 + (_difficulty ~/ 2).toInt();
    if (gameState.platforms.length < targetPlatformCount) {
      // Spawn new platforms above the highest
      double spawnY = _highestPlatformY;
      
      while (gameState.platforms.length < targetPlatformCount) {
        double x = random.nextDouble() * 
            (gameState.screenWidth - platformWidth) + platformWidth / 2;
        
        // Random vertical spacing based on difficulty
        double minSpacing = 50 - _difficulty * 0.5;
        double maxSpacing = 80 - _difficulty * 0.3;
        minSpacing = minSpacing.clamp(35, 60);
        maxSpacing = maxSpacing.clamp(55, 90);
        
        double spacing = minSpacing + random.nextDouble() * (maxSpacing - minSpacing);
        double y = spawnY - spacing;
        
        _addGenerativePlatform(x, y);
        spawnY = y;
        _platformsSpawned++;
        
        // Update difficulty
        _difficulty = 1.0 + _platformsSpawned * 0.008;
      }
      
      // Update highest platform
      _highestPlatformY = spawnY;
    }
  }

  void _removeOffscreenPlatforms() {
    // Keep at least 3 platforms below the screen
    double removeThreshold = _screenBottomY + 100;
    int visiblePlatforms = 0;
    List<Platform> toRemove = [];
    
    for (var platform in gameState.platforms) {
      if (platform.y > removeThreshold) {
        visiblePlatforms++;
        if (visiblePlatforms > 3) {
          toRemove.add(platform);
        }
      }
    }
    
    // Remove platforms that are too far below
    gameState.platforms.removeWhere((p) => p.y > removeThreshold + 300);
    
    // Update lowest platform
    double lowest = double.infinity;
    for (var platform in gameState.platforms) {
      if (platform.y < lowest) {
        lowest = platform.y;
      }
    }
    if (lowest != double.infinity) {
      _lowestPlatformY = lowest;
    }
  }

  void _addGenerativePlatform(double x, double y) {
    // Randomly select platform type based on difficulty
    int maxType = 4 + (_difficulty ~/ 2).toInt();
    if (maxType > 5) maxType = 5;
    int type = random.nextInt(maxType + 1);
    
    Platform platform;
    switch (type) {
      case 0: // Normal platform
        platform = Platform(
          x: x, 
          y: y, 
          width: platformWidth, 
          height: platformHeight,
          color: Colors.blue,
        );
        break;
      case 1: // Moving platform (side to side)
        platform = Platform(
          x: x, 
          y: y, 
          width: platformWidth * 0.8, 
          height: platformHeight,
          isMoving: true,
          moveSpeed: 0.5 + _difficulty * 0.1,
          moveRange: 30 + _difficulty * 2,
          color: Colors.purple,
        );
        break;
      case 2: // Bouncing platform (up and down)
        platform = Platform(
          x: x, 
          y: y, 
          width: platformWidth, 
          height: platformHeight,
          isMoving: true,
          moveSpeed: 0.3 + _difficulty * 0.05,
          moveRange: 20 + _difficulty,
          color: Colors.green,
        );
        break;
      case 3: // Glowing platform (gives bonus)
        platform = Platform(
          x: x, 
          y: y, 
          width: platformWidth * 1.2, 
          height: platformHeight,
          color: Colors.amber,
          highlightColor: Colors.yellow,
          glowIntensity: 1.0,
        );
        break;
      case 4: // Narrow platform (challenge)
        platform = Platform(
          x: x, 
          y: y, 
          width: platformWidth * 0.5, 
          height: platformHeight,
          color: Colors.red,
          highlightColor: Colors.redAccent,
        );
        break;
      case 5: // Super bounce platform
        platform = Platform(
          x: x, 
          y: y, 
          width: platformWidth, 
          height: platformHeight,
          color: Colors.pink,
          highlightColor: Colors.pinkAccent,
        );
        break;
      default:
        platform = Platform(x: x, y: y, width: platformWidth, height: platformHeight);
    }
    
    gameState.platforms.add(platform);

    // Spawn star on some platforms
    if (random.nextDouble() < 0.2 + _difficulty * 0.02) {
      _addStar(x + random.nextDouble() * 40 - 20, y - 40);
    }
  }

  void _updateGame() {
    if (gameState.isGameOver || !gameState.isPlaying) return;
    
    final ball = gameState.ball;

    // Apply gravity
    ball.vy += gravity;
    
    // Update position
    ball.x += ball.vx;
    ball.y += ball.vy;

    // Update trail
    _trailPositions.add(Offset(ball.x, ball.y));
    if (_trailPositions.length > maxTrailLength) {
      _trailPositions.removeAt(0);
    }

    // Update stars
    for (var star in gameState.stars) {
      if (!star.isCollected) {
        star.updateAnimation(0.016);
      }
    }

    // Update moving platforms
    for (var platform in gameState.platforms) {
      if (platform.isMoving) {
        platform.updatePosition(0.016);
      }
    }

    // Wall collisions
    if (ball.hitsLeftWall()) {
      ball.x = ball.radius;
      ball.vx = ball.vx.abs();
    } else if (ball.hitsRightWall(gameState.screenWidth)) {
      ball.x = gameState.screenWidth - ball.radius;
      ball.vx = -ball.vx.abs();
    }

    // Camera follows ball up
    double ballScreenY = ball.y + _cameraY;
    
    if (ballScreenY < scrollThreshold && !gameState.isGameOver) {
      double scrollAmount = scrollThreshold - ballScreenY;
      _cameraY += scrollAmount;
      _screenTopY += scrollAmount;
      _screenBottomY += scrollAmount;
      
      if (_screenTopY < _nextCheckpoint) {
        _checkpointCount++;
        _nextCheckpoint -= 200.0;
        gameState.score += 10;
        _shakeAmount = 5;
      }
    }

    // Also scroll if ball is above the screen
    if (ballScreenY < 0) {
      double scrollAmount = -ballScreenY + 50;
      _cameraY += scrollAmount;
      _screenTopY += scrollAmount;
      _screenBottomY += scrollAmount;
      
      if (_screenTopY < _nextCheckpoint) {
        _checkpointCount++;
        _nextCheckpoint -= 200.0;
        gameState.score += 10;
        _shakeAmount = 5;
      }
    }

    // Decrease shake
    if (_shakeAmount > 0) {
      _shakeAmount *= 0.9;
      if (_shakeAmount < 0.1) _shakeAmount = 0;
    }

    // Platform collisions
    bool hitPlatform = false;
    for (var platform in gameState.platforms) {
      // Only check platforms near the ball
      if ((platform.y - ball.y).abs() < 200) {
        if (_checkPlatformCollision(ball, platform)) {
          // Super bounce platform
          if (platform.color == Colors.pink) {
            ball.vy = bounceVelocity * 1.8;
          } else {
            _bounceBall(ball, platform);
          }
          
          hitPlatform = true;
          gameState.combo++;
          if (gameState.combo > gameState.bestCombo) {
            gameState.bestCombo = gameState.combo;
          }
          int bonusPoints = gameState.combo > 1 ? gameState.combo : 1;
          gameState.score += bonusPoints;
          
          // Glowing platform bonus
          if (platform.color == Colors.amber) {
            gameState.score += 3;
          }
          break;
        }
      }
    }

    if (!hitPlatform && !gameState.isGameOver) {
      gameState.combo = 0;
    }

    // Star collection
    for (var star in gameState.stars) {
      if (!star.isCollected && star.collidesWith(ball.x, ball.y, ball.radius)) {
        star.isCollected = true;
        gameState.score += 5;
      }
    }
    gameState.stars.removeWhere((star) => star.isCollected);

    // Check if ball fell below the lowest visible platform
    if (ball.isOutOfBounds(gameState.screenHeight)) {
      gameState.lives--;
      if (gameState.lives <= 0) {
        _gameOver();
      } else {
        _respawnOnLowestVisiblePlatform();
      }
    }
  }

  void _respawnOnLowestVisiblePlatform() {
    final ball = gameState.ball;
    double screenBottom = gameState.screenHeight;
    
    // Find the lowest visible platform (closest to bottom of screen)
    Platform? lowestPlatform;
    double lowestY = double.negativeInfinity;
    
    for (var platform in gameState.platforms) {
      // Check if platform is visible on screen
      double platformScreenY = platform.y + _cameraY;
      if (platformScreenY < screenBottom + 50 && platformScreenY > -50) {
        if (platform.y > lowestY) {
          lowestY = platform.y;
          lowestPlatform = platform;
        }
      }
    }
    
    // If no visible platform, find the lowest platform overall
    if (lowestPlatform == null && gameState.platforms.isNotEmpty) {
      lowestPlatform = gameState.platforms.reduce((a, b) => a.y > b.y ? a : b);
    }
    
    if (lowestPlatform != null) {
      // Place ball above the lowest visible platform
      ball.x = lowestPlatform.x;
      ball.y = lowestPlatform.y - ball.radius - 5;
      ball.vx = 2;
      ball.vy = -5;
      _shakeAmount = 10;
    } else {
      // Fallback: reset to center bottom
      ball.reset(gameState.screenWidth, gameState.screenHeight);
      ball.vy = -5;
    }
    
    _trailPositions.clear();
  }

  bool _checkPlatformCollision(Ball ball, Platform platform) {
    if (ball.vy <= 0) return false;
    if (!platform.isBallWithinRange(ball.x)) return false;
    
    bool verticalCollision =
        ball.y + ball.radius > platform.y - platform.height / 2 &&
        ball.y + ball.radius < platform.y + platform.height / 2 + ball.vy;

    return verticalCollision;
  }

  void _bounceBall(Ball ball, Platform platform) {
    ball.vy = bounceVelocity;
    double hitPos = (ball.x - platform.x) / (platform.width / 2);
    ball.vx = hitPos * 3.5;

    if (ball.vx > maxHorizontalSpeed) ball.vx = maxHorizontalSpeed;
    if (ball.vx < -maxHorizontalSpeed) ball.vx = -maxHorizontalSpeed;
  }

  void _moveBall(double deltaX) {
    gameState.ball.vx += deltaX * dragSensitivity;
    
    if (deltaX.abs() > 2) {
      gameState.ball.vx += deltaX.sign * 0.15;
    }
    
    if (gameState.ball.vx > maxHorizontalSpeed) {
      gameState.ball.vx = maxHorizontalSpeed;
    }
    if (gameState.ball.vx < -maxHorizontalSpeed) {
      gameState.ball.vx = -maxHorizontalSpeed;
    }
  }

  void _addStar(double x, double y) {
    gameState.stars.add(Star(x: x, y: y, radius: starRadius));
  }

  void _gameOver() async {
    try {
      await HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
    } catch (e) {
      print('Vibration not available: $e');
    }
    
    setState(() {
      gameState.isGameOver = true;
      gameState.isPlaying = false;
    });

    final isNewHigh = await HighScoreManager.isNewHighScore(gameState.score);
    if (isNewHigh) {
      await HighScoreManager.saveHighScore(gameState.score);
      setState(() {
        gameState.highScore = gameState.score;
      });
    }

    _gameTimer?.cancel();
    _spawnTimer?.cancel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }
}

// Updated Game Painter with support for generative platform colors
class GamePainter extends CustomPainter {
  final Ball ball;
  final List<Platform> platforms;
  final List<Star> stars;
  final List<Offset> trailPositions;
  final double cameraY;
  final double shakeAmount;
  final double screenHeight;
  final double screenTop;
  final double screenBottom;

  GamePainter({
    required this.ball,
    required this.platforms,
    required this.stars,
    required this.trailPositions,
    required this.cameraY,
    required this.shakeAmount,
    required this.screenHeight,
    required this.screenTop,
    required this.screenBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    
    if (shakeAmount > 0.1) {
      final random = Random();
      final dx = (random.nextDouble() - 0.5) * shakeAmount;
      final dy = (random.nextDouble() - 0.5) * shakeAmount;
      canvas.translate(dx, dy);
    }
    
    canvas.translate(0, cameraY);

    // Draw trail
    for (int i = 0; i < trailPositions.length; i++) {
      final opacity = (i / trailPositions.length) * 0.3;
      final paint = Paint()
        ..color = Colors.orange.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      final radius = ball.radius * (0.3 + 0.7 * (i / trailPositions.length));
      canvas.drawCircle(trailPositions[i], radius, paint);
    }

    // Draw stars
    for (var star in stars) {
      if (!star.isCollected) {
        _drawStar(canvas, star);
      }
    }

    // Draw platforms
    for (var platform in platforms) {
      _drawPlatform(canvas, platform);
    }

    // Draw ball
    _drawBall(canvas, ball);

    // Draw background grid
    _drawBackgroundGrid(canvas, size);

    canvas.restore();
  }

  void _drawBackgroundGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (double y = -50; y < size.height + 50; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawBall(Canvas canvas, Ball ball) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x + 2, ball.y + 2), ball.radius, shadowPaint);

    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Color(0xFFFF9800), Color(0xFFE65100)],
        stops: [0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(ball.x, ball.y), radius: ball.radius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x - 4, ball.y - 4), ball.radius * 0.3, highlightPaint);

    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius * 1.8, glowPaint);
  }

  void _drawPlatform(Canvas canvas, Platform platform) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(platform.x + 2, platform.y + 2),
        width: platform.width,
        height: platform.height,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // Get colors based on platform type
    Color color1, color2, color3;
    if (platform.color == Colors.amber) {
      color1 = Colors.yellow.shade300;
      color2 = Colors.amber.shade500;
      color3 = Colors.orange.shade700;
    } else if (platform.color == Colors.purple) {
      color1 = Colors.purple.shade200;
      color2 = Colors.purple.shade400;
      color3 = Colors.purple.shade700;
    } else if (platform.color == Colors.green) {
      color1 = Colors.green.shade200;
      color2 = Colors.green.shade400;
      color3 = Colors.green.shade700;
    } else if (platform.color == Colors.red) {
      color1 = Colors.red.shade200;
      color2 = Colors.red.shade400;
      color3 = Colors.red.shade700;
    } else if (platform.color == Colors.pink) {
      color1 = Colors.pink.shade200;
      color2 = Colors.pink.shade400;
      color3 = Colors.pink.shade700;
    } else {
      color1 = Colors.blue.shade200;
      color2 = Colors.blue.shade400;
      color3 = Colors.blue.shade600;
    }

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color1, color2, color3],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromCenter(
          center: Offset(platform.x, platform.y),
          width: platform.width,
          height: platform.height,
        ),
      )
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(platform.x, platform.y),
        width: platform.width,
        height: platform.height,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    // Highlight on top
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(platform.x, platform.y - 2),
        width: platform.width * 0.8,
        height: platform.height * 0.3,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(highlightRect, highlightPaint);

    // Glow effect for special platforms
    if (platform.color == Colors.amber || platform.color == Colors.pink) {
      final glowPaint = Paint()
        ..color = (platform.color == Colors.amber ? Colors.amber : Colors.pink)
            .withOpacity(0.15)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(platform.x, platform.y),
            width: platform.width + 20,
            height: platform.height + 10,
          ),
          const Radius.circular(10),
        ),
        glowPaint,
      );
    }

    // Moving indicator
    if (platform.isMoving) {
      final indicatorPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(platform.x + platform.width / 2 - 10, platform.y - 6),
        3,
        indicatorPaint,
      );
      canvas.drawCircle(
        Offset(platform.x - platform.width / 2 + 10, platform.y - 6),
        3,
        indicatorPaint,
      );
    }
  }

  void _drawStar(Canvas canvas, Star star) {
    canvas.save();
    canvas.translate(star.x, star.y);
    canvas.scale(star.scale, star.scale);
    canvas.rotate(star.rotation);

    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.15 + 0.1 * sin(star.pulseValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, star.radius * 2.0, glowPaint);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow.shade100, Colors.yellow.shade700, Colors.amber.shade900],
        stops: const [0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset.zero, radius: star.radius),
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 5;
    final outerRadius = star.radius;
    final innerRadius = star.radius * 0.4;
    final angleStep = 2 * pi / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -pi / 2 + i * angleStep / 2;
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}