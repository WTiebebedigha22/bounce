import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const BounceGame());
}

class BounceGame extends StatelessWidget {
  const BounceGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bounce',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}