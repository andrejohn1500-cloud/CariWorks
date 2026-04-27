import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _trainCtrl;
  late AnimationController _carriageCtrl;
  late AnimationController _logoCtrl;
  late Animation<double> _trainScale;
  late Animation<double> _trainOpacity;
  late Animation<double> _carriageOffset;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  final List<Map<String, dynamic>> _carriages = [
    {'icon': Icons.construction, 'label': 'Tradesman', 'color': Color(0xFFFF6B35)},
    {'icon': Icons.laptop_mac, 'label': 'Developer', 'color': Color(0xFF4ECDC4)},
    {'icon': Icons.school, 'label': 'Teacher', 'color': Color(0xFFFFE66D)},
    {'icon': Icons.storefront, 'label': 'Vendor', 'color': Color(0xFF95E1D3)},
    {'icon': Icons.medical_services, 'label': 'Medical', 'color': Color(0xFFFF6B6B)},
    {'icon': Icons.brush, 'label': 'Creative', 'color': Color(0xFFA8E6CF)},
  ];

  @override
  void initState() {
    super.initState();

    // Train rushing toward you
    _trainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500));
    _trainScale = Tween<double>(begin: 0.02, end: 18.0).animate(
      CurvedAnimation(parent: _trainCtrl, curve: Curves.easeInCubic),
    );
    _trainOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _trainCtrl, curve: const Interval(0.75, 1.0, curve: Curves.easeOut)),
    );

    // Carriages sweep past
    _carriageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _carriageOffset = Tween<double>(begin: 1.0, end: -7.0).animate(
      CurvedAnimation(parent: _carriageCtrl, curve: Curves.easeInCubic),
    );

    // Logo fade in
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _trainCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 4000));
    _carriageCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1100));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final user = Supabase.instance.client.auth.currentUser;
    Navigator.pushReplacementNamed(context, user != null ? '/home' : '/login');
  }

  @override
  void dispose() {
    _trainCtrl.dispose();
    _carriageCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle radial glow behind train
          Center(
            child: Container(
              width: w,
              height: h,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.6,
                  colors: [Color(0x33FF5B8B), Colors.black],
                ),
              ),
            ),
          ),

          // Train rushing toward camera
          AnimatedBuilder(
            animation: _trainCtrl,
            builder: (context, child) => Opacity(
              opacity: _trainOpacity.value,
              child: Center(
                child: Transform.scale(
                  scale: _trainScale.value,
                  child: _buildTrainFront(),
                ),
              ),
            ),
          ),

          // Carriages sweeping past
          AnimatedBuilder(
            animation: _carriageCtrl,
            builder: (context, child) {
              if (!_carriageCtrl.isAnimating && _carriageCtrl.value == 0) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: h * 0.25,
                left: 0,
                right: 0,
                height: h * 0.5,
                child: Transform.translate(
                  offset: Offset(_carriageOffset.value * w, 0),
                  child: Row(
                    children: _carriages.map((c) => _buildCarriage(c, h * 0.5)).toList(),
                  ),
                ),
              );
            },
          ),

          // CariWorks logo
          AnimatedBuilder(
            animation: _logoCtrl,
            builder: (context, child) => Opacity(
              opacity: _logoFade.value,
              child: Center(
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: _buildLogo(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainFront() {
    return SizedBox(
      width: 120,
      height: 160,
      child: CustomPaint(painter: _TrainFrontPainter()),
    );
  }

  Widget _buildCarriage(Map<String, dynamic> data, double height) {
    final w = height * 0.65;
    return Container(
      width: w,
      height: height,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1F),
        border: Border.all(color: data['color'] as Color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Window
          Container(
            width: w * 0.7,
            height: height * 0.38,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withValues(alpha: 0.15),
              border: Border.all(color: data['color'] as Color, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data['icon'] as IconData, color: data['color'] as Color, size: 28),
                const SizedBox(height: 4),
                Text(
                  data['label'] as String,
                  style: TextStyle(
                    color: data['color'] as Color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Wheels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _wheel(data['color'] as Color),
              _wheel(data['color'] as Color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wheel(Color color) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: Colors.black,
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      );

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon mark
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5B8B), Color(0xFFFF8C42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5B8B).withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.work_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 20),
        const Text(
          'CariWorks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Caribbean Jobs & Gigs',
          style: TextStyle(
            color: Color(0xFFFF8C42),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _TrainFrontPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pink = const Color(0xFFFF5B8B);
    final orange = const Color(0xFFFF8C42);
    final navy = const Color(0xFF0D0D1F);

    // Body
    final bodyPaint = Paint()..color = navy;
    final borderPaint = Paint()
      ..color = pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.05, w * 0.92, h * 0.72),
      const Radius.circular(14),
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, borderPaint);

    // Cabin roof
    final roofPaint = Paint()..color = pink.withValues(alpha: 0.3);
    final roofBorder = Paint()
      ..color = pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*0.15, h*0.02, w*0.70, h*0.06), const Radius.circular(6)),
      roofPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*0.15, h*0.02, w*0.70, h*0.06), const Radius.circular(6)),
      roofBorder);

    // Horn
    final hornPaint = Paint()..color = orange..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawLine(Offset(w*0.28, h*0.02), Offset(w*0.28, h*-0.01), hornPaint);
    canvas.drawLine(Offset(w*0.24, h*-0.01), Offset(w*0.32, h*-0.01), hornPaint);

    // Left window
    final winPaint = Paint()..color = pink.withValues(alpha: 0.15);
    final winBorder = Paint()..color = pink..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.08, h*0.12, w*0.33, h*0.20), const Radius.circular(6)), winPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.08, h*0.12, w*0.33, h*0.20), const Radius.circular(6)), winBorder);

    // Right window
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.59, h*0.12, w*0.33, h*0.20), const Radius.circular(6)), winPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.59, h*0.12, w*0.33, h*0.20), const Radius.circular(6)), winBorder);

    // Headlight glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(w/2, h*0.42), radius: w*0.28));
    canvas.drawCircle(Offset(w/2, h*0.42), w*0.28, glowPaint);

    // Headlight
    canvas.drawCircle(Offset(w/2, h*0.42), w*0.14, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w/2, h*0.42), w*0.16, Paint()..color = orange..style = PaintingStyle.stroke..strokeWidth = 3);

    // Side lights
    canvas.drawCircle(Offset(w*0.14, h*0.42), w*0.05, Paint()..color = orange);
    canvas.drawCircle(Offset(w*0.86, h*0.42), w*0.05, Paint()..color = orange);

    // Grille lines
    final grillePaint = Paint()..color = pink.withValues(alpha: 0.5)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(Offset(w*0.25, h*0.58 + i*h*0.025), Offset(w*0.75, h*0.58 + i*h*0.025), grillePaint);
    }

    // Bumper
    canvas.drawLine(Offset(w*0.08, h*0.80), Offset(w*0.92, h*0.80),
      Paint()..color = orange..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Coupler
    canvas.drawRect(Rect.fromLTWH(w*0.42, h*0.80, w*0.16, h*0.04), Paint()..color = orange);

    // ignore: unnecessary_underscores
    // Wheels with spokes
    for (final cx in [w*0.22, w*0.78]) {
      canvas.drawCircle(Offset(cx, h*0.92), w*0.14, Paint()..color = navy);
      canvas.drawCircle(Offset(cx, h*0.92), w*0.14, Paint()..color = pink..style = PaintingStyle.stroke..strokeWidth = 3);
      final sp = Paint()..color = orange..strokeWidth = 2;
      canvas.drawLine(Offset(cx - w*0.10, h*0.92), Offset(cx + w*0.10, h*0.92), sp);
      canvas.drawLine(Offset(cx, h*0.92 - w*0.10), Offset(cx, h*0.92 + w*0.10), sp);
      canvas.drawLine(Offset(cx - w*0.07, h*0.92 - w*0.07), Offset(cx + w*0.07, h*0.92 + w*0.07), sp);
      canvas.drawLine(Offset(cx + w*0.07, h*0.92 - w*0.07), Offset(cx - w*0.07, h*0.92 + w*0.07), sp);
      canvas.drawCircle(Offset(cx, h*0.92), w*0.04, Paint()..color = orange);
    }

    // Axle
    canvas.drawLine(Offset(w*0.22, h*0.92), Offset(w*0.78, h*0.92),
      Paint()..color = orange.withValues(alpha: 0.4)..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
