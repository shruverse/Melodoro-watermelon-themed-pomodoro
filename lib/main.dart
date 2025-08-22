import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WatermelonTimerApp());
}

class WatermelonTimerApp extends StatelessWidget {
  const WatermelonTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watermelon Study Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Watermelon green
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFD81B60), // Darker watermelon pink
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
