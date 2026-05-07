import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _imagesReady = false;

  final List<Map<String, String>> _slides = [
    {
      'image': 'https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_0000000020a471f793f01f5fb6403f07.jpg',
      'title': 'Get Hired.',
      'body': 'Find jobs across the Caribbean. Fresh graduate or seasoned pro, your next opportunity starts here.',
    },
    {
      'image': 'https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_00000000f32c71f7b60152098e305915.jpg',
      'title': 'Every Skill\nBelongs Here.',
      'body': 'Trades, tech, creative or professional. Post your service and let the work come to you.',
    },
    {
      'image': 'https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_00000000d09871f7947fe7156df8be3e.jpg',
      'title': 'Apply. Post.\nGrow.',
      'body': 'Apply in seconds. Post a listing in minutes. Track it all from your phone.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  Future<void> _precacheImages() async {
    await Future.wait(_slides.map((s) => precacheImage(
    if (mounted) setState(() => _imagesReady = true);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagesReady) {
      return Scaffold(
        backgroundColor: const Color(0xFF1565C0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/hero_image.png', width: 90, height: 90),
              const SizedBox(height: 20),
              const Text('CariWorks', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Caribbean Jobs & Gigs', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.42,
                        child: CachedNetworkImage(
                          imageUrl: slide['image']!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                          errorWidget: (ctx, url, err) => Container(color: const Color(0xFF0F3460)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                slide['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide['body']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFB0BEC5),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? const Color(0xFFFFD700) : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        } else {
                          _finish();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C5C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_currentPage < _slides.length - 1) ...[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
