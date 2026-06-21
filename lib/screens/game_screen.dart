import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
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
  static const double gravity = 0.3;
  static const double bounceVelocity = -6.5;
  static const double maxHorizontalSpeed = 8.0;
  static const double platformWidth = 80;
  static const double platformHeight = 12;
  static const double starRadius = 10;
  static const double dragSensitivity = 0.02;

  // Trail effect
  List<Offset> _trailPositions = [];
  static const int maxTrailLength = 12;

  @override
  void initState() {
    super.initState();
    // Initialize game state
    gameState = GameState.initial(400, 800);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Re-initialize game state if dimensions changed
    if (gameState.screenWidth != screenWidth ||
        gameState.screenHeight != screenHeight) {
      gameState = GameState.initial(screenWidth, screenHeight);
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
        child: Container(
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
          child: Stack(
            children: [
              // Game objects
              _buildGameObjects(),
              _buildUIOverlay(),
              if (!gameState.isPlaying || gameState.isGameOver)
                _buildOverlay(),
            ],
          ),
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
    // Cancel any existing timers
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    
    setState(() {
      gameState.reset();
      gameState.isPlaying = true;
      _trailPositions.clear();
      gameState.lives = 3;

      // Add initial platforms
      _addPlatform(gameState.screenWidth / 2, gameState.screenHeight - 50);
      _addPlatform(gameState.screenWidth / 3, gameState.screenHeight - 150);
      _addPlatform(gameState.screenWidth * 2 / 3, gameState.screenHeight - 250);
      
      // Set initial ball velocity
      gameState.ball.vy = -5;
      gameState.ball.vx = 2;
    });

    // Start game loop using Timer.periodic
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (gameState.isPlaying && !gameState.isGameOver) {
        _updateGame();
        if (mounted) {
          setState(() {});
        }
      }
    });

    // Start spawn timer
    _spawnTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (gameState.isPlaying && !gameState.isGameOver && mounted) {
        _spawnNewPlatform();
      }
    });
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

    // Update star animations
    for (var star in gameState.stars) {
      if (!star.isCollected) {
        star.updateAnimation(0.016);
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

    // Platform collisions
    bool hitPlatform = false;
    for (var platform in gameState.platforms) {
      if (_checkPlatformCollision(ball, platform)) {
        _bounceBall(ball, platform);
        hitPlatform = true;
        gameState.combo++;
        if (gameState.combo > gameState.bestCombo) {
          gameState.bestCombo = gameState.combo;
        }
        int bonusPoints = gameState.combo > 1 ? gameState.combo : 1;
        gameState.score += bonusPoints;
        break;
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

    // Check if ball fell off screen
    if (ball.isOutOfBounds(gameState.screenHeight)) {
      gameState.lives--;
      if (gameState.lives <= 0) {
        _gameOver();
      } else {
        ball.reset(gameState.screenWidth, gameState.screenHeight);
        ball.vy = -5;
        _trailPositions.clear();
      }
    }
  }

  void _spawnNewPlatform() {
    if (gameState.platforms.isEmpty) return;
    
    double x = random.nextDouble() * 
        (gameState.screenWidth - platformWidth) + platformWidth / 2;
    double y = gameState.platforms.last.y - 
        80 - random.nextDouble() * 60;
    
    _addPlatform(x, y);
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
    ball.vx = hitPos * 3;

    if (ball.vx > maxHorizontalSpeed) ball.vx = maxHorizontalSpeed;
    if (ball.vx < -maxHorizontalSpeed) ball.vx = -maxHorizontalSpeed;
  }

  void _moveBall(double deltaX) {
    gameState.ball.vx += deltaX * dragSensitivity;
    if (gameState.ball.vx > maxHorizontalSpeed) {
      gameState.ball.vx = maxHorizontalSpeed;
    }
    if (gameState.ball.vx < -maxHorizontalSpeed) {
      gameState.ball.vx = -maxHorizontalSpeed;
    }
  }

  void _addPlatform(double x, double y) {
    gameState.platforms.add(
      Platform(x: x, y: y, width: platformWidth, height: platformHeight),
    );

    if (random.nextDouble() < 0.3) {
      _addStar(x + random.nextDouble() * 40 - 20, y - 40);
    }
  }

  void _addStar(double x, double y) {
    gameState.stars.add(Star(x: x, y: y, radius: starRadius));
  }

  void _gameOver() async {
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

// Game Painter Widget
class GamePainter extends CustomPainter {
  final Ball ball;
  final List<Platform> platforms;
  final List<Star> stars;
  final List<Offset> trailPositions;

  GamePainter({
    required this.ball,
    required this.platforms,
    required this.stars,
    this.trailPositions = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  void _drawBall(Canvas canvas, Ball ball) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x + 2, ball.y + 2), ball.radius, shadowPaint);

    // Main ball
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Color(0xFFFF9800), Color(0xFFE65100)],
        stops: [0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(ball.x, ball.y), radius: ball.radius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(ball.x, ball.y), ball.radius, paint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(ball.x - 4, ball.y - 4), ball.radius * 0.3, highlightPaint);

    // Glow
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

    // Main platform
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue.shade200, Colors.blue.shade400, Colors.blue.shade600],
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
  }

  void _drawStar(Canvas canvas, Star star) {
    canvas.save();
    canvas.translate(star.x, star.y);
    canvas.scale(star.scale, star.scale);
    canvas.rotate(star.rotation);

    // Glow effect
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.15 + 0.1 * sin(star.pulseValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, star.radius * 2.0, glowPaint);

    // Star body
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