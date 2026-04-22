import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const CariJobsApp());
}

class CariJobsApp extends StatelessWidget {
  const CariJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cari-Jobs&Gigs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B8DB8),
          primary: const Color(0xFF5B8DB8),
          secondary: const Color(0xFFD4A843),
          background: const Color(0xFFFAF8F5),
          surface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/onboarding": (context) => const PlaceholderScreen(title: "Onboarding"),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: Center(
        child: Text(title, style: const TextStyle(fontSize: 24, color: Color(0xFF5B8DB8), fontWeight: FontWeight.bold)),
      ),
    );
  }
}
