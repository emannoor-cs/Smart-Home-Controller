import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/connection_screen.dart';

void main() {
  runApp(
    // ProviderScope is REQUIRED for Riverpod — wraps the entire app
    // Think of it as a global state container
    const ProviderScope(
      child: SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Purple accent
          brightness: Brightness.dark, // Dark theme
        ),
        useMaterial3: true,
      ),
      home: const ConnectionScreen(),
    );
  }
}
