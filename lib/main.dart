import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'account_type_screen.dart';
import 'home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const CariJobsApp());
}

class CariJobsApp extends StatefulWidget {
  const CariJobsApp({super.key});

  @override
  State<CariJobsApp> createState() => _CariJobsAppState();
}

class _CariJobsAppState extends State<CariJobsApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }
    _linkSub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> _handleUri(Uri uri) async {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } catch (e) {
      debugPrint('Deep link auth error: $e');
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CariWorks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B8DB8),
          primary: const Color(0xFF5B8DB8),
          secondary: const Color(0xFFD4A843),
          surface: const Color(0xFFFFFFFF),
        ),
        canvasColor: const Color(0xFFFFFAF5),
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/account-type': (context) => const AccountTypeScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
