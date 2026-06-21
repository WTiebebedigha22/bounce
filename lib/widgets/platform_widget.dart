import 'package:flutter/material.dart';
import '../models/platform.dart';

class PlatformWidget extends StatelessWidget {
  final Platform platform;
  final bool showHighlight;

  const PlatformWidget({
    super.key,
    required this.platform,
    this.showHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: platform.width,
      height: platform.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: platform.isMoving
              ? [
                  Colors.purple.shade300,
                  Colors.purple.shade600,
                ]
              : [
                  Colors.blue.shade200,
                  Colors.blue.shade400,
                  Colors.blue.shade600,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (platform.isMoving)
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Highlight bar on top
          if (showHighlight)
            Positioned(
              top: 2,
              left: platform.width * 0.1,
              child: Container(
                width: platform.width * 0.8,
                height: platform.height * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          
          // Moving indicator
          if (platform.isMoving)
            Positioned(
              right: 4,
              top: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}