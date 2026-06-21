import 'package:flutter/material.dart';
import 'dart:math';
import '../models/ball.dart';
import '../models/platform.dart';
import '../models/star.dart';
import '../models/game_state.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameState gameState;
  late AnimationController animationController;
  final Random random = Random();
  
  // Game constants
  static const double gravity = 0.3;
  static const double bounceVelocity = -6.5;
  static const double maxHorizontalSpeed = 8.0;
  static const double platformWidth = 80;
  static const double platformHeight = 12;
  static const double starRadius = 10;
  static const double dragSensitivity = 0.02;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
      if (gameState.isPlaying && !gameState.isGameOver) {
        _updateGame();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Initialize game state if needed
    if (gameState.screenWidth != screenWidth || gameState.screenHeight != screenHeight) {
      gameState = GameState.initial(screenWidth, screenHeight);
    }

    return Scaffold(
      body: GestureDetector(
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
                Color(0xFF0D47A1), // Dark blue
                Color(0xFF1976D2), // Medium blue
                Color(0xFF42A5F5), // Light blue
              ],
            ),
          ),
          child: Stack(
            children: [
              // Game objects
              if (gameState.isPlaying || gameState.isGameOver)
                _buildGameObjects(),

              // UI Overlay
              _buildUIOverlay(),

              // Start/Game Over overlay
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
      ),
      size: Size(gameState.screenWidth, gameState.screenHeight),
    );
  }

  Widget _buildUIOverlay() {
    return Positioned(
      top: 40,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score: ${gameState.score}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          Text(
            'High Score: ${gameState.highScore}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Platforms: ${gameState.platforms.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
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
            const Icon(
              Icons.sentiment_very_dissatisfied,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.black45,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Final Score: ${gameState.score}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            if (gameState.score == gameState.highScore && gameState.score > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '🏆 New High Score! 🏆',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ] else ...[
            const Icon(
              Icons.sports_esports,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bounce Game',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.black45,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              gameState.isGameOver ? 'Tap to Restart' : 'Tap to Start',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!gameState.isGameOver && !gameState.isPlaying) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swipe, color: Colors.white70),
                  SizedBox(width: 10),
                  Text(
                    'Drag left/right to move the ball',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startGame() {
    setState(() {
      gameState.reset();
      gameState.isPlaying = true;
      
      // Add initial platforms
      _addPlatform(gameState.screenWidth / 2, gameState.screenHeight - 50);
      _addPlatform(gameState.screenWidth / 3, gameState.screenHeight - 150);
      _addPlatform(gameState.screenWidth * 2 / 3, gameState.screenHeight - 250);
    });
    
    // Start animation
    animationController.forward(from: 0);
  }

  void _updateGame() {
    final ball = gameState.ball;
    
    // Apply gravity
    ball.vy += gravity;
    
    // Update position
    ball.x += ball.vx;
    ball.y += ball.vy;
    
    // Wall collisions
    if (ball.hitsLeftWall()) {
      ball.x = ball.radius;
      ball.vx = ball.vx.abs();
    } else if (ball.hitsRightWall(gameState.screenWidth)) {
      ball.x = gameState.screenWidth - ball.radius;
      ball.vx = -ball.vx.abs();
    }
    
    // Platform collisions
    for (var platform in gameState.platforms) {
      if (_checkPlatformCollision(ball, platform)) {
        _bounceBall(ball, platform);
        setState(() {
          gameState.score++;
        });
        // Play bounce sound effect here
        break;
      }
    }
    
    // Star collection
    for (var star in gameState.stars) {
      if (!star.isCollected && star.collidesWith(ball.x, ball.y, ball.radius)) {
        setState(() {
          star.isCollected = true;
          gameState.score += 5;
        });
        // Play collect sound effect here
      }
    }
    gameState.stars.removeWhere((star) => star.isCollected);
    
    // Check game over
    if (ball.isOutOfBounds(gameState.screenHeight)) {
      _gameOver();
    }
  }

  bool _checkPlatformCollision(Ball ball, Platform platform) {
    // Ball must be falling
    if (ball.vy <= 0) return false;
    
    // Check horizontal overlap
    if (!platform.isBallWithinRange(ball.x)) return false;
    
    // Check vertical collision
    bool verticalCollision = 
        ball.y + ball.radius > platform.y - platform.height / 2 &&
        ball.y + ball.radius < platform.y + platform.height / 2 + ball.vy;
    
    return verticalCollision;
  }

  void _bounceBall(Ball ball, Platform platform) {
    ball.vy = bounceVelocity;
    // Add horizontal movement based on hit position
    double hitPos = (ball.x - platform.x) / (platform.width / 2);
    ball.vx = hitPos * 3;
    
    // Clamp horizontal speed
    if (ball.vx > maxHorizontalSpeed) ball.vx = maxHorizontalSpeed;
    if (ball.vx < -maxHorizontalSpeed) ball.vx = -maxHorizontalSpeed;
  }

  void _moveBall(double deltaX) {
    gameState.ball.vx += deltaX * dragSensitivity;
    
    // Clamp horizontal speed
    if (gameState.ball.vx > maxHorizontalSpeed) {
      gameState.ball.vx = maxHorizontalSpeed;
    }
    if (gameState.ball.vx < -maxHorizontalSpeed) {
      gameState.ball.vx = -maxHorizontalSpeed;
    }
  }

  void _addPlatform(double x, double y) {
    gameState.platforms.add(Platform(
      x: x,
      y: y,
      width: platformWidth,
      height: platformHeight,
    ));
    
    // Occasionally spawn a star
    if (random.nextDouble() < 0.3) {
      _addStar(
        x + random.nextDouble() * 40 - 20,
        y - 40,
      );
    }
  }

  void _addStar(double x, double y) {
    gameState.stars.add(Star(
      x: x,
      y: y,
      radius: starRadius,
    ));
  }

  void _gameOver() {
    setState(() {
      gameState.isGameOver = true;
      gameState.isPlaying = false;
      if (gameState.score > gameState.highScore) {
        gameState.highScore = gameState.score;
      }
    });
    animationController.stop();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

// Game Painter Widget
class GamePainter extends CustomPainter {
  final Ball ball;
  final List<Platform> platforms;
  final List<Star> stars;

  GamePainter({
    required this.ball,
    required this.platforms,
    required this.stars,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          Color(0xFFFF9800), // Orange 300
          Color(0xFFE65100), // Orange 700
        ],
        stops: [0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(ball.x, ball.y),
        radius: ball.radius,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(ball.x, ball.y),
      ball.radius,
      paint,
    );

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(ball.x - 4, ball.y - 4),
      ball.radius * 0.3,
      highlightPaint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(ball.x, ball.y),
      ball.radius * 1.5,
      glowPaint,
    );
  }

  void _drawPlatform(Canvas canvas, Platform platform) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade200,
          Colors.blue.shade400,
          Colors.blue.shade600,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(platform.x, platform.y),
        width: platform.width,
        height: platform.height,
      ))
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
      ..color = Colors.white.withOpacity(0.2)
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
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.shade100,
          Colors.yellow.shade700,
          Colors.amber.shade900,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(star.x, star.y),
        radius: star.radius,
      ))
      ..style = PaintingStyle.fill;

    // Draw 5-pointed star
    final path = Path();
    const points = 5;
    final outerRadius = star.radius;
    final innerRadius = star.radius * 0.4;
    final angleStep = 2 * pi / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -pi / 2 + i * angleStep / 2 + star.rotation;
      final x = star.x + radius * cos(angle);
      final y = star.y + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(star.x, star.y),
      star.radius * 1.8,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}