import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const int cols = 3, rows = 3;
  static const double logoSize = 260.0;

  late List<AnimationController> _pieceControllers;
  late List<Animation<Offset>> _slideAnims;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  late AnimationController _exitController;
  late Animation<double> _exitAnim;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    _pieceControllers = List.generate(
      rows * cols,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 450)),
    );

    _slideAnims = List.generate(rows * cols, (i) {
      final dx = (rng.nextDouble() * 6 - 3);
      final dy = (rng.nextDouble() * 6 - 3);
      return Tween<Offset>(begin: Offset(dx, dy), end: Offset.zero).animate(
        CurvedAnimation(parent: _pieceControllers[i], curve: Curves.easeOutBack),
      );
    });

    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _exitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _exitAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _pieceControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (mounted) _pieceControllers[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) await _scaleController.forward();
    if (mounted) await _scaleController.reverse();
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) await _exitController.forward();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var c in _pieceControllers) c.dispose();
    _scaleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _exitAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A6DB5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: rows * cols,
                    itemBuilder: (_, index) {
                      final row = index ~/ cols;
                      final col = index % cols;
                      return SlideTransition(
                        position: _slideAnims[index],
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment(
                              -1.0 + col * 2.0 / (cols - 1),
                              -1.0 + row * 2.0 / (rows - 1),
                            ),
                            widthFactor: 1.0 / cols,
                            heightFactor: 1.0 / rows,
                            child: Image.asset(
                              'assets/images/icon.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'CariWorks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jobs & Gigs for the Caribbean',
                style: TextStyle(
                  color: Color(0xFFB3D4F5),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
