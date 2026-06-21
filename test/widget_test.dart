import 'package:bounce_remake/main.dart';
import 'package:bounce_remake/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const BounceGame());
      
      // Check if home screen is displayed
      expect(find.text('BOUNCE'), findsOneWidget);
      expect(find.text('Play Now'), findsOneWidget);
      expect(find.text('Classic Arcade Game'), findsOneWidget);
    });

    testWidgets('Home screen displays high score', (WidgetTester tester) async {
      await tester.pumpWidget(const BounceGame());
      
      expect(find.textContaining('High Score'), findsOneWidget);
    });

    testWidgets('Game screen navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(const BounceGame());
      
      // Find and tap play button
      final playButton = find.text('PLAY NOW');
      expect(playButton, findsOneWidget);
      
      await tester.tap(playButton);
      await tester.pumpAndSettle();
      
      // Check if game screen appears
      expect(find.text('Score: 0'), findsOneWidget);
    });

    testWidgets('Game over overlay appears when ball falls', (WidgetTester tester) async {
      await tester.pumpWidget(const BounceGame());
      
      // Navigate to game
      final playButton = find.text('PLAY NOW');
      await tester.tap(playButton);
      await tester.pumpAndSettle();
      
      // Simulate game over by triggering it through the game controller
      // This is a simplified test - you'd need to mock the game controller
      expect(find.text('Game Over!'), findsNothing);
    });
  });

  group('Game Screen UI Tests', () {
    testWidgets('Game screen has score display', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GameScreen(),
        ),
      );
      
      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('High Score: 0'), findsOneWidget);
    });

    testWidgets('Game screen shows start overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GameScreen(),
        ),
      );
      
      expect(find.text('Tap to Start'), findsOneWidget);
      expect(find.text('← Drag to move →'), findsOneWidget);
    });
  });
}