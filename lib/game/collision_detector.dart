import '../models/ball.dart';
import '../models/platform.dart';
import '../models/star.dart';

class CollisionDetector {
  bool checkPlatformCollision(Ball ball, Platform platform) {
    // Ball must be falling
    if (ball.vy <= 0) return false;
    
    // Check horizontal overlap
    bool horizontalOverlap = 
        ball.x > platform.x - platform.width / 2 &&
        ball.x < platform.x + platform.width / 2;
    
    if (!horizontalOverlap) return false;
    
    // Check vertical collision
    bool verticalCollision = 
        ball.y + ball.radius > platform.y - platform.height / 2 &&
        ball.y + ball.radius < platform.y + platform.height / 2 + ball.vy;
    
    return verticalCollision;
  }
  
  bool checkStarCollision(Ball ball, Star star) {
    if (star.isCollected) return false;
    
    double dx = ball.x - star.x;
    double dy = ball.y - star.y;
    double distance = dx * dx + dy * dy;
    double collisionDistance = ball.radius + star.radius;
    
    return distance < collisionDistance * collisionDistance;
  }
  
  bool isOutOfBounds(Ball ball, double screenHeight) {
    return ball.y + ball.radius > screenHeight;
  }
}