import 'package:flutter/material.dart';
import '../models/ball.dart';

class BallWidget extends StatelessWidget {
  final Ball ball;
  final bool showGlow;

  const BallWidget({
    super.key,
    required this.ball,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (showGlow)
          Container(
            width: ball.radius * 4,
            height: ball.radius * 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orange.withOpacity(0.2),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        
        // Main ball
        Container(
          width: ball.radius * 2,
          height: ball.radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Color(0xFFFF9800),
                Color(0xFFE65100),
              ],
              stops: [0.3, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Highlight
              Positioned(
                top: ball.radius * 0.2,
                left: ball.radius * 0.2,
                child: Container(
                  width: ball.radius * 0.5,
                  height: ball.radius * 0.3,
                  decoration: const BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Reflection
              Positioned(
                bottom: ball.radius * 0.1,
                right: ball.radius * 0.1,
                child: Container(
                  width: ball.radius * 0.3,
                  height: ball.radius * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}