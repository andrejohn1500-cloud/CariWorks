import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _exitController;
  late Animation<double> _scaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;
  late Animation<double> _exitAnim;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));
    _textController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _exitController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _exitAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) await _exitController.forward();
    // Pre-cache onboarding images
    await Future.wait([
      precacheImage(CachedNetworkImageProvider('https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_0000000020a471f793f01f5fb6403f07.jpg'), context),
      precacheImage(CachedNetworkImageProvider('https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_00000000f32c71f7b60152098e305915.jpg'), context),
      precacheImage(CachedNetworkImageProvider('https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_00000000d09871f7947fe7156df8be3e.jpg'), context),
    ]).catchError((_) => <void>[]);
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final session = Supabase.instance.client.auth.currentSession;
    bool isSuspended = false;
    if (session != null) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('is_suspended')
            .eq('id', session.user.id)
            .single();
        isSuspended = profile['is_suspended'] == true;
      } catch (_) {}
    }
    if (isSuspended) {
      await Supabase.instance.client.auth.signOut();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => !onboardingDone ? const OnboardingScreen()
            : (session != null && !isSuspended) ? const HomeScreen() : const LoginScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _exitAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFF1565C0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoFadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _textSlideAnim,
                child: FadeTransition(
                  opacity: _textFadeAnim,
                  child: const Column(
                    children: [
                      Text(
                        'CariWorks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Jobs & Gigs for the Caribbean',
                        style: TextStyle(
                          color: Color(0xFFBBDEFB),
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
