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

  final List<Map<String, String>> _slides = [
    {
      'image': 'https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_0000000020a471f793f01f5fb6403f07.jpg',
      'title': 'Get Hired.',
      'body': 'Connect with employers across the region who are actively looking for your skills. Whether you\'re fresh out of school or a seasoned professional, your next opportunity starts here.',
    },
    {
      'image': 'https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_00000000f32c71f7b60152098e305915.jpg',
      'title': 'Every Skill\nBelongs Here.',
      'body': 'Trades, tech, creative or professional. Post your service and let the work come to you.',
    },
    {
      'image': 'https://ajprjkpjjkppcphjvccv.supabase.co/storage/v1/object/public/onboarding/file_00000000d09871f7947fe7156df8be3e.jpg',
      'title': 'Apply. Post.\nGrow.',
      'body': 'Apply in seconds. Post a listing in minutes. Track it all from your phone. This is how the Caribbean works now.',
    },
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      Expanded(
                        flex: 6,
                        child: CachedNetworkImage(
                          imageUrl: slide['image']!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                          errorWidget: (ctx, url, err) => Container(color: const Color(0xFF0F3460)),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                slide['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                slide['body']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFB0BEC5),
                                  fontSize: 17,
                                  height: 1.6,
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
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
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
                  const SizedBox(height: 24),
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
                    const SizedBox(height: 12),
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
